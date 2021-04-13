param ResourcePrefix string = 'bicep'
param ResourceName string = 'bicep'
param location string = resourceGroup().location
param tagValues object
param securityRules array

var nsgName = !(empty(ResourcePrefix)) ? '${ResourcePrefix}-NSG' : ResourceName

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: location
  tags: tagValues
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        protocol: rule.protocol
        sourcePortRange: rule.sourcePortRange
        destinationPortRange: rule.destinationPortRange
        sourceAddressPrefix: rule.sourceAddressPrefix
        destinationAddressPrefix: rule.destinationAddressPrefix
        access: rule.access
        priority: rule.priority
        direction: rule.direction
      }
    }]
  }
}

output nsgid string = nsg.id
