load data
  infile '/home/msw978/cs339/fec/cn.txt'
     into table candidate_master replace 
     fields terminated by '|' trailing nullcols
        ( CAND_ID,  CAND_NAME, CAND_PTY_AFFILIATION, CAND_ELECTION_YR,
        CAND_OFFICE_ST, CAND_OFFICE, CAND_OFFICE_DISTRICT, CAND_ICI,
        CAND_STATUS, CAND_PCC, CAND_ST1, CAND_ST2, CAND_CITY, CAND_ST, CAND_ZIP)

