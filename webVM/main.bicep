param baseTime string = utcNow('u')
param location string = resourceGroup().location
var shutdownTime = dateTimeAdd(baseTime, 'PT1H', 'HHmm')
param snapshotName string = 'personalVMsnapshot'
param snapshotRgName string = 'snapshot-rg'
param vmName string = 'webVM'
param vmSize string = 'Standard_B4ms'

resource existingSnapshot 'Microsoft.Compute/snapshots@2023-03-01' existing = {
  name: snapshotName
  scope: resourceGroup(snapshotRgName)
}

resource vNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'jumpboxVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.3.0.0/28'
        }
      }
    ]
  }
}


resource diskName_resource 'Microsoft.Compute/disks@2022-03-02' = {
  name: 'osDiskFromSnapshot'
  location: location
  tags: {
  }
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Copy'
      sourceResourceId: existingSnapshot.id
    }
    diskSizeGB: 127
    encryption: {
      type: 'EncryptionAtRestWithPlatformKey'
    }
    networkAccessPolicy: 'AllowAll'
    publicNetworkAccess: 'Enabled'
  }
}

resource nsgjumpbox 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: 'vmfromsnapshotdisk-nsg'
  location: location
  properties: {
    securityRules: [
  {
    name: 'RDP'
    properties: {
      priority: 300
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]
  }
}

resource webVM 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  location: location
  name: vmName
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'attach'
        osType: 'Windows'
        managedDisk: {
          id: diskName_resource.id
        }
        deleteOption: 'Detach'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmnetworkinterface.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
    }
    licenseType: 'Windows_Client'
  }
}

resource autoShutdownConfig 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 15
      notificationLocale: 'en'
      emailRecipient: 'email@recipient.com'
    }
    dailyRecurrence: {
       time: shutdownTime
    }
     timeZoneId: 'UTC'
     taskType: 'ComputeVmShutdownTask'
     targetResourceId: webVM.id
  }
}

resource activitylogalerts_Alert_on_VM_shutdown_deallocate 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: 'Alert on VM shutdown(deallocate)'
  location: 'global'
  properties: {
    scopes: [
      webVM.id
          ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Compute/virtualMachines/deallocate/action'
        }
        {
          field: 'level'
          containsAny: [
            'informational'
          ]
        }
        {
          field: 'status'
          containsAny: [
            'succeeded'
          ]
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: '/subscriptions/<your-subscription-id>/resourceGroups/automation-rg/providers/microsoft.insights/actiongroups/vm_ag'
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource vmnetworkinterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  location: location
  name: 'vmnetworkinterface'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddressName_resource.id
          }
          subnet: {
            id: vNet.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsgjumpbox.id
    }
  }
  dependsOn: [
    nsgjumpbox
  ]
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: 'webVM-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
