CREATE OR REPLACE PROCEDURE FDW.SP_OBI_LOAD_MART_TRN
(  I_SUBJECT_AREA_NM IN    VARCHAR
  ,I_PE_OR_YR        IN    VARCHAR
  ,O_RTN_CD          OUT   INTEGER
  ,O_RTN_MSG         OUT   VARCHAR
)
AS
/**************************************************************************************************/
/*                                                                                                */
/*                                                                                                */
/*  Description                                                                                   */
/*  ____________________________________________________________________________________________  */
/*                                                                                                */
/*  This procedure clears and loads data into the OBI_MART_TRN table for a period or year.        */
/*  Procedure Parameters                                                                          */
/*  ____________________________________________________________________________________________  */
/*                                                                                                */
/*  I_SUBJECT_AREA_NM      The subject area to refresh                                            */
/*  I_PE_OR_YR             The period or year to refresh                                            */
/*  O_RTN_CD               Return Code (0 successful,                                             */
/*                                     (-1 Invalid Parameters Passed, -2 Other fatal error        */
/*  O_RTN_MSG      OUT   VARCHAR    In case of non zero return codes provide additional message   */
/*                                                                                                */
/*  Modification Log                                                                              */
/*  ____________________________________________________________________________________________  */
/*                                                                                                */
/*  Date        User       Description                                                            */
/*                                                                                                */
/*  05-05-2015 MHassan  Created                                                                   */
/**************************************************************************************************/


/**************************************************************************************************/
/* Declare Variables                                                                              */
/**************************************************************************************************/

E_INVALID_PARAMS_PASSED               EXCEPTION;


V_PE_LIST                             VARCHAR2(255 BYTE);

V_ERR_DTA                             VARCHAR2(255  BYTE);
V_SQL_STR                             VARCHAR2(30000 BYTE);

C_INVALID_PARAMS_PASSED               VARCHAR2(100  BYTE) := 'Invalid Parameters Passed to Procedure';
C_PROC_NM                             VARCHAR2(100  BYTE) := 'SP_OBI_LOAD_MART_TRN';


/**************************************************************************************************/
/* Declare Cursors                                                                                */
/**************************************************************************************************/

--CURSOR PART_CSR
--IS
--SELECT  PARTITION_NAME
--     FROM    ALL_TAB_PARTITIONS
--     WHERE   TABLE_OWNER='FDW'
--     AND     TABLE_NAME='F_LDGR_TRN';

--PART_ROW          PART_CSR%ROWTYPE;

CURSOR INDX_CSR
IS
select 'ALTER INDEX '||INDEX_NAME||' REBUILD' INDX_SQL from user_indexes
where table_name='OBI_MART_TRN';

INDX_ROW          INDX_CSR%ROWTYPE;

BEGIN

/**************************************************************************************************/
/* Validate Parameters Passed                                                                     */
/**************************************************************************************************/

   O_RTN_CD := 0;
   V_ERR_DTA := 'INPUT PARAMS: I_SUBJECT_AREA_NM, I_PE_OR_YR - INPUT PARAM DATA: ' || I_SUBJECT_AREA_NM || ', ' || I_PE_OR_YR;

   IF I_SUBJECT_AREA_NM IS NULL THEN
        RAISE E_INVALID_PARAMS_PASSED;
   END IF;

   IF I_PE_OR_YR IS NULL THEN
        RAISE E_INVALID_PARAMS_PASSED;
   END IF;

   select listagg(chr(39)||d_cal_pe_key||chr(39), ',') within group (order by d_cal_pe_key)
   INTO V_PE_LIST
   from fdw.d_cal_pe
   where d_cal_pe_key=I_PE_OR_YR or cal_pe_fscl_yr_nm=I_PE_OR_YR or cal_pe_yr_chr=I_PE_OR_YR;

   IF V_PE_LIST IS NULL THEN
        RAISE E_INVALID_PARAMS_PASSED;
   END IF;

/**************************************************************************************************/
/* Delete from table for given period(s)                                                          */
/**************************************************************************************************/

  V_SQL_STR := 'DELETE FROM FDW.OBI_MART_TRN WHERE PE_NM IN (' || V_PE_LIST || ') AND SUBJECT_AREA_NM=' || chr(39) || I_SUBJECT_AREA_NM || CHR(39);
  DBMS_OUTPUT.PUT_LINE(V_SQL_STR);
  EXECUTE IMMEDIATE V_SQL_STR;

/**************************************************************************************************/
/* Load all subpartitions for given period                                                        */
/**************************************************************************************************/

-- OPEN PART_CSR;


--  LOOP

--   FETCH PART_CSR
--   INTO  PART_ROW;
--   EXIT WHEN
--         PART_CSR%NOTFOUND;

IF I_SUBJECT_AREA_NM = 'T and E' THEN

     V_SQL_STR := 'INSERT INTO FDW.OBI_MART_TRN (
'||CHR(10)||'    SELECT
'||CHR(10)||'    ''T and E'' as SUBJECT_AREA_NM
'||CHR(10)||'    ,T88232.PART_MAIN
'||CHR(10)||'    ,T88232.PE_NM
'||CHR(10)||'    ,T88232.INSTC_NM
'||CHR(10)||'    ,T88232.D_LDGR_KEY
'||CHR(10)||'    ,T88232.LDGR_NM
'||CHR(10)||'    ,T88232.D_PE_KEY
'||CHR(10)||'    ,T88232.D_SGMNT_KEY
'||CHR(10)||'    ,T88232.D_CRNCY_CD_KEY
'||CHR(10)||'    ,T88232.JOUR_LINE_NR
'||CHR(10)||'    ,T88232.JOUR_HEADER_ID
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.ENTD_DR_AM else T566126.ENTD_DR_AM end as ENTD_DR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.ENTD_CR_AM else T566126.ENTD_CR_AM end as ENTD_CR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.ENTD_NET_AM else T566126.ENTD_NET_AM end as ENTD_NET_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_DR_AM else T566126.ACCT_DR_AM end as LCL_DR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CR_AM else T566126.ACCT_CR_AM end as LCL_CR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_NET_AM else T566126.ACCT_NET_AM end as LCL_NET_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.USD_CY_STD_DR_AM else T566126.USD_CY_STD_DR_AM end as USD_CY_STD_DR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.USD_CY_STD_CR_AM else T566126.USD_CY_STD_CR_AM end as USD_CY_STD_CR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.USD_CY_STD_NET_AM else T566126.USD_CY_STD_NET_AM end as USD_CY_STD_NET_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.USD_CY_GAAP_DR_AM else T566126.USD_CY_GAAP_DR_AM end as USD_CY_GAAP_DR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.USD_CY_GAAP_CR_AM else T566126.USD_CY_GAAP_CR_AM end as USD_CY_GAAP_CR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.USD_CY_GAAP_NET_AM else T566126.USD_CY_GAAP_NET_AM end as USD_CY_GAAP_NET_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CY_GAAP_DR_AM else T566126.LCL_CY_GAAP_DR_AM end as LCL_CY_GAAP_DR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CY_GAAP_CR_AM else T566126.LCL_CY_GAAP_CR_AM end as LCL_CY_GAAP_CR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CY_GAAP_NET_AM else T566126.LCL_CY_GAAP_NET_AM end as LCL_CY_GAAP_NET_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CY_STD_DR_AM else T566126.LCL_CY_STD_DR_AM end as LCL_CY_STD_DR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CY_STD_CR_AM else T566126.LCL_CY_STD_CR_AM end as LCL_CY_STD_CR_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL_CY_STD_NET_AM else T566126.LCL_CY_STD_NET_AM end as LCL_CY_STD_NET_AM
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.SRC2LCL_CY_GAAP_RT else T566126.SRC2LCL_CY_GAAP_RT end as SRC2LCL_CY_GAAP_RT
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.SRC2LCL_CY_STD_RT else T566126.SRC2LCL_CY_STD_RT end as SRC2LCL_CY_STD_RT
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL2USD_CY_GAAP_RT else T566126.LCL2USD_CY_GAAP_RT end as LCL2USD_CY_GAAP_RT
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then T88232.LCL2USD_CY_STD_RT else T566126.LCL2USD_CY_STD_RT end as LCL2USD_CY_STD_RT
'||CHR(10)||'    ,case when T566126.SLA_HEADER_ID is null then ''N'' else ''Y'' end as SLA_INDICATOR
'||CHR(10)||'    ,T165148.JOUR_BTCH_ID
'||CHR(10)||'    ,T165148.JOUR_NM
'||CHR(10)||'    ,T165148.JOUR_DESC
'||CHR(10)||'    ,T165148.JOUR_CAT_NM
'||CHR(10)||'    ,T165148.JOUR_SRC_NM
'||CHR(10)||'    ,T165148.CRNCY_CD
'||CHR(10)||'    ,T165148.ACTL_FLG
'||CHR(10)||'    ,T165148.CONV_FLG
'||CHR(10)||'    ,T165148.CREATION_DT
'||CHR(10)||'    ,T165148.POST_DT
'||CHR(10)||'    ,T165148.ATTR1 H_ATTR1
'||CHR(10)||'    ,T165148.ATTR2 H_ATTR2
'||CHR(10)||'    ,T165148.ATTR3 H_ATTR3
'||CHR(10)||'    ,T165148.ATTR4 H_ATTR4
'||CHR(10)||'    ,T165148.ATTR5 H_ATTR5
'||CHR(10)||'    ,T165133.JOUR_BTCH_NM
'||CHR(10)||'    ,T165133.JOUR_BTCH_DESC
'||CHR(10)||'    ,T165133.ATTR1 B_ATTR1
'||CHR(10)||'    ,T165133.ATTR2 B_ATTR2
'||CHR(10)||'    ,T165133.ATTR3 B_ATTR3
'||CHR(10)||'    ,T165133.ATTR4 B_ATTR4
'||CHR(10)||'    ,T165133.ATTR5 B_ATTR5
'||CHR(10)||'    ,T566126.SLA_HEADER_ID
'||CHR(10)||'    ,T566126.SLA_LINE_NBR
'||CHR(10)||'    ,T566126.D_APPL_KEY
'||CHR(10)||'    ,T566126.APPL_ID
'||CHR(10)||'    ,T566126.CD_CMBNTN_ID
'||CHR(10)||'    ,T566126.GL_SL_LINK_ID
'||CHR(10)||'    ,T566126.ACCTNG_CLASS_CD
'||CHR(10)||'    ,T566126.PRTY_ID
'||CHR(10)||'    ,T566126.PRTY_SITE_ID
'||CHR(10)||'    ,T566126.PRTY_TYP_CD
'||CHR(10)||'    ,T566126.LINE_DESC
'||CHR(10)||'    ,T566126.GL_SL_LNK_TBL
'||CHR(10)||'    ,T566126.DSPLY_LINE_NBR
'||CHR(10)||'    ,T566126.CREATE_DT
'||CHR(10)||'    ,T566126.BUS_CLASS_CD
'||CHR(10)||'    ,T566126.ACCTNG_DT
'||CHR(10)||'    ,T566126.LDGR_ID
'||CHR(10)||'    ,T566126.XRF_JOUR_BTCH_ID
'||CHR(10)||'    ,T566126.XRF_JOUR_HDR_ID
'||CHR(10)||'    ,T566126.XRF_JOUR_LINE_NBR
'||CHR(10)||'    ,T566126.XRF_SLA_DOC_SEQ_ID
'||CHR(10)||'    ,T566126.XRF_SLA_DOC_SEQ_VAL
'||CHR(10)||'    ,T566126.XRF_GL_SLA_LNK_TBL_NM
'||CHR(10)||'    ,T566126.VNDR_NM
'||CHR(10)||'    ,T566126.VNDR_NBR
'||CHR(10)||'    ,T566126.VNDR_SITE_CD
'||CHR(10)||'    ,T566126.DOC_TYP
'||CHR(10)||'    ,T566126.DOC_SRC
'||CHR(10)||'    ,T566126.DOC_NBR
'||CHR(10)||'    ,T566126.DOC_DESC
'||CHR(10)||'    ,T566126.EMP_NBR
'||CHR(10)||'FROM
'||CHR(10)||'    FDW.D_CAL_PE T87972 /* D06_CalendarPeriod */
'||CHR(10)||'    ,FDW.D_SGMNT T88008 /* D08_Segment */
'||CHR(10)||'    ,FDW.F_LDGR_TRN T88232 /* F02_LedgerTransactions */
'||CHR(10)||'LEFT OUTER JOIN FDW.F_SLA_LINES T566126 /* F07_SLALines */ ON T88232.JOUR_HEADER_ID = T566126.XRF_JOUR_HDR_ID AND T88232.JOUR_LINE_NR = T566126.XRF_JOUR_LINE_NBR AND T88232.D_PE_KEY = T566126.D_PE_KEY AND T88232.PART_MAIN = T566126.PART_MAIN AND T88232.PE_NM = T566126.PE_NM
'||CHR(10)||'    ,FDW.F_JOUR_HEADERS T165148 /* D24_JournalHeader */
'||CHR(10)||'    ,FDW.F_JOUR_BATCHES T165133 /* D23_JournalBatch */
'||CHR(10)||'    ,FDW.D_PE T764688 /* D05_Period_D_PE_Trx */
'||CHR(10)||'WHERE
'||CHR(10)||'        T88232.JOUR_HEADER_ID = T165148.JOUR_HEADER_ID
'||CHR(10)||'        AND T88232.D_PE_KEY = T165148.D_PE_KEY
'||CHR(10)||'        AND T88232.PART_MAIN = T165148.PART_MAIN
'||CHR(10)||'        AND T88232.PE_NM = T165148.PE_NM
'||CHR(10)||'        AND T165148.JOUR_BTCH_ID = T165133.JOUR_BTCH_ID
'||CHR(10)||'        AND T165148.D_PE_KEY = T165133.D_PE_KEY
'||CHR(10)||'        AND T165148.PART_MAIN = T165133.PART_MAIN
'||CHR(10)||'        AND T165148.PE_NM = T165133.PE_NM
'||CHR(10)||'        AND T87972.D_CAL_PE_KEY = T88232.PE_NM
'||CHR(10)||'        AND T87972.D_CAL_PE_KEY = T764688.PE_NM
'||CHR(10)||'        AND T88008.D_SGMNT_KEY = T88232.D_SGMNT_KEY
'||CHR(10)||'        AND T88232.D_PE_KEY = T764688.D_PE_KEY
'||CHR(10)||'        AND T88008.D_ACCT_KEY IN (SELECT MEMBER_KEY FROM FDW.V_OBI_ACCT a, FDW.D_ACCT b where a.ANCESTOR_KEY = b.D_ACCT_KEY and b.ACCT_ID IN (''MER_TEMeeting'',''TRAVEL_ENT'',''GC_TRAVEL_ENT'',''MAR_TRAVEL_ENT'') and a.IS_LEAF=1)
'||CHR(10)||'        AND T87972.D_CAL_PE_KEY IN (' || V_PE_LIST || ')
'||CHR(10)||' ) ';

END IF;

--AND T88232.PART_MAIN = ' || CHR(39) || PART_ROW.PARTITION_NAME || CHR(39) ||

 --    DBMS_OUTPUT.PUT_LINE(V_SQL_STR);

     EXECUTE IMMEDIATE V_SQL_STR;
     COMMIT;

--   END LOOP;

-- CLOSE PART_CSR;

/**************************************************************************************************/
/* Rebuild indexes                                                                                */
/**************************************************************************************************/

 OPEN INDX_CSR;


  LOOP

   FETCH INDX_CSR
   INTO  INDX_ROW;
   EXIT WHEN
         INDX_CSR%NOTFOUND;

     V_SQL_STR := INDX_ROW.INDX_SQL;

     EXECUTE IMMEDIATE V_SQL_STR;

   END LOOP;

 CLOSE INDX_CSR;

/**************************************************************************************************/
/* Exception Handling                                                                             */
/**************************************************************************************************/


  EXCEPTION
    WHEN E_INVALID_PARAMS_PASSED THEN
         O_RTN_MSG := 'Invalid parameters passed to Procedure';
         O_RTN_CD := -1;
         DBMS_OUTPUT.PUT_LINE ('Invalid parameters passed to Procedure');
        -- RAISE;

    WHEN OTHERS THEN
         O_RTN_MSG := 'Unexpected Error ' || SQLCODE || ' ' || SUBSTR(SQLERRM,1,200);
         O_RTN_CD := -2;
         DBMS_OUTPUT.PUT_LINE ('Unexpected Error ' || SQLCODE || ' ' || SUBSTR(SQLERRM,1,200));
        -- RAISE;



/**************************************************************************************************/
/* End Procedure                                                                                  */
/**************************************************************************************************/

END;
/