---
page_type: sample
languages:
- powershell
products:
- Windows Sandbox
description: "Public repository for helpful Windows Sandbox scripts and utilites"
---

# Installing Applications In Sandbox Using Chocolatey

Use the [Chocolatey](https://chocolatey.org) package manager to install software into Windows Sandbox upon logon. Provided in this project is a generic install script for getting Windows Sandbox running with a custom set of Chocolatey packages. This script performs the following:

1. Checks Windows Sandbox is enabled on the host. If it is not, the script will enable it (restart required).
    - Note that Windows Sandbox is only supported on Windows 10 Pro or Enterprise Insider build 18362 or newer. More info available [here](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview).
1. Create the init.cmd script to be run within the sandbox. This will run the Chocolatey installer, and install the packages you specify upon Sandbox logon.
1. Generate a Windows Sandbox [configuration file](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file).
    - Maps the 'mapped' folder as a read/write directory into the sandbox
    - Sets init.cmd as the logon script to be run after initialization of the sandbox
5. Starts Windows Sandbox using the .wsb configuration file.
    - Upon logon, Chocolatey and the custom packages will be installed into Sandbox

## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `install_with_chocolatey.ps1`             | Run and install script for Choco in Sandbox                       |

## Prerequisites

The [install_with_chocolatey.ps1](install_with_chocolatey.ps1) script, the [SandboxCommon](../Common/SandboxCommon.psm1) module, and a host computer running Windows 10 Pro or Enterprise Insider build 18362 or newer should be all you need to get started. This script does require administrative permissions, purely so it can check for and enable Windows Sandbox automatically. The easiest way to get all of this together in one place is to clone this repository on your machine.

## Configuring Packages

All you need to do here is edit the following line at the top of the [install_with_chocolatey.ps1](install_with_chocolatey.ps1) script:
```powershell
$ChocoPkgs = @('package1', 'package2', ...)
```

The default value is simply the newest version of the Microsoft Edge browser. To find the packages available for installation, visit the [Chocolatey website](https://chocolatey.org/packages).

## Setup

You must first ensure that virtualization is enabled on your machine:
- If you are using a physical machine, ensure virtualization capabilities are enabled in the BIOS.
- If you are using a virtual machine, enable nested virtualization with this PowerShell cmdlet:
    
    ```Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true```

The [install_with_chocolatey.ps1](install_with_chocolatey.ps1) script will enable Windows Sandbox for you, so the only thing you'll need to do from here is reboot when asked to.

## Running the sample

To run the script, open command prompt or powershell as an administrator and enter the following:

```Powershell.exe -ExecutionPolicy Bypass -File .\install_with_chocolatey.ps1```

And you're off! Feel free to submit work items or pull requests to this repository if you have any problems, ideas, or suggestions!
