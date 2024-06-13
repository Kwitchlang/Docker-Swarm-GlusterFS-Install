## Why I made this?
I wanted a really minimal hands off approach to deploying GLUSTERFS and setting up docker swarm in an all-in-one script


## Prequisites
X amount of servers with the same username and Password

## Instructions

Tested working on Ubuntu Server 23.10 (minimal installation)

Many thanks to Jim's Garage for a lot of the heavy lifting!
https://github.com/JamesTurland/JimsGarage/blob/main/Docker-Swarm/swarm-3-nodes.sh

Many thanks to Techdox for the glusterfs setup:
https://www.youtube.com/watch?v=Has6lUPdzzY&t=183s


Run these commands on manager1 (Whatever server you decide!)
Make sure all your nodes are using the same password 

This command will point to the most recent version of my script, downloads it, and executes it.
```
curl -k https://raw.githubusercontent.com/Kwitchlang/Docker-Swarm-GlusterFS-Install/main/Install%20Docker%20GlusterFS.sh | sed -e 's/\r//g' > swarm.sh && \
sudo chmod a+x swarm.sh && \
sudo bash ./swarm.sh
```

Please note there is an array called Managers and Workers - Add your server IPs that you want to deploy this on.

> [!IMPORTANT]
> Please note code execution on this poses MANY security risks - use at your own risk :)


## To do
- [x] Enable glusterfs to mount on reboot
- [ ] Install GlusterFS plugin to work with docker compose
- [ ] Allow for pure remote code execution - Currently it executes on one of the manager nodes, I want this to be done off any server that wont be part of the cluster
