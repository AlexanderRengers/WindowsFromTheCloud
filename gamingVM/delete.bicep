param snapshotName string = 'snapshotcli-${utcNow()}'
param disks_osDiskFromSnapshot_externalid string = '/subscriptions/<your-subscription-id>/resourceGroups/GAMINGVM.RG/providers/Microsoft.Compute/disks/osDiskFromSnapshot'

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
