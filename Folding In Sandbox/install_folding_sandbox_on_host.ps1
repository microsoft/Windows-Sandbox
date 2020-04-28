#Requires -RunAsAdministrator

[cmdletbinding()]
    param(
        [Parameter(Mandatory=$false)][string]$username='wsandbox_anon',
        [Parameter(Mandatory=$false)][string]$team='251561'
    
)

function CreateFAHConf
{
<#
    .SYNOPSIS
        Create the FAH configuration file
    .DESCRIPTION
        Creates the configuration file used to run FAH
    .EXAMPLE
        C:\> CreateFAHConf -team '251561';
#>   
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)][string]$username,
        [Parameter(Mandatory=$true)][string]$team
    )
    Write-Verbose 'Creating init command...';
    $working_dir = "$env:USERPROFILE\fah_conf";
    $conf_file = 'fah_sandbox_conf.xml';
    Write-Verbose "Saved Folding@Home configuration file to $working_dir\$conf_file";
    New-Item -Force -Path "$working_dir\$conf_file" -ItemType File | Out-Null;
    Set-Content -Path "$working_dir\$conf_file" -Value @"
<config>
  <user v='$username'/>
  <team v='$team'/>
  <core-priority v='low'/>
  <power v='full' />
  <priority v='realtime'/>
  <smp v='true'/>
  <gpu v='true'/>
  <open-web-control v='true'/>
</config>
"@;
}


function CreateLogonScript
{
<#
    .SYNOPSIS
        Create the script that runs at logon
    .DESCRIPTION
        This script:
        1. Starts the installer
        2. Creates a volatile working directory
        3. Copies the config into the working directory
        4. Sets the firewall policies to let FAH run
        5. Starts the FAH client 
    .EXAMPLE
        C:\> CreateLogonScript;
#>   
    Write-Verbose 'Creating init command...'
    $working_dir = "$env:USERPROFILE\fah_conf";
    $conf_file = 'fah_sandbox_conf.xml';
    $install_fname = 'folding_installer.exe';
    $logon_cmd = "$working_dir\init.cmd"
    $wdg_install_dir = 'C:\users\wdagutilityaccount\desktop\fah_conf'
    $wdg_working_dir = 'C:\users\wdagutilityaccount\desktop\fah_working_dir'
    Write-Verbose "Saved logon script to $logon_cmd, this will be run upon starting Sandbox."
    New-Item -Force -Path $logon_cmd -ItemType File | Out-Null;
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
"@;

    # Create the Sandbox configuration file with the new working dir & LogonCommand.
    $sandbox_conf = "$working_dir\fah_sandbox.wsb";
    Write-Verbose "Creating sandbox configuration file to $sandbox_conf";
    New-Item -Force -Path $sandbox_conf -ItemType File | Out-Null;
    Set-Content -Path $sandbox_conf -Value @"
<Configuration>
    <VGpu>Enable</VGpu>
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
"@;
}


function GetFAH
{
<#
    .SYNOPSIS
        Download the latest version of FAH
    .DESCRIPTION
        Check if the installer is present, download otherwise
    .EXAMPLE
        C:\> GetFAH;
#>   
    Write-Verbose 'Checking for latest version of foldingathome...';
    $installer_url = 'https://download.foldingathome.org/releases/public/release/fah-installer/windows-10-32bit/';

    # Use regex to get the latest version from the FAH website.
    $version = ((Invoke-WebRequest -Uri $installer_url -UseBasicParsing).Links | Where-Object  {$_.href -match '^v\d+([.]\d+)?'} | ForEach-Object {[float]($_.href -replace '[^.\d]', '')} | Measure-Object -Max).Maximum;
    $installer = "$($installer_url)v$($version)/latest.exe";
    $installer_size =(Invoke-WebRequest $installer -Method Head -UseBasicParsing).Headers.'Content-Length';
    Write-Verbose "Using FAH v$version.";

    # Check if the installer is present, download otherwise.
    $working_dir = "$env:USERPROFILE\fah_conf";
    $install_fname = 'folding_installer.exe';
    if (!(test-path "$working_dir\$install_fname") -or (Get-ChildItem "$working_dir\$install_fname").Length -ne $installer_size ) 
    {
        Remove-Item "$working_dir\$install_fname" -Force -ErrorAction SilentlyContinue;
        Write-Verbose "Downloading latest folding executable: $working_dir\$install_fname";
        Write-Verbose "Saving to $working_dir\$install_fname...";
        New-Item -ItemType Directory -Force -Path $working_dir | Out-Null;
        Invoke-WebRequest -Uri $installer -OutFile "$working_dir\$install_fname";
    }
}


function VerifyBios
{
<#
    .SYNOPSIS
        Check BIOS
    .DESCRIPTION
        This function is used to ensure that virtualization is enbaled in BIOS.
    .EXAMPLE
        C:\> VerifyBios;
#>   
    [cmdletbinding()]
    [OutputType([bool])]
    param ()
    # Ensure that virtualization is enbaled in BIOS.
    Write-Output 'Verifying that virtualization is enabled in BIOS...'
    if ((Get-CimInstance Win32_ComputerSystem).VirtualizationFirmwareEnabled -eq $false) {
        Write-Output 'ERROR: Please Enable Virtualization capabilities in your BIOS settings...'
        return $false
    }

    # Ensure that virtualization is enbaled in Windows 10.
    Write-Output 'Verifying that virtualization is enabled in Windows 10...'
    if ((Get-CimInstance Win32_ComputerSystem).HypervisorPresent -eq $false) {
        Write-Output 'ERROR: Please Enable Hyper-V in your Control Panel->Programs and Features->Turn Windows features on or off'
        return $false
    }
    
    return $true;
}

function VerifySandbox
{
<#
    .SYNOPSIS
        Check Windows Feature is enabled
    .DESCRIPTION
        This function is used to ensure that Windows Sandbox has been enabled
    .EXAMPLE
        C:\> VerifySandbox;
#>   
    [cmdletbinding()]
    [OutputType([bool])]
    param ()
    Write-Verbose 'Checking to see if Windows Sandbox is installed...';
    try
    {
        If ((Get-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -Online).State -ne 'Enabled') 
        {
            Write-Verbose 'Windows Sandbox is not installed, attempting to install it (may require reboot)...';
            if ((Enable-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -All -Online -NoRestart).RestartNeeded) 
            {
                Write-Verbose 'Please reboot to finish installing Windows Sandbox, then re-run this script...'
                return $false;
            }
        
            return $true;
        }
        else 
        {
            Write-Verbose 'Windows Sandbox already installed.';
            return $true;
        }
    }
    catch
    {
        Write-Error 'ERROR: Please Enable Virtualization capabilities in your BIOS settings ,then re-run this script...';
        return $false;
    }
}
    try
    {
        Write-Verbose 'Start process';
        $ProgressPreference = 'SilentlyContinue'; #Progress bar makes things way slower
        Write-Output 'Verify host system...';
        $bios = VerifyBios;
        if (-not $bios -or $bios -eq $false)        {
            throw 'ERROR: Please Enable Virtualization capabilities in your BIOS settings...';
        }
    
        $sandbox = VerifySandbox;
        if (-not $sandbox -or $sandbox -eq $false)        {
            throw 'Please reboot to finish installing Windows Sandbox, then re-run this script...';
        }
        
        Write-Output 'Setup configuration...';
        GetFAH;
        CreateFAHConf -username $username -team $team;
        CreateLogonScript;
        $config = "$env:USERPROFILE\fah_conf\fah_sandbox.wsb";
        Write-Verbose "Start-Process 'C:\WINDOWS\system32\WindowsSandbox.exe' -ArgumentList '$config';";
        $proc = Start-Process 'C:\WINDOWS\system32\WindowsSandbox.exe' -ArgumentList $config;
        do 
        {
            start-sleep -Milliseconds 500;
        }
        until ($proc.HasExited);
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message;
        Write-Error $ErrorMessage;
    }

