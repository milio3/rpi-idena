#####################################
# RPI IDENA NODE INSTALLER
# @milio3
# 13/11/2021
# 11/04/2021 - Force GO 1.16
#####################################

echo "************************"
echo "RPI IDENA NODE INSTALLER"
echo "************************"
echo ""

# Presets
echo "- Disable cloud-init and set timezone"
touch /etc/cloud/cloud-init.disabled
timedatectl set-timezone Europe/Madrid
echo ""

# Updating Ubuntu and installing all required dependencies
echo "- Updating and installing all required dependencies"
echo ""
apt-get update
apt-get upgrade -y
apt-get install -y jq git ufw curl wget nano screen psmisc unzip vnstat gcc g++ libc6-dev 
echo ""

# Install go-lang
wget -c https://golang.org/dl/go1.16.15.linux-arm64.tar.gz
tar -C /usr/local -xvf go1.16.15.linux-arm64.tar.gz
echo ""

# Creating user
echo "- Creating a user name and password for IDENA Service"
echo ""
if [ $(id -u) -eq 0 ]; then
	read -p "Enter new username : " username
	read -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -s /bin/bash -m -p $pass $username
                usermod -aG sudo $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi
echo ""

# IDENA node install
echo "- IDENA node install"
echo ""

# Take node version
read -p "Enter the number of the idena-go version (eg. 0.28.8): " version
echo ""

# Continue as username
sudo -i -u $username bash << EOF
whoami
cd ~
git clone https://github.com/idena-network/idena-go.git

/usr/local/go/bin/go build -ldflags "-X main.version=$version"
mv idena-go ../idena-node

cd ~
mkdir datadir ; mkdir datadir/idenachain.db ; mkdir datadir/keystore

cd datadir/idenachain.db
wget https://sync.idena.site/idenachain.db.zip
unzip idenachain.db.zip
rm idenachain.db.zip

cd ~
chmod +x idena-node

EOF

# Copy service, config.json, update script
cp idena.service /etc/systemd/system/
cp config.json /home/$username/
cp idena_update.sh /home/$username/

chown -R $username:$username /home/$username/

# Finish
echo ""
echo "*********************************************"
echo "RPI IDENA NODE INSTALL SUCCESSFULLY COMPLETED"
echo "*********************************************"
