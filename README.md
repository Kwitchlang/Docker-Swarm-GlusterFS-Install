## Thank you community!
Tested working on Ubuntu Server 23.10 (minimal installation)

Many thanks to Jim's Garage for a lot of the heavy lifting!\
https://github.com/JamesTurland/JimsGarage/blob/main/Docker-Swarm/swarm-3-nodes.sh\

Many thanks to Techdox for the glusterfs setup:\
https://www.youtube.com/watch?v=Has6lUPdzzY&t=183s

> [!IMPORTANT]
> Please note, code execution on this likely poses MANY security risks - use at your own risk :)
> This is more of a proof of concept



## Why I made this?
I wanted a really zero-touch approach to deploying GLUSTERFS and setting up docker swarm with an all-in-one script, idealy for a high availability swarm cluster with persistant storage accross ALL nodes. So if a node fully fails, The storage will be replicated accross all nodes and pick up where it left off by moving the docker container to another node

## Features:
- [X] 90% is remote code execution (SSH to the nodes)
- [X] Minimal Password Entries (1 password + Each node password), Enters Sudo on all devices
- [x] Installs GLUSTERFS across 5 Nodes (3 Managers, 2 Workers, or as many nodes as you want!)
- [X] Installs Docker to all nodes
- [X] Configures Swarm Roles based off of IP Arrays
- [X] Connects and Stores portainer in GLUSTERFS storage pool

## Prequisites

Variables to change
 * user="ubuntu"
   * This User can be named anything but must be set with the same name and password accross all nodes - Please make sure this is set up first on your nodes, as this user will not get created from this script.
 * Docker_Manager_IPs=("10.10.5.1" "10.10.5.2" "10.10.5.3")
   * Array of IP Addresses: Idealy 3 manager servers - adds redundancy, make sure to run the script on the first Manage server
 * Docker_Worker_IPs=("10.10.5.4" "10.10.5.5")
   * Array of IP Addresses: Add your server IPs that you want to deploy this on - this can be any other amount
  

> [!WARNING]
> Please note: There is an APT cache at line 95/96 - Please Comment this out if not used or set up! (image: sameersbn/apt-cacher-ng)

## Instructions
First SSH into your first Manager Node
` ssh -t ubuntu@<First_manager_node_IP> `
Run these commands on manager1 (Whatever server you decide!)
Make sure all your nodes are using the same password 

This command will point to the most recent version of my script, and executes it.
Please read through the script provided in the command -  Never install something you don't know or understand (Stanadard internet spheel :P)
```
curl -k https://raw.githubusercontent.com/Kwitchlang/Docker-Swarm-GlusterFS-Install/main/Install%20Docker%20GlusterFS.sh | sed -e 's/\r//g' > swarm.sh && \
sudo chmod a+x swarm.sh && \
sudo bash ./swarm.sh
```
This command ` sed -e 's/\r//g' > swarm.sh ` is used to strip any windows characters from scripts - Usefull when useing a webdav server for hosting bash files.\
There are external commands like ` curl -fsSL https://get.docker.com | sudo -S bash >> /dev/null ` used in this script. This is a file hosted by someone that will install Docker and Docker-compose.

## To do
- [x] Enable glusterfs to mount on reboot
- [ ] fix issue: /mnt will not mount when theres been an ungraceful shutdown, a gracefull reboot will fix this (sudo reboot) 
- [ ] Enable Persistant storage accross all nodes using docker compose - Currently This only works providing the origional host with the data is still live and accessable (and its just the application that crashed), if the actual server node crashed, a new instance and volume will be created fresh on that node, will no link to the previous data - Not ideal
- [ ] Install GlusterFS plugin to work with docker compose
- [ ] Allow for pure remote code execution - Currently it executes on one of the manager nodes and stores the configs there, I want this to be done off any server that wont be part of the cluster

## Enterprise To do (Maybe)
- [ ] Use Directus/APi for storing Swarm worker/manager join tokens, recording Device hostnames/MAC addresses - This will be usefull for when wanting to add a node to the server that weren't  already setup in the (Add device credentials, IP, and Node type Worker/Manager in staging to Directus)
- [ ] Create a cron job on installed nodes that acts like an agent for Directus for monitoring the servers status  

