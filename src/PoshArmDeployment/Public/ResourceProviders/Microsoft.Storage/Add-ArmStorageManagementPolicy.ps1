function Add-ArmStorageManagementPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType("StorageAccountManagementPolicy")]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('StorageAccount')]
        $StorageAccount,
        [string]
        $ApiVersion = '2019-06-01'
    )

    If ($PSCmdlet.ShouldProcess("Creates a new ArmStorageManagementPolicy object")) {
        $resourceType = 'Microsoft.Storage/storageAccounts/managementPolicies'
        $storageAccountName = $StorageAccount.Name
        $storageAccountManagementPolicy = [PSCustomObject][ordered]@{
            _ResourceId = $storageAccountName | New-ArmFunctionResourceId -ResourceType $resourceType
            PSTypeName  = "StorageAccountManagementPolicy"
            type        = $resourceType
            name        = "[concat($storageAccountName, '/default')]"
            apiVersion  = $ApiVersion
            properties  = @{
                policy = @{
                    rules = @()
                }
            }
            resources   = @()
            dependsOn   = @()
        }

        $storageAccountManagementPolicy.PSTypeNames.Add("ArmResource")
        $storageAccountManagementPolicy | Add-ArmDependencyOn -Dependency $StorageAccount
        return $storageAccountManagementPolicy
    }
}