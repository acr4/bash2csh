# -*- mode: shell-script -*-

# alias 'source' to handle sourcing csh-style files
unset -f __source
function __source () {

  ## temp files
  env=$(mktemp -t env.`hostname`.XXXXXX)
  alias=$(mktemp -t alias.`hostname`.XXXXXX)

  ## clean up femp files and internal functions
  trap "\rm -f ${env} ${alias} && unset read_env read_alias csource ksource" RETURN


  ## read environment variables from file and export them to environment
  function read_env()
  {
    while read line;
    do
      export "$line"
    done < <(cat ${env})
  }

  ## Read aliases from file and import them (maybe convert to functions)
  function read_alias()
  {
    while read line;
    do
      alias $line
    done < <(cat ${alias})
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
  if bash -n $* 2>/dev/null;
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
  fi


}
alias source=__source
