cls
# Get file name for "sample" script
$FileName = "$PSScriptRoot\install_folding_sandbox_on_host.ps1"
if (Test-Path $FileName) 
{
  Remove-Item $FileName
}

# Stick requires in the sample script
Add-Content $FileName "#Requires -RunAsAdministrator`r`n";

# Grab the contents of the public function for the module - this assumes we're only going to have
# a single entry point for the module.  If this changes, we'll need to revist this
$publicScript = (Get-Content "$PSScriptRoot\Module\Public\Start.ps1" -Raw).Replace("#Requires -RunAsAdministrator","").Replace("function Start","");
# Ugly way to find the parameter definitions for the top of the script
$startParameters = $publicScript.Substring($publicScript.IndexOf("[cmdletbinding()]"));
$scriptContents = ($startParameters -split "\)\n");
Add-Content $FileName $scriptContents[0];
Add-Content $FileName ")";

# Grab the contents of each of the private functions for the module and stick them in the sample script file
Get-ChildItem "$PSScriptRoot\Module\Private" -Filter *.ps1 | 
Foreach-Object {
    Add-Content $FileName (Get-Content $_.FullName -Raw).Replace("#Requires -RunAsAdministrator","");
}

$finalScriptContent = "";
for ($i=1; $i -le $scriptContents.Length; $i++) 
{
    $finalScriptContent += $scriptContents[$i];
    $finalScriptContent += ")";
}

Add-Content $FileName $finalScriptContent.Substring(0, $finalScriptContent.Length-3);