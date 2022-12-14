#!/bin/sh
# export NEWT_COLORS="
# root=,red
# roottext=yellow,red"
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\x1b[5m'
clear
#Uninstall everything first
#rm -rf ~/emudeck  &>> /dev/null
rm -f scrap.sh &>> /dev/null
rm -f compress.sh &>> /dev/null
rm -f update.sh  &>> /dev/null
rm -f run_update.sh  &>> /dev/null
rm -f undo.sh  &>> /dev/null
rm -f startup.sh  &>> /dev/null
rm -f snes_config.sh  &>> /dev/null
rm -f ~/storage/shared/scrap.log  &>> /dev/null
rm -rf ~/storage &>> /dev/null

FOLDER=~/storage
if [ ! -d "$FOLDER" ]; then	
	termux-setup-storage
fi


#Creating log file
LOGFILE="$HOME/storage/shared/emudeck.log"
mv "${LOGFILE}" "$HOME/storage/shared/emudeck/emudeck.last.log" #backup last log
echo "${@}" > "${LOGFILE}" #might as well log out the parameters of the run
exec > >(tee "${LOGFILE}") 2>&1
clear
echo -e "EmuDeck for ${GREEN}Android${NONE} ${RED}BETA 0.1.5${NONE}"
echo -e  "${BOLD}You must hide the virtual keyboard to continue so you can read all the instructions${NONE}"
echo -e  "Press the ${RED}A button${NONE} when ready"
read clear
clear
echo -e  "${BOLD}Hi!${NONE} We're gonna start configuring your device"
echo -e  "${RED}Read before continuing${NONE}"
echo -e  "If you are going to store your roms in the SD Card make sure your SD Card is inserted"
echo -e  "${BOLD}This script will create all the rom folders for you in your device${NONE}"
echo -e ""
echo -e  "${BOLD}Controls${NONE}"
echo -e  "DPAD = Move around options"
echo -e  "${RED}A button${NONE} = Accept"
echo -e  "${GREEN}Y button${NONE} = Select option"
echo -e  "Press the ${RED}A button${NONE} to start"
read clear

echo "### Installing pkgs"  &>> ~/storage/shared/emudeck.log
echo -e "Installing components, please be patient, these will take several minutes..."
export DEBIAN_FRONTEND=noninteractive
apt-get update && 
	apt-get -o "Dpkg::Options::=--force-confold"  upgrade -q -y --force-yes &&
	apt-get -o "Dpkg::Options::=--force-confold"  dist-upgrade -q -y --force-yes
pkg autoclean
pkg update -y && pkg upgrade -y
pkg install git wget jq rsync unzip whiptail binutils build-essential liblz4 libuv ninja -y
echo "### Creating Emudeck Folder "  &>> ~/storage/shared/emudeck.log
mkdir -p ~/emudeck &>> ~/storage/shared/emudeck.log
cd ~/emudeck &>> ~/storage/shared/emudeck.log



echo "### Cloning the git repo"  &>> ~/storage/shared/emudeck.log
clear
echo -e "Downloading EmuDeck Android, please be patient..."
#Download Pegasus Metadata files

FOLDER=~/emudeck/backend/
if [ -d "$FOLDER" ]; then
	cd ~/emudeck/backend/ && git reset --hard && git pull
else
	git clone https://github.com/EmuDeck/EmuDeck-Android.git ~/emudeck/backend
fi

#Validate
FOLDER=~/emudeck/backend/
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}Download OK${NONE}"
	echo "### Repo cloned "  &>> ~/storage/shared/emudeck.log
else
	echo "### Termux Mirrors down"  &>> ~/storage/shared/emudeck.log
	echo -e "${RED}ERROR${NONE}"
	echo -e "It seems Termux repositories are down. Let's fix it"
	echo -e "When you press the ${RED}A button${NONE} selector will open. In the first screen ${BOLD}select all three options with the ${GREEN}Y button${NONE} and then Accept using the ${RED}A button${NONE}${NONE}"
	echo -e "Then in the next screen select the first option and press the ${RED}A button${NONE}"
	read pause
	termux-change-repo
	pkg update -y -F &>> ~/storage/shared/emudeck.log && pkg upgrade -y -F &>> ~/storage/shared/emudeck.log
	pkg install git wget jq rsync unzip whiptail binutils build-essential liblz4 libuv ninja -y  &>> ~/storage/shared/emudeck.log
	
	
fi

clear




echo "### Handheld selection "  &>> ~/storage/shared/emudeck.log

while true; do
	handheldModel=$(whiptail --title "What Android Device do you have" \
   --radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
	"RG552" "Anbernic RG552" OFF \
	"ODIN" "16:9 Devices like Odin or RP3" OFF \
	"RP2+" "4:3 Devices Like RP2+ and RG553" OFF \
   3>&1 1<&2 2>&3)
	case $handheldModel in
		[RG552]* ) break;;
		[ODIN]* ) break;;
		[RP2+]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
 done
echo "### HandHeld Selected : ${handheldModel} "  &>> ~/storage/shared/emudeck.log
while true; do
	#touch ~/emudeck/.device
	echo $handheldModel > ~/emudeck/.device
	echo "### Handlheld selection failed first time"  &>> ~/storage/shared/emudeck.log
	FILE=~/emudeck/.device
	if [ -f "$FILE" ]; then
		break;
	fi
	handheldModel=$(whiptail --title "What Android Device do you have" \
	   --radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
		"RG552" "Anbernic RG552" OFF \
		"ODIN" "AYN Odin" OFF \
		"RP2+" "Retroid Pocket 2+" OFF \
	   3>&1 1<&2 2>&3)
done

#cat ~/emudeck/backend/logo.ans

#Storage Selection
if (whiptail --title "Android Version" --yesno "Do you have Android 11 or newer?" 8 78); then
	echo "### Has Android 11"  &>> ~/storage/shared/emudeck.log
	clear
	if (whiptail --title "Android 11+ limitations" --yesno "Only Internal Storage is available to store your roms, if you want to use your SD Card, format it as internal. Do you want to continue? " 8 78); then		
		echo "### Continue Android 11"  &>> ~/storage/shared/emudeck.log
		storageOption == 'Internal'
	else
		echo "### Exit Android 11"  &>> ~/storage/shared/emudeck.log
		exit		
	fi
else
	while true; do
		storageOption=$(whiptail --title "Where do you want to store your roms?" \
	   --radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
		"SDCard" "The roms will be stored in your SD Card or external HD" ON \
		"Internal" "The roms will be stored in your Internal Storage " OFF \
	   3>&1 1<&2 2>&3)
		case $storageOption in
			[SDCard]* ) break;;
			[Internal]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	   
	 done
	
fi

#Detect installed emulators
/bin/bash ~/emudeck/backend/emu_check.sh


# Chose your frontend
while true; do
	frontend=$(whiptail --title "Choose your frontend" \
   --radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
	"PEGASUS" "Pegasus - Automatic configuration" OFF \
	"DAIJISHO" "Daihisho - Needs manual configuration" OFF \
	"DIG" "Dig - Needs manual configuration" OFF \
	"LAUNCHBOX" "Launchbox - Needs manual configuration" OFF \
	"RESET" "Reset Collection - Paid - Needs manual configuration" OFF \
	"ARC" "Arc Browser - Paid - Needs manual configuration" OFF \
   3>&1 1<&2 2>&3)
	case $frontend in
		[PEGASUS]* ) break;;
		[DAIJISHO]* ) break;;
		[DIG]* ) break;;
		[LAUNCHBOX]* ) break;;
		[RESET]* ) break;;
		[ARC]* ) break;;
		* ) echo "Please choose.";;
	esac
 done
echo "### Frontend Selected : ${frontend} "  &>> ~/storage/shared/emudeck.log

if [[ $frontend == 'PEGASUS' ]]; then
	echo "### Downloading Pegasus "  &>> ~/storage/shared/emudeck.log
	
	installPegasus=true
	DIR=~/storage/shared/Android/data/org.pegasus_frontend.android
	FOLDER=$(test -d "$DIR" && echo -n "true")
	case $FOLDER in
	  *"true"*)
		installPegasus=false
		;;
	esac
	
	if [[  $installPegasus == true ]]; then
		#Download Pegasus
		echo -e "Downloading Pegasus, please be patient..."
		wget   -q --show-progress https://github.com/mmatyas/pegasus-frontend/releases/download/weekly_2022w30/pegasus-fe_alpha16-42-g996720eb_android.apk -P ~/emudeck
		echo "### Pegasus downloaded"  &>> ~/storage/shared/emudeck.log
		
		echo -e  "Now let's install ${RED}Pegasus${NONE}"
		echo -e  "Press the ${RED}A button${NONE} to install Pegasus, when Pegasus is installed click ${BOLD}DONE${NONE} in the installation window so you can come back to continue the next steps"
		read pause
		clear
		echo -ne  "Installing ${RED}Pegasus${NONE}..."
		#Launch Pegasus
		xdg-open ~/emudeck/pegasus-fe_alpha16-42-g996720eb_android.apk
		echo -e  "${GREEN}OK${NONE}"
		echo ""
		echo "### Pegasus installed"  &>> ~/storage/shared/emudeck.log
		
		
		#Configure Pegasus
		echo "### Configuring Pegasus "  &>> ~/storage/shared/emudeck.log
		echo -ne "Configuring Pegasus..."
		mkdir -p ~/storage/shared/pegasus-frontend &>> ~/storage/shared/emudeck.log
		mkdir -p ~/storage/shared/pegasus-frontend/themes &>> ~/storage/shared/emudeck.log
		echo -e "${GREEN}OK${NONE}"
		echo "### Pegasus configured"  &>> ~/storage/shared/emudeck.log
	fi
fi


if [[ $frontend == 'DAIJISHO' ]]; then
	installDaihisho=true
	DIR=~/storage/shared/Android/data/com.magneticchen.daijishou
	FOLDER=$(test -d "$DIR" && echo -n "true")
	case $FOLDER in
	  *"true"*)
	  	installDaihisho=false
		;;
	esac
	if [[  $installDaihisho == true ]]; then
		echo -e  "Press the ${RED}A button${NONE} to install Daijisho, when it is installed come back to continue the next steps"
		read pause
		termux-open "https://play.google.com/store/apps/details?id=com.magneticchen.daijishou"
	fi
fi

if [[ $frontend == 'DIG' ]]; then
	installDig=true
	DIR=~/storage/shared/Android/data/com.magneticchen.daijishou
	FOLDER=$(test -d "$DIR" && echo -n "true")
	case $FOLDER in
	  *"true"*)
	  	installDig=false
		;;
	esac
	if [[  $installDig == true ]]; then
		echo -e  "Press the ${RED}A button${NONE} to install Dig, when it is installed come back to continue the next steps"
		read pause
		termux-open "https://play.google.com/store/apps/details?id=com.digdroid.alman.dig"	
	fi
fi

if [[ $frontend == 'LAUNCHBOX' ]]; then
	installLaunch=true
	DIR=~/storage/shared/Android/data/com.magneticchen.daijishou
	FOLDER=$(test -d "$DIR" && echo -n "true")
	case $FOLDER in
	  *"true"*)
	  	installLaunch=false
		;;
	esac
	if [[  $installLaunch == true ]]; then
		echo -e  "Press the ${RED}A button${NONE} to go to LaunchBox website, when it is installed come back to continue the next steps"
		read pause
		termux-open "https://www.launchbox-app.com/android-download"
	fi
fi

if [[ $frontend == 'RESET' ]]; then
	installReset=true
	DIR=~/storage/shared/Android/data/com.magneticchen.daijishou
	FOLDER=$(test -d "$DIR" && echo -n "true")
	case $FOLDER in
	  *"true"*)
	  	installReset=false
		
		;;
	esac
	if [[  $installReset == true ]]; then
		echo -e  "Press the ${RED}A button${NONE} to install Reset Collection, when it is installed come back to continue the next steps"
		read pause
		termux-open "https://play.google.com/store/apps/details?id=com.retroloungelab.resetcollection"
	fi
fi

if [[ $frontend == 'ARC' ]]; then
	installArc=true
	DIR=~/storage/shared/Android/data/com.magneticchen.daijishou
	FOLDER=$(test -d "$DIR" && echo -n "true")
	case $FOLDER in
	  *"true"*)
	  	installArc=false
		;;
	esac
	if [[  $installArc == true ]]; then
		echo -e  "Press the ${RED}A button${NONE} to install Arc Browser, when it is installed come back to continue the next steps"
		read pause
		termux-open "https://play.google.com/store/apps/details?id=net.floatingpoint.android.arcturus"
		
	fi
fi

#Backup
echo "### Creating Backups "  &>> ~/storage/shared/emudeck.log

echo -ne "Creating Backups of everything..."
cp ~/storage/shared/pegasus-frontend/settings.txt ~/storage/shared/pegasus-frontend/settings.txt.bak &>> ~/storage/shared/emudeck.log
cp ~/storage/shared/pegasus-frontend/game_dirs.txt ~/storage/shared/pegasus-frontend/game_dirs.txt.bak &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/internal/common/pegasus-frontend/settings.txt ~/storage/shared/pegasus-frontend &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/internal/common/pegasus-frontend/game_dirs.txt ~/storage/shared/pegasus-frontend &>> ~/storage/shared/emudeck.log
echo -e "${GREEN}OK${NONE}"
echo "### Backups created"  &>> ~/storage/shared/emudeck.log

echo "### Creating Symlinks "  &>> ~/storage/shared/emudeck.log
echo -ne "Installing Scrap, Update & Undo Scripts..."
cp ~/emudeck/backend/update.sh ~/update.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/update.sh &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/update.sh ~/run_update.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/run_update.sh &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/scrap.sh  ~/scrap.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/scrap.sh &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/compress.sh  ~/compress.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/compress.sh &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/undo.sh  ~/undo.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/undo.sh &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/startup.sh  ~/startup.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/startup.sh &>> ~/storage/shared/emudeck.log
cp ~/emudeck/backend/snes_config.sh  ~/snes_config.sh &>> ~/storage/shared/emudeck.log
chmod a+rwx ~/snes_config.sh &>> ~/storage/shared/emudeck.log
echo "### Symlinks created"  &>> ~/storage/shared/emudeck.log
echo -e "${GREEN}OK${NONE}"
clear
echo "### Storage selection & Android version "  &>> ~/storage/shared/emudeck.log



echo "### Storage Selected: ${storageOption}"  &>> ~/storage/shared/emudeck.log
rm ~/emudeck/.storageInternal &> /dev/null
rm ~/emudeck/.storageSD &> /dev/null
echo -ne "Storage Selected..."
if [[ $storageOption == 'Internal' ]]; then
	touch ~/emudeck/.storageInternal &> /dev/null
	storageLocation="shared/Emulation/roms"
	echo -e "${GREEN}Internal${NONE}"
	mkdir -p ~/storage/shared/Emulation/roms &> /dev/null
else
	touch ~/emudeck/.storageSD &> /dev/null
	storageLocation="external-1/Emulation/roms"
	#We get the SD Card Volume name
	sdcardID=false
	for entry in /storage/*
	 do
		 STR=$entry
		 SUB='-'
		 if grep -q "$SUB" <<< "$STR"; then
			 firstString=$entry
				 secondString=""
			  sdcardID="${firstString/"/storage/"/"$secondString"}"   
		 fi
	 done	
	 
	 #Android 11
	 if [ $sdcardID == false ]; then
	  
		  SDPath=$(readlink ~/storage/external-1)
		  firstString=$SDPath
		  secondString=""
		  sdcardID="${firstString/"/storage/"/"$secondString"}"   
	  		
	   		firstString=$sdcardID
	   		secondString=""
	   		sdcardID="${firstString/"/Android/data/com.termux/files"/"$secondString"}" 
		  
	  fi
	 mkdir -p ~/storage/external-1/Emulation/roms &> /dev/null
	
	echo -e "${GREEN}SD Card${NONE}"
fi

useInternalStorage=false
FILE=~/emudeck/.storageInternal
if [ -f "$FILE" ]; then
	useInternalStorage=true
fi

 
echo -ne "Configuring Rom Storage..."
if [ $useInternalStorage == false ]; then
	sed -i "s/0000-0000\//${sdcardID}\/Android\/data\/com.termux\/files\//g" ~/storage/shared/pegasus-frontend/game_dirs.txt &>> ~/storage/shared/emudeck.log 
else
	sed -i "s/0000-0000/emulated\/0\/roms/g" ~/storage/shared/pegasus-frontend/game_dirs.txt &>> ~/storage/shared/emudeck.log 
fi

echo "### Creating roms folders "  &>> ~/storage/shared/emudeck.log
# Instaling roms folders
rsync -r ~/emudeck/backend/roms/ ~/storage/$storageLocation &>> ~/storage/shared/emudeck.log
echo "### Rom folders created"  &>> ~/storage/shared/emudeck.log

#Retroarch 64? We edit the metadatafiles
echo "### RA64 detection "  &>> ~/storage/shared/emudeck.log

hasRetroArch64=false
FOLDER64=~/storage/shared/Android/data/com.retroarch.aarch64
if [ -d "$FOLDER64" ]; then
	hasRetroArch64=true
fi
if [[ $hasRetroArch64 == true ]]; then
	find ~/storage/$storageLocation/ -type f -name "*.txt" -exec sed -i -e 's/com.retroarch\//com.retroarch.aarch64\//g' {} \;
	find ~/storage/$storageLocation/ -type f -name "*.txt" -exec sed -i -e 's/-e DATADIR \/data\/data\/com.retroarch/-e DATADIR \/data\/data\/com.retroarch.aarch64/g' {} \;	
	find ~/storage/$storageLocation/ -type f -name "*.txt" -exec sed -i -e 's/.browser.retroactivity/com.retroarch.browser.retroactivity/g' {} \;	
	find ~/storage/$storageLocation/ -type f -name "*.txt" -exec sed -i -e 's/com.retroarch-1/com.retroarch.aarch64-1/g' {} \;	
fi
echo -e "${GREEN}OK${NONE}"
echo "### RetroArch64 sed done"  &>> ~/storage/shared/emudeck.log

# PPSSPP Gold? We need to edit the metadata file
hasPPSSPPGold=false
PPSSPPGold=~/storage/shared/Android/data/org.ppsspp.ppssppgold
if [ -d "$PPSSPPGold" ]; then
	hasPPSSPPGold=true
fi
if [[ $hasPPSSPPGold == true ]]; then
	find ~/storage/$storageLocation/ -type f -name "*.txt" -exec sed -i -e 's/org.ppsspp.ppsspp\/.PpssppActivity/org.ppsspp.ppssppgold\/org.ppsspp.ppsspp.PpssppActivity/g' {} \;
fi
echo -e "${GREEN}OK${NONE}"
echo "### PPSSPP Gold sed done"  &>> ~/storage/shared/emudeck.log

#Configure Retroarch
echo "### RA Backup "  &>> ~/storage/shared/emudeck.log
echo -ne "Creating RetroArch Backup..."
#We create the backup only if we don't have one, to prevent erasing the original backup if the user reinstalls
FOLDER=~/storage/shared/RetroArch/config_bak/
if [ -d "$FOLDER" ]; then
	echo -e "${GREEN}OK${NONE}"
else
	cp -r ~/storage/shared/RetroArch/config/ ~/storage/shared/RetroArch/config_bak/ &>> ~/storage/shared/emudeck.log
	if [[ $hasRetroArch64 == false ]]; then
		cp ~/storage/shared/Android/data/com.retroarch/files/retroarch.cfg ~/storage/shared/Android/data/com.retroarch/files/retroarch.bak.cfg &>> ~/storage/shared/emudeck.log
	fi
	if [[ $hasRetroArch64 == true ]]; then
		cp ~/storage/shared/Android/data/com.retroarch.aarch64/files/retroarch.cfg ~/storage/shared/Android/data/com.retroarch.aarch64/files/retroarch.bak.cfg &>> ~/storage/shared/emudeck.log
	fi
	echo -e "${GREEN}OK${NONE}"
fi
echo "### RetroArch backup done"  &>> ~/storage/shared/emudeck.log
echo -ne "Configuring Retroarch..."

#RetroArch Configs
/bin/bash ~/emudeck/backend/retroarch_config.sh $handheldModel
/bin/bash ~/emudeck/backend/emus_config.sh

clear

if [[ $frontend == 'PEGASUS' ]]; then
	
	echo "### Downloading themes "  &>> ~/storage/shared/emudeck.log
	# Install Themes for Pegasus
	echo -ne "Downloading Pegasus Theme : RP Epic Noir..."
	git clone https://github.com/dragoonDorise/RP-epic-noir.git ~/emudeck/themes/RP-epic-noir &>> ~/storage/shared/emudeck.log
	echo -e "${GREEN}OK${NONE}"
	
	echo -ne "Downloading Pegasus Theme : RP Switch..."
	#We delete the theme, for previous users
	rm -rf ~/storage/shared/pegasus-frontend/themes/RP-switch &>> ~/storage/shared/emudeck.log
	git clone https://github.com/dragoonDorise/RP-switch.git ~/emudeck/themes/RP-switch &>> ~/storage/shared/emudeck.log
	
	echo -e "${GREEN}OK${NONE}"
		echo -ne "Downloading Pegasus Theme : Retro Mega..."
	git clone https://github.com/plaidman/retromega-next.git ~/emudeck/themes/retromega &>> ~/storage/shared/emudeck.log
	echo -e "${GREEN}OK${NONE}"
	
	if [ $handheldModel != 'RP2+' ]; then
	
		echo -ne "Downloading Pegasus Theme : GameOS..."
		git clone https://github.com/PlayingKarrde/gameOS.git ~/emudeck/themes/gameOS &>> ~/storage/shared/emudeck.log
		echo -e "${GREEN}OK${NONE}"
	
		echo -ne "Downloading Pegasus Theme : ClearOS..."
		git clone https://github.com/PlayingKarrde/clearOS.git ~/emudeck/themes/clearOS &>> ~/storage/shared/emudeck.log
		echo -e "${GREEN}OK${NONE}"
		
		echo -ne "Downloading Pegasus Theme : NeoRetro Dark..."
		git clone https://github.com/TigraTT-Driver/neoretro-dark.git ~/emudeck/themes/neoretro-dark &>> ~/storage/shared/emudeck.log
		echo -e "${GREEN}OK${NONE}"
		echo "### Themes installed"  &>> ~/storage/shared/emudeck.log
		
	fi
		
	
		echo -e "The default theme on Pegasus is RP Epic Noir"
		echo -e "You can change it anytime on Pegasus."
		echo -e  "Press the ${RED}A button${NONE} to continue to next step"
		read pause
	
	echo "### Rsync the dl themes "  &>> ~/storage/shared/emudeck.log
	rsync -r ~/emudeck/themes/ ~/storage/shared/pegasus-frontend/themes/ &>> ~/storage/shared/emudeck.log

fi

echo "/bin/bash ~/startup.sh" > ~/.bashrc
echo "### Startup created"  &>> ~/storage/shared/emudeck.log
sleep .5
clear
echo -e ""
echo -e ""
echo -e  "${GREEN}Success!!${NONE}"
echo -e ""
echo -e  "We've finished the first step!"
echo -e  ""
if [ $useInternalStorage == false ]; then
	echo -e  "You can now remove your SD Card and start copying your roms"
	echo -e  "Insert your SD Card in your computer and go to this folder in your SD Card: ${GREEN}/Android/data/com.termux/files/Emulation/roms${NONE}"
	if [[ $frontend == 'PEGASUS' ]]; then
		echo -e  "If you want to use Pegasus you need to keep your roms there so we can scrap your artwork"
	else	
		echo -e  "You can configure your Frontend to point to that directory"

	fi
	echo -e  "You will see that every system has its own folder, just copy your roms to the corresponding folder."
else
	echo -e  "You can now copy your roms in the ${BOLD}Emulation/roms${NONE} directory in the Internal Storage of your device"
	echo -e  "You will see that every system has its own folder, just copy your roms to the corresponding folder."
fi
echo -e  "${BOLD}We recommend roms named after no-intro romsets${NONE}"
echo -e ""

echo -e  "Press the ${RED}A button${NONE} to continue to next step"
read pause
clear

echo -e "${YELLOW}Retroarch Cores${NONE}"
echo -e "Remember to go to Retroarch's Main Menu -> Load Core -> Install or Restore a Core"
echo -e "And then select the core you want to install"
echo -e ""
echo -e "${YELLOW}BIOS${NONE}"
echo -e "Remember to copy your BIOS files for the following emulators:"
echo -e "RetroArch - internal storage/RetroArch/system folder"
echo -e "Duckstation & AetherSX2 on App Settings, BIOS section"
echo -e ""
echo -e "${RED}IMPORTANT${NONE}"
echo -e "Be aware that if you delete the Termux app Android will ${RED}DELETE${NONE} the Termux folder on your SD Card"
echo -e "The roms on ${GREEN}/Android/data/com.termux/files/${NONE} will be deleted"
echo -e "No other files on the SD Card will be affected"
echo -e "If you have ${RED}Android > 10${NONE} you need to manually apply RetroArch configuration"
echo -e "Go to Retroarch - > Main Menu -> Configuration File -> Load Configuration"
echo -e "and select ${BOLD}custom-retroarch.cfg${NONE} on /storage/emulated/0/RetroArch/config"
echo -e  "Press the ${RED}A button${NONE} to continue to next step"
read pause
echo "### Installation Finished"  &>> ~/storage/shared/emudeck.log

#Compressor section (compress before scraping)
while true; do
	compressNow=$(whiptail --title "Do you want to compress your ISOs now?" \
   --radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
	"YES" "Compress my roms!" OFF \
	"NO" "You can always do the compressing later by opening Termux" OFF \
   3>&1 1<&2 2>&3)
	case $compressNow in
		[YES]* ) break;;
		[NO]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac

 done

if [ $compressNow == "YES" ]; then
	clear
	echo -e  "";
	echo -e  "Do you have your roms ready on your SD Card or Internal Storage?"
	echo -e  "${BOLD}Let's start compressing them!${NONE}"
	echo -e  "Press the ${RED}A button${NONE} to continue"
	read pause
	cd ~/
	bash ~/compress.sh
fi

if [[ $frontend == 'PEGASUS' ]]; then
	while true; do
		scrapNow=$(whiptail --title "Do you want to scrape your roms now?" \
   	--radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
		"YES" "Scrape my roms!" OFF \
		"NO" "You can always do the scraping later by opening Termux" OFF \
   	3>&1 1<&2 2>&3)
		case $scrapNow in
			[YES]* ) break;;
			[NO]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	
 	done
	
	if [ $scrapNow == "YES" ]; then
		clear
		echo -e  "";
		echo -e  "Do you have your roms ready on your SD Card or Internal Storage?"
		echo -e  "${BOLD}Let's start getting all your artwork!${NONE}"
		echo -e  "Press the ${RED}A button${NONE} to continue"
		read pause
		cd ~/
		bash ~/scrap.sh	
	else
		clear	
		echo -e  "${STRONG}If you want to compress or scrape more roms, update or uninstall EmuDeck:${NONE}"
		echo -e  "Just open the Termux app again"
		echo -e  "Press the ${RED}A button${NONE} to exit"
		read pause
		am startservice -a com.termux.service_stop com.termux/.app.TermuxService &> /dev/null
	
	fi
fi
