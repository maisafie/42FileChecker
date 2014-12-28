#!/bin/bash

if [ "$FILECHECKER_SH" == "1" ]
then

	function check_forbidden_func
	{
		local -a MYFUNCS
		local exists total
		LOG_FILENAME=.myforbiddenfunc
		OLD_IFS=$IFS
		IFS=''
		local tab_str="$1[*]"
		local tab_local=(${!tab_str})
		IFS=$OLD_IFS

		rm -f "$LOG_FILENAME"
		touch "$LOG_FILENAME"
		if [ -f "$2" ]
		then
			RET0=`nm -m "$2" | grep " external " | grep -v " _ft_" | awk '{OFS=""} $0 ~ / _[^_]/ {gsub(/^[a-zA-Z0-9\(\)_, \[\]]*( _)/, ""); print $1}' | tr "\n" "\ "`
			RET0=`printf "MYFUNCS=($RET0)"`
			eval $RET0
			total=0
			for item in ${!MYFUNCS[@]};
			do
				exists=0
				for item2 in ${!tab_local[@]};
				do
					if [ ${MYFUNCS[$item]} == ${tab_local[$item2]} ]
					then
						exists=1
					fi
				done
				if [ "$exists" == "0" ]
				then
					(( total += 1 ))
					if (( total == 1 ))
					then
						echo "You should justify the use of the following functions:" > $LOG_FILENAME
					fi
					echo "-> ${MYFUNCS[$item]}" >> $LOG_FILENAME
				fi
			done
			if (( total == 0 ))
			then
				printf $C_GREEN"  No forbidden function found"$C_CLEAR
				echo "" > $LOG_FILENAME
			else
				printf $C_RED"  $total warning(s)"$C_CLEAR
			fi
		else
			printf $C_RED"  Test not performed (see details)"$C_CLEAR
			echo "$2: File Not Found" > $LOG_FILENAME
		fi
	}

fi