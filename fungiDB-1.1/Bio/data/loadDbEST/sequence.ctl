-- This is the oracle sqlldr control file for the dbest.SEQUENCE table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'sequence.*'
-- BADFILE 'sequence.*.err'
APPEND
INTO TABLE dbest.SEQUENCE
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(id_est         CHAR(50),
 LOCAL_ID       CHAR(50),
 DATA           CHAR(260) TERMINATED BY "\t"
)
