#!/bin/ksh

#########################################################################
#
#   tablst2 : 특정 글자로 시작하는 테이블명을 보여주는 Shell입니다
#
#   사용법 : tablst2.sh [일월 테이블의 머릿글 or File명] (DB명)
#   결과물 : tables_일월 테이블의 머릿글 or File명 (optional)
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
export TempFile1=$TOOL/tmp/`echo $0 | $CAWK -F '/' '{ print $NF }'`.tmp_${TempTail}
export TempFile2=$TOOL/tmp/`echo $0 | $CAWK -F '/' '{ print $NF }'`.tmp2_${TempTail}

if [ -f $TempFile1 ]; then rm $TempFile1; fi
if [ -f $TempFile2 ]; then rm $TempFile2; fi
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

	echo '사용법 : tablst2.sh [일월 테이블의 머릿글 or File명] (DB명)'

else

	if [ -f $1 ]
	then

		for i in `cat $1`
		do

			dbaccess $dbname<<! 1> /dev/null 2> /dev/null
				set isolation to dirty read;
				unload to $TempFile1 delimiter ' '
				select tabname from systables 
				 where tabid > 99 and tabtype='T'
				   and tabname like '$i%'
				 order by 1;
!
			cat $TempFile1 >> $TempFile2

			if [ -f $TempFile1 ]; then rm $TempFile1
			fi

		done

	else

		dbaccess $dbname<<! 1> /dev/null 2> /dev/null
			set isolation to dirty read;
			unload to $TempFile2 delimiter ' '
			select tabname from systables 
			 where tabid > 99 and tabtype='T'
			   and tabname like '$1%'
			 order by 1;
!

	fi

	echo '------------------------------------------'
	cat $TempFile2
	echo '------------------------------------------'
	echo '[4;35mtables_'$1'[0m File을 남길까요? \c'
	read yn
	if [ "$yn" ] 
	then 
		if [ $yn = 'y' ]; then mv $TempFile2 tables_$1; fi
	fi

	if [ -f $TempFile2 ]; then rm $TempFile2; fi

fi
