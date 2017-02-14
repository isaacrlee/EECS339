--create table committee_design_codes (
--  CMTE_DSGN VARCHAR2(1) PRIMARY KEY,
--  CMTE_DSGN_DESC VARCHAR2(64) NOT NULL
--);

--insert into committee_design_codes values ('A','Authorized by a candidate');
--insert into committee_design_codes values ('B','Lobbyist/Registrant PAC');
--insert into committee_design_codes values ('D','Leadership PAC');
--insert into committee_design_codes values ('J','Joint fundraiser');
--insert into committee_design_codes values ('P','Principal campaign committee of candidate');
--insert into committee_design_codes values ('U','Unauthorized');

create table cand_comm_linkage (
  CAND_ID               VARCHAR2(9) NOT NULL REFERENCES candidate_master(CAND_ID),
  CAND_ELECTION_YR      NUMBER(4) NOT NULL,
  FEC_ELECTION_YR       NUMBER(4) NOT NULL,
  CMTE_ID               VARCHAR2(9) REFERENCES committee_master(CMTE_ID),
  CMTE_TP               VARCHAR2(9) REFERENCES committee_type_codes(CMTE_TP),
  CMTE_DSGN             VARCHAR2(1) REFERENCES committee_designation_codes(CMTE_DSGN),
  LINKAGE_ID            NUMBER(12) NOT NULL PRIMARY KEY
);

quit;

