btcLiveTools
=============

btcLiveTools is a bash script that makes setting up a Debian Live CD environment for bitcoin use very quick and simple.   It carries out the following tasks when installing your preferred bitcoin software:

1.  Downloads the installation files from the software author.
2.  Downloads the installation file signature files or hash files from the author.
3.  Imports the author's public pgp key from pgp.mit.edu.
4.  Validates that the downloaded files are genuine using the author's public key.  If the validation fails the script fails with an error message.
5.  The dependencies, if there are any, are downloaded using the default Debian repositories using apt.
6.  The software installer for the software chosen will be ran.

Currently btcLiveTools provides the option to install the following software:

*  [MultiBit](https://multibit.org/)
*  [Bitcoin-Qt](http://bitcoin.org/en/download)
*  [Electrum](https://electrum.org/)
*  [Armory](https://bitcoinarmory.com/)
*  [Truecrypt Encryption software](http://www.truecrypt.org/)


Prerequisites
---------------
**A Debian CD or usb running the following:**

* [Debian Live 7.2 i386 (Most machines will run this)](http://live.debian.net/cdimage/release/stable+nonfree/i386/iso-hybrid/)

**OR for 64-bit processors:**

*  [Debian Live 7.2 amd64 (Most intel 64-bit processors will work with this regardless of the "amd")](http://live.debian.net/cdimage/release/stable+nonfree/amd64/iso-hybrid/)


btcLiveTools has been tested using [Debian Live 7.2 amd64 Gnome](http://live.debian.net/cdimage/release/stable+nonfree/amd64/iso-hybrid/debian-live-7.2-amd64-gnome-desktop+nonfree.iso) and [Debian Live 7.2 i386 Xfce](http://live.debian.net/cdimage/release/stable+nonfree/i386/iso-hybrid/debian-live-7.2-i386-xfce-desktop+nonfree.iso) however it should run fine on any Debian 7.2 live cd regardless of the desktop environment.

Installing btcLiveTools
------------------------
Move the file btcLiveTools.sh to the directory of your choice and then run the following from terminal:

        sudo chmod 777 btcLiveTools.sh

Running btcLiveTools
----------------------
From the same directory as btcLiveTools.sh run the following:

        sudo ./btcLiveTools.sh
You will then be prompted for the tools you would like to install.  

![Screenshot](https://bitmagi.com/btcLiveTools.png "Screenshot")

Help
-----
You can get a list of optional command line arguments by running the following:

        sudo ./btcLiveTools.sh help

![Screenshot](https://bitmagi.com/btcLiveTools2.png "Screenshot")        

**Debian screensaver lock you out?**  The password is "live"

**Errors?**   Are you running btcLiveTools from a Debian Live 7.2 cd, usb or VM?



Current Limitations
--------------------
Depends on Debian Live 7.2, otherwise you might need to modify the script to get it to work with your preferred distro.

After completing an install of one of the supported packages the script assumes everything was a success, which should be the case if using Debian 7.2, however if there was a failure the script will erroneously return a success message.

WARNING
---------
btcLiveTools only simplifies the proper installation of various software, it is still up to you to properly encrypt, backup keys/wallet files and use the software like somebody who knows what they are doing.
***
*Copyright (C) 2013, [Bitmagi.com](https://bitmagi.com)    bitmagicc@gmail.com*
*License GNU GPL v3*
*See [http://www.gnu.org/licenses/gpl.txt](http://www.gnu.org/licenses/gpl.txt)*
