-- This is the oracle sqlldr control file for the dbest.MAPREC table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'maprec.*'
-- BADFILE 'maprec.*.err'
APPEND
INTO TABLE dbest.MAPREC
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_MAP           CHAR(50),
 ID_EST           CHAR(50),
 ID_METHOD        CHAR(50),
 ID_PUB           CHAR(50),
 ID_CONTACT       CHAR(50),
 PUBLC            DATE "Mon DD YYYY HH:MIAM",
 SUPERSEDED_BY    CHAR(50),
 MAPSTRING        CHAR(130),
 CHROMOSOME	  CHAR(130),
 COORD_L          CHAR(130),
 COORD_R          CHAR(130),
 L1		  CHAR(130),
 L2		  CHAR(130),
 L3               CHAR(130),
 L4		  CHAR(130),
 L5		  CHAR(130),
 L6		  CHAR(130),
 L7		  CHAR(130),
 L8		  CHAR(130),
 L9		  CHAR(130),
 L10		  CHAR(130) TERMINATED BY "\t"
)
