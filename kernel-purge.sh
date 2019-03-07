#!/bin/bash

# @see http://ubuntugenius.wordpress.com/2011/01/08/ubuntu-cleanup-how-to-remove-all-unused-linux-kernel-headers-images-and-modules/
# Originally from kivisade/kernel-purge

current_kernel="$(uname -r | sed 's/\(.*\)-\([^0-9]\+\)/\1/')"
current_ver=${current_kernel/%-generic}

#Display the current running kernel version
echo "Running kernel version is: ${current_kernel}"

#Display the currently installed kernel packages which are unused
echo 'Installed and unusued kernel packages:'
select kernelVersion in dpkg -l 'linux-*' | sed '/^ii/!d;/libc-dev/d;/'${current_ver}'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d'
do
  case $kernelVersion in

    *)
      echo "$kernelVersion"
      exit
      break;;
  esac
done

#Ask the user which one they wish to delete
#read -p 'Which version do you want to remove (I.e. 4.15.0-33)? ' -r
#todelete=$REPLY

#Check that the version exists, otherwise exit
exists="$(dpkg -l 'linux-*' | sed '/^ii/!d;/'${current_ver}'/d;/-'${todelete}'-/!d' | wc -l)"

if [[ $exists > 0 ]]
then
  #Version exists, confirm that the version is to be deleted
  read -p ${todelete}' exists. Are you sure [y/n]? ' -n 1 -r
  printf '\n'

  #User selected Yes, delete the kernel
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo 'Deleting '${todelete}
    dpkg -l 'linux-*' | sed '/^ii/!d;/libc-dev/d;/'${todelete}'/!d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge 
    echo ${todelete} 'deleted'
  else
    echo 'User cancelled. Nothing deleted.'
  fi
else
  #Version does not exist. Throw error an quit
  echo 'Version '${todelete}' does not exist. Exiting.'
fi
