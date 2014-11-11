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
  env=$(mktemp -t env.XXXXXX)
  alias=$(mktemp -t alias.XXXXXX)

  ## clean up femp files and internal functions
  trap "\rm -f ${env} ${alias} && unset read_env read_alias csource ksource; trap - RETURN" RETURN


  ## Unset Bash's exported functions before exec'ing another shell.
  ## This simplifies parsing environment later, as env entries will be only 1 line
  function unset_env_funcs()
  {
    eval `env | sed -rn 's/^(\S+)=\(\).*/unset -f \1/p'`
  }

  ## read environment variables from file and export them to environment
  function read_env()
  {
    while read line;
    do
      export "$line"
    done <${env}
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
    (unset_env_funcs; exec tcsh -f -c "source $* && env >${env} && alias >${alias}")
    read_env
    read_alias
  }

  ## source ksh files
  function ksource ()
  {
    (unset_env_funcs; exec ksh -c ". $* && env >${env} && alias >${alias}")
    read_env
    read_alias
  }


  ##############################################################################
  ## Real work here
  if test \! -e $1;
  then
    echo "File $1 does not exist"
    return 1
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
