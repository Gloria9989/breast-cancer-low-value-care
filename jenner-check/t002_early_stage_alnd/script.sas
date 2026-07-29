/* Adapted from "breast cancer claims data analysis.sas" (category 4:
   avoid axillary lymph node dissection for clinical stages I and II breast
   cancer with clinically negative nodes without SLNB). The original reads
   external libname datasets (Tmp1.Tcdb_breast91/92 via libname Gloria
   "H:\BreastCancer"); here a small inline TCDB sample stands in for them.
   The early-stage flag and the LNSCOPE-based ALND classification are the
   author's, unchanged. */

/* Mock TCDB breast-cancer sample. Shapes (PSTAGE, LNSCOPE) match the
   axillary-lymph-node-dissection query in the analysis. */
data tcdb9192;
  length PSTAGE $4 LNSCOPE $1;
  input ID PSTAGE $ LNSCOPE $;
  datalines;
1 1A 3
2 2A 7
3 1C 8
4 2B 1
5 1B1 9
6 3A 3
7 2A 8
8 1A 1
9 2B 7
10 4 9
;
run;

/* 4, Don't perform axillary lymph node dissection for clinical stages I and II
   breast cancer with clinically negative lymph nodes without SLNB. */

/* only stages I and II breast cancer */
data earlyBC; set tcdb9192;
if substr(PSTAGE,1,3) in ('1','1A', '1B1', '1C', '2','2A', '2B') then earlyBC=1;
else earlybc=0;
run;
proc freq data=tcdb9192; table PSTAGE; run;
proc freq data=earlyBC; table earlyBC; run;

/* axillary lymph node dissection (ALND); LNSCOPE has 1 code number */
data ALND; set earlyBC;
if substr(LNSCOPE,1,1) in ('9') then delete;
if substr(LNSCOPE,1,1) in ('3','7','8') then ALND=1;
else ALND=0;
proc freq; table ALND;
run;
