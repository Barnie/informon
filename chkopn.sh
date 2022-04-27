#!/bin/ksh

#########################################################################
#
#   chkopn : Table을 Open 하고 있는 Session을 보여주는 Shell입니다
#
#   작성자 : 바니                 표준버전 : v0.2
#
#   사용법 : chkopn [Table명]
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
export TempFile2=$TOOL/tmp/`ech' $0 | $CAWK -F '/' '{ print $NF }'`.tmp2_${TempTail}
                                echo $lines' '`cat $TempFile2 | wc -l` | ${TempTail}
 총 '`cat $TempFile1 | wc -l`'개의 Object가 Open 되었습니다'tf("%6.2f%", 100 - $2 * 100 / $1); }'
                        elsem $TempFile1; fi
                export cnt=1    breakle2; fi
                for i in `cat $TempFile1` fi
                done#####################################################
                        if [ $cnt -gt 1 ]; then echo ',\c' >> $TempFile2; fi
                        export tblsnum="16#"`echo $i | $CAWK '{print substr($1, 3, length($1)-2)}'`
                        typeset -i10 tblsnum#############################
                        echo $tblsnum'\c' >> $TempFile2
                        export cnt=`expr $cnt + 1`
                doneAME" ]
        then export dbname="dbname"
                rm $TempFile1BNAME
        fi
                dbaccess sysmaster<<! 1> /dev/null 2> /dev/null
                        set isolation to dirty read;
                        unload to $TempFile1 delimiter ' '###############
                        select {+INDEX(systabnames systabs_pnix)}
                               dbsname, tabname
                          from systabnames###############################
                         where partnum IN (`cat $TempFile2`);
!cho
                rm $TempFile2
if [ ! "$1" ]
                echo '--------------------------------------'
                echo 'Database Name   Object Name           '
                echo '--------------------------------------'
                cat $TempFile1 | $CAWK -F ' ' '{
                        { printf("%13s : %-30s\n", $1, $2); }
                }'lect lower(hex(partnum))
                echo '--------------------------------------'
                 where tabname = 'systables'
        else

                echo '결과가 없습니다.'
        then
        fi      export systables=`cat $TempFile1`
                rm $TempFile1
        else
else            export systables='0x00000000'
        fi

        dbaccess sysmaster<<! 1> /dev/null 2> /dev/null'tid' | egrep -v '^$' | egrep -v $systables |
                set isolation to dirty read;
                unload to $TempFile1 delimiter ' '
                select lower(hex(partnum)) from systabnames
                 where dbsname = '$dbname'
                   and tabname = '$1'
!       then
                if [ -f $TempFile1 ]; then rm $TempFile1; fi
        if [ -f $TempFile1 ]
        then    clear
                export partnum=`cat $TempFile1`wc -l`
                rm $TempFile1-------------------------------'
        else    echo '    Object Open 정보 중복 제거 작업   '
                export partnum='0x00000000'-----------------'
        fi      printf '%10d' $lines; echo 'Line : 작업진행율 :   0.00%'
                echo '--------------------------------------'
        onstat -g opn | egrep -v 'Informix' | egrep -v 'tid' | egrep -v '^$' | grep $partnum |
                $CAWK -F ' ' '{
                        { print $1 }
                }' > $TempFile1at $TempFile2 | wc -l` -gt 0 ]
                        then
                                head -1 $TempFile2 >> $TempFile1
        if [ -f $TempFile1 ]    echo '1,$g/^'`head -1 $TempFile2`'/d\nw\nq' | ed $TempFile2 > /dev/null
        then                    printf '

                for i in `cat $TempFile1`
                do
                        dbaccess sysmaster<<! 1> /dev/null 2> /dev/null
                                set isolation to dirty read;
                                unload to $TempFile2 delimiter ' '
                                select c.cbl_sessionid, s.username, s.pid,
                                       decode(s.ttyin, "", "-", s.ttyin) ttyin
                                  from sysconblock c, sysscblst s, sysrstcb r
                                 where r.tid = $i
                                   and c.cbl_sessionid = s.sid
                                   and s.sid = r.sid;
!
                        if [ -f $TempFile2 ]; then
                                cat $TempFile2 >> $TempFile3
                                rm $TempFile2
                        fi
                done

                rm $TempFile1

                if [ -f $TempFile3 ]
                then

                        echo '-------------------------------------------------------'
                        echo 'Session ID  User Name   Terminal    Process Information'
                        echo '-------------------------------------------------------'

                        cat $TempFile3 | $CAWK -F ' ' '{
                                {
                                        printf("%10d  %-10s  %-10s  ", $1, $2, $4);
                    if ($3 > -1 )
                        system("echo `UNIX95= ps -eo pid,comm | grep \""$3" \"`");
                                        else
                        printf("Unknown Process : 외부접속 가능성 있음\n");
                                }
                        }'

                        echo '-------------------------------------------------------'

                else
                        echo '결과가 없습니다.'
                fi

        else

                echo '결과가 없습니다.'

        fi

fi
