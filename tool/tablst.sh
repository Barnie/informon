#!/bin/ksh

####################################################################         
# 
#   tablst : 지정된 DB에 생성된 Table 목록을 보는 Shell입니다
#
#   사용법 : tablst.sh DB명 (tables 뒤의파일명) 
#                        (s:카탈로그까지/v:카탈로그와 View까지)
#
####################################################################

# Tool 폴더 설정 ########################################################
if [ ! "$TOOL" ]
then export TOOL=$HOME/tool
fi
#########################################################################

# DB명 설정 #############################################################
if [ ! "$1" ]
then
	if [ ! "$DBNAME" ]
	then 
		export dbname="dbname"
	else 
		export dbname=$DBNAME
	fi
else export dbname=$1
fi
#########################################################################


################### Default #############################################

if [ -f tables$2 ]
then 
	mv tables$2 tables$2.old
	echo 'tables'$2'를 tables'$2'.old로 바꿨습니다.'
fi

if [ ! "$3" ]
then

	dbaccess $dbname<<! 1> /dev/null 2> /dev/null
		set isolation to dirty read;
		unload to tables$2 delimiter ' '
		select tabname from systables 
		 where tabid > 99 
		   and tabtype='T'
		 order by 1;
!

else

	if [ $3 = 's' ]
	then
		dbaccess $dbname<<! 1> /dev/null 2> /dev/null
			set isolation to dirty read;
			unload to tables$2 delimiter ' '
			select tabname from systables 
			 where tabtype='T'
			 order by 1;
!
	else
		dbaccess $dbname<<! 1> /dev/null 2> /dev/null
			set isolation to dirty read;
			unload to tables$2 delimiter ' '
			select tabname from systables 
			 order by 1;
!
	fi

fi

echo '-----------------------------------------'
echo 'tables'$2' 파일의 내용입니다.'
echo '-----------------------------------------'
cat tables$2
echo '-----------------------------------------'
echo '사용법 : tablst DB명 (tables 뒤의파일명)'
echo '                     (s:카탈로그까지/v:카탈로그와 View까지)'
