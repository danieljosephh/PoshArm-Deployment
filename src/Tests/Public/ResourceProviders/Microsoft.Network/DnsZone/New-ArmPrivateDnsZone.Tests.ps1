$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
    Describe "New-ArmPrivateDnsZone" {
        
        $ResourceType = "Microsoft.Network/privateDnsZones"
        $ExpectedName = "Name1"

        Context "Unit tests" {

            $Depth = 1
            $expectedTypes = @("PDNSZ", "ArmResource")

            It "Given the required parameters, it returns '<Expected>'" -TestCases @(
                @{ Name = $ExpectedName; Expected = [PSCustomObject][ordered]@{
                        _ResourceId = $ExpectedName | New-ArmFunctionResourceId -ResourceType $ResourceType
                        PSTypeName  = "PDNSZ"
                        type        = $ResourceType
                        name        = $ExpectedName
                        apiVersion  = "2018-09-01"
                        location    = "global"
                        properties  = @{
                            maxNumberOfRecordSets = 25000
                            maxNumberOfVirtualNetworkLinks = 1000
                            maxNumberOfVirtualNetworkLinksWithRegistration = 100
                            numberOfRecordSets = 4
                            numberOfVirtualNetworkLinks = 1
                            numberOfVirtualNetworkLinksWithRegistration = 0
                        }
                        dependsOn   = @()
                    }
                    Types = $expectedTypes
                }
            ) {
                param($Name, $Expected, $Types)

                $actual = $Name | New-ArmPrivateDnsZone

                ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
                    | Should -BeExactly ($Expected | ConvertTo-Json -Depth $Depth -Compress| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

                $Types | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
            }

            $ExpectedMaxNumberOfRecordSets = 5
            $ExpectedMaxNumberOfVirtualNetworkLinks = 5
            $ExpectedMaxNumberOfVirtualNetworkLinksWithRegistration = 5
            $ExpectedNumberOfRecordSets = 5
            $ExpectedNumberOfVirtualNetworkLinks = 5
            $ExpectedNumberOfVirtualNetworkLinksWithRegistration = 5
            It "Given the nondefault parameters, it returns '<Expected>'" -TestCases @(
                @{  Name = $ExpectedName
                    MaxNumberOfRecordSets = $ExpectedMaxNumberOfRecordSets
                    MaxNumberOfVirtualNetworkLinks = $ExpectedMaxNumberOfVirtualNetworkLinks
                    MaxNumberOfVirtualNetworkLinksWithRegistration = $ExpectedMaxNumberOfVirtualNetworkLinksWithRegistration
                    NumberOfRecordSets = $ExpectedNumberOfRecordSets
                    NumberOfVirtualNetworkLinks = $ExpectedNumberOfVirtualNetworkLinks
                    NumberOfVirtualNetworkLinksWithRegistration = $ExpectedNumberOfVirtualNetworkLinksWithRegistration
                    Expected = [PSCustomObject][ordered]@{
                        _ResourceId = $ExpectedName | New-ArmFunctionResourceId -ResourceType $ResourceType
                        PSTypeName  = "PDNSZ"
                        type        = $ResourceType
                        name        = $ExpectedName
                        apiVersion  = "2018-09-01"
                        location    = "global"
                        properties  = @{
                            maxNumberOfRecordSets = $ExpectedMaxNumberOfRecordSets
                            maxNumberOfVirtualNetworkLinks = $ExpectedMaxNumberOfVirtualNetworkLinks
                            maxNumberOfVirtualNetworkLinksWithRegistration = $ExpectedMaxNumberOfVirtualNetworkLinksWithRegistration
                            numberOfRecordSets = $ExpectedNumberOfRecordSets
                            numberOfVirtualNetworkLinks = $ExpectedNumberOfVirtualNetworkLinks
                            numberOfVirtualNetworkLinksWithRegistration = $ExpectedNumberOfVirtualNetworkLinksWithRegistration
                        }
                        dependsOn   = @()
                    }
                    Types = $expectedTypes
                }
            ) {
                param(
                        $Name, 
                        $MaxNumberOfRecordSets,
                        $MaxNumberOfVirtualNetworkLinks,
                        $MaxNumberOfVirtualNetworkLinksWithRegistration,
                        $NumberOfRecordSets,
                        $NumberOfVirtualNetworkLinks,
                        $NumberOfVirtualNetworkLinksWithRegistration,
                        $Expected,
                        $Types
                    )

                $actual = $Name | New-ArmPrivateDnsZone `
                            -MaxNumberOfRecordSets $MaxNumberOfRecordSets `
                            -MaxNumberOfVirtualNetworkLinks $MaxNumberOfVirtualNetworkLinks `
                            -MaxNumberOfVirtualNetworkLinksWithRegistration $MaxNumberOfVirtualNetworkLinksWithRegistration `
                            -NumberOfRecordSets $NumberOfRecordSets `
                            -NumberOfVirtualNetworkLinks $NumberOfVirtualNetworkLinks `
                            -NumberOfVirtualNetworkLinksWithRegistration $NumberOfVirtualNetworkLinksWithRegistration

                ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
                    | Should -BeExactly ($Expected | ConvertTo-Json -Depth $Depth -Compress| ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

                $Types | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
            }
        }

        Context "Integration tests" {
            It "Default" -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    New-ArmResourceName $ResourceType `
                    | New-ArmPrivateDnsZone `
                    | Add-ArmResource
                }
            }

            It "Multiple"  -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    $PrivateDnsZones = @()
                    for ($i = 0; $i -lt 5; $i++) {
                        $PrivateDnsZones += @(
                            New-ArmResourceName -ResourceType $ResourceType `
                                -ResourceName "$ExpectedName$i" `
                            | New-ArmPrivateDnsZone -NumberOfRecordSets 5
                        )
                    }
                    $PrivateDnsZones | Add-ArmResource
                }
            }
        }
    }
}