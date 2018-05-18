# map 'limit' commands from csh to bash 'ulimit'
function limit () {
  # csh syntax is "limit [-h] [resource [maximum-use]]"
  # -h is synonymous with Bash's -H
  local -A resources=(
    [cputime]='-t'
    [filesize]='-f'
    [datasize]='-d' # (kind of...)
    [stacksize]='-s'
    [coredumpsize]='-c'
    [memoryuse]='-v' # (kind of...)
    [heapsize]='-v' # (kind of...)
    [desciptors]='-n'
    [openfiles]='-n'
    [concurrency]='-T'
    [memorylocked]='-l'
    [maxproc]='-u'
    [sbsize]='-b'
  );
  local -A scales=(
    [k]="*(1<<10)"
    [kilobytes]="*(1<<10)"
    [m]="*(1<<20)"
    [megabytes]="*(1<<20)"
    # [m]=*60
    [h]=*3600
    ## cpulimit times in m (minutes) not handled yet
  );

  local -a ARGV=("$@")
  for (( i=0 ; $i<"${#ARGV[@]}" ; i++ ));
  do
    [[ ${ARGV[$i]} =~ -h ]] && ARGV[$i]='-H' # convert -h -> -H
    [[ ${resources[${ARGV[$i]}]} ]] && ARGV[$i]=${resources[${ARGV[$i]}]} # replace resource with correct flag
    [[ ${ARGV[$i]} =~ ([0-9]+)(.+) ]] && ARGV[$i]=$(( ${BASH_REMATCH[1]} ${scales[${BASH_REMATCH[2]}]} ))
  done

  ulimit ${ARGV[@]}
}
