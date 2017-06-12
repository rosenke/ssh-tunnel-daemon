#!/bin/bash

# Purpose:	open ssh tunnel and check it
# Usage:	ssh-tunnel-daemon.bash
# Example:	ssh-tunnel-daemon.bash
# Responsible:	Stephan Rosenke <r01-571@r0s.de>
# License:	CC BY-SA 4.0
# Version:	2016-08-12
# Based on:	n/a

################################################################################
# set some user serviceable vars                                               #
################################################################################
# ssh options
# ssh_options needs at least one option, e.g. "-q"
ssh_options="-q"
ssh_target_host="CHANGEME"
ssh_user="CHANGEME"

# tunnel options
tunnel_source_port="10001"
tunnel_target_host="localhost"
tunnel_target_port="25"

# seconds to wait for next loop
wait=10

################################################################################
################################################################################
######################### DON'T MESS BEHIND THIS LINE ##########################
################################################################################
################################################################################

################################################################################
# set some non-user serviceable vars                                           #
################################################################################

file_lock="./$(basename ${0}).lock"
ssh_pid=FALSE

# unset LANG if you parse stdout-put of your commands for preventing problems
# with unanticipated languages
unset LANG

################################################################################
# define some functions                                                        #
################################################################################
#n/a

################################################################################
################################################################################
##################################### Main #####################################
################################################################################
################################################################################

# stop if ssh-tunnel-daemon.bash already runs
if [ -f "${file_lock}" ] &&  pgrep --pidfile "${file_lock}" >/dev/null ; then
 echo "${file_lock} already exists and $(basename ${0}) is still running ... exiting ..."
 exit 1
fi

# main program loop
while true ; do
 # check if PID from lock file exists
 if [ "${ssh_pid}" != "FALSE" ] && [ -f "${file_lock}" ] && ! pgrep --pidfile "${file_lock}" >/dev/null ; then
  ssh_pid=FALSE
 fi

 # clean up
 if [ "${ssh_pid}" = "FALSE" ] && [ -f "${file_lock}" ] ; then
  rm "${file_lock}"
 fi

 # start ssh tunnel
 if [ "${ssh_pid}" = "FALSE" ] ; then
  # start ssh tunnel
  ssh -N -T "${ssh_options}" \
   -L "${tunnel_source_port}":"${tunnel_target_host}":"${tunnel_target_port}" \
   "${ssh_user}"@"${ssh_target_host}" &

  # get ssh tunnel pid and write it to lock file
  ssh_pid=$!
  echo "${ssh_pid}" >"${file_lock}"
 fi

 # wait for next round
 sleep "${wait}"
done

#cleanup
# n/a

################################################################################
##################################### EOF ######################################
################################################################################
