#
# Module manifest for module 'MinecraftSandbox'
#
# Generated on: 27/04/2020
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'MinecraftSandbox.psm1'

# Version number of this module.
ModuleVersion = '1.0.0'

# ID used to uniquely identify this module
GUID = '56102c49-de7e-4a42-872e-adbaef408e2a'

# Description of the functionality provided by this module
Description = 'Run a Minecraft Server in Windows Sandbox'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Start'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # A URL to the license for this module.
         LicenseUri = 'https://github.com/microsoft/Windows-Sandbox-Utilities/blob/master/LICENSE'

        # A URL to the main website for this project.
         ProjectUri = 'https://github.com/microsoft/Windows-Sandbox-Utilities'

    } # End of PSData hashtable

} # End of PrivateData hashtable


}