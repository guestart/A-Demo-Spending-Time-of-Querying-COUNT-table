# A-Demo-Spending-Time-of-Querying-COUNT-table

### 1. Introduction

Using 3 **tables** (`cnt_method`, `tab_stru` and `cnt_spd_time`), some **procedures** `dynamically creating` test table, a `special` **function** and another **procedure** to build this pretty interesting `demo`.

The **ER Diagram** of those 3 tables previously cited is coming from the following picture:

![Image_text](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/ERD.png)

Exactly speaking, this demo should have been splitted into **4** `sections` (in other words, 4 small pieces of demo):

- `Demo1` used to build test tables (by using a very simple approach `CTAS`) with `NO PARALLEL`;

- `Demo2` is basically similar to `Demo1` and its only difference is at a table property `PARALLEL 10` when building a mode of test tables;

- `Demo3` usually builds test tables (by **creating some table structures** firstly with `NO PARALLEL` and then **adding the appropriate check or index** to those tables, at last **inserting several test data** by using hint `APPEND`);

- `Demo4` is also basically similar to `Demo3` and its only difference is also at a table property `PARALLEL 10`;

Of course, all `Demos` previously mentioned use the same (**3 tables**) `ERD model`.

- `Demo1` seems like this, `cnt_method`, `tab_stru` and `cnt_spd_time`;

- `Demo2` 


