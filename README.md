# WindowsFromTheCloud
A cloud pc on my iPad, spinning up with the touch of a button and deletes itself automatically after 1 hour to save costs.

<img src="images/overview.png" alt="Alt Text" width="50%">

# Goal
I want my iPad to replace my private laptop. As I don't often need a private laptop and when only for 
 1. browsing the web
 2. playing games

I thought it cheaper to spin up a vm in Azure on a pay-per-use basis.

# Prerequisites
- An Azure account with an active Subscription for Infrastructure
- An Azure DevOps account for pipeline deployment
- An iPad as client and to run a shortcut to start the VM
- A client device to run [Parsec](https://parsec.app/downloads) for low latency game streaming

# Setup WebVM
## Initial Setup
1. Create a resource group named `webVM.rg`
2. Create a resource group name `snapshot.rg`
3. Create a VM with the configs you want inside the `webVM.rg`
3. Log into the VM via RDP and install [Jump Desktop Connect](https://jumpdesktop.com/connect/)
4. Install Jump Desktop on your iPad and verify that you can connect to your VM.
5. Create a snapshot of the vm inside the `snapshot.rg` resource group.
6. Delete all resources within the `webVM.rg`

## Pipeline Setup
### Service Connection
Create a service connection to your azure subscription for use in the following pipelines.

### Pipelines
There is one pipeline `deployment-pipeline.yml` for starting and deleting the vm.
1. create the start pipeline from the `deployment-pipeline.yml` file with the pipeline variable `templateFileName` 
and value `main.bicep`
2. create the stop/delete pipeline analog with the pipeline variable `delete.bicep`. The `delete.bicep` file is 
just an empty bicep file, the `--mode Complete` ensures the deployment deletes any resource in the `webVM.rg`

If you run the start pipeline your vm should be created and you should be able to connect from your iPad.
Accordingly if you run the stop pipeline all resources should be deleted.

## ipadOS Shortcuts Setup
### Runbooks
The runbooks are executed with a Azure Automation Account.
- You need to create a personal access token with Build - read & execute rights.
- You find the definitionId of your devops pipeline in the URL in your browser if you have the pipeline open.

### Automation Account Setup
1. Create a resource group `automation-rg` 
2. Create a Azure Automation Account
3. Create two runbooks with the provided `.ps1` files.
4. Create a webhook for each runbook.
5. Crate a action group that runs the shutdown runbook upon alert
6. Create two iOS shortcuts:

<img src="images/startup_shortcut.jpg" alt="Alt Text" width="50%">
<img src="images/shutdown_shortcut.jpg" alt="Alt Text" width="50%">

## Auto-shutdown after 1 hour
### Goal
To further save costs, the deployed vm should shutdown itself after 1 hour. In case a shutdown is detected by a existing 
action group, a runbook is executed that triggers the delete pipeline.

The action group is refernced in the vm deployment `main.bicep`

So after one hour the vm basically self-destroys.

## Shrink OS Disk to save costs
See following [instructions](https://www.linkedin.com/pulse/shrink-azure-vms-os-managed-disk-using-powershell-vikram-s-solanki/) to shrink the os disk size to a smaller size.

# Gaming VM (GPU) Setup
## Goal
I want a vm with Nvidia GPU to install games on and stream it to my (thin) client. In comparison to cloud gaming services (e.g. GeforeceNow) there are two advantages:
- 1 hour playing costs about 1,60 € compared to GeforceNow if you play less than 7 hours (say just one weekend) its cheaper.
- Most importantly: not every game is available on GeforceNow

## Initial Setup
1. Create a resource group `gamingVM.rg`
2. Create a vm with 
    - Windows 11 Pro
    - Size: Standard_NV12ads_A10_v5
3. Connect via RDP to your vm
4. Install [Parsecs Cloud Preparation Tools](https://github.com/parsec-cloud/Parsec-Cloud-Preparation-Tool)
5. Install a [virtual audio driver](https://vb-audio.com/Cable/)
6. Install Steam and one game
7. Connect via parsec and check everything works
8. Disconnect and shutdown the vm
9. Create a snapshot from the vm named `snapshotcli-initial`
10. Deploy the vm again using the deployment pipeline.
11. Delete the vm with the delete pipeline, which deletes all resources and creates a snapshot of the current vm disk.

## Pipeline Setup
1. Create a deployment pipeline 
   - `gamingVM/deploy-vm-pipeline.yml`
   - variables: `resourceGroup=gamingVm.rg` and `templateFilePath=gamingVM/main.bicep`
2. Create a deployment pipeline for deleting and snapshot creation
   - reusing the `webVM/deployment-pipeline.yml`
   - variables: `resourceGroup=gamingVm.rg` and `templateFilePath=gamingVM/delete.bicep`