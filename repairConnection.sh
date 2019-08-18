#!/bin/bash

# Script for Raspberry PI 2 
# Establishing a wire network link is not reliable in my home. 
# It turns out, the best solution is, do a reboot until it works. Other solutions did not work. 
# Simply doing a reboot if network is not available can lead to an infinity loop. 
# Therfore the state of the last tries is stored in a log file (INET_LOG). 
# When failed to many times, the script stops the reboot. 

VERS="0.19"

# If set to 1, no reboot and debug messages 
DEBUG="0"
#DEBUG="1"

# Number of retrys with reboot 
# Must be higher then 1!
NUMBER_OF_TRIES=4

INET_LOG="/home/pi/InetLog.txt"
INET_STAT="+"

## TODO: 
# output script version and name... 

# Debug echo: Generates output if DEBUG!=0 is set 
decho()
{
  if [ "$DEBUG" = '0'  ] ; then    
    return 0     
  fi
  
  echo "$1" "$2" "$3" "$4"
}

# Checks the status of internet connection and write to the logfile 
# When working, first char is + otherwise - 
CheckAndWriteInetStatus() 
{   
  INET_STAT="+"
  # 
  ping -c 1 www.google.de 
  if [ $? -ne 0 ]; then
    echo "Network is not working"
    INET_STAT="-"
  fi

  echo "$INET_STAT"   $(date)   "$VERS" >> "$INET_LOG"
}
# Disable / Enable Lan. Did not fix the issue 
retryGetLanIP ()
{
  ifconfig eth0 down
  sleep 40 
  ifconfig eth0 up 
  sleep 3 
  ping -c 1 www.google.de 
}

# Reads the line $p1 count from end of file 
# @return prints the proper line
# @para $p1 line number to read. Last line is index 1
GetLineFromBack()
{
  # echo "GetLineFromBack"  $1
  tail -n "$1" "$INET_LOG" | head -n 1
}

# @para p1 need to be the sign!
# @return 0: no error, 1: not ok
DoTheBusiness()
{
  # extract from line the first sign
  # echo "sign: $1"

  # check if it is + or -
  if [ $1 = '+' ]
  then
    echo "we have +"
      if [ "$DEBUG" = '1'  ]
        then
        # all fine 
        decho "DEBUG no reboot"
        # We tell we can stop the script         
        return 0 
        
      fi
    # Fail! 
    return 1 
  else
    echo "Fail: wo do not have +"
  fi

  return 1 
}

# Reads number $1 line and do the analysis 
# Starts DoTheBusiness to do the action 
# @para p1 read line number $1 from the back 
# @return 0: no error, 1: not ok
ReadLogLineAndReportStatus()
{
  echo "ReadLogLineAndReportStatus: Processing line $1"
  LINE=$(GetLineFromBack $1)
  
  DoTheBusiness $LINE
  return $?
}

# the main()
DoIt()
{
  echo "DoIt..."

  sleep 45 
  CheckAndWriteInetStatus

  # so if we have inet all good we exit here 
  if [ $INET_STAT =  '+' ]; then
    echo "all is good - Goodbye "

    exit 0 
  fi

  # so we check line for line, 
  # wo just wrote the status. Because we are herer, things went wrong 
  # When we will find a plus in the line 
  # this tells us a new attempt is worth a try 
  # If there are only minus, we tried to many times 
  # and we prevent from an infinity loop  
  for i in $(seq 2 "$NUMBER_OF_TRIES"); do 
  
    ReadLogLineAndReportStatus $i
    if [ $? -eq 0 ]; then 
      # connection is working well 
      decho "alll right...."
  
      exit 0 
      
    else
      if [ "$DEBUG" = '1'  ]; then
        decho "Debug: No reboot!"
      else 
        echo "Reboot initialized from script: repairConnection.sh"
        
        ###########
        # We do not have a +
        # So we do reboot 
        sudo reboot 
        ###########
      fi 
    fi 
  done 

  echo "to many retries, stopping..."
}

###############################################
# force to 10mbit, it is more reliable  
sudo ethtool -s eth0 speed 10 duplex full
sleep 1
###############################################

DoIt & 


