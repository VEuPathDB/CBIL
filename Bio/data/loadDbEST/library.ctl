 -- This is the oracle sqlldr control file for the dbest.LIBRARY table
LOAD DATA
-- not needed since I need to give multiple files on the command line
-- INFILE 'library.*'
-- BADFILE 'library.*.err'
APPEND
INTO TABLE dbest.LIBRARY
FIELDS TERMINATED BY '\t'
TRAILING NULLCOLS
(ID_LIB       CHAR(50),      	
 NAME         CHAR(130),
 ORGANISM     CHAR(160),
 STRAIN       CHAR(160),
 CULTIVAR     CHAR(160),
 SEX          CHAR(70),
 ORGAN        CHAR(160),
 TISSUE_TYPE  CHAR(160),
 CELL_TYPE    CHAR(160),
 CELL_LINE    CHAR(160),
 DEV_STAGE    CHAR(160),
 LAB_HOST     CHAR(160),
 VECTOR       CHAR(160),
 V_TYPE       CHAR(70),
 RE_1         CHAR(50),
 RE_2         CHAR(50),
 DESCRIPTION  CHAR(5000) TERMINATED BY "\t"
)
