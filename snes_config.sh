#!/bin/sh

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

handheldModel=$(cat ~/emudeck/.device)
snesMode="CLASSIC"
snesConfigured="false"
FILE=~/emudeck/.snes87
if [ -f "$FILE" ]; then
	snesMode="INTERNAL"
	snesConfigured="true"
fi
FILE=~/emudeck/.snes43
if [ -f "$FILE" ]; then
	snesMode="CLASSIC"
	snesConfigured="true"
fi
echo "### SNES AR Selection "  &>> ~/storage/shared/emudeck.log

while true; do
	snesMode=$(whiptail --title "Please choose your Super Nintendo Aspect Ratio" \
   --radiolist "Move using your DPAD and select your options with the Y button. Press the A button to select." 10 80 4 \
	"CLASSIC" "4:3 Aspect Ratio (Classic TV Resolution)" ON \
	"INTERNAL" "8:7 Aspect Ratio (Real internal Resolution)" OFF \
   3>&1 1<&2 2>&3)
	case $snesMode in
		[CLASSIC]* ) break;;
		[INTERNAL]* ) break;;
		* ) echo "Please choose";;
	esac
   
 done

if [[ $handheldModel == "RG552" ]]; then
	echo "### SNES RG552 "  &>> ~/storage/shared/emudeck.log
	
	if [[ $snesMode == "CLASSIC" ]]; then
		rm ~/emudeck/.snes43 &>> ~/storage/shared/emudeck.log
		rm ~/emudeck/.snes87 &>> ~/storage/shared/emudeck.log
		touch ~/emudeck/.snes43 &>> ~/storage/shared/emudeck.log
	cp -r ~/emudeck/backend/internal/rg552/RetroArch/config/Snes9x/snes.cfg ~/storage/shared/RetroArch/config/Snes9x/snes.cfg &>> ~/storage/shared/emudeck.log	
		
	else
		rm ~/emudeck/.snes43 &>> ~/storage/shared/emudeck.log
		rm ~/emudeck/.snes87 &>> ~/storage/shared/emudeck.log
		touch ~/emudeck/.snes87 &>> ~/storage/shared/emudeck.log
		cp -r ~/emudeck/backend/internal/rg552/RetroArch/config/Snes9x/snes87.cfg ~/storage/shared/RetroArch/config/Snes9x/snes.cfg &>> ~/storage/shared/emudeck.log	
	fi
else
	if [[ $snesMode == "CLASSIC" ]]; then
		rm ~/emudeck/.snes43 &>> ~/storage/shared/emudeck.log
		rm ~/emudeck/.snes87 &>> ~/storage/shared/emudeck.log
		touch ~/emudeck/.snes43 &>> ~/storage/shared/emudeck.log
		cp -r ~/emudeck/backend/internal/common/RetroArch/config/Snes9x/snes.cfg ~/storage/shared/RetroArch/config/Snes9x/snes.cfg &>> ~/storage/shared/emudeck.log	
		
	else
		rm ~/emudeck/.snes43 &>> ~/storage/shared/emudeck.log
		rm ~/emudeck/.snes87 &>> ~/storage/shared/emudeck.log
		touch ~/emudeck/.snes87 &>> ~/storage/shared/emudeck.log
		cp -r ~/emudeck/backend/internal/common/RetroArch/config/Snes9x/snes87.cfg ~/storage/shared/RetroArch/config/Snes9x/snes.cfg &>> ~/storage/shared/emudeck.log	
	fi

fi

clear
echo ""
echo -ne  "Snes configuration..."
echo -e  "${GREEN}OK${NONE}"
