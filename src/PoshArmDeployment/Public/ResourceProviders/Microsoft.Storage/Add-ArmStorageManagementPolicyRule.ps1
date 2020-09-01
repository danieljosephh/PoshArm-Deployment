function Add-ArmStorageManagementPolicyRule {
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType("StorageAccountManagementPolicy")]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('StorageAccountManagementPolicy')]
        $StorageAccountManagementPolicy,
        [Parameter(Mandatory)]
        [ValidatePattern('^(\[.*\]|[a-zA-Z0-9]*)$')]
        [string]
        $Name,
        [PSCustomObject]
        $Actions,
        [string[]]
        $FilterBlobTypes,
        [string[]]
        $FilterPrefixMatches,
        [bool]
        $Enabled = $true
    )

    If ($PSCmdlet.ShouldProcess("Adds a ArmStorageManagementPolicyRule to a StorageAccountManagementPolicy")) {
      
        $storageAccountManagementPolicyRule = [PSCustomObject][ordered]@{
            type       = 'Lifecycle'
            name       = $Name
            enabled    = $Enabled
            definition = @{
                actions = $Actions
                filters = @{
                    blobTypes   = $FilterBlobTypes
                    prefixMatch = $FilterPrefixMatches
                }
            }
        }

        $StorageAccountManagementPolicy.properties.policy.rules += $storageAccountManagementPolicyRule

        return $storageAccountManagementPolicy
    }
}