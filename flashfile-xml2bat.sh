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
* Welcome to Motorola servicefile.xml to batch converter for Linux
------------------------------------------------------------------------------
BANNER

# Create servicefile.bat
echo "echo off" > servicefile.bat

# Add fastboot commands to servicefile.bat
echo "fastboot getvar max-sparse-size" >> servicefile.bat
echo "fastboot oem fb_mode_set" >> servicefile.bat

# Extract data from servicefile.xml using grep
grep '<filename>' servicefile.xml | awk '{print "fastboot flashall " $4 " " $6 " " $8}' >> servicefile.bat
grep '<erase>' servicefile.xml | awk '{print "fastboot erase " $2 " " $4}' >> servicefile.bat
grep '<mbn>' servicefile.xml | awk '{print "fastboot flash modem " $4 " " $6 " " $8}' >> servicefile.bat
grep '<BTFM>' servicefile.xml | awk '{print "fastboot flash boot " $4 " " $6 " " $8}' >> servicefile.bat

# Add additional commands to servicefile.bat
echo "fastboot oem fb_mode_clear" >> servicefile.bat
echo "echo -------------------------------------------------------------------------" >> servicefile.bat
echo "echo Please scroll up and check your flash for any errors" >> servicefile.bat
echo "echo -------------------------------------------------------------------------" >> servicefile.bat
echo "pause" >> servicefile.bat
echo "fastboot reboot" >> servicefile.bat
echo "exit" >> servicefile.bat

# Informative messages
echo "* The Servicefile.xml has been converted to a Servicefile.bat"
echo "* Press any key to exit and then double-click the servicefile.bat"
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
