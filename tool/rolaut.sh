#!/bin/ksh

####################################################################         
# 
#   rolaut : Role이 부여된 사용자를 Check 하는 Shell입니다
#
#   사용법 : rolaut [DB명] [Role명]
#
####################################################################

export TOOL=$HOME/tool

if [ -f $TOOL/tmp/rolaut.tmp ]; then rm $TOOL/tmp/rolaut.tmp; fi

if [ ! "$1" ]
then dbname="dbname"
     echo '사용법 : rolaut [DB명] [Role명]'
else dbname=$1
fi

if [ ! "$2" ]
then rolename="%"
else rolename=$2
fi

echo '--------------------------------------------------'
echo '[34;43mRole Name                       Grantee  Grantable[0m'
echo '--------------------------------------------------'

dbaccess $dbname<<! 1> /dev/null 2> /dev/null  
set isolation to dirty read;
unload to $TOOL/tmp/rolaut.tmp delimiter ' '
select rolename, 
       grantee, 
       is_grantable
  from sysroleauth
 where rolename like '$rolename'
 order by 1;
!

if [ `cat $TOOL/tmp/rolaut.tmp | wc -l` -gt 0 ]
then
cat $TOOL/tmp/rolaut.tmp | nawk -F ' ' '{
{ printf ("%-30s  %-15s  %1s\n", $1, $2, $3); }
}'
else
echo '해당 사항 없음'
fi
rm $TOOL/tmp/rolaut.tmp

echo '--------------------------------------------------'

if [ -f $TOOL/tmp/rolaut.tmp ]; then rm $TOOL/tmp/rolaut.tmp; fi
