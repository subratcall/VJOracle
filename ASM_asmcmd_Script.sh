################################################################################################
### Script Name:  asmcmd_script.sh                                                                                     ###   
################################################################################################
###  The next script generates additional ASM metadata information thru the ASMCMD interface ###
################################################################################################
###  Author: Esteban D. Bernal                                                               ###
################################################################################################
###  Property: Oracle Corporation                                                            ###
################################################################################################


echo "ASMCMD commands to gather complementary metadata information:"    > /tmp/asmcmd_script.out                2> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p ls -ls        >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsattr        >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsct  >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsdg  >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsdsk >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsof  >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsod  >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p iostat        >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p dsget >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p lsop  >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p spget >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p  lstmpl       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p   lsusr       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p  lsgrp        >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p   lspwusr     >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
asmcmd -p   volinfo -a  >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "=================================="       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
echo "                                  "       >> /tmp/asmcmd_script.out               2>> /tmp/asmcmd_script.out
##############################################################################################################

