#Requires -RunAsAdministrator
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
    $version = ((Invoke-WebRequest -Uri $installer_url -UseBasicParsing).Links | Where-Object  {$_.href -match '^v\d+([.]\d+)?'} | ForEach-Object {($_.href -replace '[^.\d]', '')} | Measure-Object -Max).Maximum;
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
