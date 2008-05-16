-- This is the oracle sqlldr control file for the dbest.CONTACT table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'contact.*'
-- BADFILE 'contact.*.err'
APPEND
INTO TABLE dbest.CONTACT
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_CONTACT          CHAR(50),
 NAME                CHAR(260),
 FAX	             CHAR(260),
 PHONE               CHAR(260),
 EMAIL               CHAR(260),
 LAB	             CHAR(260),
 INSTITUTION         CHAR(260),
 ADDRESS	     CHAR(260) TERMINATED BY "\t"
)
