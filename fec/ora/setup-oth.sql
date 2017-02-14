create table comm_to_comm (
  CMTE_ID               VARCHAR2(9) NOT NULL REFERENCES committee_master(CMTE_ID),
  AMNDT_IND             VARCHAR2(1) REFERENCES amendment_ind_codes(AMNDT_IND),
  RPT_TP                VARCHAR2(3) REFERENCES report_type_codes(RPT_TP),
  TRANSACTION_PGI       VARCHAR2(5), -- not sure how to handle this, type is EYYYY, E is type, Y is year...
  IMAGE_NUM             VARCHAR2(11),
  TRANSACTION_TP        VARCHAR2(3) REFERENCES transaction_type_codes(TRANSACTION_TP),
  ENTITY_TP             VARCHAR2(3) REFERENCES entity_type_codes(ENTITY_TP),
  NAME                  VARCHAR2(200),
  CITY                  VARCHAR2(30),
  STATE                 VARCHAR2(2),
  ZIP_CODE              VARCHAR2(9),
  EMPLOYER              VARCHAR2(38),
  OCCUPATION            VARCHAR2(38),
  TRANSACTION_DT        DATE,
  TRANSACTION_AMNT      NUMBER(14,2),
  OTHER_ID              VARCHAR2(9),
  CAND_ID               VARCHAR2(9) REFERENCES candidate_master(CAND_ID),
  TRAN_ID               VARCHAR2(32),
  FILE_NUM              NUMBER(22),
  MEMO_CD               VARCHAR2(1),
  MEMO_TEXT             VARCHAR2(100),
  SUB_ID                NUMBER(19) NOT NULL PRIMARY KEY
);

quit;

