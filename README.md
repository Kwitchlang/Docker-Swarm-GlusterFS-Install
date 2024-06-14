## Thank you community!
Tested working on Ubuntu Server 23.10 (minimal installation)

Many thanks to Jim's Garage for a lot of the heavy lifting!\
https://github.com/JamesTurland/JimsGarage/blob/main/Docker-Swarm/swarm-3-nodes.sh\

Many thanks to Techdox for the glusterfs setup:\
https://www.youtube.com/watch?v=Has6lUPdzzY&t=183s



## Why I made this?
I wanted a really zero-touch approach to deploying GLUSTERFS and setting up docker swarm in an all-in-one script, idealy for a high availability, scalable docker environment with persistant storage accross ALL nodes.

## Features:
- [X] 90% is remote code execution (SSH to the nodes)
- [X] Minimal Password Entries (1 password + Each node password), Enters Sudo on all devices
- [x] Installs GLUSTERFS across 5 Nodes (3 Managers, 2 Workers)
- [X] Installs Docker to all nodes
- [X] Configures Swarm Roles based of IP Arrays
- [X] Connects and Stores portainer in GLUSTERFS storage pool

## Prequisites

*Variables to change
 * user="ubuntu" - This User must be set with the same password accross all nodes.
 * Docker_Manager_IPs=("10.10.5.1" "10.10.5.2" "10.10.5.3") - Array of IP Addresses: Idealy 3 manager servers - adds redundancy, make sure to run the script on the first Manage server
 * Docker_Worker_IPs=("10.10.5.4" "10.10.5.5") - Array of IP Addresses: Add your server IPs that you want to deploy this on - this can be any other amount
 * 

> [!WARNING]
> Please note: There is an APT cache at line 64 - Please Comment this out if not used or set up! (image: sameersbn/apt-cacher-ng)

## Instructions
First SSH into your first Manager Node
` ssh -t ubuntu@<First_manager_node_IP> `
Run these commands on manager1 (Whatever server you decide!)
Make sure all your nodes are using the same password 

This command will point to the most recent version of my script, and executes it.
```
curl -k https://raw.githubusercontent.com/Kwitchlang/Docker-Swarm-GlusterFS-Install/main/Install%20Docker%20GlusterFS.sh | sed -e 's/\r//g' > swarm.sh && \
sudo chmod a+x swarm.sh && \
sudo bash ./swarm.sh
```


> [!IMPORTANT]
> Please note code execution on this poses MANY security risks - use at your own risk :)
> This is more of a proof of concept


## To do
- [x] Enable glusterfs to mount on reboot
- [ ] Install GlusterFS plugin to work with docker compose
- [ ] Allow for pure remote code execution - Currently it executes on one of the manager nodes and stores the configs there, I want this to be done off any server that wont be part of the cluster
