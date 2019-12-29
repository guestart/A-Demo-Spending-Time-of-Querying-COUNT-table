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
  ![Demo1_18c_no_pk_bi](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_on_pk_bi.jpg)
  
  ```sql
  -- Demo1_18c_only_pk:
  
  SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_pk' ORDER BY ROWID;
  
     TAB_NUM TAB_MARK   CNT_   SPD_TIME T
  ---------- ---------- ---- ---------- -
    50000000 only_pk    *      1.991366 s
    50000000 only_pk    1      1.585741 s
    50000000 only_pk    id     1.595641 s
    50000000 only_pk    flag   1.741364 s
    ```
    ![Demo1_18c_only_pk](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_only_pk.jpg)
    
    ```sql
    -- Demo1_18c_only_bi:
    
    SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_bi' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK   CNT_   SPD_TIME T
    ---------- ---------- ---- ---------- -
      50000000 only_bi    *       .023629 s
      50000000 only_bi    1       .012871 s
      50000000 only_bi    id     1.703165 s
      50000000 only_bi    flag    .928293 s
    ```
    ![Demo1_18c_only_bi](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_only_bi.jpg)
    
    ```sql
    -- Demo1_18c_both_pk_bi:
    
    SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'both_pk_bi' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK   CNT_   SPD_TIME T
    ---------- ---------- ---- ---------- -
      50000000 both_pk_bi *       .019995 s
      50000000 both_pk_bi 1       .012551 s
      50000000 both_pk_bi id      .011584 s
      50000000 both_pk_bi flag    .914173 s
    ```
    ![Demo1_18c_both_pk_bi](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_both_pk_bi.jpg)
    
    ```sql
    -- Demo1_18c_asterisk:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '*' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK   CNT_   SPD_TIME T
    ---------- ---------- ---- ---------- -
      50000000 no_pk_bi   *      1.667343 s
      50000000 only_pk    *      1.991366 s
      50000000 only_bi    *       .023629 s
      50000000 both_pk_bi *       .019995 s
    ```
    ![Demo1_18c_asterisk](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_asterisk.jpg)
    
    ```sql
    -- Demo1_18c_1:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '1' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK   CNT_   SPD_TIME T
    ---------- ---------- ---- ---------- -
      50000000 no_pk_bi   1       .787276 s
      50000000 only_pk    1      1.585741 s
      50000000 only_bi    1       .012871 s
      50000000 both_pk_bi 1       .012551 s
    ```
    ![Demo1_18c_1](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_1.jpg)
    
    ```sql
    -- Demo1_18c_id:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'id' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK   CNT_   SPD_TIME T
    ---------- ---------- ---- ---------- -
      50000000 no_pk_bi   id      1.28991 s
      50000000 only_pk    id     1.595641 s
      50000000 only_bi    id     1.703165 s
      50000000 both_pk_bi id      .011584 s
    ```
    ![Demo1_18c_id](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_id.jpg)
    
    ```sql
    -- Demo1_18c_flag:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'flag' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK   CNT_   SPD_TIME T
    ---------- ---------- ---- ---------- -
      50000000 no_pk_bi   flag   1.349071 s
      50000000 only_pk    flag   1.741364 s
      50000000 only_bi    flag    .928293 s
      50000000 both_pk_bi flag    .914173 s
    ```
    ![Demo1_18c_flag](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/18.3/Demo1_18c_flag.jpg)
    
    - ##### Oracle 11.2
    ```sql
    -- Demo1_11g_no_pk_bi:
    
    SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'no_pk_bi' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 no_pk_bi             *          1.590687 s
      50000000 no_pk_bi             1          1.184074 s
      50000000 no_pk_bi             id         1.666568 s
      50000000 no_pk_bi             flag       1.770705 s
    ```
    ![Demo1_11g_no_pk_bi](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_no_pk_bi.jpg)
    
    ```sql
    -- Demo1_11g_only_pk:
    
    SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_pk' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 only_pk              *          2.371787 s
      50000000 only_pk              1          2.075631 s
      50000000 only_pk              id         2.087134 s
      50000000 only_pk              flag       1.717795 s
    ```
    ![Demo1_11g_only_pk](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_only_pk.jpg)
    
    ```sql
    -- Demo1_11g_only_bi:
    
    SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'only_bi' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 only_bi              *           .035909 s
      50000000 only_bi              1           .025202 s
      50000000 only_bi              id         2.201092 s
      50000000 only_bi              flag        1.18439 s
    ```
    ![Demo1_11g_only_bi](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_only_bi.jpg)
    
    ```sql
    -- Demo1_11g_both_pk_bi:
    
    SQL> SELECT * FROM cnt_spd_time WHERE tab_mark = 'both_pk_bi' ORDER BY ROWID;

       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 both_pk_bi           *            .02406 s
      50000000 both_pk_bi           1            .01521 s
      50000000 both_pk_bi           id          .014518 s
      50000000 both_pk_bi           flag       1.166561 s
    ```
    ![Demo1_11g_both_pk_bi](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_both_pk_bi.jpg)
    
    ```sql
    -- Demo1_11g_asterisk:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '*' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 no_pk_bi             *          1.590687 s
      50000000 only_pk              *          2.371787 s
      50000000 only_bi              *           .035909 s
      50000000 both_pk_bi           *            .02406 s
    ```
    ![Demo1_11g_asterisk](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_asterisk.jpg)
    
    ```sql
    -- Demo1_11g_1:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = '1' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 no_pk_bi             1          1.184074 s
      50000000 only_pk              1          2.075631 s
      50000000 only_bi              1           .025202 s
      50000000 both_pk_bi           1            .01521 s
    ```
    ![Demo1_11g_1](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_1.jpg)
    
    ```sql
    -- Demo1_11g_id:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'id' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 no_pk_bi             id         1.666568 s
      50000000 only_pk              id         2.087134 s
      50000000 only_bi              id         2.201092 s
      50000000 both_pk_bi           id          .014518 s
    ```
    ![Demo1_11g_id](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/Demo1/11.2/Demo1_11g_id.jpg)
    
    ```sql
    -- Demo1_11g_flag:
    
    SQL> SELECT * FROM cnt_spd_time WHERE cnt_mark = 'flag' ORDER BY ROWID;
    
       TAB_NUM TAB_MARK             CNT_MARK   SPD_TIME TI
    ---------- -------------------- -------- ---------- --
      50000000 no_pk_bi             flag       1.770705 s
      50000000 only_pk              flag       1.717795 s
      50000000 only_bi              flag        1.18439 s
      50000000 both_pk_bi           flag       1.166561 s
    ```
  
    
    
    







