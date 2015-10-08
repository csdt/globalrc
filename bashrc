#! /bin/bash

# Se place dans le dossier .globalrc (ou qu'il soit)
pushd "$(dirname "$BASH_SOURCE")" > /dev/null

# Arrête tout si on a pas réussi à se déplacer
if [[ $? != 0 ]]
then
  exit $?
fi


# Charge le prompt s'il existe
if [ -f prompt ]
then
  . prompt
fi

# Charge les définitions de variables si elles existent
if [ -f definitions ]
then
  . definitions
fi

# Charge les fonctions si elles existent
if [ -f functions ]
then
  . functions
fi

# Charge les aliases s'ils existent
if [ -f aliases ]
then
  . aliases
fi

# Charge les completions s'ils existent
if [ -f completions ]
then
  . completions
fi

# Affiche le message s'il existe
if [ -f message ] && [ "$SHLVL" = 1 ] && [ -n "$PS1" ]
then
  cat message
fi

# Se replace dans le dossier précédent ou dans le home en cas d'erreur
popd > /dev/null || cd
