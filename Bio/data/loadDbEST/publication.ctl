-- This is the oracle sqlldr control file for the dbest.PUBLICATION table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'publication.*'
-- BADFILE 'publication.*.err'
APPEND
INTO TABLE dbest.PUBLICATION
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_PUB 	CHAR(50),
 MEDUID 	CHAR(50),
 TITLE		CHAR(260),
 JOURNAL	CHAR(260),
 VOL		CHAR(260),
 SUPPL		CHAR(130),
 ISSUE		CHAR(130),
 I_SUPPL	CHAR(130),
 PAGES		CHAR(260),
 YEAR		CHAR(50),
 STATUS 	CHAR(50),
 BLOBFLAG	CHAR(50),
 ASN		CHAR(4500) TERMINATED BY "\t"
)
