$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
    Describe "New-ArmPrivateDnsZoneVirtualNetworkLink" {
        
        $ResourceType = "Microsoft.Network/privateDnsZones/virtualNetworkLinks"
        $ExpectedName = "Name1"
        $ExpectedPrivateDnsZoneName = "Name2"
        $ExpectedVirtualNetworkName = New-ArmResourceName 'Microsoft.Network/virtualNetworks'
        $ExpectedResourceGroupName = "ResourceGroupName"

        $PrivateDnsZone = $ExpectedPrivateDnsZoneName | New-ArmPrivateDnsZone
        $VirtualNetwork = $ExpectedVirtualNetworkName | New-ArmVirtualNetworkResource

        Context "Unit tests" {

            $Depth = 3
            $expectedTypes = @("PDNSZVirtualNetworkLink", "ArmResource")

            It "Given the required parameters, it returns '<Expected>'" -TestCases @(
                @{  Name = $ExpectedName
                    PrivateDnsZone = $PrivateDnsZone
                    VirtualNetwork = $VirtualNetwork
                    ResourceGroupName = $ExpectedResourceGroupName
                    Expected = [PSCustomObject][ordered]@{
                        _ResourceId = New-ArmFunctionResourceId -ResourceType $ResourceType -ResourceName1 $ExpectedPrivateDnsZoneName -ResourceName2 $ExpectedName
                        PSTypeName  = "PDNSZVirtualNetworkLink"
                        type        = $ResourceType
                        name        = "[concat('$ExpectedPrivateDnsZoneName/$ExpectedName-$ExpectedResourceGroupName-', $ExpectedVirtualNetworkName)]"
                        location    = "global"
                        apiVersion  = "2018-09-01"
                        properties  = @{
                            registrationEnabled = $false
                            virtualNetwork = @{
                                id = $VirtualNetwork._ResourceId
                            }
                        }
                        dependsOn   = @()
                    }
                    Types = $expectedTypes
                }
            ) {
                param($Name, $PrivateDnsZone, $VirtualNetwork, $ResourceGroupName, $Expected, $Types)

                $Expected.PSTypeNames.Add("ArmResource")

                $actual = $Name | New-ArmPrivateDnsZoneVirtualNetworkLink `
                    -ResourceGroupName $ResourceGroupName `
                    -VirtualNetwork $VirtualNetwork `
                    -PrivateDnsZone $PrivateDnsZone

                ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
                    | Should -BeExactly ($Expected | ConvertTo-Json -Depth $Depth -Compress| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

                $Types | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
            }
        }

        Context "Integration tests" {
            It "Default" -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    $ExpectedName | New-ArmPrivateDnsZoneVirtualNetworkLink `
                        -ResourceGroupName $ExpectedResourceGroupName `
                        -VirtualNetwork $VirtualNetwork `
                        -PrivateDnsZone $PrivateDnsZone `
                        | Add-ArmResource
                }
            }

            It "Multiple"  -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    $PrivateDnsZoneVirtualNetworkLinks = @()
                    for ($i = 0; $i -lt 5; $i++) {
                        $PrivateDnsZoneVirtualNetworkLinks += @(
                            "$ExpectedName$i" | New-ArmPrivateDnsZoneVirtualNetworkLink `
                                -ResourceGroupName $ExpectedResourceGroupName `
                                -VirtualNetwork $VirtualNetwork `
                                -PrivateDnsZone $PrivateDnsZone `
                        )
                    }
                    $PrivateDnsZoneVirtualNetworkLinks | Add-ArmResource
                }
            }
        }
    }
}