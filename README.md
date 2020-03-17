# bash2csh
Bash-to-t/csh 

Bash helper utility functions for sourcing scripts for other shells.

This collection of utilities primarily allows Bash users to source scripts
written for t/csh.  Ksh support is also attempted, but mostly untested.  Other
shells could be added (Fish/Dash, anyone?).

To use this utility, add it as a Git submodule to your dotfiles repository, and
then add the following line somewhere in your Bash shell initializing scripts:

  source <path_to_bash2csh>/bash2csh.sh

Bugfixes, feature enhancements, and documentation improvements are appreciated.
