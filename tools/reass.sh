#!/bin/bash

rg=$1
vmname=$2
nicname=$3

[[ -z "${rg// }" ]] && echo "Place group name as a first argument" && exit 1
if ! type jq ; then echo "Jq utility is needed for script run" && exit 1 ; fi

nics=`az vm list --resource-group $rg --query "[?provisioningState=='Succeeded'] | [?name=='$vmname'].{netprofile: networkProfile.networkInterfaces[*].id}" | jq -r '.[].netprofile | .[]'`
[[ -z $nics ]] && echo "nic list cannot be found for machines in given group, exiting" && exit 1

nicfound=0

for nic in $nics
do
  if [[ "$nic" == *$nicname ]] ; then

    ipconfig=`az network nic show --ids "$nic" --query "{ ipconfig: ipConfigurations[0].id }" | jq -r ".ipconfig"`
    [[ -z $ipconfig ]] && echo "ip config list cannot be found for machines in given group, exiting" && exit 1

    publicip=`az network nic ip-config show --ids "$ipconfig" --query "{ publicip: publicIpAddress.id }" | jq -r ".publicip"`
    [[ -z $publicip ]] && echo "public ip cannot be found for machines in given group, exiting" && exit 1

    echo "Starting dissociate IP address from interface $nic on vm $vmname"
    az network nic ip-config update --ids "$ipconfig" --public-ip-address ''
    echo "Starting associate new IP address to interface $nic on vm $vmname"
    az network nic ip-config update --ids "$ipconfig" --public-ip-address "$publicip"
    nicfound=1
  fi
done
if [[ "$nicfound" == "0" ]] ; then
  echo "Interface $nicname was not found in vm $vmname. Error."
else
  echo 'Done with success'
fi
