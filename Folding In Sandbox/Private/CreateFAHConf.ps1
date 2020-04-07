#Requires -RunAsAdministrator
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
