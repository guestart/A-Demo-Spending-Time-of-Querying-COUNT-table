# A-Demo-Spending-Time-of-Querying-COUNT-table

### 1. Introduction

Using 3 **tables** (`cnt_method`, `tab_stru` and `cnt_spd_time`), some **procedures** `dynamically creating` test table, a `special` **function** and another **procedure** to build this pretty interesting `demo`.

The **ER Diagram** of those 3 tables previously cited is coming from the following picture:

![Image_text](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/ERD.png)

Exactly speaking, this demo should have been splitted into **4** `sections` (in other words, 4 small pieces of demo):

- `Demo1` used to build test tables (using a very simple approach `CTAS`) with `NO PARALLEL`;

- `Demo2` is basically similar to `Demo1` and its only difference is at a table property `PARALLEL 10` when building a mode of test tables;

- `Demo3` usually builds test tables (**creating some table structures** firstly with `NO PARALLEL` and then **adding the appropriate check or index** to those tables, at last **inserting several test data** using hint `APPEND`);

- `Demo4` is also basically similar to `Demo3` and its only difference is also at a table property `PARALLEL 10`;

Of course, all `Demos` previously mentioned use the same (**3 tables**) `ER Diagram`.

- The **ER Diagram** of `Demo1` consists of three tables `cnt_method`, `tab_stru` and `cnt_spd_time`;

- The **ER Diagram** of `Demo2` includes this three tables `cnt_method_2`, `tab_stru_2` and `cnt_spd_time_2`;

- The **ER Diagram** of `Demo3` contains 3 tables `cnt_method_3`, `tab_stru_3` and `cnt_spd_time_3`;

- The **ER Diagram** of `Demo4` has these 3 tables `cnt_method_4`, `tab_stru_4` and `cnt_spd_time_4`;

There has another one more important point being emphasized here, my Demo(s) has all tested on **Oracle** `11.2`, `18.3` and `19.5 (Live SQL)`.

### 2. Comparing spending time querying COUNT table on each Demo according to different 8 dimensions

- #### Demo1
  - ##### Oracle 18.3
  ```sql
  -- Demo1_18c_no_pk_bi:
  
  SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'no_pk_bi' ORDER BY ROWID;
  
     TAB_NUM TAB_MARK   CNT_   SPD_TIME T
  ---------- ---------- ---- ---------- -
    50000000 no_pk_bi   *      1.667343 s
    50000000 no_pk_bi   1       .787276 s
    50000000 no_pk_bi   id      1.28991 s
    50000000 no_pk_bi   flag   1.349071 s
  ```








