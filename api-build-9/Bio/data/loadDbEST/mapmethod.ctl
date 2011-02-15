-- This is the oracle sqlldr control file for the dbest.MAPMETHOD table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'mapmethod.*'
-- BADFILE 'mapmethod.*.err'
APPEND
INTO TABLE dbest.MAPMETHOD
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_METHOD        CHAR(50),
 NAME             CHAR(260),
 ORGANISM         CHAR(160),
 ABS_REL          CHAR(50),
 L1		  CHAR(130),
 L2		  CHAR(130),
 L3               CHAR(130),
 L4		  CHAR(130),
 L5		  CHAR(130),
 L6		  CHAR(130),
 L7		  CHAR(130),
 L8		  CHAR(130),
 L9		  CHAR(130),
 L10		  CHAR(130),
 SP_NAME	  CHAR(130),
 DESCRN 	  CHAR(2000) TERMINATED BY "\t"
)
