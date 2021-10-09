# RPI IDENA NODE UPDATER
# @milio3
# 09/10/2021

echo "** RPI IDENA NODE UPDATER **"

# Take node version
read -p "Enter the number of the idena-go version (eg. 0.18.2) keep it empty to download the latest one: " version

# Updating Ubuntu
apt-get update
apt-get upgrade -y

# Stopping idena.service
echo "Stopping the idena.service"
systemctl stop idena
systemctl disable idena
systemctl daemon-reload
systemctl reset-failed

# /hone/<user>
whoami
cd ~

# Backup idena-node
if [ -f "./idena-node-old" ]
then
    rm idena-node-old
    mv idena-node idena-node-old
else
    mv idena-node idena-node-old
fi

# Downloading new node version
rm -rf idena-go/
git clone https://github.com/idena-network/idena-go.git
cd idena-go/

# Compile node
go build -ldflags "-X main.version=$version"
mv idena-go ../idena-node

# Starting idena.service
systemctl start idena.service
systemctl enable idena.service

# Finish
echo "Idena node successfully completed"