# Map 'setenv' commands from csh to bash 'export'
function setenv () {
  # play nice w/ .csh
  export ${1}=${2}
}
