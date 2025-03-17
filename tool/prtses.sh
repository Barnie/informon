#!/bin/ksh
export LANG=C

####################################################################         
# 
#   prtses : 입력된 Session 관련 정보를 한줄로 보여줍니다
#   사용법 : prtses
#   요파일 : chkpid가 필요함
#
####################################################################

# Tool 폴더 설정 ########################################################
if [ ! "$TOOL" ]
then export TOOL=$HOME/tool
fi
#########################################################################


# OS별 awk 설정 #########################################################
if [ `uname` = 'HP-UX' ]
then
   export CAWK=awk
else
   export CAWK=nawk
fi
#########################################################################


# 임시파일 초기화 #######################################################
export TempTail=`tty | $CAWK -F/ '{print $4}'`
export TempFile1=$TOOL/tmp/`echo $0 | $CAWK -F '/' '{ print $NF }'`.tmp_${TempTail}_$$

if [ -f $TempFile1 ]; then rm $TempFile1; fi
#########################################################################


echo '[0m\c'
################### Default #############################################

if [ ! "$1" ]
then
	echo '사용법 : prtses [Session ID]'
	exit
fi

export sid=$1
export flag=`onstat -u | grep ' '$1' ' | $CAWK -F ' ' '{ if ( $3 == '$1' ) { printf("%s", $2); } }'` 
export username=`onstat -u | grep ' '$1' ' | $CAWK -F ' ' '{ if ( $3 == '$1' ) { printf("%s", $4); } }'` 

print '[1m\c'

if [ `echo $flag | egrep -v ^$ | wc -l` -gt 0 ]
then

	export flag1=`echo $flag | $CAWK -F ':' '{ { print substr($1,1,1); } }'`
	export flag3=`echo $flag | $CAWK -F ':' '{ { print substr($1,3,1); } }'`
	export flag4=`echo $flag | $CAWK -F ':' '{ { print substr($1,4,1); } }'`
	export flag5=`echo $flag | $CAWK -F ':' '{ { print substr($1,5,1); } }'`
	export flag7=`echo $flag | $CAWK -F ':' '{ { print substr($1,7,1); } }'`

	case "$flag1" in
		B)  export flagn1='Buffer' ;;
		C)  export flagn1='ChkPt' ;;
		G)  export flagn1='LLogBf' ;;
		L)  export flagn1='Lock' ;;
		S)  export flagn1='Mutex' ;;
		T)  export flagn1='Tx' ;;
		X)  export flagn1='TxClup' ;;
		Y)  export flagn1='Cond' ;;
		\-) export flagn1='-' ;;
		*)  # Unidentified Flag:
   			 export flagn1='?' ;;
	esac

	case "$flag3" in
		A)  export flagn3='DBs_Bkup' ;;
		B)  export flagn3='Begin' ;;
		P)  export flagn3='Prepare' ;;
		X)  export flagn3='XA_Prep' ;;
		C)  export flagn3='Commit' ;;
		R)  export flagn3='Abort' ;;
		H)  export flagn3='H_abort' ;;
		\-) export flagn3='-' ;;
		*)  # Unidentified Flag:
   		    export flagn3='?' ;;
	esac

	case "$flag4" in
		P)  export flagn4='Primary' ;;
		\-) export flagn4='-' ;;
		*)  # Unidentified Flag:
			export flagn4='?' ;;
	esac

	case "$flag5" in
		R)  export flagn5='RSAM' ;;
		X)  export flagn5='CWrite' ;;
		\-) export flagn5='-' ;;
		*)  # Unidentified Flag:
   			export flagn5='?' ;;
	esac

	case "$flag7" in
		B)  export flagn7='BT_Clean' ;;
		C)  export flagn7='CleanUp' ;;
		D)  export flagn7='Daemon' ;;
		F)  export flagn7='Flusher' ;;
		M)  export flagn7='Monitor' ;;
		\-) export flagn7='-' ;;
		*)  # Unidentified Flag:
   		 	export flagn7='?' ;;
	esac

	onstat -g ses | grep '^'$1' ' | $CAWK -F ' ' ' 
		BEGIN {
			count = 0;
		}
		{
			count++;
			printf("%8d %10s  %6s %8s %7s %6s %8s  ", $1, $2, "'`echo $flagn1`'", "'`echo $flagn3`'", "'`echo $flagn4`'", "'`echo $flagn5`'", "'`echo $flagn7`'"); 
			if ( $4 < 0 ) print "Unknown Process"
			else if (system("chkpid "$4" "$1"")) print "";
		}
		END {
			if ( count == 0 ) {
				printf("%8d %10s  %6s %8s %7s %6s %8s  \n", "'`echo $sid`'", "'`echo $username`'", "'`echo $flagn1`'", "'`echo $flagn3`'", "'`echo $flagn4`'", "'`echo $flagn5`'", "'`echo $flagn7`'"); 
				
			}
		}
	'

else

	printf "%8s %10s  %6s %8s %7s %6s %8s  " $1 'Unknown' ' ' ' ' ' ' ' ' ' ' 
    echo 'Already Finished'

fi

print '[0m\c'

if [ -f $TempFile1 ]; then rm $TempFile1; fi
