# WindowsFromTheCloud
A cloud pc on my iPad, spinning up with the touch of a button.

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

#Setup
## WebVM
## Initial Setup
1. Create a resource group named `webVM.rg`
2. Create a resource group name `snapshot.rg`
3. Create a VM with the configs you want inside the `webVM.rg`
3. Log into the VM via RDP and install [Jump Desktop Connect](https://jumpdesktop.com/connect/)
4. Install Jump Desktop on your iPad and verify that you can connect to your VM
5. Create a snapshot of the vm inside the `snapshot.rg` resource group.
6. Delete all resources within the `webVM.rg`

## Pipeline Setup

## ipadOS Shortcuts Setup

## Gaming VM (GPU)