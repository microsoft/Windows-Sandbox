#Requires -RunAsAdministrator

#Add to / remove from this array as desired
$ChocoPkgs = @('microsoft-edge')

Write-Output "================= Windows Sandbox Chocolatey Installer ================="

#Ensure Sandbox is installed
Write-Output "Checking if Windows Sandbox is properly installed..."
Import-Module -Force ..\Common\SandboxCommon.psm1
VerifySetup

# Create the Sandbox configuration file with the new working dir & LogonCommand.
$sandbox_conf = "choco_sandbox.wsb"
$mapped_dir = "$PSScriptRoot\mapped"
$wdg_working_dir = 'C:\users\wdagutilityaccount\desktop\mapped'

#Create the mapped folder in the same directory, it's been added to the .gitignore
If (!(test-path $mapped_dir)) {
	Write-Output "Creating folder to be shared with Sandbox $mapped_dir"
	New-Item -ItemType Directory -Force -Path $mapped_dir | Out-Null
}

#This could be just a single powershell script, but doing it this way gives us log feedback
#We're using an absolute path to choco for now instead having to refresh the environment after installation
$logon_cmd = "init.cmd"
New-Item -Force -Path $mapped_dir\$logon_cmd -ItemType File | Out-Null
Set-Content -Path $mapped_dir\$logon_cmd -Value @"
start /w powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
start powershell -noexit -command C:\ProgramData\chocolatey\bin\choco.exe install -y $($ChocoPkgs -join ' ')
"@
Write-Output "Saved logon script to $mapped_dir\$logon_cmd, this will be run upon starting Sandbox."

#Sandbox configuration
Write-Output "Creating sandbox configuration file $sandbox_conf"
New-Item -Force -Path $sandbox_conf -ItemType File | Out-Null
Set-Content -Path $sandbox_conf -Value @"
<Configuration>
    <VGpu>Enable</VGpu>
    <Networking>Default</Networking>
	<MappedFolders>
		<MappedFolder>
			<HostFolder>$mapped_dir</HostFolder>
			<ReadOnly>false</ReadOnly>
		</MappedFolder>
	</MappedFolders>
	<LogonCommand>
		<Command>$wdg_working_dir\$logon_cmd</Command>
	</LogonCommand>
</Configuration>
"@

#Start Sandbox
Write-Output 'Starting sandbox...'
Start-Process 'C:\WINDOWS\system32\WindowsSandbox.exe' -ArgumentList $sandbox_conf