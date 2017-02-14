create table candidate_office_codes (
  CAND_OFFICE   VARCHAR2(1) PRIMARY KEY,
  CAND_OFFICE_DESC  VARCHAR2(64) NOT NULL
);

insert into candidate_office_codes values ('H','House');
insert into candidate_office_codes values ('P','President');
insert into candidate_office_codes values ('S','Senate');

create table candidate_ici_codes (
  CAND_ICI  VARCHAR2(1) PRIMARY KEY,
  CAND_ICI_DESC VARCHAR2(64)
);

insert into candidate_ici_codes values ('C','Challenger');
insert into candidate_ici_codes values ('I','Incumbent');
insert into candidate_ici_codes values ('O','Open Seat');

create table candidate_status_codes (
  CAND_STATUS VARCHAR2(1) PRIMARY KEY,
  CAND_STATUS_DESC VARCHAR2(64)
);

insert into candidate_status_codes values ('C','Statutory candidate');
insert into candidate_status_codes values ('F','Statutory candidate for future election');
insert into candidate_status_codes values ('N','Not yet statutory candidate');
insert into candidate_status_codes values ('P','Statutory candidate in prior cycle');

create table candidate_master (
  CAND_ID               VARCHAR2(9) NOT NULL PRIMARY KEY,
  CAND_NAME             VARCHAR2(200),
  CAND_PTY_AFFILIATION  VARCHAR2(3),
  CAND_ELECTION_YR      NUMBER(4),
  CAND_OFFICE_ST        VARCHAR2(2),
  CAND_OFFICE           VARCHAR2(1) REFERENCES candidate_office_codes(CAND_OFFICE),
  CAND_OFFICE_DISTRICT  VARCHAR2(2),
  CAND_ICI              VARCHAR2(1) REFERENCES candidate_ici_codes(CAND_ICI),
  CAND_STATUS           VARCHAR2(1) REFERENCES candidate_status_codes(CAND_STATUS),
  CAND_PCC              VARCHAR2(9),
  CAND_ST1              VARCHAR2(34),
  CAND_ST2              VARCHAR2(34),
  CAND_CITY             VARCHAR2(30),
  CAND_ST               VARCHAR2(2),
  CAND_ZIP              VARCHAR2(9)
);

quit;

