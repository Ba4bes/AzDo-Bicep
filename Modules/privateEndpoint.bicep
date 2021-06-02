param privateEndpointName string
param location string = resourceGroup().location
param storageAccountId string
param vnetId string
param subnetName string
param tagValues object

@allowed([
    'blob'
    'table'
    'queue'
    'share'
])
param groupIds array = [
    'blob'
]


var privateDNSZoneName = 'privatelink.blob.core.windows.net'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
    name: privateEndpointName
    tags: tagValues
    location: location
    properties: {
        privateLinkServiceConnections: [
            {
                name: privateEndpointName
                properties: {
                    privateLinkServiceId: storageAccountId
                    groupIds: groupIds
                    privateLinkServiceConnectionState: {
                        status: 'Approved'
                        description: 'Auto-Approved'
                        actionsRequired: 'None'
                    }
                }
            }
        ]
        subnet: {
            id: '${vnetId}/subnets/${subnetName}'
        }
    }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
    name: privateDNSZoneName
    location: 'global'
    properties: {}
  }
  
  resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
    name: '${privateDnsZones.name}/${privateDnsZones.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
  resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
    name: '${privateEndpoint.name}/dnsgroupname'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config1'
          properties: {
            privateDnsZoneId: privateDnsZones.id
          }
        }
      ]
    }
  }
  
