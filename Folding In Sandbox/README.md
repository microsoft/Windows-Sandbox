---
page_type: sample
languages:
- powershell
products:
- Windows Sandbox
description: "Public repository for helpful Windows Sandbox scripts and utilites"
urlFragment: "update-this-to-unique-url-stub"
---

# Folding In Sandbox

Use Windows Sandbox to develop a Hyper-V isolated environment dedicated to the [Folding@Home](https://foldingathome.org/) client. Configure Windows Sandbox to automatically install the client and test a multitude of different Folding@Home features. 

Provided in this project is an install script you can run on your host computer that will:

1. Check Windows Sandbox is enabled on the host. If it is not, the script will enable it (restart required).
    - Note that Windows Sandbox is only supported on Windows 10 Pro or Enterprise Insider build 18362 or newer. More info available [here](https://techcommunity.microsoft.com/t5/windows-kernel-internals/windows-sandbox/ba-p/301849).
2. Download the latest Folding@Home installer for Windows.
3. Generate the Folding@Home configuration file. This contains some default configurations that allow Folding@Home in the sandbox to start immediately.
4. Create the init.cmd script to be run within the sandbox. This script runs the Folding@Home installer in silent mode and then starts Folding@Home in a temporary working directory.
4. Generate a Windows Sandbox [configuration file](https://techcommunity.microsoft.com/t5/windows-kernel-internals/windows-sandbox-config-files/ba-p/354902).
    - The folder containing the Folding@Home installer and configuration file is mapped as a read-only folder to the sandbox.
    - Sets init.cmd as the logon script to be run after initialization of the sandbox
5. Starts Windows Sandbox using the .wsb configuration file.

**Note:** Due to increased interest from the community with the COVID-19 outbreak, the Folding@Home assignment servers are under a lot of pressure. It may take some time to receive a work unit so make sure to leave the client running while waiting for an assignment.

## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `install_folding_sandbox_on_host.ps1`             | All-in-one install & run script for Folding in Sandbox                        |

## Prerequisites

The [install_folding_sandbox_on_host.ps1](install_folding_sandbox_on_host.ps1) script, and a host computer running Windows 10 Pro or Enterprise Insider build 18362 or newer should be all you need to get started. This script does require administrative permissions, purely so it can check for and enable Windows Sandbox automatically. 

## Setup

You must first ensure that virtualization is enabled on your machine:
- If you are using a physical machine, ensure virtualization capabilities are enabled in the BIOS.
- If you are using a virtual machine, enable nested virtualization with this PowerShell cmdlet:
    
    ```Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true```

The [install_folding_sandbox_on_host.ps1](install_folding_sandbox_on_host.ps1) script will enable Windows Sandbox for you, so the only thing you'll need to do from here is reboot when asked to.

## Running the sample

To run the script, open command prompt or powershell as an administrator and enter the following:
```
Powershell.exe -ExecutionPolicy Bypass -File .\install_folding_sandbox_on_host.ps1
```

And you're off! Feel free to submit work items or pull requests to this repository if you have any problems, ideas, or suggestions!

## Key concepts

Finding the cure for a disease is a complex process formed through a series of large scientific efforts. Modern advancements in both medical and computational technologies have alleviated several burdens that slow down the process of understanding how a disease works. In most cases it boils down to understanding the structure and behavior of life's fundamental building block: proteins. The chemical composition and shape of a protein define its behavior, and interactions between proteins form the intricate systems that constitute a living organism.

Modern technology has enabled us to rapidly characterize the chemical composition of proteins. This, however, only gives us half the picture in understanding how a protein function. Once a chain of amino acids develops, it does not form a protein until it collapses into its functional state. The transition into this state is called folding and is dependent on both the type and sequence of amino acids that make up the protein. The complexity of this crucial process poses a massive computational challenge that the world is just starting to solve.

[Folding@Home](https://foldingathome.org/) is one of the largest efforts to solve the computational problem of protein folding. It utilizes a globally distributed network of computers - whether it be your own home computer or a server living in a data center. It can be installed by anyone anywhere and contributes to the greater cause of understanding how certain diseases work, and what we can do to minimize their impact. Right now, the group is [managing an effort](https://foldingathome.org/2020/03/15/coronavirus-what-were-doing-and-how-you-can-help-in-simple-terms/) to simulate the dynamics of COVID-19 proteins in the search for new therapeutic solutions. For more information, be sure to visit the [Folding@Home Knowledge Base](https://foldingathome.org/dig-deeper/).
