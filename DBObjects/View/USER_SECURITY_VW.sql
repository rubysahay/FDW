CREATE OR REPLACE FORCE VIEW MMC_FDW_DATA_DUMP.USER_SECURITY_VW
(
   ROWN_NUM,
   VCHGROUP,
   USERID,
   DISPLAYNAME,
   LASTNAME,
   FIRSTNAME,
   EMAIL,
   PEOPLESOFTID,
   INSTANCE,
   ORGANIZATION_ID,
   ORGNAME,
   LEDGER_ID,
   LEDGERNAME
)
AS
 WITH OperUnit
        AS (SELECT 'RIS12' AS Instance,
                   a.organization_id,
                   b.name,
                   a.ORG_INFORMATION1,
                   NULL AS country
              FROM FDW_EBSRIS12.hr_organization_information a,
                   FDW_EBSRIS12.HR_ALL_ORGANIZATION_UNITS b
             WHERE     a.organization_id = b.organization_id
                   AND a.ORG_INFORMATION_CONTEXT = 'Accounting Information'
            UNION
            SELECT 'CONS12' AS Instance,
                   a.organization_id,
                   b.name,
                   a.ORG_INFORMATION1,
                   c.TRTRY_ID AS country
              FROM FDW_EBSCONS12.hr_organization_information a,
                   FDW_EBSCONS12.HR_ALL_ORGANIZATION_UNITS b,
                   FDW.D_TRTRY c
             WHERE     a.organization_id = b.organization_id
                   AND a.ORG_INFORMATION_CONTEXT = 'Accounting Information'
                   AND b.attribute13 =
                          SUBSTR (trtry_desc,
                                  1,
                                  INSTR (trtry_desc, '(', 1) - 1)),
        Ledg
        AS (SELECT 'RIS12' AS Instance,
                   ledger_id,
                   Name,
                   Attribute2 AS Country
              FROM FDW_EBSRIS12.GL_LEDGERS
            UNION
            SELECT 'CONS12' AS Instance,
                   ledger_id,
                   Name,
                   NULL
              FROM FDW_EBSCONS12.GL_LEDGERS),
        Ldgr_Org
        AS (SELECT a.Instance,
                   a.organization_id,
                   a.Name AS OrgName,
                   b.ledger_id,
                   b.Name AS LedgerName,
                   NVL (a.Country, b.Country) AS Country
              FROM OperUnit a, Ledg b
             WHERE     a.instance = b.instance
                   AND a.ORG_INFORMATION1 = b.ledger_id)
   SELECT DISTINCT ROWNUM AS rown_num,
                   sec.GRP_NM,
                   USR_ID,
                   FRST_NM || ' ' || LST_NM DisplayName,
                   LST_NM,
                   FRST_NM,
                   EMAIL_ADRS_TX,
                   PPLSFT_ID,
                   lo.Instance,
                   lo.organization_id,
                   lo.OrgName,
                   lo.ledger_id,
                   lo.LedgerName
     FROM OBIEE.USR_APLCTN_GRP_MAP sec, Ldgr_Org lo
    WHERE lo.country = SUBSTR (sec.GRP_NM, 15, 2) and sec.GRP_NM like '%BIData%'
