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
    Write-Verbose 'Verifying that virtualization is enabled in BIOS...';
    if ((Get-WmiObject Win32_ComputerSystem).HypervisorPresent -eq $false) 
	{
	    Write-Verbose 'ERROR: Please Enable Virtualization capabilities in your BIOS settings...'
	    return $false;
    }
	
	return $true;
}