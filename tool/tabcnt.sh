#!/bin/ksh

####################################################################
# 
#   tabcnt.sh : 지정한 DB의 Table들의 Row Count를 Check 하는 Script
#
#   사용법 : tabcnt.sh DB명 (tables 이후 파일명)
#
####################################################################

export TOOL=$HOME/tool

if [ ! "$1" ]
then

echo '사용법 : tabcnt.sh DB명 (tables 이후 파일명)'

else

if [ -f $1_$2.cnt ]; then rm $1_$2.cnt
fi
if [ -f $TOOL/tmp/tabcnt.tmp ]; then rm $TOOL/tmp/tabcnt.tmp
fi

for i in `cat tables$2`
do
dbaccess $1<<!
set isolation to dirty read;
unload to $TOOL/tmp/tabcnt.tmp delimiter ' '
select '$i' tabname, count(*)::int8 from $i;
!
if [ -f $TOOL/tmp/tabcnt.tmp ]
then
cat $TOOL/tmp/tabcnt.tmp >> $1_$2.cnt
rm $TOOL/tmp/tabcnt.tmp
else
echo $i' NotExists' >> $1_$2.cnt
fi
done

fi
