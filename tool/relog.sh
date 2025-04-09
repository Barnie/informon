#!/bin/ksh

####################################################################         
# 
#   relog.sh : onbar 프로세스 재시작
#   사용법 : relog.sh [timeslice]
#
####################################################################

echo
export TOOL=$HOME/tool

if [ ! "$1" ]
	then export timeslice=20
	else export timeslice=$1
fi

if [ -f $TOOL/tmp/relog.tmp ]; then rm $TOOL/tmp/relog.tmp; fi
if [ -f $TOOL/tmp/relog.tmp2 ]; then rm $TOOL/tmp/relog.tmp2; fi
if [ -f $TOOL/tmp/relog.tmp3 ]; then rm $TOOL/tmp/relog.tmp3; fi

ps -ef | grep onbar | grep -v 'grep' > $TOOL/tmp/relog.tmp

cat $TOOL/tmp/relog.tmp | grep -v sh | nawk -F ' ' '{
	{ print $2 }
}' > $TOOL/tmp/relog.tmp2
export exist=`cat $TOOL/tmp/relog.tmp2 | wc -l`

if [ $exist -ne 0 ]
then
	echo '-----------------------------------------------------------------------'
	echo 'Onbar Process 입니다.'
	echo '-----------------------------------------------------------------------'
	cat $TOOL/tmp/relog.tmp
	echo '-----------------------------------------------------------------------'

	if [ -f $TOOL/tmp/relog.tmp ]; then rm $TOOL/tmp/relog.tmp; fi

	sleep $timeslice

	ps -ef | grep onbar | grep -v 'grep' > $TOOL/tmp/relog.tmp

	cat $TOOL/tmp/relog.tmp
	echo '-----------------------------------------------------------------------'

	cat $TOOL/tmp/relog.tmp | grep -v sh | nawk -F ' ' '{
		{ print $2 }
	}' > $TOOL/tmp/relog.tmp3

	export diffcnt=`diff $TOOL/tmp/relog.tmp2 $TOOL/tmp/relog.tmp3 | wc -l`

	if [ $diffcnt -eq 0 ]
	then
		echo
		for i in `cat $TOOL/tmp/relog.tmp2`
		do
			echo '죽일까요? ('$i') \c'
			read yn
			if [ $yn = 'y' ]
				then kill -9 $i
			else
				echo '계속 살려 둡니다.'
			fi
		done

		onmode -l

	else
		echo '정상동작 중인가 봅니다'
	fi

else 
	echo 'Onbar Process가 없습니다'
fi

if [ -f $TOOL/tmp/relog.tmp ]; then rm $TOOL/tmp/relog.tmp; fi
if [ -f $TOOL/tmp/relog.tmp2 ]; then rm $TOOL/tmp/relog.tmp2; fi
if [ -f $TOOL/tmp/relog.tmp3 ]; then rm $TOOL/tmp/relog.tmp3; fi
