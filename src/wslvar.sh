version="03"

var_type=1

help_short="wslvar (--sys|--shell) [NAME]\nwslvar (--help|--version|--getsys|--getshell)"

function call_shell {
	winps_exec "(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders').'$*'" | cat
}

function view_shell {
	winps_exec "Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'"| tail -n +3 | head -n -10
}

function call_sys {
	winps_exec "Write-Output \$Env:$*" | cat
}

function view_sys {
	winps_exec "Get-ChildItem env:" | tail -n +2 | head -n -2
}

function cl_destoryer {
	echo "$@" | tr -d "\r"
}

function caller {
	if [ "$*" != "" ]; then
		case $var_type in
			1) p="$(cl_destoryer "$(call_sys "$@")")";;
			2) p="$(cl_destoryer "$(call_shell "$@")")";;
			*) echo "${error}Invalid variable type. Aborted."; exit 22;;
		esac
		echo "$p"
	else
		echo "${error} No Input. Aborted."
		exit 21
	fi
}

while [ "$1" != "" ]; do
	case "$1" in
		-s|--sys) var_type=1; shift;;
		-l|--shell) var_type=2; shift;;
		-S|--getsys) view_sys; exit;;
		-L|--getshell) view_shell; exit;;
		-h|--help) help "$0" "$help_short"; exit;;
		-v|--version) echo "wslu v$wslu_version; wslvar v$version"; exit;;
		*) caller "$@"; exit;;
	esac
done

exit 21

