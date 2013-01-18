# alias 'alias' to handle csh-style aliases
function alias () {
  #echo "function alias() called with ${#@} args:  ${@}"
  local E_BADARGS=65
  case ${#@} in
    0) # bareword 'alias', which means "print all aliases".  pipe through less for easier reading
      command alias -p | less
      ;;
    1) # bash alias, or "alias -p"
      command alias "${1}"
      ;;
    2) # assume csh alias. could also be a valid "alias -p <name>" but that's unlikely.  don't even bother checking for it
      command alias "${1}"="${2}"
      ;;
    *) # assume this to be a csh alias that lacks '' or "" around the RHS.
      local lhs=${1}
      shift
      command alias "${lhs}"='${@}'
      ;;
  esac
}
