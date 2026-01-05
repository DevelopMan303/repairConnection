#!/bin/bash

# Script for Raspberry PI 2 
# Establishing a wire network link is not reliable in my home. 
# Reboot untill it is working is not required anymore. 
# Just eth port needs to be disabled/enabled.  

readonly VERS="0.20"

# If set to 1, no reboot and debug messages 
#DEBUG="0"
DEBUG="1"

# Number of retrys with reboot 
# Must be higher then 1!
NUMBER_OF_TRIES=4

#Ethernet port to use (the primary)
ETH=$(ls /sys/class/net | head -n 1)

# Debug echo: Generates output if DEBUG!=0 is set 
decho()
{
  if [ "$DEBUG" = '0'  ] ; then    
    return 0     
  fi
  
  echo "$1" "$2" "$3" "$4"
}

# Disable / Enable Lan. Did not fix the issue 
retryGetLanIP ()
{
  local SITE="www.google.de"

  if ping -I "$ETH" -c 1 "$SITE";  then
    echo "OK: PING "
    return 0
  fi 

  ifconfig "$ETH" down
  sleep 40 
  ifconfig "$ETH" up 
  sleep 3 

  if ping -I "$ETH" -c 1 "$SITE";  then
    echo "OK: PING "
    return 0
  else 
    echo "PING fail"
    return 1
  fi   
}


# the main()
DoIt()
{
  echo "DoIt..."

  for i in $(seq 2 "$NUMBER_OF_TRIES"); do 
    if retryGetLanIP ; then 
      echo "OK: Connection working"
      exit 0
    fi 
      echo "Fail: Connection NOT working)"
  done 

  echo "to many retries, stopping..."
  
  exit 3 
}

###############################################
# force to 10mbit, it is more reliable  
#sudo ethtool -s "$ETH" speed 10 duplex full
sleep 1
###############################################

echo "Repair Connection - Working at ETH: " "$ETH" "Version: " "$VERS"

DoIt 


