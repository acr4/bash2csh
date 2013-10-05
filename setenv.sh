# -*- mode:shell-script -*-


# Map 'setenv' commands from csh to bash 'export'
unset setenv
function setenv () {
  export ${1}=${2}
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
