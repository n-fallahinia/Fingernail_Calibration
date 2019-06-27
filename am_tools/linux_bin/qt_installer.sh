#!/bin/bash
# a simple bash file to install libqt3-mt_3 

echo
echo "=== Checking for required libs ==="
echo
lib=$(ldd am_build_aam | grep "not found")
if [[ "$lib" == "" ]]; then
	echo "all libraries are already installed!!"
else
	qt_lib=`echo $lib | cut -d '=' -f1`	
	if [[ "$qt_lib" == "libqt-mt.so.3 " ]]; then
		echo "insatlling qt..."
		apt-get -f install -y
		dpkg -i libqt3-mt_3.3.8-b-8ubuntu3_i386.deb
	else
		echo -e "qt library is already installed!!"
		echo -e "\tOther libraries might not be installed!!"
		echo
		echo -e '\t'$lib
	fi
fi


