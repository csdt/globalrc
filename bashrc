#! /bin/bash

# cd to the directory of this file
pushd "$(dirname "$BASH_SOURCE")" > /dev/null

# Stop if we couldn't move
if [[ $? != 0 ]]
then
  exit $?
fi

# Load prompt
if [ -f prompt ]
then
  . prompt
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

# Load completions
if [ -f completions ]
then
  . completions
fi

# Print the message
if [ -f message ] && [ "$SHLVL" = 1 ] && [ -n "$PS1" ]
then
  cat message
fi

# cd back to the previous directory
# cd to home if we couldn't cd back
popd > /dev/null || cd
