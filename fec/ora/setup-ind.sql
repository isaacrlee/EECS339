create table amendment_ind_codes (
  AMNDT_IND VARCHAR2(1) PRIMARY KEY,
  AMNDT_Ind_DESC VARCHAR2(64) NOT NULL
);

insert into amendment_ind_codes values ('N','New');
insert into amendment_ind_codes values ('A','Amendment to previous report');
insert into amendment_ind_codes values ('T','Termination of previous report');

create table report_type_codes (
  RPT_TP  VARCHAR2(3) PRIMARY KEY,
  RPT_TP_DESC VARCHAR2(550) NOT NULL
);

insert into report_type_codes values('12C','PRE-CONVENTION  For states using conventions to select candidates. Report covers through 20 days before the convention');
insert into report_type_codes values('12G','PRE-GENERAL Report covers through 20 days before the general election - due 12 days before the election');
insert into report_type_codes values('12P','PRE-PRIMARY Report covers through 20 days before the primary- due 12 days before the election');
insert into report_type_codes values('12R','PRE-RUN-OFF Report covers through 20 days before the run-off- due 12 days before the election');
insert into report_type_codes values('12S','PRE-SPECIAL Report covers through 20 days before the special election - due 12 days before the election');
insert into report_type_codes values('30D','POST-ELECTION Report covers from 19 days before the election through 20 days after - due 30 days after the election');
insert into report_type_codes values('30G','POST-GENERAL  Report covers from 19 days before the election through 20 days after. - due 30 days after the election');
insert into report_type_codes values('30P','POST-PRIMARY  Report covers from 19 days before the election through 20 days after. - due 30 days after the election');
insert into report_type_codes values('30R','POST-RUN-OFF  Report covers from 19 days before the election through 20 days after. - due 30 days after the election');
insert into report_type_codes values('30S','POST-SPECIAL  Report covers from 19 days before the election through 20 days after. - due 30 days after the election');
insert into report_type_codes values('60D','POST-CONVENTION Report filed by national party convention and host committees disclosing their convention expenses, due 61 days after the convention');
insert into report_type_codes values('ADJ','COMP ADJUST AMEND Adjustment of a comprehensive amendment - coverage is variable');
insert into report_type_codes values('CA',' COMPREHENSIVE AMEND Amendment modifying information from two or more original reports - coverage is variable');
insert into report_type_codes values('M10','OCTOBER MONTHLY Covers September - due October 20');
insert into report_type_codes values('M11','NOVEMBER MONTHLY  Covers October - due November 20');
insert into report_type_codes values('M12','DECEMBER MONTHLY  Covers November - due December 20');
insert into report_type_codes values('M2',' FEBRUARY MONTHLY  Covers January - due February 20');
insert into report_type_codes values('M3',' MARCH MONTHLY Covers February - due March 20');
insert into report_type_codes values('M4',' APRIL MONTHLY Covers March - due April 20');
insert into report_type_codes values('M5',' MAY MONTHLY Covers April - due May 20');
insert into report_type_codes values('M6',' JUNE MONTHLY  Covers May - due June 20');
insert into report_type_codes values('M7',' JULY MONTHLY  Covers June - due July 20');
insert into report_type_codes values('M8',' AUGUST MONTHLY  Covers July - due August 20');
insert into report_type_codes values('M9',' SEPTEMBER MONTHLY Covers August - due September 20');
insert into report_type_codes values('MY',' MID-YEAR REPORT Covers January 1 through June 30 - due July 31 Permissible in non-election years for PACs and party committees normally filing Quarterly reports. (Note that since 2003 campaign committees must file quarterly in all years.)');
insert into report_type_codes values('Q1',' APRIL QUARTERLY Covers January 1 through March 31 - due April 15');
insert into report_type_codes values('Q2',' JULY QUARTERLY  Covers April 1 through June 30 - due July 15');
insert into report_type_codes values('Q3',' OCTOBER QUARTERLY Covers July 1 through September 30 - due October 15');
insert into report_type_codes values('TER','TERMINATION REPORT  Final report submitted by a committee - coverage is variable');
insert into report_type_codes values('YE',' YEAR-END  Covers from the end of the last quarterly or mid-year report through December 31 - due January 31');
insert into report_type_codes values('90S','POST INAUGURAL SUPPLEMENT  ');
insert into report_type_codes values('90D','POST INAUGURAL  Filing of Presidential inaugural committee - due 90 days after the Inauguration');
insert into report_type_codes values('48H','48 HOUR NOTIFICATION  Report of specific contribution of $1,000 or more made to a campaign within 20 days of an election. Alternatively, once a PAC or party or other person has made independent expenditures exceeding $10,000 in a race these and future independent expenditures must be reported. Due within 48 hours of receiving the contribution or public distribution of the independent expenditure. 48 hour timing for independent expenditures applies prior to 20 days before the election.');
insert into report_type_codes values('24H','24 HOUR NOTIFICATION  Within 20 days of an election once a PAC or party or other person has made independent expenditures exceeding $1,000 in a race these and future independent expenditures must be reported. Due within 24 hours of the public distribution of the independent expenditure.');

--create table transaction_pgi_codes (
--  TRANSACTION_PGI VARCHAR2(5) PRIMARY KEY,
--  TRANSACTION_PGI_DESC VARCHAR2(64) NOT NULL
--);

create table entity_type_codes (
  ENTITY_TP VARCHAR2(3) PRIMARY KEY,
  ENTITY_TP_DESC  VARCHAR2(64) NOT NULL
);

insert into entity_type_codes values ('CAN','Candidate');
insert into entity_type_codes values ('CCM','Candidate Committee');
insert into entity_type_codes values ('COM','Committee');
insert into entity_type_codes values ('IND','Individual person');
insert into entity_type_codes values ('ORG','Organization (not committee and not a person');
insert into entity_type_codes values ('PAC','Political Action Committee');
insert into entity_type_codes values ('PTY','Party organization');

create table transaction_type_codes (
  TRANSACTION_TP VARCHAR2(3) PRIMARY KEY,
  TRANSACTION_TP_DESC VARCHAR2(256) NOT NULL
);

insert into transaction_type_codes values ('10','Non-Federal Receipt from Persons - Levin Account (L-1A)');
insert into transaction_type_codes values ('11','Tribal Contribution');
insert into transaction_type_codes values ('12','Non-Federal Other Receipt - Levin Account (L-2)');
insert into transaction_type_codes values ('13','Inaugural Donation Accepted');
insert into transaction_type_codes values ('15','Contribution');
insert into transaction_type_codes values ('15C','Contribution from Candidate');
insert into transaction_type_codes values ('15E','Earmarked Contribution');
insert into transaction_type_codes values ('15F','Loans forgiven by Candidate');
insert into transaction_type_codes values ('15I','Earmarked Intermediary In');
insert into transaction_type_codes values ('15J','Memo (Filers Percentage of Contribution Given to Join Fundraising Committee)');
insert into transaction_type_codes values ('15T','Earmarked Intermediary Treasury In');
insert into transaction_type_codes values ('15Z','In-Kind Contribution Received from Registered Filer');
insert into transaction_type_codes values ('16C','Loans Received from the Candidate');
insert into transaction_type_codes values ('16F','Loans Received from Banks');
insert into transaction_type_codes values ('16G','Loan from Individual');
insert into transaction_type_codes values ('16H','Loan from from Registered Filers');
insert into transaction_type_codes values ('16J','Loan Repayments from Individual');
insert into transaction_type_codes values ('16K','Loan Repayments from from Registered Filer');
insert into transaction_type_codes values ('16L','Loan Repayments Received from Unregistered Entity');
insert into transaction_type_codes values ('16R','Loans Received from Registered Filers');
insert into transaction_type_codes values ('16U','Loan Received from Unregistered Entity');
insert into transaction_type_codes values ('17R','Contribution Refund Received from Registered Entity');
insert into transaction_type_codes values ('17U','Refunds/Rebates/Returns Received from Unregistered Entity');
insert into transaction_type_codes values ('17Y','Refunds/Rebates/Returns from Individual or Corporation');
insert into transaction_type_codes values ('17Z','Refunds/Rebates/Returns from Candidate or Committee');
insert into transaction_type_codes values ('18G','Transfer In Affiliated');
insert into transaction_type_codes values ('18H','Honorarium Received');
insert into transaction_type_codes values ('18J','Memo (Files Percentage of Contribution Given to Join Fundraising Committee)');
insert into transaction_type_codes values ('18K','Contribution Received from Registered Filer');
insert into transaction_type_codes values ('18L','Bundled Contribution');
insert into transaction_type_codes values ('18S','Receipts from Secretary of State');
insert into transaction_type_codes values ('18U','Contribution Received from Unregistered Committee');
insert into transaction_type_codes values ('19','Electioneering Communication Donation Received');
insert into transaction_type_codes values ('19J','Memo (Electioneering Communication Percentage of Donation Given to Join Fundraising Committee)');
insert into transaction_type_codes values ('20','Disbursement - Exempt from Limits');
insert into transaction_type_codes values ('20A','Non-Federal Disbursement - Levin Account (L-4A) Voter Registration');
insert into transaction_type_codes values ('20B','Non-Federal Disbursement - Levin Account (L-4B) Voter Identification');
insert into transaction_type_codes values ('20C','Loan Repayments Made to Candidate');
insert into transaction_type_codes values ('20D','Non-Federal Disbursement - Levin Account (L-4D) Generic Campaign');
insert into transaction_type_codes values ('20F','Loan Repayments Made to Banks');
insert into transaction_type_codes values ('20G','Loan Repayments Made to Individual');
insert into transaction_type_codes values ('20R','Loan Repayments Made to Registered Filer');
insert into transaction_type_codes values ('20V','Non-Federal Disbursement - Levin Account (L-4C) Get Out The Vote');
insert into transaction_type_codes values ('22G','Loan to Individual');
insert into transaction_type_codes values ('22H','Loan to Candidate or Committee');
insert into transaction_type_codes values ('22J','Loan Repayment to Individual');
insert into transaction_type_codes values ('22K','Loan Repayment to Candidate or Committee');
insert into transaction_type_codes values ('22L','Loan Repayment to Bank');
insert into transaction_type_codes values ('22R','Contribution Refund to Unregistered Entity');
insert into transaction_type_codes values ('22U','Loan Repaid to Unregistered Entity');
insert into transaction_type_codes values ('22X','Loan Made to Unregistered Entity');
insert into transaction_type_codes values ('22Y','Contribution Refund to Individual');
insert into transaction_type_codes values ('22Z','Contribution Refund to Candidate or Committee');
insert into transaction_type_codes values ('23Y','Inaugural Donation Refund');
insert into transaction_type_codes values ('24A','Independent Expenditure Against');
insert into transaction_type_codes values ('24C','Coordinated Expenditure');
insert into transaction_type_codes values ('24E','Independent Expenditure For');
insert into transaction_type_codes values ('24F','Communication Cost for Candidate (C7)');
insert into transaction_type_codes values ('24G','Transfer Out Affiliated');
insert into transaction_type_codes values ('24H','Honorarium to Candidate');
insert into transaction_type_codes values ('24I','Earmarked Intermediary Out');
insert into transaction_type_codes values ('24K','Contribution Made to Non-Affiliated');
insert into transaction_type_codes values ('24N','Communication Cost Against Candidate (C7)');
insert into transaction_type_codes values ('24P','Contribution Made to Possible Candidate');
insert into transaction_type_codes values ('24R','Election Recount Disbursement');
insert into transaction_type_codes values ('24T','Earmarked Intermediary Treasury Out');
insert into transaction_type_codes values ('24U','Contribution Made to Unregistered Entity');
insert into transaction_type_codes values ('24Z','In-Kind Contribution Made to Registered Filer');
insert into transaction_type_codes values ('28L','Refund of Bundled Contribution');
insert into transaction_type_codes values ('29','Electioneering Communication Disbursement or Obligation');

create table individual (
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
  TRAN_ID               VARCHAR2(32),
  FILE_NUM              NUMBER(22),
  MEMO_CD               VARCHAR2(1),
  MEMO_TEXT             VARCHAR2(100),
  SUB_ID                NUMBER(19) NOT NULL PRIMARY KEY
);

quit;

