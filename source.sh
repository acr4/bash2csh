# -*- mode: shell-script -*-

# This file is sourced to load into the environment.  If changes are made, it could be re-sourced.
# But what happens if this file has a bug and needs to be resourced?  The simplest solution is to
# unset the function (or easier yet, just 'unalias source').  But that requires the user to remember
# to do so.  Instead, add some introspection.  This script remembers its name, and then if it is re-
# sourced, the fancy stuff is skipped (besides, it is guaranteed that it's a Bash script!).
called=$_

enable -n source
alias .=source
function source () {

  ## Introspection:
  [[ $1 -ef $called ]] && { \. $*; return; }

  ## temp files
  env_pre=$(mktemp -t env.XXXXXX)
  env_post=$(mktemp -t env.XXXXXX)
  alias=$(mktemp -t alias.XXXXXX)

  ## clean up femp files and internal functions
  trap "\rm -f ${env_pre} ${env_post} ${alias} && unset read_env read_alias csource ksource; trap - RETURN" RETURN


  ## Unset Bash's exported functions before exec'ing another shell.
  ## This simplifies parsing environment later, as env entries will be only 1 line
  function unset_env_funcs()
  {
    eval `declare -F | sed -n 's/^declare -fx/unset -f/p'`
  }

  ## read environment variables from file and export them to environment
  function read_env()
  {
    # Also apply final variables in this loop
    declare -A post
    while read line; do
      post[${line%%=*}]=1
      export "$line"
    done <${env_post}

    # Now compute (pre \ post) and remove env variables that were unset in the subshell
    while read line; do
      key=${line%%=*}
      [[ ${post[$key]} ]] || unset $key
    done <${env_pre}
  }

  ## Read aliases from file and import them (maybe convert to functions)
  function read_alias()
  {
    while read line;
    do
      alias $line
    done <${alias}
  }

  ## source csh files
  function csource ()
  {
    (unset_env_funcs; exec tcsh -f -c "env >${env_pre} && source $* && env >${env_post} && alias >${alias}")
    read_env
    read_alias
  }

  ## source ksh files
  function ksource ()
  {
    (unset_env_funcs; exec ksh -c "env ${env_pre} && . $* && env >${env_post} && alias >${alias}")
    read_env
    read_alias
  }


  ##############################################################################
  ## Real work here

  # if first line starts with #!, then get specified program and execute that
  local -rA PROGS=([bash]=\.
                   [sh]=\.
                   [csh]=csource
                   [tcsh]=csource
                   [ksh]=ksource
                   )
  local prog=$(sed -n -e '1!b' -e 's/^#\!.*\///p' $*)
  [[ $prog ]] && prog=${PROGS[$prog]}


  if test \! -e $1;
  then
    echo "File $1 does not exist"
    return 1
  elif [[ -n $prog ]];
  then
    eval $prog $*
  elif bash -n $* 2>/dev/null;
  then
    \. $*
  elif tcsh -n $* 2>/dev/null;
  then
    csource $*
  elif csh -n $* 2>/dev/null;
  then
    csource $*
  elif ksh -n $* 2>/dev/null;
  then
    ksource $*
  else
    echo "Unable to source $1:"
    file $1
    return 1
  fi


}
unset called