#!/bin/bash



#####################################################################################################################
######### can touch variables

user="ubuntu" #This the user that is on all servers
Docker_Manager_IPs=("10.10.5.1" "10.10.5.2" "10.10.5.3") # Enter your Manager Server's IP here
Docker_Worker_IPs=("10.10.5.4" "10.10.5.5") # Enter your Worker Server's IP here

Use_APTCache=True # True/False - False will disable injecting the APT cache Function
APTCacheIP="10.10.1.2:${APTCachePort}"
APTCachePort=3142 # Define the port if not set

#####################################################################################################################

###### Don't Touch Please

AllNodes=("${Docker_Manager_IPs[@]}" "${Docker_Worker_IPs[@]}")
replica_count="${#AllNodes[@]}"
certName="id_rsa"
IFS=':' read -r APTCacheIP APTCachePort <<< "${APTCacheIP}"
APTCachePort=3142
######### COMMANDS #########

InitializeSwarmNode=" docker swarm init --advertise-addr ${Docker_Manager_IPs[0]}"

#####################################################################################################################
################################
################################
######### Start Script #########
read -s -p "Enter your SSH password for all nodes: " ssh_password

######### Generate SSH Keys #########
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""

######### Move SSH certs to ~/.ssh and change permissions
clear


echo -e " \033[32;5m Copying SSH Keys \033[0m"
cp /home/"$user"/{"$certName","$certName.pub"} /home/"$user"/.ssh
chmod 600 /home/"$user"/.ssh/"$certName"
chmod 644 /home/"$user"/.ssh/"$certName.pub"


######### Create SSH Config file to ignore checking (don't use in production!)
echo "StrictHostKeyChecking no" > ~/.ssh/config


######### Add ssh keys for all nodes
echo -e " \033[94m Add ssh keys for all nodes \033[0m"
for node in "${AllNodes[@]}"; do
  ssh-copy-id "$user"@"$node"
done

######### Install GLUSTERFS
for node in "${AllNodes[@]}"; do
	ssh -t "$user"@"$node" <<EOF
		echo '$ssh_password' | sudo -S sh -c ''
  		######### Add APT Cache (Located in UNRAID - Comment out if not needed)
		sudo sh -c 'echo "Acquire::HTTP::Proxy \"http://10.10.1.2:3142\";" >> /etc/apt/apt.conf.d/01proxy'
		sudo sh -c 'echo "Acquire::HTTPS::Proxy \"false\";" >> /etc/apt/apt.conf.d/01proxy'
		sudo apt update
		sudo apt install software-properties-common glusterfs-server -y
		sudo systemctl start glusterd && sudo systemctl enable glusterd
		exit
EOF
done


for node in "${AllNodes[@]}"; do
  gluster peer probe "$node"
done

for node in "${AllNodes[@]}"; do
	ssh -t "$user"@"$node" <<EOF
		echo '$ssh_password' | sudo -S sh -c ''
		sudo mkdir -p /gluster/volumes
		exit
EOF
done

command="sudo gluster volume create staging-gfs replica $replica_count"
for server in "${AllNodes[@]}"; do
  command+=" $server:/gluster/volumes"
done
command+=" force"

# Execute the constructed command
# echo "Executing command: $command"
eval "$command"



sudo gluster volume start staging-gfs


for node in "${AllNodes[@]}"; do
	ssh -t "$user"@"$node" <<EOF
		echo '$ssh_password' | sudo -S sh -c ''
                sudo echo "localhost:/staging-gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0" | sudo tee -a /etc/fstab >/dev/null
		sudo mount.glusterfs localhost:/staging-gfs /mnt
		curl -fsSL https://get.docker.com | sudo -S bash >> /dev/null
		sudo chown -R root:docker /mnt
		exit
EOF
done

sudo mkdir /mnt/Docker
sudo mkdir /mnt/Docker/Portainer

######### Generate Swarm Cluster Tokens on first Manager Node
ssh -t "$user"@"${Docker_Manager_IPs[0]}" <<EOF
  echo "$ssh_password" | sudo -S sh -c "$InitializeSwarmNode"
  for role in "manager" "worker"; do
    output=\$(sudo docker swarm join-token \$role)
    token=\$(echo "\$output" | grep -oP 'docker swarm join --token \K\S+')
    echo "\$token" > "\${role^}.txt"
    echo "\${role^} Join token: \$(<\${role^}.txt)"
  done
EOF


######### Save Swarm join Tokens as Variables
Manager=$(<Manager.txt)
Worker=$(<Worker.txt)


######### Add Manager Nodes from the Second Index
for node in "${Docker_Manager_IPs[@]:1}"; do
    ssh -t "$user"@"$node" <<EOF
        echo "$ssh_password" | sudo -S sh -c ''
        echo -e "\033[0;35m$node - Configuring as Manager Node \033[0m"
        echo -e "\033[0;35mToken - $Manager \033[0m"
        echo -e "\033[0m \033[0m"
        sudo docker swarm join --token $Manager "${Docker_Manager_IPs[0]}:2377"
		exit
EOF
done

######### Add Worker Nodes to swarm
for node in "${Docker_Worker_IPs[@]}"; do
    ssh -t "$user"@"$node" <<EOF
        echo "$ssh_password" | sudo -S sh -c ''
        echo -e "\033[0;35m$node - Configuring as Worker Node \033[0m"
        echo -e "\033[0;35mToken - $Worker \033[0m"
        echo -e "\033[0m \033[0m"
        sudo docker swarm join --token $Worker "${Docker_Manager_IPs[0]}:2377"
		exit
EOF

done

ssh -t "$user"@"${Docker_Manager_IPs[0]}" <<EOF
  echo "$ssh_password" | sudo -S sh -c ""
  echo -e " \033[94m Installing Portainer on: ${Docker_Manager_IPs[0]} \033[0m"
  curl -k https://raw.githubusercontent.com/Kwitchlang/Docker-Swarm-GlusterFS-Install/main/portainer-agent-stack.yml | sed -e 's/\r//g' > portainer-agent-stack.yml
  sudo docker stack deploy -c portainer-agent-stack.yml portainer
EOF
echo _______________________________________________________________
df -h
echo _______________________________________________________________
sudo docker service ls
echo _______________________________________________________________
echo -e "\e]8;;https://${Docker_Manager_IPs[0]}:9443\aClick here to access your installed Portainer SWARM instance\e]8;;\a"



