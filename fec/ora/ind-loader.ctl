load data
  CHARACTERSET US7ASCII
  infile '/home/msw978/cs339/fec/itcont.txt'
     into table individual replace 
     fields terminated by '|' trailing nullcols
        ( CMTE_ID, AMNDT_IND, RPT_TP, TRANSACTION_PGI, IMAGE_NUM,
        TRANSACTION_TP, ENTITY_TP, NAME, CITY, STATE, ZIP_CODE, EMPLOYER,
        OCCUPATION, TRANSACTION_DT DATE "MMDDYYYY",
        TRANSACTION_AMNT, OTHER_ID, TRAN_ID, FILE_NUM, MEMO_CD, MEMO_TEXT,
        SUB_ID)

