#####################################
# RPI IDENA NODE UPDATER
# @milio3
# 09/10/2021
# 11/04/2022 - Force GO 1.16
#####################################

echo "**********************"
echo "RPI IDENA NODE UPDATER"
echo "**********************"
echo ""

# Take node version
read -p "Enter the number of the idena-go version (eg. 0.28.8): " version
echo ""

# Updating Ubuntu
echo "- Updating Ubuntu"
echo ""
apt-get update
echo ""

# Stopping idena.service
echo "- Stopping idena.service"
echo ""
systemctl stop idena
systemctl disable idena
systemctl daemon-reload
systemctl reset-failed
echo ""

# /home/<user>
cd ~

# Backup idena-node
echo "- Backup idena-node -> idena-node-old"
if [ -f "idena-node-old" ]
then
    rm idena-node-old
    mv idena-node idena-node-old
else
    mv idena-node idena-node-old
fi
echo ""

# Downloading new node version
echo "- Downloading new node version"
echo ""

rm -rf idena-go/
git clone https://github.com/idena-network/idena-go.git
cd idena-go/
echo ""

# Compile node
echo "- Compile idena-node version $version"
/usr/local/go/bin/go build -ldflags "-X main.version=$version"
mv idena-go ../idena-node
echo ""

# Starting idena.service
echo "- Starting idena.service"
echo ""
systemctl start idena.service
systemctl enable idena.service

# Finish
echo ""
echo "********************************************"
echo "RPI IDENA NODE UPDATE SUCCESSFULLY COMPLETED"
echo "********************************************"
