#!/bin/ksh

### chkcol을 이용하여 Table의 컬럼 정보를 tab_cols에 입력하는 Script

dbaccess dbname@tst_tcp <<!
	delete from tab_cols;
!

if [ -f tab_cols.unl ]; then rm tab_cols.unl; fi

for i in `cat tables_p`
do
        chkcol $i >> tab_cols.unl
done

echo '1,$s/$/|p/g\nw\nq' | ed tab_cols.unl

dbaccess dbname@tst_tcp <<!
	load from tab_cols.unl insert into tab_cols (테이블명, 현재컬럼명, 현재타입, 테이블유형);
!

if [ -f tab_cols.unl ]; then rm tab_cols.unl; fi

for i in `cat tables_m`
do
        chkcol $i >> tab_cols.unl
done

echo '1,$s/$/|p/g\nw\nq' | ed tab_cols.unl

dbaccess dbname@tst_tcp <<!
	load from tab_cols.unl insert into tab_cols (테이블명, 현재컬럼명, 현재타입, 테이블유형);
!

if [ -f tab_cols.unl ]; then rm tab_cols.unl; fi

for i in `cat tables_d`
do
        chkcol $i >> tab_cols.unl
done

echo '1,$s/$/|p/g\nw\nq' | ed tab_cols.unl

dbaccess dbname@tst_tcp <<!
	load from tab_cols.unl insert into tab_cols (테이블명, 현재컬럼명, 현재타입, 테이블유형);
!

#create table "informix".tab_cols
#  (
#    테이블유형 char(1),
#    테이블명 varchar(128),
#    현재컬럼명 varchar(128),
#    현재타입 varchar(128),
#    한글컬럼명 varchar(128),
#    신규컬럼명 varchar(128),
#    신규타입 varchar(128),
#    표준컬럼코드 char(5),
#    상세설명 varchar(255),
#    관련업무 varchar(255),
#    기록자 varchar(255)
#  )  extent size 1000 next size 1000 lock mode row;
#revoke all on "informix".tab_cols from "public";
