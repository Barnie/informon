#!/bin/ksh

####################################################################         
# 
#   tabaut : Table의 권한 설정을 Check 하는 Shell입니다
#
#   사용법 : tabaut (tables_ 뒤의 파일명 혹은 Table명) [DB명]
#
####################################################################

export TOOL=$HOME/tool

if [ -f $TOOL/tmp/tabaut.tmp ]; then rm $TOOL/tmp/tabaut.tmp; fi

if [ ! "$2" ]
then
   dbname="dbname"
else
   dbname=$2
fi

if [ ! "$1" ]
then

echo '사용법 : tabaut (tables_ 뒤의 파일명 혹은 Table명) [DB명]'

else 

if [ -f tables_$1 ]
then

if [ -f tabaut_$1 ]; then rm tabaut_$1
fi

echo '---------------------------------------------------------------------------' >> tabaut_$1
echo '[5mTable Name                      Grantee          TableAuth  Granter        [0m' >> tabaut_$1
echo '---------------------------------------------------------------------------' >> tabaut_$1

for i in `cat tables_$1`
do
echo $i' 테이블 조사'
dbaccess $dbname<<! 1> /dev/null 2> /dev/null  
set isolation to dirty read;
unload to $TOOL/tmp/tabaut.tmp delimiter ' '
select t.tabname, 
       NVL(a.grantee, '-'), 
       NVL(a.tabauth, '-'), 
       NVL(a.grantor, '-')
  from systables t, outer systabauth a
 where t.tabid = a.tabid
   and t.tabname = '$i'
   and t.tabid > 99
   and t.tabtype = 'T'
 order by 1;
!

if [ `cat $TOOL/tmp/tabaut.tmp | wc -l` -gt 0 ]
then
cat $TOOL/tmp/tabaut.tmp | nawk -F ' ' '{
{ printf ("%-30s  %-15s  %-9s  %-15s\n", $1, $2, $3, $4); }
}' >> tabaut_$1
else
printf "[5m%-30s  %-15s  %9s  %-15s[0m\n" $i '' '' '없는 테이블' >> tabaut_$1
fi
rm $TOOL/tmp/tabaut.tmp

done

echo '---------------------------------------------------------------------------' >> tabaut_$1
cat tabaut_$1

else

echo
dbaccess $dbname<<! 1> /dev/null 2> /dev/null 
set isolation to dirty read;
unload to $TOOL/tmp/tabaut.tmp delimiter ' '
select t.tabname, 
       NVL(a.grantee, '-'), 
       NVL(a.tabauth, '-'), 
       NVL(a.grantor, '-')
  from systables t, outer systabauth a
 where t.tabid = a.tabid
   and t.tabname = '$1'
   and t.tabid > 99
   and t.tabtype = 'T'
 order by 1;
!

if [ `cat $TOOL/tmp/tabaut.tmp | wc -l` -gt 0 ]
then 
echo '---------------------------------------------------------------------------'
echo '[5mTable Name                      Grantee          TableAuth  Granter        [0m'
echo '---------------------------------------------------------------------------'
cat $TOOL/tmp/tabaut.tmp | nawk -F ' ' '{
{ printf ("%-30s  %-15s  %-9s  %-15s\n", $1, $2, $3, $4); }
}' 
echo '---------------------------------------------------------------------------'
else
echo $1'이라는 Table 없음'
fi
rm $TOOL/tmp/tabaut.tmp

fi

fi

if [ -f $TOOL/tmp/tabaut.tmp ]; then rm $TOOL/tmp/tabaut.tmp; fi
