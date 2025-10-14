#!/usr/bin/env bash

# Display banner
cat << BANNER
"**""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   ___  ____  ____  _____  ____  ___  ____ ____  __  ________  _  _ 
"   / _ \/ _  \/ _  \/_   \/_  / / / \/ / //_/\ \/ / / __/ _  \/ \/ \ 
"  / , _/ |_| / |_| / / / / // / /_/ /  / <  \ /_/ /_/ |_| / ,  , \ 
" /_/|_|\____/\____/ /_/ \___/\____/_/\_/_/\_/  /_/_/___/\____/_/ \/ \_\ "
"                                                                      
"**""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

------------------------------------------------------------------------------
* Welcome to Motorola flashfile.xml to batch converter for Linux
------------------------------------------------------------------------------
BANNER

# Create flashfile.bat
echo "echo off" > flashfile.bat

# Add fastboot commands to flashfile.bat
echo "fastboot getvar max-sparse-size" >> flashfile.bat
echo "fastboot oem fb_mode_set" >> flashfile.bat

# Extract data from flashfile.xml using grep
grep '<filename>' flashfile.xml | awk '{print "fastboot flashall " $4 " " $6 " " $8}' >> flashfile.bat
grep '<erase>' flashfile.xml | awk '{print "fastboot erase " $2 " " $4}' >> flashfile.bat
grep '<mbn>' flashfile.xml | awk '{print "fastboot flash modem " $4 " " $6 " " $8}' >> flashfile.bat
grep '<BTFM>' flashfile.xml | awk '{print "fastboot flash boot " $4 " " $6 " " $8}' >> flashfile.bat

# Add additional commands to flashfile.bat
echo "fastboot oem fb_mode_clear" >> flashfile.bat
echo "echo -------------------------------------------------------------------------" >> flashfile.bat
echo "echo Please scroll up and check your flash for any errors" >> flashfile.bat
echo "echo -------------------------------------------------------------------------" >> flashfile.bat
echo "pause" >> flashfile.bat
echo "fastboot reboot" >> flashfile.bat
echo "exit" >> flashfile.bat

# Informative messages
echo "* The flashfile.xml has been converted to a flashfile.bat"
echo "* Press any key to exit and then double-click the flashfile.bat"
echo "* to start your firmware restore on your Motorola device."
echo "* Make sure your device is in fastboot mode first before you start"

# Cleanup temporary files (if needed)
# Since grep doesn't create separate files, this section might not be necessary. 
# Uncomment the following lines if you encounter issues.
# rm BTFM.txt
# rm mbn.txt
# rm erase.txt
# rm filename.txt

exit 0
