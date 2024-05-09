# Welcome to the Windows Sandbox repo!

Windows Sandbox (WSB) provides a lightweight desktop environment to safely run applications in isolation. This feature provides a safe and secure space for testing and debugging apps, exploring unknown files, or experimenting with tools. Software installed inside the Windows Sandbox environment remains isolated from the host machine with hypervisor-based-virtualization.

Windows Sandbox offers the following features:
- <b>Part of Windows:</b> Everything required for this feature is included in the supported Windows SKUs like Pro, Enterprise and Education. There's no need to maintain a separate VM installation.
- <b>Disposable:</b> Nothing persists on the device. Everything is discarded when the user closes the application.
- <b>Pristine:</b> Every time Windows Sandbox runs, it's as clean as a brand-new installation of Windows.
- <b>Secure:</b> Uses hardware-based virtualization for kernel isolation. It relies on the Microsoft hypervisor to run a separate kernel that isolates Windows Sandbox from the host.
- <b>Efficient:</b> Takes a few seconds to launch, supports virtual GPU and has smart memory management that optimizes memory footprint.

If you want to learn more about how Windows Sandbox, check out our [documentation](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview).

### What is this repo for?

This repository is for: 
- Links to add-ons and tools that leverage Windows Sandbox developed by Microsoft team and our awesome developer community.
- Reporting issues or suggesting new features found when using Windows Sandbox.

Please read our [Contributor's Guide](https://github.com/microsoft/Windows-Sandbox/blob/master/CONTRIBUTING.md) for more information.

## Windows Sandbox Resources


### Community Windows Sandbox projects

Here is a list of great repositories made by the community - feel free to browse through them and contribute where you can!

<table>
    <thead>
        <tr style="border-bottom: 2px solid black">
            <th></th>
            <th>Name</th>
            <th>Owner</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=2><strong>GUI Tools</strong></td>
            <td><a href="https://github.com/damienvanrobaeys/Windows_Sandbox_Editor">Windows Sandbox Editor</a></td>
            <td>Damien Van Robaeys</td>
            <td>GUI for generating and managing Windows Sandbox. <a href="http://www.systanddeploy.com/2019/07/windows-sandbox-editor-update.html">Blog post.</href></td>
        </tr>
        <tr>
            <td><a href="https://github.com/damienvanrobaeys/Run-in-Sandbox">Run in Sandbox Context Menu</a></td>
            <td>Damien Van Robaeys</td>
            <td>Adds right-click context menus for running scripts, applications, and more in Windows Sandbox</td>
        </tr>
        <tr>
            <td rowspan=1><strong>Utilities</strong></td>
            <td><a href="https://github.com/karkason/pywinsandbox">PyWinSandbox</a/></td>
            <td>Yiftach Karkason</td>
            <td>Python library to create and control Windows Sandboxes with RPyC & Simple CLI Utilities.</td>
        </tr>
    </tbody>
</table>


## Code of conduct

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks
This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark and Brand Guidelines]([url](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general)). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos is subject to those third-parties' policies.

