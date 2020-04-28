#Requires -RunAsAdministrator
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