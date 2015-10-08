################################################################################
# Library used by pushrc and pullrc synchronization scripts
################################################################################

. "$GLOBALRC/lib.sh/stream.sh"

GLOBALRC_DIR="$(echo "${GLOBALRC:-.globalrc}" | sed '/./s:/*$:/:')"
HOOKS_DIR="${GLOBALRC_DIR}hooks/"


# shell commands to execute on the remote machine in order to be sure the GLOBALRC files are sourced
remote_source='
  # set shell as interactive
  set -i 2>/dev/null ;
  PS1="fake interactive shell" ;

  # reload bashrc
  . .bashrc >/dev/null 2>&1 ;

  # set shell as non-interactive
  set +i 2>/dev/null ;
  unset PS1 ;
'

# ssh multiplexing control
masterco=
mastersoc=
masterpid=

generate_execute_hooks () {
  local sender moment dir first_hook last_hook
  moment="$1"
  dir="$2"
  sender=
  first_hook="sync"
  last_hook="copy"
  if [ "$moment" = post ]
  then
    first_hook="copy"
    last_hook="sync"
  fi
  if [ "$dir" = pull ]
  then
    sender="sender-"
  fi
  echo '
    HOOKS_DIR="$(echo "${GLOBALRC:-.globalrc}" | sed s:/*$:/:)hooks/"
    # execute hooks
    "$HOOKS_DIR"'"$sender$dir-$moment-$first_hook" "$(hostname)"' &&
    "$HOOKS_DIR"'"$sender$moment-sync"             "$(hostname)"' &&
    "$HOOKS_DIR"'"$sender$dir-$moment-$last_hook"  "$(hostname)"' ;
  '
}

execute_hooks () {
  local sender moment dir host first_hook last_hook
  host="$1"
  moment="$2"
  dir="$3"
  sender=
  first_hook="sync"
  last_hook="copy"
  if [ "$moment" = post ]
  then
    first_hook="copy"
    last_hook="sync"
  fi
  if [ "$dir" = push ]
  then
    sender="sender-"
  fi
  fake "$HOOKS_DIR$sender$dir-$moment-$first_hook" "$host" &&
  fake "$HOOKS_DIR$sender$moment-sync"             "$host" &&
  fake "$HOOKS_DIR$sender$dir-$moment-$last_hook"  "$host" ;
}



# Establish the ssh master connection for multiplexing
establish_master_co () {
  mastersoc="/tmp/ssh-master-pushd-$(id -ru)-$$-$(date +%N)-$host"
  masterco="-o ControlMaster=auto -o ControlPath=$mastersoc"
  if [ -n "$use_master_co" ]
  then
    info "Establishing the master connection to $host${port:+:$port}"

    # try to establish master connexion
    if fake ssh -nNfS $mastersoc $masterco $compression ${port:+-p $port} "$host"
    then
      # get ssh master connexion PID
      FAKE_DISPLAY="ssh -S $mastersoc -O check ${port:+-p $port} $host" fake :
      masterpid="$( [ -z "$FAKE" ] && ssh -S $mastersoc -O check ${port:+-p $port} "$host" 2>&1 | sed 's/^.*(pid=\(.*\)).*$/\1/')"
      verbose "PID = $masterpid"

      # ensure we close the master connexion if an error occurs
      trap 'RCODE=$? ; close_master ; exit $RCODE' 0 1 2 3 4 6 8 15
    else
      warning "Unable to establish master connexion"
      warning "Standalone connexions will be used"
      # Ensure the master connexion is actually closed as we don't want ghost process
      close_master >/dev/null 2>&1
      masterco=
      mastersoc=
    fi
  fi
  if [ -z "$masterco" ]
  then
    return 1
  else
    return 0
  fi
}

# Close the master connexion if needed
close_master () {
  # Properly close the ;aster connexion
  if [ -n "$masterco" -a -n "$mastersoc" ] 
  then
    info "Closing master connexion to $host${port:+:$port}"
    fake ssh -S $mastersoc -O exit ${port:+-p $port} "$host" 2>&1 | verbose
  fi
  masterco=

  # if the ssh client is still running, just kill it
  if [ -n "$masterpid" ] && ps | grep "$masterpid"
  then
    fake kill "$masterpid"
    ps | grep "$masterpid" && fake kill -9 "$masterpid"
  fi
  masterpid=

  # if the socket still exists, delete it
  if [ -e "$mastersoc" ]
  then
    fake rm -f "$mastersoc"
  fi
  mastersoc=

  # we don't need anymore to call this function at exit
  trap 0 1 2 3 4 6 8 15
}
