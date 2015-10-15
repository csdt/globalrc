#! /bin/bash
# TODO: This file is not POSIX compliant

# cd to the directory of this file
pushd "$(dirname "$BASH_SOURCE")" > /dev/null

# Stop if we couldn't move
if [ $? != 0 ]
then
  exit $?
fi

# Load variables definitions
if [ -f definitions ]
then
  . definitions
fi

# Load functions
if [ -f functions ]
then
  . functions
fi

# Load aliases
if [ -f aliases ]
then
  . aliases
fi

if [ -n "$PS1" -a "${GLOBALRC_NOT_INTERACTIVE:-0}" = 0 ] && [[ $- = *i* ]]
then
  # Load prompt
  if [ -f prompt ]
  then
    . prompt
  fi

  # Print the message
  if [ -f message ] && [ "$SHLVL" = 1 ]
  then
    cat message
  fi

  # Load completions
  if [ -f completions ]
  then
    . completions
  fi
fi

# cd back to the previous directory
# cd to home if we couldn't cd back
popd > /dev/null || cd
