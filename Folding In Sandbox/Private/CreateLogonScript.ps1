#Requires -RunAsAdministrator
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
