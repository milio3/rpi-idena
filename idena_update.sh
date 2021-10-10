#####################################
# RPI IDENA NODE UPDATER
# @milio3
# 09/10/2021
#####################################

echo "**********************"
echo "RPI IDENA NODE UPDATER"
echo "**********************"
echo ""

# Take node version
read -p "Enter the number of the idena-go version (eg. 0.27.2): " version

# Updating Ubuntu
echo ""
echo "- Updating Ubuntu"
echo ""
apt-get update
apt-get upgrade -y

# Stopping idena.service
echo ""
echo "- Stopping the idena.service"
echo ""
systemctl stop idena
systemctl disable idena
systemctl daemon-reload
systemctl reset-failed

# /home/<user>
cd /home/ubuntu/

# Backup idena-node
echo ""
echo "- Backup idena-node -> idena-node-old"
if [ -f "idena-node-old" ]
then
    rm idena-node-old
    mv idena-node idena-node-old
else
    mv idena-node idena-node-old
fi

# Downloading new node version
echo ""
echo "- Downloading new node version"
echo ""

rm -rf idena-go/
git clone https://github.com/idena-network/idena-go.git
cd idena-go/

# Compile node
echo ""
echo "- Compile idena-node version $version"
go build -ldflags "-X main.version=$version"
mv idena-go ../idena-node

# Starting idena.service
echo ""
echo "- Starting idena.service"
echo ""
systemctl start idena.service
systemctl enable idena.service

# Successfull update
echo ""
echo "********************************************"
echo "RPI IDENA NODE UPDATE SUCCESSFULLY COMPLETED"
echo "********************************************"
