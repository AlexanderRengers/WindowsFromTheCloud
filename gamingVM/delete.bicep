param snapshotName string = 'snapshotcli-${utcNow()}'
param disks_osDiskFromSnapshot_externalid string
param location string

resource snapshot 'Microsoft.Compute/snapshots@2022-03-02' = {
  name: snapshotName
  location: location
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

output snapshotName string = snapshot.id
