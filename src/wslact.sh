# shellcheck shell=bash
version="03"

help_short="wslact COMMAND ..."

function time_sync {
	local help_short="wslact time-sync [-h]"

	while [ "$1" != "" ]; do
		case "$1" in
			-h|--help) help "wslact" "$help_short"; exit;;
			*) shift;;
		esac
	done

	if [ "$EUID" -ne 0 ]
		then echo "${error} \`wslact time-sync\` requires you to run as root. Aborted."
		exit 1
	fi

	echo "${info} Before Sync: $(date +"%d %b %Y %T %Z")"
	if date -s "$(winps_exec "Get-Date -UFormat \"%d %b %Y %T %Z\"" | tr -d "\r")" >/dev/null; then
		echo "${info} After Sync: $(date +"%d %b %Y %T %Z")"
		echo "${info} Manual Time Sync Complete."
	else
		echo "${error} Time Sync failed."
		exit 1
	fi
}

function auto_mount {
	local help_short="wslact auto-mount [-h]"
	local mntpt_prefix="$(interop_prefix)"
	local sysdrv_prefix="$(sysdrive_prefix)"

	while [ "$1" != "" ]; do
		case "$1" in
			-h|--help) help "wslact" "$help_short"; exit;;
			*) shift;;
		esac
	done

	if [ "$EUID" -ne 0 ]
		then echo "${error} \`wslact auto-mount\` requires you to run as root. Aborted."
		exit 1
	fi

	mount_opt=""
	drive_list="$("$mntpt_prefix$sysdrv_prefix"/WINDOWS/system32/fsutil.exe fsinfo drives | tail -1 | tr '[:upper:]' '[:lower:]' | tr -d ':\\' | sed -e 's/drives //g' -e 's|'$sysdrv_prefix' ||g' -e 's|\r||g' -e 's| $||g' -e 's| |\n|g')"

	if [ -f /etc/wsl.conf ]; then
		tmp="$(grep ^options /etc/wsl.conf | sed -r -e 's|^options[ ]+=[ ]+||g' -e 's|^"||g' -e 's|"$||g')"
		if [ "$tmp" != "" ]; then
			echo "${info} Custom mount option detected: $tmp"
			mount_opt="$tmp"
			unset tmp
		fi
	fi

	mount_s=0
	mount_f=0
	mount_j=0
	
	for drive in $drive_list; do
		[[ -d "$mntpt_prefix$drive" ]] || mkdir -p "$mntpt_prefix$drive"
		if [[ -n $(find "$mntpt_prefix$drive" -maxdepth 0 -type d -empty 2>/dev/null) ]]; then
			echo "${info} Mounting Drive ${drive^} to $mntpt_prefix$drive..."
			if mount -t drvfs ${drive}: "$mntpt_prefix$drive" -o "$mount_opt" 2>/dev/null; then
				echo "${info} Mounted Drive ${drive^} to $mntpt_prefix$drive."
				mount_s=$((mount_s + 1))
			else
				echo "${error} Failed to mount Drive ${drive^}. Skipped."
				mount_f=$((mount_f + 1))
			fi
		else
			echo "${warn} Already mounted Drive ${drive^} at $mntpt_prefix$drive. Skipped."
			mount_j=$((mount_j + 1))
		fi
	done
	echo "${info} Auto mounting completed. $mount_s drive(s) succeed. $mount_f drive(s) failed. $mount_j drive(s) skipped."
}

while [ "$1" != "" ]; do
	case "$1" in
		am|auto-mount) auto_mount "$@"; exit;;
		ts|time-sync) time_sync "$@"; exit;;
		-h|--help) help "$0" "$help_short"; exit;;
		-v|--version) echo "wslu v$wslu_version; wslact v$version"; exit;;
		*) echo "${error} Invalid Input. Aborted."; exit 22;;
	esac
done