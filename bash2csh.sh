for s in alias limit setenv source; do
  source ${BASH_SOURCE[0]%/*}/${s}.sh
done
unset s
