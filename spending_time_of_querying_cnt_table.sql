REM
REM     Script:        spending_time_of_querying_cnt_table.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 24, 2019
REM     Updated:       Dec 29, 2019
REM                    adding some SQL statments queryig table 'cnt_spd_time' according to different 8 dimensions.
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
REM               'TEST', 'TEST_PK', 'TEST_BI' and 'TEST_PK_BI';
REM           (3) creating a model consuming time of querying count(*|1|id|flag)
REM               on the previous 4 different tables;
REM        By the way those tables are going to be dynamically created by using several
REM        oracle PL/SQL procedures. I just use 'CTAS' (a very simple approach creating table)
REM        to create my TEST tables with two physical properties (SEGMENT CREATION IMMEDIATE and
REM        NOLOGGING) and a table property (NO PARALLEL).
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
PROMPT *  (1) test: no primary key and bitmap index;                      *
PROMPT *  (2) test_pk: only primary key  => test_only_pk;                 *
PROMPT *  (3) test_bi: only bitmap index => test_only_bi;                 *
PROMPT *  (4) test_pk_bi: primary key    => test_pk,                      *
PROMPT *                  bitmap index   => test_bi;                      *
PROMPT ********************************************************************

CONN qwz/qwz

SET TIMING ON

CREATE OR REPLACE PROCEDURE crt_tab_test
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test PURGE';
   v_sql_2 := q'[CREATE TABLE test 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 -- PARALLEL 10 
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
           TABNAME            => 'TEST'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST'
      );
END crt_tab_test;
/

CREATE OR REPLACE PROCEDURE crt_tab_test_pk
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test_pk PURGE';
   v_sql_2 := q'[CREATE TABLE test_pk 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 -- PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE 'ALTER TABLE test_pk ADD CONSTRAINT test_only_pk PRIMARY KEY (id)';
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST_PK'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE 'ALTER TABLE test_pk ADD CONSTRAINT test_only_pk PRIMARY KEY (id)';
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST_PK'
      );
END crt_tab_test_pk;
/

CREATE OR REPLACE PROCEDURE crt_tab_test_bi
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test_bi PURGE';
   v_sql_2 := q'[CREATE TABLE test_bi 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 -- PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test_only_bi ON test_bi (flag)';
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST_BI'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test_only_bi ON test_bi (flag)';
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST_BI'
      );
END crt_tab_test_bi;
/

CREATE OR REPLACE PROCEDURE crt_tab_test_pk_bi
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test_pk_bi PURGE';
   v_sql_2 := q'[CREATE TABLE test_pk_bi 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 -- PARALLEL 10 
                 AS SELECT ROWNUM id 
                           , CASE WHEN ROWNUM BETWEEN  1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[              WHEN ROWNUM BETWEEN  2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[              WHEN ROWNUM BETWEEN  4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[              ELSE 'unknown' 
                             END flag 
                    FROM XMLTABLE('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE 'ALTER TABLE test_pk_bi ADD CONSTRAINT test_pk PRIMARY KEY (id)';
   EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test_bi ON test_pk_bi (flag)';
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST_PK_BI'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE 'ALTER TABLE test_pk_bi ADD CONSTRAINT test_pk PRIMARY KEY (id)';
      EXECUTE IMMEDIATE 'CREATE BITMAP INDEX test_bi ON test_pk_bi (flag)';
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST_PK_BI'
      );
END crt_tab_test_pk_bi;
/

EXECUTE crt_tab_test;
EXECUTE crt_tab_test_pk;
EXECUTE crt_tab_test_bi;
EXECUTE crt_tab_test_pk_bi;

PROMPT ****************************************************************************************
PROMPT * Creating a model consuming time of querying count(*|1|id|flag) on 4 different tables *
PROMPT * 'TEST', 'TEST_PK', 'TEST_BI' and 'TEST_PK_BI', so that we're able to conveniently    *
PROMPT * compare what the difference of their spending time is.                               *
PROMPT ****************************************************************************************

CREATE TABLE cnt_method (
   mark VARCHAR2(4) CONSTRAINT cnt_method_pk PRIMARY KEY,
   CONSTRAINT cnt_method_ck CHECK (mark IN ('*', '1', 'id', 'flag'))
);

INSERT INTO cnt_method (mark) VALUES ('*');
INSERT INTO cnt_method (mark) VALUES ('1');
INSERT INTO cnt_method (mark) VALUES ('id');
INSERT INTO cnt_method (mark) VALUES ('flag');

COMMIT;

CREATE TABLE tab_stru (
   name VARCHAR2(10) NOT NULL,
   mark VARCHAR2(10) CONSTRAINT tab_stru_pk PRIMARY KEY,
   CONSTRAINT tab_stru_ck_1 CHECK (name IN ('test', 'test_pk', 'test_bi', 'test_pk_bi')),
   CONSTRAINT tab_stru_ck_2 CHECK (mark IN ('no_pk_bi', 'only_pk', 'only_bi', 'both_pk_bi'))
);

INSERT INTO tab_stru (name, mark) VALUES ('test', 'no_pk_bi');
INSERT INTO tab_stru (name, mark) VALUES ('test_pk', 'only_pk');
INSERT INTO tab_stru (name, mark) VALUES ('test_bi', 'only_bi');
INSERT INTO tab_stru (name, mark) VALUES ('test_pk_bi', 'both_pk_bi');

COMMIT;

CREATE TABLE cnt_spd_time (
   tab_num   NUMBER NOT NULL,
   tab_mark  VARCHAR2(10) NOT NULL,
   cnt_mark  VARCHAR2(4) NOT NULL,
   spd_time  NUMBER NOT NULL,
   time_unit VARCHAR2(1) DEFAULT 's',
   CONSTRAINT cnt_spd_time_pk PRIMARY KEY (tab_num, tab_mark, cnt_mark),
   CONSTRAINT cnt_spd_time_fk_1 FOREIGN KEY (tab_mark) REFERENCES tab_stru (mark),
   CONSTRAINT cnt_spd_time_fk_2 FOREIGN KEY (cnt_mark) REFERENCES cnt_method (mark)
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

CREATE OR REPLACE PROCEDURE cnt_tab_spd_time
AS
   line_nums       NUMBER;
   start_time      TIMESTAMP;
   end_time        TIMESTAMP;
   consume_seconds NUMBER;
   v_name   tab_stru.name%TYPE;
   v_mark_1 tab_stru.mark%TYPE;
   v_mark_2 cnt_method.mark%TYPE;
BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TIMESTAMP_FORMAT = ''YYYY-MM-DD HH24:MI:SS.FF''';
   FOR cur1 IN (SELECT * FROM tab_stru ORDER BY ROWID) LOOP
      FOR cur2 IN (SELECT * FROM cnt_method ORDER BY ROWID) LOOP
         v_name := cur1.name;
         v_mark_1 := cur1.mark;
         v_mark_2 := cur2.mark;
         start_time := SYSTIMESTAMP;
         EXECUTE IMMEDIATE 'SELECT COUNT(' || v_mark_2 || ') FROM ' || v_name INTO line_nums;
         end_time := SYSTIMESTAMP;
         consume_seconds := two_timestamp_interval(end_time, start_time);
         INSERT INTO cnt_spd_time (tab_num, tab_mark, cnt_mark, spd_time, time_unit) VALUES (line_nums, v_mark_1, v_mark_2, consume_seconds, DEFAULT);
         COMMIT;
      END LOOP;
   END LOOP;
END cnt_tab_spd_time;
/

EXECUTE cnt_tab_spd_time;

SELECT * FROM cnt_spd_time;

PROMPT =====================
PROMPT spending time on 18.3
PROMPT =====================

-- SQL> SELECT * FROM cnt_spd_time;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   *      1.667343 s
--   50000000 no_pk_bi   1       .787276 s
--   50000000 no_pk_bi   id      1.28991 s
--   50000000 no_pk_bi   flag   1.349071 s
--   50000000 only_pk    *      1.991366 s
--   50000000 only_pk    1      1.585741 s
--   50000000 only_pk    id     1.595641 s
--   50000000 only_pk    flag   1.741364 s
--   50000000 only_bi    *       .023629 s
--   50000000 only_bi    1       .012871 s
--   50000000 only_bi    id     1.703165 s
--   50000000 only_bi    flag    .928293 s
--   50000000 both_pk_bi *       .019995 s
--   50000000 both_pk_bi 1       .012551 s
--   50000000 both_pk_bi id      .011584 s
--   50000000 both_pk_bi flag    .914173 s
-- 
-- 16 rows selected.

-- Demo1_18c_no_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'no_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   *      1.667343 s
--   50000000 no_pk_bi   1       .787276 s
--   50000000 no_pk_bi   id      1.28991 s
--   50000000 no_pk_bi   flag   1.349071 s
-- 
-- Demo1_18c_only_pk:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_pk' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 only_pk    *      1.991366 s
--   50000000 only_pk    1      1.585741 s
--   50000000 only_pk    id     1.595641 s
--   50000000 only_pk    flag   1.741364 s
-- 
-- Demo1_18c_only_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 only_bi    *       .023629 s
--   50000000 only_bi    1       .012871 s
--   50000000 only_bi    id     1.703165 s
--   50000000 only_bi    flag    .928293 s
-- 
-- Demo1_18c_both_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'both_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 both_pk_bi *       .019995 s
--   50000000 both_pk_bi 1       .012551 s
--   50000000 both_pk_bi id      .011584 s
--   50000000 both_pk_bi flag    .914173 s
-- 
-- Demo1_18c_asterisk:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '*' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   *      1.667343 s
--   50000000 only_pk    *      1.991366 s
--   50000000 only_bi    *       .023629 s
--   50000000 both_pk_bi *       .019995 s
-- 
-- Demo1_18c_1:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '1' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   1       .787276 s
--   50000000 only_pk    1      1.585741 s
--   50000000 only_bi    1       .012871 s
--   50000000 both_pk_bi 1       .012551 s
-- 
-- Demo1_18c_id:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'id' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   id      1.28991 s
--   50000000 only_pk    id     1.595641 s
--   50000000 only_bi    id     1.703165 s
--   50000000 both_pk_bi id      .011584 s
-- 
-- Demo1_18c_flag:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'flag' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   flag   1.349071 s
--   50000000 only_pk    flag   1.741364 s
--   50000000 only_bi    flag    .928293 s
--   50000000 both_pk_bi flag    .914173 s

PROMPT =====================
PROMPT spending time on 11.2
PROMPT =====================

-- SQL> SELECT * FROM cnt_spd_time;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME T
-- ---------- -------------------- -------- ---------- -
--   50000000 no_pk_bi             *          1.590687 s
--   50000000 no_pk_bi             1          1.184074 s
--   50000000 no_pk_bi             id         1.666568 s
--   50000000 no_pk_bi             flag       1.770705 s
--   50000000 only_pk              *          2.371787 s
--   50000000 only_pk              1          2.075631 s
--   50000000 only_pk              id         2.087134 s
--   50000000 only_pk              flag       1.717795 s
--   50000000 only_bi              *           .035909 s
--   50000000 only_bi              1           .025202 s
--   50000000 only_bi              id         2.201092 s
--   50000000 only_bi              flag        1.18439 s
--   50000000 both_pk_bi           *            .02406 s
--   50000000 both_pk_bi           1            .01521 s
--   50000000 both_pk_bi           id          .014518 s
--   50000000 both_pk_bi           flag       1.166561 s
-- 
-- 16 rows selected.

-- Demo1_11g_no_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'no_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             *          1.590687 s
--   50000000 no_pk_bi             1          1.184074 s
--   50000000 no_pk_bi             id         1.666568 s
--   50000000 no_pk_bi             flag       1.770705 s
-- 
-- Demo1_11g_only_pk:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_pk' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 only_pk              *          2.371787 s
--   50000000 only_pk              1          2.075631 s
--   50000000 only_pk              id         2.087134 s
--   50000000 only_pk              flag       1.717795 s
-- 
-- Demo1_11g_only_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 only_bi              *           .035909 s
--   50000000 only_bi              1           .025202 s
--   50000000 only_bi              id         2.201092 s
--   50000000 only_bi              flag        1.18439 s
-- 
-- Demo1_11g_both_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'both_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 both_pk_bi           *            .02406 s
--   50000000 both_pk_bi           1            .01521 s
--   50000000 both_pk_bi           id          .014518 s
--   50000000 both_pk_bi           flag       1.166561 s
-- 
-- Demo1_11g_asterisk:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '*' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             *          1.590687 s
--   50000000 only_pk              *          2.371787 s
--   50000000 only_bi              *           .035909 s
--   50000000 both_pk_bi           *            .02406 s
-- 
-- Demo1_11g_1:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '1' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             1          1.184074 s
--   50000000 only_pk              1          2.075631 s
--   50000000 only_bi              1           .025202 s
--   50000000 both_pk_bi           1            .01521 s
-- 
-- Demo1_11g_id:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'id' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             id         1.666568 s
--   50000000 only_pk              id         2.087134 s
--   50000000 only_bi              id         2.201092 s
--   50000000 both_pk_bi           id          .014518 s
-- 
-- Demo1_11g_flag:
-- 
-- SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'flag' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             flag       1.770705 s
--   50000000 only_pk              flag       1.717795 s
--   50000000 only_bi              flag        1.18439 s
--   50000000 both_pk_bi           flag       1.166561 s
