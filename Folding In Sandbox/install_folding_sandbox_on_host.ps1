#Requires -RunAsAdministrator
$ProgressPreference = 'SilentlyContinue' #Progress bar makes things way slower

#Check if virtualization is enbaled in BIOS
Write-Output 'Checking that virtualization is enabled in BIOS.'
if((Get-WmiObject Win32_ComputerSystem).HypervisorPresent -eq $true){
	#Check Sandbox is enabled
	Write-Output 'Checking to see if Windows Sandbox is already installed...'
    If((Get-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -Online).State -ne 'Enabled') {
		Write-Output 'Windows Sandbox is not installed, installing (will require reboot)...'
		Enable-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -All -Online
		exit
	} else {
		Write-Output 'Windows Sandbox is already enabled.'
	}
}else{
	Write-Output 'Please Enable Virtualization capabilities in your BIOS settings...'
	exit
}

#Get the latest version of folding
Write-Output 'Checking for latest version of foldingathome...'
$installer_url = 'https://download.foldingathome.org/releases/public/release/fah-installer/windows-10-32bit/'

#Using regex to get the latest version of FAH available on their website
$version = ((Invoke-WebRequest -Uri $installer_url -UseBasicParsing).Links | Where-Object  {$_.href -match '^v\d+([.]\d+)?'} | ForEach-Object {[float]($_.href -replace '[^.\d]', '')} | Measure-Object -Max).Maximum
$installer = "$($installer_url)v$($version)/latest.exe"
Write-Output "Using FAH v$version."

#Check if the installer is present, download otherwise
$working_dir = "$env:USERPROFILE\fah_conf"
$install_fname = 'folding_installer.exe'
If(!(test-path "$working_dir\$install_fname")) {
	Write-Output "Downloading latest folding executable: $working_dir\$install_fname"
	Write-Output "Saving to $working_dir\$install_fname..."
	New-Item -ItemType Directory -Force -Path $working_dir | Out-Null
	Invoke-WebRequest -Uri $installer -OutFile "$working_dir\$install_fname"
}

#Create the FAH configuration file with the windows sandbox team #251561
Write-Output 'Creating init command...'
$conf_file = 'fah_sandbox_conf.xml'
Write-Output "Saved Folding@Home configuration file to $working_dir\$conf_file"
New-Item -Force -Path "$working_dir\$conf_file" -ItemType File
Set-Content -Path "$working_dir\$conf_file" -Value @"
<config>
<user value='wsandbox_anon'/>
<team value='251561'/>
<smp value='true'/>
<gpu value='true'/>
<open-web-control>true</open-web-control>
</config>
"@

<#Create the script that runs at logon
This script:
	1. Starts the installer
	2. Creates a volatile working directory
	3. Copies the config into the working directory
	4. Sets the firewall policies to let FAH run
	5. Starts the FAH client #>
Write-Output 'Creating init command...'
$logon_cmd = "$working_dir\init.cmd"
$wdg_install_dir = 'C:\users\wdagutilityaccount\desktop\fah_conf'
$wdg_working_dir = 'C:\users\wdagutilityaccount\desktop\fah_working_dir'
Write-Output "Saved logon script to $logon_cmd, this will be run upon starting Sandbox."
New-Item -Force -Path $logon_cmd -ItemType File
Set-Content -Path $logon_cmd -Value @"
start $wdg_install_dir\$install_fname /S
goto WAITLOOP

:WAITLOOP
if exist "C:\Program Files (x86)\FAHClient\FAHClient.exe" goto INSTALLCOMPLETE
ping -n 6 127.0.0.1 > nul
goto WAITLOOP

:INSTALLCOMPLETE
mkdir $wdg_working_dir
cd $wdg_working_dir
echo \"Copying config file to $wdg_working_dir\"
copy $wdg_install_dir\$conf_file $wdg_working_dir
netsh advfirewall firewall Add rule name="FAHClient" program="C:\Program Files (x86)\FAHClient\FAHClient.exe" action=allow dir=out
netsh advfirewall firewall Add rule name="FAHClient" program="C:\Program Files (x86)\FAHClient\FAHClient.exe" action=allow dir=in
start C:\"Program Files (x86)"\FAHClient\FAHClient.exe --config $wdg_working_dir\$conf_file
"@

#Create the sandbox configuration file with the new working dir & logon cmd
$sandbox_conf = "$working_dir\fah_sandbox.wsb"
Write-Output "Creating sandbox configuration file to $sandbox_conf"
New-Item -Force -Path $sandbox_conf -ItemType File
Set-Content -Path $sandbox_conf -Value @"
<Configuration>
	<VGpu>Default</VGpu>
	<MappedFolders>
		<MappedFolder>
			<HostFolder>$working_dir</HostFolder>
			<ReadOnly>true</ReadOnly>
		</MappedFolder>
	</MappedFolders>
	<LogonCommand>
		<Command>$wdg_install_dir\init.cmd</Command>
	</LogonCommand>
</Configuration>
"@

#For convenience, start the sandbox
Write-Output 'Starting sandbox...'
Start-Process 'C:\WINDOWS\system32\WindowsSandbox.exe' -ArgumentList $sandbox_conf
