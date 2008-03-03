-- This is the oracle sqlldr control file for the dbest.EST table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'est.*'
-- BADFILE 'est.*.err'
APPEND
INTO TABLE dbest.EST
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(id_est         CHAR(50) ,
 ID_GI          CHAR(50),
 HSP_ID         CHAR(50),
 HSP_FOPID      CHAR(50),
 CREATE_DATE    DATE "Mon DD YYYY HH:MIAM",
 ID_LIB         CHAR(50),
 ID_CONTACT     CHAR(50),
 ID_PUB         CHAR(50),
 EST_UID        CHAR(64),
 GB_UID         CHAR(40),
 GB_VERSION     CHAR(50),
 GB_SEC         CHAR(64),
 GDB_UID        CHAR(64),
 GDB_DSEG       CHAR(64),
 DBNAME         CHAR(64),
 DBXREF         CHAR(64),
 CLONE_UID      CHAR(64),
 CLONE_SOURCE   CHAR(128),
 SOURCE_DNA     CHAR(64),
 SOURCE_INHOST  CHAR(64),
 OTHER_EST      CHAR(128),
 PCR_FPRIMER    CHAR(128),
 PCR_BPRIMER    CHAR(128),
 INSERT_LENGTH  CHAR(128),
 STD_ERROR      CHAR(128),
 PLATE          CHAR(64),
 PLATE_ROW      CHAR(64),
 PLATE_COL      CHAR(64),
 SEQ_PRIMER     CHAR(128),
 P_END          CHAR(64),
 DNA_TYPE       CHAR(64) ,
 AUTHOR_ID      CHAR(300),
 PUBLC          DATE "Mon DD YYYY HH:MIAM",
 REPLACED_BY    CHAR(64),
 OWNER          CHAR(64),
 HIQUAL_START   CHAR(64),
 HIQUAL_STOP    CHAR(64),
 LAST_DUMP      DATE "Mon DD YYYY HH:MIAM",
 LAST_UPDATE    DATE "Mon DD YYYY HH:MIAM",
 TAG_LIB        CHAR(64),
 TAG_TISSUE     CHAR(128),
 TAG_SEQ        CHAR(64),
 POLYA          CHAR(64) TERMINATED BY "\t"
)
