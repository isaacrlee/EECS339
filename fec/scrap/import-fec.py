#!/usr/bin/python

import os, subprocess

pwd = os.getcwd()

ctls = {"cm" :  """load data
  infile '""" + pwd + """/fec/REPLACE/cm.txt'
     into table committee_master append 
     fields terminated by '|' trailing nullcols
       ( CMTE_ID,  CMTE_NM, TRES_NM, CMTE_ST1, CMTE_ST2, CMTE_CITY, CMTE_ST,
       CMTE_ZIP, CMTE_DSGN, CMTE_TP, CMTE_PTY_AFFILIATION, CMTE_FILING_FREQ,
       ORG_TP,  CONNECTED_ORG_NM, CAND_ID )""",
      "cn":    """load data
  infile '""" + pwd + """/fec/REPLACE/cn.txt'
     into table candidate_master append 
     fields terminated by '|' trailing nullcols
       ( CAND_ID,  CAND_NAME, CAND_PTY_AFFILIATION, CAND_ELECTION_YR,
       CAND_OFFICE_ST, CAND_OFFICE, CAND_OFFICE_DISTRICT, CAND_ICI,
       CAND_STATUS, CAND_PCC, CAND_ST1, CAND_ST2, CAND_CITY, CAND_ST,
       CAND_ZIP )""",
      "ccl":   """load data
  infile '""" + pwd + """/fec/REPLACE/ccl.txt'
     into table cand_comm_linkage append 
     fields terminated by '|' trailing nullcols
       ( CAND_ID, CAND_ELECTION_YR, FEC_ELECTION_YR, CMTE_ID, CMTE_TP, CMTE_DSGN,
       LINKAGE_ID )""",
      "itcont":   """load data
  infile '""" + pwd + """/fec/REPLACE/itcont.txt'
     into table individual append 
     fields terminated by '|' trailing nullcols
       ( CMTE_ID, AMNDT_IND, RPT_TP, TRANSACTION_PGI, IMAGE_NUM,
       TRANSACTION_TP, ENTITY_TP, NAME, CITY, STATE, ZIP_CODE, EMPLOYER,
       OCCUPATION, TRANSACTION_DT DATE "MMDDYYYY",
       TRANSACTION_AMNT, OTHER_ID, TRAN_ID, FILE_NUM, MEMO_CD, MEMO_TEXT,
       SUB_ID )""",
      "itpas2":"""load data
  infile '""" + pwd + """/fec/REPLACE/itpas2.txt'
     into table comm_to_cand append 
     fields terminated by '|' trailing nullcols
       ( CMTE_ID, AMNDT_IND, RPT_TP, TRANSACTION_PGI, IMAGE_NUM,
       TRANSACTION_TP, ENTITY_TP, NAME, CITY, STATE, ZIP_CODE, EMPLOYER,
       OCCUPATION, TRANSACTION_DT DATE "MMDDYYYY",
       TRANSACTION_AMNT, OTHER_ID, CAND_ID, TRAN_ID, FILE_NUM, MEMO_CD,
       MEMO_TEXT, SUB_ID )""",
      "itoth":"""load data
  infile '""" + pwd + """/fec/REPLACE/itoth.txt'
     into table comm_to_cand append 
     fields terminated by '|' trailing nullcols
       ( CMTE_ID, AMNDT_IND, RPT_TP, TRANSACTION_PGI, IMAGE_NUM,
       TRANSACTION_TP, ENTITY_TP, NAME, CITY, STATE, ZIP_CODE, EMPLOYER,
       OCCUPATION, TRANSACTION_DT DATE "MMDDYYYY",
       TRANSACTION_AMNT, OTHER_ID, TRAN_ID, FILE_NUM, MEMO_CD, MEMO_TEXT,
       SUB_ID )"""}

table_data = ["cm",      #"committee_master"),
              "cn",      #"candidate_master"),
              "ccl",     #"can_comm_linkage"),
              "itcont",  #"individual"      ),
              "itpas2",  #"comm_to_cand"    ),
              "itoth"]   #"comm_to_comm"    )]



folders = ["7980","8182","8384","8586","8788","8990","9192","9394","9596",
           "9798","9900","0102","0304","0506","0708","0910","1112"]
folders.reverse()

for folder in folders[:-1]:
  print("++++ IN FOLDER " + folder + " ++++")
  for fil in table_data:
    # no ccl data for pre 99-00
    if fil == "ccl" and folder in folders[:10]:
      continue
    print("---- ON FILE " + fil + ".txt ----")

    # set up our current ctl file
    cur_ctl = re.sub("REPLACE",folder,ctls[fil])
    f = open(fil + ".ctl",'w')
    f.write(cur_ctl)
    f.close()

    # import the table!
    subprocess.call("sqlldr cs339/cs339 control=" + fil + \
        ".ctl errors=999999999 direct=true", shell=True)

print("FINISHED!")
