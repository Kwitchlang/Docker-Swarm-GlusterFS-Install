## Instructions
Run these commands on nmanager 1 (Whatever server you decide!)

Many Thanks to Jim's Garage for a lot of the heavy lifting!
https://github.com/JamesTurland/JimsGarage/blob/main/Docker-Swarm/swarm-3-nodes.sh

Many thanks to Techdox for the glusterfs setup:
https://www.youtube.com/watch?v=Has6lUPdzzY&t=183s



```
curl -k https://raw.githubusercontent.com/Kwitchlang/Docker-Swarm-GlusterFS-Install/main/Install%20Docker%20GlusterFS.sh | sed -e 's/\r//g' > swarm.sh && \
sudo chmod a+x swarm.sh && \
sudo bash ./swarm.sh
```


## To do
- [ ] Enable glusterfs to mount on reboot
- [ ] Install GlusterFS plugin to work with docker compose
