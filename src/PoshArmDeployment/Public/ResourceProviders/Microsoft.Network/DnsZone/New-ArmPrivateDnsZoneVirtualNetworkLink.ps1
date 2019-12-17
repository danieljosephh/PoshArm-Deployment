function New-ArmPrivateDnsZoneVirtualNetworkLink {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("PDNSZVirtualNetworkLink")]
    Param(
        [ValidatePattern('^(\[.*\]|)|([a-z0-9-_]{1,127})$')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Name,
        [ValidatePattern('^(\[.*\]|)|([a-z0-9-_]{1,127})$')]
        [Parameter(Mandatory)]
        [string]
        $ResourceGroupName,    
        [PSTypeName("VirtualNetwork")]
        [Parameter(Mandatory)]
        $VirtualNetwork,
        [PSTypeName("PDNSZ")]
        [Parameter(Mandatory)]
        $PrivateDnsZone,
        [switch]
        $RegistrationEnabled,
        [string]
        $Location = "global",
        [string]
        $ApiVersion = "2018-09-01"
    )

    If ($PSCmdlet.ShouldProcess("Adding private DNS zone virtual network link")) {
        $ResourceType = "Microsoft.Network/privateDnsZones/virtualNetworkLinks"
        $PrivateDnsZoneName = $PrivateDnsZone.name
        $VirtualNetworkName = $VirtualNetwork.name
        $vNetLink = [PSCustomObject][ordered]@{
            _ResourceId = New-ArmFunctionResourceId -ResourceType $ResourceType -ResourceName1 $PrivateDnsZoneName -ResourceName2 $Name
            PSTypeName  = "PDNSZVirtualNetworkLink"
            type        = $ResourceType
            name        = "[concat('$PrivateDnsZoneName/$Name-$ResourceGroupName-', $VirtualNetworkName)]"
            location    = $Location
            apiVersion  = $ApiVersion
            properties  = @{
                registrationEnabled = $RegistrationEnabled.ToBool()
                virtualNetwork = @{
                    id = $VirtualNetwork._ResourceId
                }
            }
            dependsOn   = @()
        }

        $vNetLink.PSTypeNames.Add("ArmResource")
        return $vNetLink
    }
}