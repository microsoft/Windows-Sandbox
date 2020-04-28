#Requires -RunAsAdministrator

[cmdletbinding()]
    param(
    
)

function GetMineCraft
{
    [cmdletbinding()]
    param(
    )
    Write-Verbose 'Checking for latest version of minecraft...';
    $jsonVersions = Invoke-WebRequest -Uri https://launchermeta.mojang.com/mc/game/version_manifest.json | ConvertFrom-Json;
    $minecraftLatestVersion = $jsonVersions.latest.release;
    Write-Verbose 'Detected latest minecraft release is $minecraftLatestVersion';
    $minecraftVersions = $jsonVersions.versions;
    $jsonUrlLatestVersion = $minecraftVersions | Where-Object id -eq $minecraftLatestVersion;
    $jsonUrlLatestVersion = $jsonUrlLatestVersion.url;
    Write-Verbose 'Detected latest minecraft release URL $jsonUrlLatestVersion';
    Write-Verbose 'Download manifest';
    $jsonLatestVersion = Invoke-WebRequest -Uri $jsonUrlLatestVersion | ConvertFrom-Json;
    Write-Verbose 'Get the server download url';
    $installer = $jsonLatestVersion.downloads.server.url;
    $installer_size =(Invoke-WebRequest $installer -Method Head -UseBasicParsing).Headers.'Content-Length';
    # Check if the installer is present, download otherwise.
    $working_dir = "$env:USERPROFILE\minecraft_conf";
    $install_fname = "minecraft_server." + $minecraftLatestVersion + ".jar";
    $install_fullname = "$working_dir\$install_fname";
    if (!(test-path "$install_fullname") -or (Get-ChildItem "$install_fullname").Length -ne $installer_size ) 
    {
        Remove-Item "$install_fullname" -Force -ErrorAction SilentlyContinue;
        Write-Verbose "Downloading latest folding executable: $install_fullname";
        Write-Verbose "Saving to $install_fullname...";
        New-Item -ItemType Directory -Force -Path $working_dir | Out-Null;
        Invoke-WebRequest -Uri $installer -OutFile "$install_fullname";
    }
    
    return $install_fullname;
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
        
        Write-Output 'Download minecraft server...';
        $installer_fullname = GetMineCraft;
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message;
        Write-Error $ErrorMessage;
    }

