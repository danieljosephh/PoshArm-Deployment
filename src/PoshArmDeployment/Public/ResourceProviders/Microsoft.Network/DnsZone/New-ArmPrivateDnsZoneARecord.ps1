function New-ArmPrivateDnsZoneARecord {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType("PDNSZARecord")]
    Param(
        [string]
        [ValidatePattern('^(\[.*\]|)|([a-z0-9-_]{1,127})$')]
        [Parameter(Mandatory, ValueFromPipeline)]
        $Name,    
        [PSTypeName("PDNSZ")]
        [Parameter(Mandatory)]
        $PrivateDnsZone,
        [int]
        $TTL = 3600,
        [string[]]
        [Parameter(Mandatory)]
        $IpV4Addresses
    )

    If ($PSCmdlet.ShouldProcess("Adding private DNS zone A record")) {
        $ResourceType = "Microsoft.Network/privateDnsZones/A"
        $PrivateDnsZoneName = $PrivateDnsZone.name
        $aRecord = [PSCustomObject][ordered]@{
            _ResourceId = New-ArmFunctionResourceId -ResourceType $ResourceType -ResourceName1 $PrivateDnsZoneName -ResourceName2 $Name
            PSTypeName  = "PDNSZARecord"
            type        = $ResourceType
            name        = "[concat('$PrivateDnsZoneName', '/', '$Name')]"
            apiVersion  = $PrivateDnsZone.apiVersion
            properties  = @{
                TTL      = $TTL
                ARecords = @()
            }
            dependsOn   = @()
        }

        foreach ($IpV4Address in $IpV4Addresses) {
            $aRecord.properties.ARecords += @{
                ipv4Address = $IpV4Address
            }
        }

        $aRecord.PSTypeNames.Add("ArmResource")
        return $aRecord
    }
}