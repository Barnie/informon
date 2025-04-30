#!/bin/ksh

#########################################################################
#
#   sq     : SQL 파일에 대한 Plan을 보녀주는 Shell입니다
#
#   사용법 : sq.sh [파일명 / -clean(sq.* 파일 정리)] [DB명]
#   결과물 : sq.yyyymmddHHMMSS 
#
#########################################################################

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
export TempFile1=$TOOL/tmp/`echo $0 | $CAWK -F '/' '{ print $NF }'`_tmp_${TempTail}.sql

if [ -f $TempFile1 ]; then rm $TempFile1; fi
#########################################################################


# DB명 설정 #############################################################
if [ ! "$2" ]
then
	if [ ! "$DBNAME" ]
	then export dbname="dbname"
	else export dbname=$DBNAME
	fi
else export dbname=$2
fi
#########################################################################

echo '[0m\c'
################### Default #############################################


if [ ! "$1" ] 
then 
	export fname='sql'
else 

	if [ $1 = "-clean" ]; then 
		rm sq.*
		exit
	fi

	export fname=$1

fi

if [ -f $TempFile1 ]; then rm $TempFile1; fi

echo 'set explain on avoid_execute;' > $TempFile1
cat $fname >> $TempFile1
echo '1,$s/?/"0000"/g\nw\nq' | ed $TempFile1

dbaccess $dbname $TempFile1

cat sqexplain.out
cat sqexplain.out >> sq.`date +"%Y%m%d%H%M%S"`

rm sqexplain.out

if [ -f $TempFile1 ]; then rm $TempFile1; fi
