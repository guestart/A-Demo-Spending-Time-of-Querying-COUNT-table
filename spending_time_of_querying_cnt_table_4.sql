REM
REM     Script:        spending_time_of_querying_cnt_table_4.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 25, 2019
REM     Updated:       Dec 29, 2019
REM                    adding some SQL statments queryig table 'cnt_spd_time_4' according to different 8 dimensions.
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
REM               'TEST4', 'TEST4_PK', 'TEST4_BI' and 'TEST4_PK_BI';
REM           (3) creating a model consuming time of querying count(*|1|id|flag)
REM               on the previous 4 different tables;
REM        By the way those tables are going to be dynamically created by using several
REM        oracle PL/SQL procedures. I just use the standard SQL syntax 'CREATE TABLE'
REM        to create my TEST4 tables with two physical properties (SEGMENT CREATION IMMEDIATE and
REM        NOLOGGING) and a table property (PARALLEL) and then also create corresponding
REM        PRIMARY KEY or BITMAP INDEX on those different TEST4 tables. Finally inserting
REM        several test data with '5e7' lines to my all TEST4 tables using the hint 'append'.
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
PROMPT *  (1) test4: no primary key and bitmap index;                     *
PROMPT *  (2) test4_pk: only primary key  => test4_only_pk;               *
PROMPT *  (3) test4_bi: only bitmap index => test4_only_bi;               *
PROMPT *  (4) test4_pk_bi: primary key    => test4_pk,                    *
PROMPT *                   bitmap index   => test4_bi;                    *
PROMPT ********************************************************************

CONN qwz/qwz

SET TIMING ON

CREATE OR REPLACE PROCEDURE crt_tab_test4
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
   v_sql_3 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test4 PURGE';
   v_sql_2 := q'[CREATE TABLE test4 ( 
                    id     NUMBER      NOT NULL 
                    , flag VARCHAR2(7) NOT NULL 
                 ) 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10
                ]';
   v_sql_3 := q'[INSERT /*+ append */ INTO test4 
                 SELECT ROWNUM id 
                        , CASE WHEN ROWNUM BETWEEN 1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[           WHEN ROWNUM BETWEEN 2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[           WHEN ROWNUM BETWEEN 4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[           ELSE 'unknown' 
                          END flag 
                 FROM XMLTABLE ('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE v_sql_3;
   COMMIT;
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST4'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE v_sql_3;
      COMMIT;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST4'
      );
END crt_tab_test4;
/

CREATE OR REPLACE PROCEDURE crt_tab_test4_pk
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
   v_sql_3 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test4_pk PURGE';
   v_sql_2 := q'[CREATE TABLE test4_pk ( 
                    id     NUMBER      NOT NULL CONSTRAINT test4_only_pk PRIMARY KEY 
                    , flag VARCHAR2(7) NOT NULL 
                 ) 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10
                ]';
   v_sql_3 := q'[INSERT /*+ append */ INTO test4_pk 
                 SELECT ROWNUM id 
                        , CASE WHEN ROWNUM BETWEEN 1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[           WHEN ROWNUM BETWEEN 2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[           WHEN ROWNUM BETWEEN 4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[           ELSE 'unknown' 
                          END flag 
                 FROM XMLTABLE ('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE v_sql_3;
   COMMIT;
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST4_PK'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE v_sql_3;
      COMMIT;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST4_PK'
      );
END crt_tab_test4_pk;
/

CREATE OR REPLACE PROCEDURE crt_tab_test4_bi
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
   v_sql_3 VARCHAR2(2000);
   v_sql_4 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test4_bi PURGE';
   v_sql_2 := q'[CREATE TABLE test4_bi ( 
                    id     NUMBER      NOT NULL 
                    , flag VARCHAR2(7) NOT NULL 
                 ) 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10
                ]';
   v_sql_3 := 'CREATE BITMAP INDEX test4_only_bi ON test4_bi (flag)';
   v_sql_4 := q'[INSERT /*+ append */ INTO test4_bi 
                 SELECT ROWNUM id 
                        , CASE WHEN ROWNUM BETWEEN 1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[           WHEN ROWNUM BETWEEN 2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[           WHEN ROWNUM BETWEEN 4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[           ELSE 'unknown' 
                          END flag 
                 FROM XMLTABLE ('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE v_sql_3;
   EXECUTE IMMEDIATE v_sql_4;
   COMMIT;
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST4_BI'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE v_sql_3;
      EXECUTE IMMEDIATE v_sql_4;
      COMMIT;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST4_BI'
      );
END crt_tab_test4_bi;
/

CREATE OR REPLACE PROCEDURE crt_tab_test4_pk_bi
AS
   v_num   NUMBER;
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
   v_sql_3 VARCHAR2(2000);
   v_sql_4 VARCHAR2(2000);
BEGIN
   v_num := 5e7;
   v_sql_1 := 'DROP TABLE test4_pk_bi PURGE';
   v_sql_2 := q'[CREATE TABLE test4_pk_bi ( 
                    id     NUMBER      NOT NULL CONSTRAINT test4_pk PRIMARY KEY 
                    , flag VARCHAR2(7) NOT NULL 
                 ) 
                 SEGMENT CREATION IMMEDIATE 
                 NOLOGGING 
                 PARALLEL 10
                ]';
   v_sql_3 := 'CREATE BITMAP INDEX test4_bi ON test4_pk_bi (flag)';
   v_sql_4 := q'[INSERT /*+ append */ INTO test4_pk_bi 
                 SELECT ROWNUM id 
                        , CASE WHEN ROWNUM BETWEEN 1                      AND 1/5*]' || v_num || q'[ THEN 'low' ]'
              || q'[           WHEN ROWNUM BETWEEN 2/5*]' || v_num || q'[ AND 3/5*]' || v_num || q'[ THEN 'mid' ]'
              || q'[           WHEN ROWNUM BETWEEN 4/5*]' || v_num || q'[ AND     ]' || v_num || q'[ THEN 'high' ]'
              || q'[           ELSE 'unknown' 
                          END flag 
                 FROM XMLTABLE ('1 to ]' || v_num || q'[')]';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   EXECUTE IMMEDIATE v_sql_3;
   EXECUTE IMMEDIATE v_sql_4;
   COMMIT;
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'TEST4_PK_BI'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      EXECUTE IMMEDIATE v_sql_3;
      EXECUTE IMMEDIATE v_sql_4;
      COMMIT;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'TEST4_PK_BI'
      );
END crt_tab_test4_pk_bi;
/

EXECUTE crt_tab_test4;
EXECUTE crt_tab_test4_pk;
EXECUTE crt_tab_test4_bi;
EXECUTE crt_tab_test4_pk_bi;

PROMPT *****************************************************************************************
PROMPT * Creating a model consuming time of querying count(*|1|id|flag) on 4 different tables  *
PROMPT * 'TEST4', 'TEST4_PK', 'TEST4_BI' and 'TEST4_PK_BI', so that we're able to conveniently *
PROMPT * compare what the difference of their spending time is.                                *
PROMPT *****************************************************************************************

CREATE TABLE cnt_method_4 (
   mark VARCHAR2(4) CONSTRAINT cnt_method_4_pk PRIMARY KEY,
   CONSTRAINT cnt_method_4_ck CHECK (mark IN ('*', '1', 'id', 'flag'))
);

INSERT INTO cnt_method_4 (mark) VALUES ('*');
INSERT INTO cnt_method_4 (mark) VALUES ('1');
INSERT INTO cnt_method_4 (mark) VALUES ('id');
INSERT INTO cnt_method_4 (mark) VALUES ('flag');

COMMIT;

CREATE TABLE tab_stru_4 (
   name VARCHAR2(12) NOT NULL,
   mark VARCHAR2(10) CONSTRAINT tab_stru_4_pk PRIMARY KEY,
   CONSTRAINT tab_stru_4_ck_1 CHECK (name IN ('test4', 'test4_pk', 'test4_bi', 'test4_pk_bi')),
   CONSTRAINT tab_stru_4_ck_2 CHECK (mark IN ('no_pk_bi', 'only_pk', 'only_bi', 'both_pk_bi'))
);

INSERT INTO tab_stru_4 (name, mark) VALUES ('test4', 'no_pk_bi');
INSERT INTO tab_stru_4 (name, mark) VALUES ('test4_pk', 'only_pk');
INSERT INTO tab_stru_4 (name, mark) VALUES ('test4_bi', 'only_bi');
INSERT INTO tab_stru_4 (name, mark) VALUES ('test4_pk_bi', 'both_pk_bi');

COMMIT;

CREATE TABLE cnt_spd_time_4 (
   tab_num   NUMBER NOT NULL,
   tab_mark  VARCHAR2(10) NOT NULL,
   cnt_mark  VARCHAR2(4) NOT NULL,
   spd_time  NUMBER NOT NULL,
   time_unit VARCHAR2(1) DEFAULT 's',
   CONSTRAINT cnt_spd_time_4_pk PRIMARY KEY (tab_num, tab_mark, cnt_mark),
   CONSTRAINT cnt_spd_time_4_fk_1 FOREIGN KEY (tab_mark) REFERENCES tab_stru_4 (mark),
   CONSTRAINT cnt_spd_time_4_fk_2 FOREIGN KEY (cnt_mark) REFERENCES cnt_method_4 (mark)
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

CREATE OR REPLACE PROCEDURE cnt_tab_spd_time_4
AS
   line_nums       NUMBER;
   start_time      TIMESTAMP;
   end_time        TIMESTAMP;
   consume_seconds NUMBER;
   v_name   tab_stru_4.name%TYPE;
   v_mark_1 tab_stru_4.mark%TYPE;
   v_mark_2 cnt_method_4.mark%TYPE;
BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TIMESTAMP_FORMAT = ''YYYY-MM-DD HH24:MI:SS.FF''';
   FOR cur1 IN (SELECT * FROM tab_stru_4 ORDER BY ROWID) LOOP
      FOR cur2 IN (SELECT * FROM cnt_method_4 ORDER BY ROWID) LOOP
         v_name := cur1.name;
         v_mark_1 := cur1.mark;
         v_mark_2 := cur2.mark;
         start_time := SYSTIMESTAMP;
         EXECUTE IMMEDIATE 'SELECT COUNT(' || v_mark_2 || ') FROM ' || v_name INTO line_nums;
         end_time := SYSTIMESTAMP;
         consume_seconds := two_timestamp_interval(end_time, start_time);
         INSERT INTO cnt_spd_time_4 (tab_num, tab_mark, cnt_mark, spd_time, time_unit) VALUES (line_nums, v_mark_1, v_mark_2, consume_seconds, DEFAULT);
         COMMIT;
      END LOOP;
   END LOOP;
END cnt_tab_spd_time_4;
/

EXECUTE cnt_tab_spd_time_4;

SELECT * FROM cnt_spd_time_4;

PROMPT =====================
PROMPT spending time on 18.3
PROMPT =====================

-- SQL> SELECT * FROM cnt_spd_time_4;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   *       .299654 s
--   50000000 no_pk_bi   1       .270704 s
--   50000000 no_pk_bi   id      .334753 s
--   50000000 no_pk_bi   flag    .300006 s
--   50000000 only_pk    *       .370083 s
--   50000000 only_pk    1       .330951 s
--   50000000 only_pk    id      .343999 s
--   50000000 only_pk    flag     .30551 s
--   50000000 only_bi    *       .123682 s
--   50000000 only_bi    1       .097201 s
--   50000000 only_bi    id      .095966 s
--   50000000 only_bi    flag    .096099 s
--   50000000 both_pk_bi *       .113219 s
--   50000000 both_pk_bi 1       .092135 s
--   50000000 both_pk_bi id      .090911 s
--   50000000 both_pk_bi flag    .089577 s
-- 
-- 16 rows selected.

-- Demo4_18c_no_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'no_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   *       .299654 s
--   50000000 no_pk_bi   1       .270704 s
--   50000000 no_pk_bi   id      .334753 s
--   50000000 no_pk_bi   flag    .300006 s
-- 
-- Demo4_18c_only_pk:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'only_pk' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 only_pk    *       .370083 s
--   50000000 only_pk    1       .330951 s
--   50000000 only_pk    id      .343999 s
--   50000000 only_pk    flag     .30551 s
-- 
-- Demo4_18c_only_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'only_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 only_bi    *       .123682 s
--   50000000 only_bi    1       .097201 s
--   50000000 only_bi    id      .095966 s
--   50000000 only_bi    flag    .096099 s
-- 
-- Demo4_18c_both_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'both_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 both_pk_bi *       .113219 s
--   50000000 both_pk_bi 1       .092135 s
--   50000000 both_pk_bi id      .090911 s
--   50000000 both_pk_bi flag    .089577 s
-- 
-- Demo4_18c_asterisk:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = '*' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   *       .299654 s
--   50000000 only_pk    *       .370083 s
--   50000000 only_bi    *       .123682 s
--   50000000 both_pk_bi *       .113219 s
-- 
-- Demo4_18c_1:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = '1' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   1       .270704 s
--   50000000 only_pk    1       .330951 s
--   50000000 only_bi    1       .097201 s
--   50000000 both_pk_bi 1       .092135 s
-- 
-- Demo4_18c_id:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = 'id' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   id      .334753 s
--   50000000 only_pk    id      .343999 s
--   50000000 only_bi    id      .095966 s
--   50000000 both_pk_bi id      .090911 s
-- 
-- Demo4_18c_flag:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = 'flag' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK   CNT_   SPD_TIME T
-- ---------- ---------- ---- ---------- -
--   50000000 no_pk_bi   flag    .300006 s
--   50000000 only_pk    flag     .30551 s
--   50000000 only_bi    flag    .096099 s
--   50000000 both_pk_bi flag    .089577 s

PROMPT =====================
PROMPT spending time on 11.2
PROMPT =====================

-- SQL> SELECT * FROM cnt_spd_time_4;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME T
-- ---------- -------------------- -------- ---------- -
--   50000000 no_pk_bi             *          2.447162 s
--   50000000 no_pk_bi             1          1.916814 s
--   50000000 no_pk_bi             id         1.868669 s
--   50000000 no_pk_bi             flag       1.723454 s
--   50000000 only_pk              *          1.762631 s
--   50000000 only_pk              1          1.762798 s
--   50000000 only_pk              id         1.750415 s
--   50000000 only_pk              flag       1.716138 s
--   50000000 only_bi              *            .02717 s
--   50000000 only_bi              1           .024324 s
--   50000000 only_bi              id           .02363 s
--   50000000 only_bi              flag        .024147 s
--   50000000 both_pk_bi           *           .026919 s
--   50000000 both_pk_bi           1           .024756 s
--   50000000 both_pk_bi           id          .023722 s
--   50000000 both_pk_bi           flag         .02362 s
-- 
-- 16 rows selected.

-- Demo4_11g_no_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'no_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             *          2.447162 s
--   50000000 no_pk_bi             1          1.916814 s
--   50000000 no_pk_bi             id         1.868669 s
--   50000000 no_pk_bi             flag       1.723454 s
-- 
-- Demo4_11g_only_pk:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'only_pk' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 only_pk              *          1.762631 s
--   50000000 only_pk              1          1.762798 s
--   50000000 only_pk              id         1.750415 s
--   50000000 only_pk              flag       1.716138 s
-- 
-- Demo4_11g_only_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'only_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 only_bi              *            .02717 s
--   50000000 only_bi              1           .024324 s
--   50000000 only_bi              id           .02363 s
--   50000000 only_bi              flag        .024147 s
-- 
-- Demo4_11g_both_pk_bi:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE tab_mark = 'both_pk_bi' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 both_pk_bi           *           .026919 s
--   50000000 both_pk_bi           1           .024756 s
--   50000000 both_pk_bi           id          .023722 s
--   50000000 both_pk_bi           flag         .02362 s
-- 
-- Demo4_11g_asterisk:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = '*' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             *          2.447162 s
--   50000000 only_pk              *          1.762631 s
--   50000000 only_bi              *            .02717 s
--   50000000 both_pk_bi           *           .026919 s
-- 
-- Demo4_11g_1:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = '1' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             1          1.916814 s
--   50000000 only_pk              1          1.762798 s
--   50000000 only_bi              1           .024324 s
--   50000000 both_pk_bi           1           .024756 s
-- 
-- Demo4_11g_id:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = 'id' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             id         1.868669 s
--   50000000 only_pk              id         1.750415 s
--   50000000 only_bi              id           .02363 s
--   50000000 both_pk_bi           id          .023722 s
-- 
-- Demo4_11g_flag:
-- 
-- SQL> SELECT * FROM cnt_spd_time_4 WHERE cnt_mark = 'flag' ORDER BY ROWID;
-- 
--    TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
-- ---------- -------------------- -------- ---------- --
--   50000000 no_pk_bi             flag       1.723454 s
--   50000000 only_pk              flag       1.716138 s
--   50000000 only_bi              flag        .024147 s
--   50000000 both_pk_bi           flag         .02362 s
