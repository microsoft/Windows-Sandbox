---
page_type: sample
languages:
- powershell
products:
- Windows Sandbox
description: "Public repository for helpful Windows Sandbox scripts and utilites"
---

# Minecraft In Sandbox

Use Windows Sandbox to develop a Hyper-V isolated environment running a Minecraft server. Configure Windows Sandbox to automatically install and run the server. 

Provided in this project is an install script you can run on your host computer that will:

1. Check Windows Sandbox is enabled on the host. If it is not, the script will enable it (restart required).
    - Note that Windows Sandbox is only supported on Windows 10 Pro or Enterprise Insider build 18362 or newer. More info available [here](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview).
2. Download the latest Minecraft installer for Windows.
3. Download the latest Java installer for Windows.
4. Install Chocolatey.
4. Generate a Windows Sandbox [configuration file](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file).
5. Starts Windows Sandbox using the .wsb configuration file.

## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `install_minecraft_sandbox_on_host.ps1`             | All-in-one install & run script for Minecraft in Sandbox                        |

## Prerequisites

The [install_minecraft_sandbox_on_host.ps1](install_minecraft_sandbox_on_host.ps1) script, and a host computer running Windows 10 Pro or Enterprise Insider build 18362 or newer should be all you need to get started. This script does require administrative permissions, purely so it can check for and enable Windows Sandbox automatically. 

## Setup

You must first ensure that virtualization is enabled on your machine:
- If you are using a physical machine, ensure virtualization capabilities are enabled in the BIOS.
- If you are using a virtual machine, enable nested virtualization with this PowerShell cmdlet:
    
    ```Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true```

The [install_minecraft_sandbox_on_host.ps1](install_minecraft_sandbox_on_host.ps1) script will enable Windows Sandbox for you, so the only thing you'll need to do from here is reboot when asked to.

## Running the sample

To run the script, open command prompt or powershell as an administrator and enter the following:

```Powershell.exe -ExecutionPolicy Bypass -File .\install_minecraft_sandbox_on_host.ps1```

And you're off! Feel free to submit work items or pull requests to this repository if you have any problems, ideas, or suggestions!
