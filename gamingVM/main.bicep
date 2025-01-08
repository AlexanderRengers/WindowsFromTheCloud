param snapshotName string

module virtualMachine '../webVM/main.bicep' = {
  name: 'gamingVM'
  params: {
    vmName: 'gamingVM'
    vmSize: 'Standard_NV12ads_A10_v5'
    snapshotName: snapshotName
  }
}

resource gpuVM 'Microsoft.Compute/virtualMachines@2022-03-01' existing = { 
  name: virtualMachine.name
 }

resource gpuExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: gpuVM
  name: 'NvidiaGpuDriverWindows'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.2'
    autoUpgradeMinorVersion: true
  }
}

