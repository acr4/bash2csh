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
