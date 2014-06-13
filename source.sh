# -*- mode: shell-script -*-

# This file is sourced to load into the environment.  If changes are made, it could be re-sourced.
# But what happens if this file has a bug and needs to be resourced?  The simplest solution is to
# unset the function (or easier yet, just 'unalias source').  But that requires the user to remember
# to do so.  Instead, add some introspection.  This script remembers its name, and then if it is re-
# sourced, the fancy stuff is skipped (besides, it is guaranteed that it's a Bash script!).
called=$_

# alias 'source' to handle sourcing csh-style files
unset -f __source
function __source () {

  ## Introspection:
  [[ $1 -ef $called ]] && { \source $*; return; }

  ## temp files
  env=$(mktemp -t env.`hostname`.XXXXXX)
  alias=$(mktemp -t alias.`hostname`.XXXXXX)

  ## clean up femp files and internal functions
  trap "\rm -f ${env} ${alias} && unset read_env read_alias csource ksource; trap - RETURN" RETURN


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
    (exec csh -f -c "source $* && env >${env} && alias >${alias}")
    read_env
    read_alias
  }

  ## source ksh files
  function ksource ()
  {
    (exec ksh -c ". $* && env >${env} && alias >${alias}")
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
    \source $*
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
alias source=__source

unset called
