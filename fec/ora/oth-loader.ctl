load data
  infile '/home/msw978/cs339/fec/itoth.txt'
     into table comm_to_cand replace 
     fields terminated by '|' trailing nullcols
        ( CMTE_ID, AMNDT_IND, RPT_TP, TRANSACTION_PGI, IMAGE_NUM,
        TRANSACTION_TP, ENTITY_TP, NAME, CITY, STATE, ZIP_CODE, EMPLOYER,
        OCCUPATION, TRANSACTION_DT DATE "MMDDYYYY",
        TRANSACTION_AMNT, OTHER_ID, TRAN_ID, FILE_NUM, MEMO_CD, MEMO_TEXT,
        SUB_ID )

