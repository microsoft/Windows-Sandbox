#Requires -RunAsAdministrator
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
    If ((Get-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -Online).State -ne 'Enabled') 
	{
	    Write-Output 'Windows Sandbox is not installed, attempting to install it (may require reboot)...';
	    if ((Enable-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -All -Online -NoRestart).RestartNeeded) 
		{
		    Write-Output 'Please reboot to finish installing Windows Sandbox, then re-run this script...'
		    return $false;
		}
		
		return $true;
    }
	else 
	{
	    Write-Output 'Windows Sandbox already installed.';
		return $true;
    }
}