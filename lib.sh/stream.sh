#! /bin/sh
################################################################################
# Library to help stream redirection and output level management
################################################################################
# 
# There are 4 streams:
#   verbose
#   info
#   warning
#   error
# 
# verbose: print on stdout only if $VERBOSE is not empty
# info:    print on stdout only if $QUIET is empty
# warning: print on stderr only if $QUIET is empty
# error:   print on stderr always
# 
# To use a stream, eg: verbose
# you can use it like echo (same options as echo):
#   verbose my super text
# or you can use it like a redirection:
#   mycommand | verbose
# 
# These functions never fail (ie: always return 0) evenif the piped command fails
# 
# If your command output must always be printed, don't pipe it to any stream
# If you want to always print some text, just use echo
# 
# If you really want to use a stream which always print,
# you can use the internal stream called always which can be used exactly the same way
# 
################################################################################
# Special cases
################################################################################
# no pipe and no arguments, eg:
#   verbose
# prints a new line on the stream
# It is equivalent to:
#   echo | verbose
# 
# pipe + arguments, eg:
#   mycommand | verbose text
# forwards the output of mycommand to the stream and print text on the stream
# It is equivalent to:
#   mycommand | verbose; verbose text
# This form is discouraged.
# 
################################################################################
# fake & execute
################################################################################
# This library also provides 2 utils in order to debug your scripts
# fake and execute
# 
# execute allow you to print a command on the verbose stream and then execute it, eg:
#   execute mycommand myargs
# is equivalent to:
#   verbose "=> " mycommand myargs; mycommand myargs
# 
# fake is exactly the same but allows you
# to prevent the actual execution of your command if $FAKE is not empty
# eg:
#   fake mycommand myargs
# is equivalent to:
#   if [ -n "$FAKE" ]; then
#     verbose "=>X" mycommand myargs
#   else
#     verbose "=> " mycommand myargs
#     mycommand myargs
#   fi
# 
# Both fake and execute forward the exit code of the executed command
# In FAKE mode (if $FAKE is not empty), fake returns the value of $FAKE_RETURN_CODE (or 0 if empty)
# 
# fake and execute also allow to print an alternative text for extra long commands for example
# eg:
#   FAKE_DISPLAY="myfakecommand myfakeargs"
#   execute mycommand myargs
# is equivalent to:
#   verbose "myfakecommand myfakeargs"
#   mycommand myargs
# $FAKE_DISPLAY is reset every time you call fake or verbose
# so you don't to do it yourself
# 
################################################################################
# This library is POSIX compliant
################################################################################

# Control output
FAKE=
VERBOSE=
QUIET=

# print on stdout from stdin and args
always () {
  # here is the magic
  tty 2>/dev/null 1>&2 || { cat && [ $# != 0 ]; } && echo "$@"
  return 0
}

# print if verbose mode enabled
verbose () {
  [ -n "$VERBOSE" ] && always "$@"
  return 0
}

# print if not quiet
info () {
  [ -z "$QUIET" ] && always "$@"
  return 0
}

# print on stderr if not quiet
warning () {
  [ -z "$QUIET" ] && always "$@" >&2
  return 0
}

# print on stderr
error () {
  always "$@" >&2
  return 0
}

# print the command to execute if in verbose mode
# and execute it if FAKE mode disabled
fake () {
  local prepend
  prepend="=>${FAKE:+X} "
  if [ -n "$FAKE_DISPLAY" ]; then
    verbose "$FAKE_DISPLAY" | sed "s/^/$prepend/"
  else
    verbose "$@" | sed "s/^/$prepend/"
  fi
  FAKE_DISPLAY=
  [ -z "$FAKE" ] || return ${FAKE_EXIT_CODE:-0} && "$@"
  return $? # explicitly return the last exit code
}

# print the command to execute if in verbose mode before executing it
execute () {
  FAKE= fake "$@"
}


# Ask for yes or no
# success if yes
# fail if no
# retry otherwise
promptyn () {
  while true; do
    printf "$1 " && read yn

    case ${yn:-$2} in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}
