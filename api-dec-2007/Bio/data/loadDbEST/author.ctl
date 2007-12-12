-- This is the oracle sqlldr control file for the dbest.AUTHOR table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'author.*'
-- BADFILE 'author.*.err'
APPEND
INTO TABLE dbest.AUTHOR
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_PUB          CHAR(50),
 AUTHOR          CHAR(260),
 POSITION	 CHAR(50) TERMINATED BY "\t"
)
