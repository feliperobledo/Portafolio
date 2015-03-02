#-------------------------------------------------------------------------------
#File: environment.sh
#Description: This bash file should be used to set the GOPATH environmental
#             variable.
#
#Note: I have set the GOPATH under .bash_profile since this file still does not
#      work. I will continue to automate this process without having to
#      convolute the user's .bash_profile file.
#
#-------------------------------------------------------------------------------

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "setting GOPATH to running directory"
export GOPATH="$DIR"
echo "GOPATH=$GOPATH"

export PATH="$PATH:$GOPATH/bin"
echo "added project bin to PATH: $PATH"
