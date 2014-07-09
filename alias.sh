# Create a function to overload alias
unset -f alias
function alias () {
  local E_BADARGS=65
  local extglob=$(shopt -p extglob) # get original value of extglob in a string that can be eval'ed later
  shopt -s extglob # unconditionally set extglob for extended globbing

  # echo "function alias() called with ${#@} args:  ${@}"

  if [[ "$1" = "-p" ]];
  then
    builtin alias "${*}" | less
  else
    case ${#@} in
      0) # bareword 'alias', which means "print all aliases".  pipe through less for easier reading
        builtin alias -p | less
        ;;
      1) # bash alias, or "alias -p"
        builtin alias "${1}"
        ;;
      *) # csh alias
        local lhs=${1}
        local rhs="${@:2}"
        local term # terminating charater

        ## if csh's !* operator is detected in alias and it's not at the end of the alias (allowing for ;" or ;' after it)
        ## then the alias needs to be converted to a function, and !* needs to be converted to $@
        if [[ ${rhs} =~ \!\*(.*)$ && ${BASH_REMATCH[1]} =~ [^\"\'\;] ]];
        then
          rhs=${rhs/?(\\)\!\*/\$\@} # convert !* or \!* to $@
          [[ ${rhs} =~ ^([\"\']) ]] && { rhs=${rhs%${BASH_REMATCH[1]}}; rhs=${rhs#${BASH_REMATCH[1]}}; } # remove enclosing ' or "
          ## Now figure out if we need to add a terminating ';'.  csh alias may already end in '&', ';', or nothing at all.
          [[ ${rhs} =~ [\&\;][[:space:]]*$ ]] || term=";"
          eval "function ${lhs} { ${rhs}${term} }"
        else ## normal alias
          builtin alias "${lhs}"="${rhs}"
        fi
        ;;
    esac
  fi

  eval "$extglob" # restore former extglob value
}
