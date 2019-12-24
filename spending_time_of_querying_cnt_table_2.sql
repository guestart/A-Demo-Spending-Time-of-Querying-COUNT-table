REM
REM     Script:        spending_time_of_querying_cnt_table_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 24, 2019
REM
REM     Last tested:
REM             11.2.0.4
REM             18.3.0.0
REM             19.5.0.0 (Live SQL)
REM
REM     Purpose:
REM        This Demo script mainly contains three sections. They're as follows:
REM           (1) creating user 'QWZ';
REM           (2) using 4 separate procedures to quickly create 4 different tables,
REM               'TEST2', 'TEST2_PK', 'TEST2_BI' and 'TEST2_PK_BI';
REM           (3) creating a model consuming time of querying count(*|1|id|flag)
REM               on the previous 4 different tables;
REM        By the way those tables are going to be dynamically created by using several
REM        oracle PL/SQL procedures. I just use 'CTAS' (a very simple approach creating table)
REM        to create my TEST2 tables with two physical properties (SEGMENT CREATION IMMEDIATE and
REM        NOLOGGING) and a table property (PARALLEL).
REM

PROMPT =====================
PROMPT version 11.2 and 18.3
PROMPT =====================

PROMPT ***************************************************************************************
PROMPT * Creating user 'QWZ', permanent tablespace 'QWZ', and temporary tablespace 'QWZ_TMP' *
PROMPT * Granting several related privileges for 'SYS', 'ROLE' and 'TAB' to user 'QWZ'.      *
PROMPT ***************************************************************************************

CONN / AS SYSDBA;

CREATE TABLESPACE qwz DATAFILE '/*+ specific location of your datafile on Oracle 11.2 or 18.3 */qwz_01.dbf' SIZE 5g AUTOEXTEND ON NEXT 5g MAXSIZE 25g;
CREATE TEMPORARY TABLESPACE qwz_tmp TEMPFILE '/opt/oracle/oradata/ORA18C/datafile/qwz_tmp_01.dbf' SIZE 500m;
CREATE USER qwz IDENTIFIED BY qwz DEFAULT TABLESPACE qwz TEMPORARY TABLESPACE qwz_tmp QUOTA UNLIMITED ON qwz;
GRANT alter session TO qwz;
GRANT create any table TO qwz;
GRANT connect, resource TO qwz;
GRANT select ON v_$sql_plan TO qwz;
GRANT select ON v_$session TO qwz;
GRANT select ON v_$sql_plan_statistics_all TO qwz;
GRANT select ON v_$sql TO qwz;

PROMPT ********************************************************************
PROMPT * Using 4 separate procedures to quickly create 4 different tables *
PROMPT *  (1) test2: no primary key and bitmap index;                     *
PROMPT *  (2) test2_pk: only primary key  => test2_only_pk;               *
PROMPT *  (3) test2_bi: only bitmap index => test2_only_bi;               *
PROMPT *  (4) test2_pk_bi: primary key    => test2_pk,                    *
PROMPT *                   bitmap index   => test2_bi;                    *
PROMPT ********************************************************************

CONN qwz/qwz

SET TIMING ON

CREATE OR REPLACE PROCEDURE crt_tab_test2
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test2 PURGE';
   v_sql_2 := q'[CREATE TABLE test2 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST2'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST2'
      );
END crt_tab_test2;
/

CREATE OR REPLACE PROCEDURE crt_tab_test2_pk
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test2_pk PURGE';
   v_sql_2 := q'[CREATE TABLE test2_pk 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE 'ALTER TABLE test2_pk ADD CONSTRAINT test2_only_pk PRIMARY KEY (id)';
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST2_PK'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE 'ALTER TABLE test2_pk ADD CONSTRAINT test2_only_pk PRIMARY KEY (id)';
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST2_PK'
      );
END crt_tab_test2_pk;
/

CREATE OR REPLACE PROCEDURE crt_tab_test2_bi
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test2_bi PURGE';
   v_sql_2 := q'[CREATE TABLE test2_bi 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test2_only_bi ON test2_bi (flag)';
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST2_BI'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test2_only_bi ON test2_bi (flag)';
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST2_BI'
      );
END crt_tab_test2_bi;
/

CREATE OR REPLACE PROCEDURE crt_tab_test2_pk_bi
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test2_pk_bi PURGE';
   v_sql_2 := q'[CREATE TABLE test2_pk_bi 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE 'ALTER TABLE test2_pk_bi ADD CONSTRAINT test2_pk PRIMARY KEY (id)';
   EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test2_bi ON test2_pk_bi (flag)';
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST2_PK_BI'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE 'ALTER TABLE test2_pk_bi ADD CONSTRAINT test2_pk PRIMARY KEY (id)';
      EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test2_bi ON test2_pk_bi (flag)';
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST2_PK_BI'
      );
END crt_tab_test2_pk_bi;
/

PROMPT *****************************************************************************************
PROMPT * Creating a model consuming time of querying count(*|1|id|flag) on 4 different tables  *
PROMPT * 'TEST2', 'TEST2_PK', 'TEST2_BI' and 'TEST2_PK_BI', so that we're able to conveniently *
PROMPT * compare what the difference of their spending time is.                                *
PROMPT *****************************************************************************************

CREATE TABLE cnt_method_2 (
   mark VARCHAR2(4) CONSTRAINT cnt_method_2_pk PRIMARY KEY,
   CONSTRAINT cnt_method_2_ck CHECK (mark IN ('*', '1', 'id', 'flag'))
);

INSERT INTO cnt_method_2 (mark) VALUES ('*');
INSERT INTO cnt_method_2 (mark) VALUES ('1');
INSERT INTO cnt_method_2 (mark) VALUES ('id');
INSERT INTO cnt_method_2 (mark) VALUES ('flag');

COMMIT;

CREATE TABLE tab_stru_2 (
   name VARCHAR2(12) NOT NULL,
   mark VARCHAR2(10) CONSTRAINT tab_stru_2_pk PRIMARY KEY,
   CONSTRAINT tab_stru_2_ck_1 CHECK (name IN ('test2', 'test2_pk', 'test2_bi', 'test2_pk_bi')),
   CONSTRAINT tab_stru_2_ck_2 CHECK (mark IN ('no_pk_bi', 'only_pk', 'only_bi', 'both_pk_bi'))
);

INSERT INTO tab_stru_2 (name, mark) VALUES ('test2', 'no_pk_bi');
INSERT INTO tab_stru_2 (name, mark) VALUES ('test2_pk', 'only_pk');
INSERT INTO tab_stru_2 (name, mark) VALUES ('test2_bi', 'only_bi');
INSERT INTO tab_stru_2 (name, mark) VALUES ('test2_pk_bi', 'both_pk_bi');

COMMIT;

CREATE TABLE cnt_spd_time_2 (
   tab_num   NUMBER NOT NULL,
   tab_mark  VARCHAR2(10) NOT NULL,
   cnt_mark  VARCHAR2(4) NOT NULL,
   spd_time  NUMBER NOT NULL,
   time_unit VARCHAR2(1) DEFAULT 's',
   CONSTRAINT cnt_spd_time_2_pk PRIMARY KEY (tab_num, tab_mark, cnt_mark),
   CONSTRAINT cnt_spd_time_2_fk_1 FOREIGN KEY (tab_mark) REFERENCES tab_stru_2 (mark),
   CONSTRAINT cnt_spd_time_2_fk_2 FOREIGN KEY (cnt_mark) REFERENCES cnt_method_2 (mark)
);

CREATE OR REPLACE FUNCTION two_timestamp_interval (endtime IN TIMESTAMP, starttime IN TIMESTAMP)
RETURN NUMBER
AS
   str VARCHAR2(50);
   seconds  NUMBER;
   minutes  NUMBER;
   hours    NUMBER;
   days     NUMBER;
BEGIN
   str := TO_CHAR(endtime - starttime);
   seconds := TO_NUMBER(SUBSTR(str, INSTR(str, ' ')+7));
   minutes := TO_NUMBER(SUBSTR(str, INSTR(str, ' ')+4, 2));
   hours := TO_NUMBER(SUBSTR(str, INSTR(str, ' ')+1, 2));
   days := TO_NUMBER(SUBSTR(str, 1, INSTR(str, ' ')));
   RETURN (days*24*60*60 + hours*60*60 + minutes*60 + seconds);
END two_timestamp_interval;
/

CREATE OR REPLACE PROCEDURE cnt_tab_spd_time_2
AS
   line_nums       NUMBER;
   start_time      TIMESTAMP;
   end_time        TIMESTAMP;
   consume_seconds NUMBER;
   v_name   tab_stru_2.name%TYPE;
   v_mark_1 tab_stru_2.mark%TYPE;
   v_mark_2 cnt_method_2.mark%TYPE;
BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TIMESTAMP_FORMAT = ''YYYY-MM-DD HH24:MI:SS.FF''';
   FOR cur1 IN (SELECT * FROM tab_stru_2 ORDER BY ROWID) LOOP
      FOR cur2 IN (SELECT * FROM cnt_method_2 ORDER BY ROWID) LOOP
         v_name := cur1.name;
         v_mark_1 := cur1.mark;
         v_mark_2 := cur2.mark;
         start_time := SYSTIMESTAMP;
         EXECUTE IMMEDIATE 'SELECT COUNT(' || v_mark_2 || ') FROM ' || v_name INTO line_nums;
         end_time := SYSTIMESTAMP;
         consume_seconds := two_timestamp_interval(end_time, start_time);
         INSERT INTO cnt_spd_time_2 (tab_num, tab_mark, cnt_mark, spd_time, time_unit) VALUES (line_nums, v_mark_1, v_mark_2, consume_seconds, DEFAULT);
         COMMIT;
      END LOOP;
   END LOOP;
END cnt_tab_spd_time_2;
/
