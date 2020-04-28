cls
Write-Output "Loop over $PSScriptRoot to find modules";
foreach($folder in (Get-ChildItem $PSScriptRoot -Directory))
{
    if ($folder.Name -ne "Common" -and $folder.Name -ne "Install with Chocolatey")
    {
        Write-Verbose "Get filename for $folder";
        $initialFileName = $folder.Name.ToLower().Replace(' in ','_').Replace(' ','_');
        $FileName = "$PSScriptRoot\$folder\install_$initialFileName";
        $FileName = $FileName + "_on_host.ps1";
        Write-Verbose "Filename $FileName detected";
        if (Test-Path $FileName) 
        {
          Write-Verbose "Delete $FileName";
          Remove-Item $FileName
        }

        Write-Verbose "Stick requires in the sample script";
        Add-Content $FileName "#Requires -RunAsAdministrator`r`n";

        Write-Verbose "Grab the contents of the public function for the module - this assumes we're only going to have a single entry point for the module.  If this changes, we'll need to revist this";
        $publicScript = (Get-Content "$PSScriptRoot\$folder\Module\Public\Start.ps1" -Raw).Replace("#Requires -RunAsAdministrator","").Replace("function Start","");
        Write-Verbose "Ugly way to find the parameter definitions for the top of the script";
        $startParameters = $publicScript.Substring($publicScript.IndexOf("[cmdletbinding()]"));
        if ($startParameters.Contains("param("))
        {
            $scriptContents = ($startParameters -split "\)\n");
            Add-Content $FileName $scriptContents[0];
            Add-Content $FileName ")";
        }
        else
        {
            $scriptContents = ($startParameters -split "\[cmdletbinding\(\)\]");
            Add-Content $FileName "[cmdletbinding()]";
        }

        Write-Verbose "Grab the contents of each of the private functions for the module and stick them in the sample script file";
        foreach($file in (Get-ChildItem "$PSScriptRoot\$folder\Module\Private" -Filter *.ps1))
        {
            Add-Content $FileName (Get-Content $file.FullName -Raw).Replace("#Requires -RunAsAdministrator","");
        }

        Write-Verbose "Build final script contents";
        $finalScriptContent = "";
        for ($i=1; $i -le $scriptContents.Length; $i++) 
        {
            $finalScriptContent += $scriptContents[$i];
            $finalScriptContent += ")";
        }

        Write-Output "Finalise $FileName contents";
        if ($finalScriptContent.Length -gt 3)
        {
            Add-Content $FileName $finalScriptContent.Substring(0, $finalScriptContent.Length-3);
        }
    }
}