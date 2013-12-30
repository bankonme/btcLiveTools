#!/bin/bash
##MultiBit variable declarations
multibit_version="0.5.16"
multibit_pgp_address="0x79F7C572"
multibit_pgp_verify="jim618@fastmail.co.uk"

##TrueCrypt variable declarations
truecrypt_version="7.1a"
truecrypt_pgp_address="0xe3ba73caf0d6b1e0"
truecrypt_pgp_verify="info@truecrypt-foundation.org"

##bitcoin-qt variable declarations
bitcoin_version="0.8.6"
bitcoin_pgp_address="1FC730C1"
bitcoin_pgp_verify="gavinandresen@gmail.com"

##electrum variable declarations
electrum_version="1.9.6"
electrum_pgp_address="7F9470E6"
electrum_pgp_verify="thomasv1@gmx.de"

##armory full variable declarations
armory_version="0.90-beta"
armory_pgp_address="98832223"
armory_pgp_verify="alan@bitcoinarmory.com"


##if set to one this will prevent previously downloaded install files and sig files from being downloaded
##used during debugging to speed up testing
dev=0
pgp_key_server="pgp.mit.edu"
columns=75
red='\e[0;31m';
default='\e[0m';

#prints a row of stars
fancy_stars()
{
	for (( x=0; x<columns; x++))
	do
		printf "*"
	done
	printf "\n"
}
#prints a row of words while preventing word concatenation from one row to the next
fancy()
{
	local line
	local line_length=0
	for word in $1;
	do
		line_length=$((${#line} + ${#word} ));
		if (( $line_length < $columns ))
		then
			line="${line}${word} "
		else
			printf "${line}\n"
			line="$word "
		fi
	done
	if(( $((${#line})) ))
	then
		printf "${line}\n"
	fi
}
#prints a block of text sangwiched between stars, doesn't support strings with newlines
fancy_block()
{

	fancy_stars
	fancy "$1"
	fancy_stars
}
#only used with testing to prevent having to continuously download large installer files
file_exists()
{
    	local f="$1"
    	[[ -f "$f" ]] && echo "1" || echo "0"
}
process_download()
{
	local f_name="$1"
	local f_path="$2"
	local f_desc="$3"
	local overwrite="$4"
	exists=$(file_exists "$f_name")
	fancy "Downloading: ${f_name}"
	if [ "$exists" = "1" ] && [ "$overwrite" != 1 ] ;
	then
		fancy_block "You already have the $f_desc downloaded.  To replace it delete the file and run again."
	else
		wget -t 1 -O "$f_name" "$f_path"
		exists=$(file_exists "$f_name")
		if [ "$exists" = "0" ] ;
		then
			printf "${red}$f_name not dowloaded.  Check your internet connection and try again.${default}\n";
			exit
		fi
	fi
}
did_download()
{
	local f_name="$1"
	if [ $(file_exists "$f_name") = "0" ] ;
	then
		printf "$red"
		fancy_block "Failed to download ${f_name}, check your internet connection and try again."
		printf "$default"
		exit
	fi
	local f_size=$(du -b "$f_name" | cut -f 1)
	if [ "$f_size" = "0" ] ;
	then
		printf "$red"
		fancy_block "File ${f_name} is empty, check your internet connection and try again."
		printf "$default"
		exit
	fi
}
get_author_pgp_key()
{
	fancy_block "Retrieving author's pgp key"
	local pgp_address="$1"
	local pgp_server="$2"
	gpg --keyserver "$pgp_server" --recv-keys "$pgp_address"
}
validate_file()
{
	local sig_file="$1"
	local package="$2"
	fancy_block "pgp validation: ${sig_file}"
	printf "gpg --verify ${sig_file}\n"
	local response=$(gpg --verify "$sig_file" 2>&1)
	printf "${response} \n"
	local response=$(echo "${response}" | grep "Good signature from")
	if [ "$response" = "" ] ;
	then
		printf "${red}SECURITY ALERT!!\n";
		printf "${package} pgp signature verification failed, installation can't proceed.\n";
		printf "This could be caused by a corrupt download, or an unlikely man in the middle attack, your installation files should not be trusted.${default}\n";
		exit;
	fi
}
validate_file_dpkg()
{
	local file="$1"
	local package="$2"
	fancy_block "dpkg-sig validation: ${file}"
	printf "dpkg-sig --verify ${file}\n"
	local response=$(dpkg-sig --verify "$file" 2>&1)
	printf "${response} \n"
	local response=$(echo "${response}" | grep "GOODSIG")
	if [ "$response" = "" ] ;
	then
		printf "${red}SECURITY ALERT!!\n";
		printf "${package} dpkg-sig signature verification failed, installation can't proceed.\n";
		printf "This could be caused by a corrupt download, or an unlikely man in the middle attack, your installation files should not be trusted.${default}\n";
		exit;
	fi
}

os_version=$(uname -a)
if [[ "$os_version"  = *x86_64* ]] ;
then
	os_version="64"
else
	os_version="32"
fi
if [ "$1" != "" ] ;
then
	if [ ${1,,} == "multibit" ] ;
	then
		if [[ $(file_exists "/usr/local/MultiBit-${multibit_version}/multibit-exe.jar") == "1" ]]
		then
			java -jar /usr/local/MultiBit-${multibit_version}/multibit-exe.jar
		else
			fancy "Multibit not found.  Have you installed it?  Did you install it to the default path?"
		fi
		exit
	fi
	if [ ${1,,} == "bitcoin-qt" ] ;
	then
		if [[ $(file_exists "./bitcoin-${bitcoin_version}-linux/bin/${os_version}/bitcoin-qt") == "1" ]]
		then
			./bitcoin-${bitcoin_version}-linux/bin/${os_version}/bitcoin-qt
		else
			fancy "Bitcoin-Qt not found.  Have you installed it?  Did you install it to the default path?"
		fi
		exit
	fi
	if [ ${1,,} == "armory" ] ;
	then
		if [[ $(file_exists "/usr/lib/armory/ArmoryQt.py") == "1" ]]
		then
			python /usr/lib/armory/ArmoryQt.py
		else
			fancy "ArmoryQt.py not found.  Have you installed it?"
		fi
		exit
	fi

	fancy_stars
	fancy "To install TrueCrypt, Multibit, Bitcoin-qt, Electrum or Armory run the following:"
	fancy "\tsudo ./btcLiveTools.sh"
	fancy "To open TrueCrypt run the following:"
	fancy "\ttruecrypt"
	fancy "To open Multibit run the following:"
	fancy "\tsudo ./btcLiveTools.sh multibit"
	fancy "To open Bitcoin-qt with default settings run the following:"
	fancy "\tsudo ./btcLiveTools.sh bitcoin-qt"
	fancy "You can run Electrum from the applications menu or by executing the following:"
	fancy "\telectrum"
	fancy "You can run Armory from the applications menu or by executing the following:"
	fancy "\tsudo ./btcLiveTools.sh armory"
	fancy_stars
	exit
fi
if [ $(whoami) != "root" ] ;
then
	printf "$red"
	fancy_stars
	fancy "You must run as sudo to install packages!  Try again using this:"
	fancy "\tsudo ./btcLiveTools.sh"
	fancy_stars
	printf "$default"
	exit
fi
fancy_block "Multibit is a simple to use open source bitcoint client that doesn't require the bitcoin blockchain data.  It typically takes around 60 seconds to synch with the bitcoin network."

read -p "Install Multibit wallet? (y/n)"
printf "${default}"
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] ;
then
	fancy_block "Installing dependency: openjdk-7-jre"
	apt-get install openjdk-7-jre
	file_name="multibit-${multibit_version}-linux.jar"
	file_url="https://www.multibit.org/releases/multibit-${multibit_version}/multibit-${multibit_version}-linux.jar"
	file_desc="Multibit ${multibit_version} installer"
	fancy_block "Downloading Multibit installer, signature file and public key"
	process_download "$file_name" "$file_url" "$file_desc" $dev
	file_name="multibit-${multibit_version}-linux.jar.asc"
	file_url="https://www.multibit.org/releases/multibit-${multibit_version}/multibit-${multibit_version}-linux.jar.asc"
	file_desc="Multibit installer signature file"
	process_download "$file_name" "$file_url" "$file_desc" $dev
	get_author_pgp_key "$multibit_pgp_address" "$pgp_key_server"
	validate_file "$file_name" "$file_desc"
	fancy_block "All Multibit files have been downloaded and validated using the author's public pgp key found at pgp.mit.edu.  The Multibit installer will be ran next, make sure and install Multibit to the default installation path, please close the multibit installer upon completion to continue running the btcLiveTools script"
	read -p "Press enter key to launch Multibit installer..."
	printf "${default}"
	java -jar multibit-"$multibit_version"-linux.jar
	fancy_stars
	fancy "Multibit has installed successfully.  You can run Multibit by executing the following command:"
	fancy "\t./btcLiveTools.sh multibit"
	fancy "Or by running"
	fancy "\tjava -jar /usr/local/MultiBit-${multibit_version}/multibit-exe.jar\n"
	fancy_stars
	read -p "press enter key to continue..."
fi

fancy_block "TrueCrypt is open source encryption software that allows you to create encrypted virtual disks."
read -p "Install TrueCrypt encryption software? (y/n)"
printf "${default}"
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] ;
then
	[[ "$os_version" == "32" ]] && i_version="86" || i_version="64"
	file_name="truecrypt-${truecrypt_version}-linux-x${i_version}.tar.gz"
	file_url="http://www.truecrypt.org/download/truecrypt-${truecrypt_version}-linux-x${i_version}.tar.gz"
	file_desc="TrueCrypt ${truecrypt_version} installer"
	fancy_block "Downloading Truecrypt installer, signature file and public key..."
	process_download "$file_name" "$file_url" "$file_desc" $dev
	sig_file_name="truecrypt-${truecrypt_version}-linux-x${i_version}.tar.gz.sig"
	sig_file_url="http://www.truecrypt.org/download/truecrypt-${truecrypt_version}-linux-x${i_version}.tar.gz.sig"
	sig_file_desc="TrueCrypt installer signature file"
	process_download "$sig_file_name" "$sig_file_url" "$sig_file_desc" $dev
	get_author_pgp_key "$truecrypt_pgp_address" "$pgp_key_server"
	validate_file "$sig_file_name" "$file_desc"
	fancy_block "All Truecrypt files have been downloaded and validated using the author's public pgp key found at pgp.mit.edu.  The Truecrypt installer will be ran next, please close the Truecrypt installer upon completion to continue running the btcLiveTools script"
	read -p "Press enter key to launch Truecrypt installer..."
	tar -xzvf "$file_name"
	./truecrypt-"$truecrypt_version"-setup-x"$i_version"
	fancy_stars
	fancy "Truecrypt has installed successfully.  You can run Truecrypt from the applications menu or you can run it from terminal using the following command:"
	fancy "\ttruecrypt"
	fancy_stars
	read -p "press enter key to continue..."
fi

fancy_block "Bitcoin-Qt is a standalone bitcoin client.  It will require a great deal of time to synchronize with the network and will require a significant amount of drive space to operate.  Bitcoin-qt also acts as a bitcoin node which increases the overall processing power of the bitcoin network.";
read -p "Install Bitcoin-qt encryption software? (y/n)"

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] ;
then
	fancy_block "Installing Bitcoin-qt dependencies: qt-devel libqt4-gui libqt4-network"
	apt-get install libqt4-gui libqt4-network
	file_url="http://downloads.sourceforge.net/project/bitcoin/Bitcoin/bitcoin-${bitcoin_version}/bitcoin-${bitcoin_version}-linux.tar.gz?r=http%3A%2F%2Fbitcoin.org%2Fen%2Fdownload&ts=1386525391&use_mirror=hivelocity"
	file_name="bitcoin-${bitcoin_version}-linux.tar.gz"
	file_desc="Bitcoin-qt installer"
	sig_file_url="http://downloads.sourceforge.net/project/bitcoin/Bitcoin/bitcoin-${bitcoin_version}/SHA256SUMS.asc?r=&ts=1386526323&use_mirror=hivelocity";
	sig_file_name="SHA256SUMS.asc"
	sig_file_desc="Bitcoin-qt signature file"
	fancy_block "Downloading Bitcoin-qt installer, signature file and public key..."
	process_download "$file_name" "$file_url" "$file_desc" $dev
	did_download "$file_name"
	process_download "$sig_file_name" "$sig_file_url" "$sig_file_desc" $dev
	did_download "$sig_file_name"
	get_author_pgp_key "$bitcoin_pgp_address" "$pgp_key_server"
	#since bitcoin doesn't have signature files for it's files rather hashes we have to do some cludgy work
	valid=0
	hash=$(sha256sum "$file_name")
	while read -r line
	do
	grep_res=$(echo "${line}" | grep "$hash")
	[[ $grep_res != "" ]] && valid=1
	done < $sig_file_name
	#end the cludge
	if (( $valid != 1))
	then
		printf "${red}SECURITY ALERT!!\n";
		printf "${package} pgp signature verification failed, installation can't proceed.\n";
		printf "This could be caused by a corrupt download, or an unlikely man in the middle attack, your installation files should not be trusted.${default}\n";
		exit;
	fi
	#validate_file "$file_name".asc "$file_desc"
	tar -xzvf "$file_name" >/dev/null 2>&1
	fancy_stars
	fancy "All Bitcoin files have been downloaded and validated using the author's public pgp key."
	fancy "${green}Bitcoin-qt has installed succesfully.  You can run a default instance of Bitcoin-qt by running the following command:"
	fancy "\tsudo ./btcLiveTools.sh bitcoin-qt"
	fancy_stars
	read -p "press enter key to continue..."
fi
fancy_block "Electrum is an easy to use Bitcoin client. It protects you from losing coins in a backup mistake or computer failure, because your wallet can be recovered from a secret phrase that you can write on paper or learn by heart. There is no waiting time when you start the client, because it does not download the Bitcoin blockchain."
read -p "Install Electrum software? (y/n)"
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] ;
then
	fancy_block "Installing Electrum dependencies: python-qt4 python-setuptools";
	apt-get install python-qt4 python-setuptools
	file_url="http://download.electrum.org/Electrum-${electrum_version}.tar.gz"
	file_name="Electrum-${bitcoin_version}.tar.gz"
	file_desc="Electrum installer"
	sig_file_url="http://download.electrum.org/Electrum-${electrum_version}.tar.gz.asc";
	sig_file_name="Electrum-${bitcoin_version}.tar.gz.asc"
	sig_file_desc="Electrum signature file"
	fancy_block "Downloading Electrum installer, signature file and public key..."
	process_download "$file_name" "$file_url" "$file_desc"
	process_download "$sig_file_name" "$sig_file_url" "$sig_file_desc" $dev
	get_author_pgp_key "$electrum_pgp_address" "$pgp_key_server" $dev
	validate_file "$file_name".asc "$file_desc"
	fancy_block "All Electrum files have been downloaded and validated using the author's public pgp key.  The Electrum installer script will be ran next"
	read -p "Press enter key to run Electrum installer..."

	tar -xzvf "$file_name" >/dev/null 2>&1
	cd Electrum-"$electrum_version"
	python setup.py install
	fancy_stars
	fancy "Electrum has installed succesfully.  You can run Electrum through the applications menu or by executing the following in terminal:"
	fancy "\telectrum"
	fancy_stars
	read -p "press enter key to continue..."
fi
fancy_block "Armory is an open-source wallet-management application for the Bitcoin network."
read -p "Install Armory software? (y/n)"
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] ;
then
	fancy_block "Updating apt-get"
	apt-get update
	fancy_block "Installing Armory dependencies: libqtcore4 libqt4-dev python-qt4 python-setuptools dpkg-sig libpython2.6 python-psutil python-twisted"
	apt-get install libqtcore4 libqt4-dev python-qt4 python-setuptools dpkg-sig libpython2.6 python-psutil python-twisted
	[[ "$os_version" == "32" ]] && i_version="i386" || i_version="amd64"
	file_url="https://s3.amazonaws.com/bitcoinarmory-releases/armory_${armory_version}_10.04_${i_version}.deb"
	file_name="armory_${armory_version}_10.04_${i_version}.deb"
	file_desc="Armory installer"
	fancy_block "Downloading Armory .deb installer and author's public key..."
	process_download "$file_name" "$file_url" "$file_desc" $dev
	get_author_pgp_key "$armory_pgp_address" "$pgp_key_server"
	validate_file_dpkg "$file_name" "$file_desc"
	fancy_block "All Armory files have been downloaded and validated using the author's public pgp key.  The Armory installer script will be ran next"
	read -p "Press enter key to run Armory installer..."

	dpkg -i "$file_name"
	fancy_stars
	fancy "Armory has installed succesfully.  You can run Armory through the applications menu or by executing the following in terminal:"
	fancy "\tsudo ./btcLiveTools.sh armory"
	fancy_stars
fi