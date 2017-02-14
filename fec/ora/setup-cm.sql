create table committee_designation_codes (
  CMTE_DSGN   VARCHAR(1) PRIMARY KEY,
  CMTE_DSGN_DESC   VARCHAR(64) NOT NULL      
);

insert into committee_designation_codes values ('A','Authorized by a candidate');
insert into committee_designation_codes values ('B','Lobbyist/Registrant PAC');
insert into committee_designation_codes values ('D','Leadership PAC');
insert into committee_designation_codes values ('J','Joint fundraiser');
insert into committee_designation_codes values ('P','Principle campaign committee of a candidate');
insert into committee_designation_codes values ('U','Unauthorized');


create table committee_type_codes (
  CMTE_TP   VARCHAR(1) PRIMARY KEY,
  CMTE_TP_DESC   VARCHAR(64) NOT NULL      
);

insert into committee_type_codes values ('C','Communication Cost');
insert into committee_type_codes values ('D','Delegate Committee');
insert into committee_type_codes values ('E','Electioneering Communication');
insert into committee_type_codes values ('H','House');
insert into committee_type_codes values ('I','Independent Expenditor');
insert into committee_type_codes values ('N','PAC - Nonqualified');
insert into committee_type_codes values ('O','Independent Expenditure-Only (Super PAC)');
insert into committee_type_codes values ('P','Presidential');
insert into committee_type_codes values ('Q','PAC - Qualified');
insert into committee_type_codes values ('S','Senate');
insert into committee_type_codes values ('U','Single Candidate Independent Expenditure');
insert into committee_type_codes values ('V','PAC with Non-contribution Account - Nonqualified');
insert into committee_type_codes values ('W','PAC with Non-contribution Account - Qualified');
insert into committee_type_codes values ('X','Party - Nonqualifed');
insert into committee_type_codes values ('Y','Party - Qualified');
insert into committee_type_codes values ('Z','National Party Nonfederal Account');

create table committee_filingfreq_codes (
  CMTE_FILING_FREQ   VARCHAR(1) PRIMARY KEY,
  CMTE_FILING_FREQ_DESC   VARCHAR(64) NOT NULL      
);

insert into committee_filingfreq_codes values ('A','Administratively terminated');
insert into committee_filingfreq_codes values ('D','Debt');
insert into committee_filingfreq_codes values ('M','Monthly filer');
insert into committee_filingfreq_codes values ('Q','Quarterly filer');
insert into committee_filingfreq_codes values ('T','Terminated');
insert into committee_filingfreq_codes values ('W','Waived');

create table committee_interest_group_codes (
  ORG_TP   VARCHAR(1) PRIMARY KEY,
  ORG_TP_DESC   VARCHAR(64) NOT NULL      
);

insert into committee_interest_group_codes values ('C','Corporation');
insert into committee_interest_group_codes values ('L','Labor organizaion');
insert into committee_interest_group_codes values ('M','Membership organiztion');
insert into committee_interest_group_codes values ('T','Trade assocation');
insert into committee_interest_group_codes values ('V','Cooperative');
insert into committee_interest_group_codes values ('W','Corporation without capital stock');



create table committee_master (
  CMTE_ID   VARCHAR2(9) PRIMARY KEY,
  CMTE_NM   VARCHAR2(200) NOT NULL, -- unbelievably, need not be unique...
  TRES_NM   VARCHAR2(90), -- unbelievably, these fields can be null in their data...
  CMTE_ST1  VARCHAR2(34),
  CMTE_ST2  VARCHAR2(34),
  CMTE_CITY VARCHAR2(30),
  CMTE_ST   VARCHAR2(2),
  CMTE_ZIP  VARCHAR2(9),
  CMTE_DSGN VARCHAR2(1) REFERENCES committee_designation_codes(CMTE_DSGN),
  CMTE_TP   VARCHAR2(1) REFERENCES committee_type_codes(CMTE_TP),
  CMTE_PTY_AFFILIATION VARCHAR2(3), -- need not be affiliated with a party
  CMTE_FILING_FREQ VARCHAR2(1) REFERENCES committee_filingfreq_codes(CMTE_FILING_FREQ),
  ORG_TP    VARCHAR2(1) REFERENCES committee_interest_group_codes(ORG_TP),
  CONNECTED_ORG_NM VARCHAR2(200), -- REFERENCES  committee_master(CMTE_NM), --- can be null, but if not, refs this table
  CAND_ID   VARCHAR2(9) -- can be null depending on the designation code (not null if H, S or P
  --
  -- sqlldr direct path cannot tolerate this constraint
  --
  -- constraint valid_cand_id CHECK ((CAND_ID IS NOT NULL) OR (CMTE_DSGN NOT IN ('H','S','P')))
);



quit;

