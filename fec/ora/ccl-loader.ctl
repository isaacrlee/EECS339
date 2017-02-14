load data
  infile '/home/msw978/cs339/fec/ccl.txt'
     into table cand_comm_linkage replace 
     fields terminated by '|' trailing nullcols
     ( CAND_ID, CAND_ELECTION_YR, FEC_ELECTION_YR, CMTE_ID, CMTE_TP, CMTE_DSGN,
     LINKAGE_ID )

