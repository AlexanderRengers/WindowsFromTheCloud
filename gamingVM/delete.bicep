param snapshotName string = 'snapshotcli-${utcNow()}'
param disks_osDiskFromSnapshot_externalid string = '/subscriptions/3969faee-df3c-4071-99fe-d4daf6042b96/resourceGroups/GAMINGVM.RG/providers/Microsoft.Compute/disks/osDiskFromSnapshot'

resource snapshot 'Microsoft.Compute/snapshots@2022-03-02' = {
  name: snapshotName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Copy'
      sourceResourceId: disks_osDiskFromSnapshot_externalid
    }
    incremental: true
    networkAccessPolicy: 'AllowAll'
    publicNetworkAccess: 'Enabled'
  }
}
