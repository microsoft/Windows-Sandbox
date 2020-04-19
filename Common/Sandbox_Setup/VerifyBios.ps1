#Requires -RunAsAdministrator
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