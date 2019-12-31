$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
    Describe "New-ArmPrivateDnsZoneARecord" {
        
        $ResourceType = "Microsoft.Network/privateDnsZones/A"
        $ExpectedName = "Name1"
        $ExpectedPrivateDnsZoneName = "Name2"

        $PrivateDnsZone = $ExpectedPrivateDnsZoneName `
            | New-ArmPrivateDnsZone
        $IpV4Addresses = @("address1", "address2")

        Context "Unit tests" {

            $Depth = 3
            $expectedTypes = @("PDNSZARecord", "ArmResource")

            It "Given the required parameters, it returns '<Expected>'" -TestCases @(
                @{  Name = $ExpectedName
                    PrivateDnsZone = $PrivateDnsZone
                    IpV4Addresses = $IpV4Addresses
                    Expected = [PSCustomObject][ordered]@{
                        _ResourceId = New-ArmFunctionResourceId -ResourceType $ResourceType -ResourceName1 $ExpectedPrivateDnsZoneName -ResourceName2 $ExpectedName
                        PSTypeName  = "PDNSZARecord"
                        type        = $ResourceType
                        name        = "[concat('$ExpectedPrivateDnsZoneName', '/', '$ExpectedName')]"
                        apiVersion  = $PrivateDnsZone.apiVersion
                        properties  = @{
                            TTL      = 3600
                            ARecords = @()
                        }
                        dependsOn   = @()
                    }
                    Types = $expectedTypes
                }
            ) {
                param($Name, $PrivateDnsZone, $IpV4Addresses, $Expected, $Types)

                foreach ($IpV4Address in $IpV4Addresses) {
                    $Expected.properties.ARecords += @{
                        ipv4Address = $IpV4Address
                    }
                }
                $Expected.PSTypeNames.Add("ArmResource")

                $actual = $Name | New-ArmPrivateDnsZoneARecord -PrivateDnsZone $PrivateDnsZone -IpV4Addresses $IpV4Addresses

                ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
                    | Should -BeExactly ($Expected | ConvertTo-Json -Depth $Depth -Compress| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

                $Types | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
            }
        }

        Context "Integration tests" {
            It "Default" -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    $ExpectedPrivateDnsZoneName `
                    | New-ArmPrivateDnsZoneARecord -PrivateDnsZone $PrivateDnsZone -IpV4Addresses $IpV4Addresses `
                    | Add-ArmResource
                }
            }

            It "Multiple"  -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    $PrivateDnsZoneARecords = @()
                    for ($i = 0; $i -lt 5; $i++) {
                        $PrivateDnsZoneARecords += @(
                            "$ExpectedPrivateDnsZoneName$i" `
                                | New-ArmPrivateDnsZoneARecord -PrivateDnsZone $PrivateDnsZone -IpV4Addresses $IpV4Addresses -TTL 400 `
                        )
                    }
                    $PrivateDnsZoneARecords | Add-ArmResource
                }
            }
        }
    }
}