/* Adapted from "breast cancer claims data analysis.sas" (category 1:
   whole-breast radiation therapy in 25 fractions for early-stage invasive
   breast cancer, age 50+). The original reads external libname datasets
   (Tmp1.Tcdb_breast91/92 via libname Gloria "H:\BreastCancer"); here a small
   inline TCDB sample stands in for them so the classification pipeline runs
   in isolation. The surgery / early-stage / age / fractionation logic is the
   author's, unchanged. */

/* Mock TCDB breast-cancer claims sample. Column shapes (OPTYPE, PSTAGE,
   RTNO, idiagy, biry) match what the analysis reads. */
data tcdb9192;
  length OPTYPE $2 PSTAGE $4 RTNO $2 idiagy $8 biry $8;
  input ID OPTYPE $ PSTAGE $ RTNO $ idiagy $ biry $ RTH_NF;
  datalines;
1 20 1A 25 20030512 19500101 25
2 22 2A 30 20040118 19480101 30
3 30 1C 24 20050920 19550101 24
4 19 2B 99 20060704 19600101 0
5 21 1B1 28 20070811 19450101 28
6 24 2A 20 20080203 19620101 20
7 40 1A 25 20030512 19700101 25
8 22 3A 26 20040118 19520101 26
9 20 1A 12 20050920 19980101 12
10 30 2B 25 20060704 19470101 25
;
run;

/*only patient with breast-conserving surgery, OPTYPE 2 number code*/
/*19 Local tumor destruction, 20 Partial mastectomy, 21 Partial mastectomy WITH nipple resection,
  22 Lumpectomy or excisional biopsy, 24 Segmental mastectomy, 30 Subcutaneous mastectomy*/
data BCS_1; set tcdb9192;
if substr(OPTYPE,1,2) in ('19','20','21','22','24','30') then operation=1;
else delete;
run;

/*early stage breast cancer, code in 1, 1A,1B1,1C, 2,2A, 2B*/
proc freq data=BCS_1; table PSTAGE;
run;
data BCS_2; set BCS_1;
if substr(PSTAGE,1,3) in ('1','1A', '1B1', '1C', '2','2A', '2B') then earlyBC=1;
else delete;
run;

/*define age gp; there are too many 9999*/
data age50; set BCS_2;
if idiagy=9999 then delete;
if biry=9999 then delete;
birthyear=substr(biry,1,4)*1;
treatdate=substr(idiagy,1,4)*1;  /*format as YYYYMMDD*/
age=treatdate-birthyear;
if age<50 then delete;
run;

/*RTNO, 2 number code -> fractionation group*/
proc freq data=age50; table RTNO; run;
data RT_1; set age50;
fraction=substr(RTNO,1,2)*1; /*convert category to number*/
if fraction=99 then delete;
data RT_2; set RT_1;
if fraction>=25 then RTgp=1;
if fraction<25 then RTgp=2;
proc freq; table RTgp;
run;
