-- This is the oracle sqlldr control file for the dbest.CMNT table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'comment.*'
-- BADFILE 'comment.*.err'
APPEND
INTO TABLE dbest.CMNT
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_EST         CHAR(50) ,
 LOCAL_ID       CHAR(50),
 DATA           CHAR(260) TERMINATED BY "\t"
)
