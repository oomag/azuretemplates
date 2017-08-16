Azure template for easier storage vm creation

This Azure template supposed to create a VM with 1 nic with public IP attached
to it and a disk storage with 5 disks in it.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

How to use
----------

First, obtain a copy of Azure cli utility. I personally prefer Docker one, so
will show you an example with help of it. So, get Azure CLI and run it:

`$ docker run -it azuresdk/azure-cli-python:latest`

you will be thrown into docker container with `az` utility. Next, login into
Azure:

`$ az login`

and do what that utility will propose for your case. After successful login,
create a resource group in which you will ran a VM:

`$ az group create --name ExampleGroup --location "Central US"`

and then start the deployment of VM:

`$ az group deployment create --name TestStorageDeploy
  --resource-group ExampleGroup
  --template-uri https://raw.githubusercontent.com/dokkur/azuretemplates/master/vm-1nic-1pip-5diskstorage/azuredeploy.json
`

You will be asked about vm name, network name, admin username and password.
After that your deployment will be started. Wait for several minutes - that's
all. Congrats you!!
