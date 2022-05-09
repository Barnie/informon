#!/bin/ksh

### chkcol�� �̿��Ͽ� Table�� �÷� ������ tab_cols�� �Է��ϴ� Script

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
	load from tab_cols.unl insert into tab_cols (���̺��, �����÷���, ����Ÿ��, ���̺�����);
!

if [ -f tab_cols.unl ]; then rm tab_cols.unl; fi

for i in `cat tables_m`
do
        chkcol $i >> tab_cols.unl
done

echo '1,$s/$/|p/g\nw\nq' | ed tab_cols.unl

dbaccess dbname@tst_tcp <<!
	load from tab_cols.unl insert into tab_cols (���̺��, �����÷���, ����Ÿ��, ���̺�����);
!

if [ -f tab_cols.unl ]; then rm tab_cols.unl; fi

for i in `cat tables_d`
do
        chkcol $i >> tab_cols.unl
done

echo '1,$s/$/|p/g\nw\nq' | ed tab_cols.unl

dbaccess dbname@tst_tcp <<!
	load from tab_cols.unl insert into tab_cols (���̺��, �����÷���, ����Ÿ��, ���̺�����);
!

#create table "informix".tab_cols
#  (
#    ���̺����� char(1),
#    ���̺�� varchar(128),
#    �����÷��� varchar(128),
#    ����Ÿ�� varchar(128),
#    �ѱ��÷��� varchar(128),
#    �ű��÷��� varchar(128),
#    �ű�Ÿ�� varchar(128),
#    ǥ���÷��ڵ� char(5),
#    �󼼼��� varchar(255),
#    ���þ��� varchar(255),
#    ����� varchar(255)
#  )  extent size 1000 next size 1000 lock mode row;
#revoke all on "informix".tab_cols from "public";
