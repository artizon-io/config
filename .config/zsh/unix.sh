#!/usr/bin/env bash

# Print full system info w/ `uname -a`
system_info() {
  uname -a
}

# When the setuid bit is set on an executable file, users who run that file gain the same permissions as the owner of the file
add_setuid_bit() {
  chmod u+s "$@"
}

# When the setgid bit is set on an executable file, the group which the user who run that file belong gain the same permissions as the owner of the file
add_setgid_bit() {
  chmod g+s "$@"
}

# When the sticky bit is set on a directory, only the owner of a file in that directory can rename or delete the file
add_setsticky_bit() {
  chmod +t "$@"
}