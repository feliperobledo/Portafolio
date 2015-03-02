#export GOPATH=$PATH:/usr/local/go/bin

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "setting GOPATH to running directory"
export GOPATH="$DIR"
echo "GOPATH=$GOPATH"
