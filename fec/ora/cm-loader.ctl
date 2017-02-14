load data
  infile '/home/msw978/cs339/fec/cm.txt'
     into table committee_master replace 
     fields terminated by '|' trailing nullcols
     ( CMTE_ID,  CMTE_NM, TRES_NM, CMTE_ST1, CMTE_ST2, CMTE_CITY, CMTE_ST,
     CMTE_ZIP, CMTE_DSGN, CMTE_TP, CMTE_PTY_AFFILIATION, CMTE_FILING_FREQ,
     ORG_TP,  CONNECTED_ORG_NM, CAND_ID)


