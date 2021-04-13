param ResourcePrefix string = ''
param ResourceName string = ''
param location string = resourceGroup().location
param virtualNetworkPrefix string
param subnets array
param tagValues object

var vnetName = !(empty(ResourcePrefix)) ? '${ResourcePrefix}-VNET' : ResourceName

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.virtualNetworkPrefix
        networkSecurityGroup: {
          id: subnet.nsg
        }
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
        ]
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
      }
    }]
    enableDdosProtection: false
  }
}

output vnetid string = vnet.id
output vnetname string = vnet.name
