# -*- mode:shell-script -*-


# Map 'setenv' commands from csh to bash 'export'
unset setenv
function setenv () {
  # if no arguments, then print environment
  if [[ -z ${1} ]]
  then
    env
  else
    export ${1}="${2}"
  fi
}


# Map 'unsetenv' commands from csh to bash 'export'
# unsetenv supports globbing
unset unsetenv
function unsetenv () {
  pattern="^${1/\*/.*}\$"
  while read var
  do
    [[ ${var} =~ ${pattern} ]] && unset ${var}
  done < <(env | \grep -Eo ^[^=]+)
  :
}


# Detect csh-style set:
# set var=val
# set var="array"
unset set
function set() {
  if [[ $* =~ ^([^=]+)=(.*)$ ]]
  then
    var=${BASH_REMATCH[1]}
    val=${BASH_REMATCH[2]}
    if [[ $val =~ ' ' ]]
    then
      eval "$var=($val)"
    else
      eval "$var=$val"
    fi
  else
    command set $@
  fi
}
