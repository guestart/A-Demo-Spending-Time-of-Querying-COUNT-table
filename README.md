# A-Demo-Spending-Time-of-Querying-COUNT-table

### 1. Introduction

Using 3 **tables** `(**"cnt_method"**, **"tab_stru"** and **"cnt_spd_time"**)`, some **procedures** dynamically creating test table, a **special** function and another procedure to build this pretty interesting `**demo**`.

The **ER Diagram** of those 3 tables previously cited is coming from the following picture:

![Image_text](https://github.com/guestart/A-Demo-Spending-Time-of-Querying-COUNT-table/blob/master/picture/ERD.png)

Exactly speaking, this demo should have been splitted into **4** `sections` (in other words, 4 small pieces of demo):
(1) Demo1, building test table (by using a very simple approach `**CTAS**`) with `NO PARALLEL`
