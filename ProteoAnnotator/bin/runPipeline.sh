#!/bin/sh
# The shell script to run the Proteomics Pipeline
# Set the PIPELINE_HOME in .profile file
PIPELINE_HOME="$1"
#echo "Starting the Proteomics Pipeline For A Single MGF.."
#echo "Proteomics Pipeline Path = $PIPELINE_HOME"

EXECUTE_DIR="$2"
MGF_DIR="$3"
OUTPUT_DIR="$4"

#if [ ! -d $OUTPUT_DIR ]
#    then
#    mkdir $OUTPUT_DIR
#fi

#echo $OUTPUT_DIR

cd "$PIPELINE_HOME"


INPUT_SEARCH_CONFIG=$EXECUTE_DIR/inputFiles/searchCriteria.txt
INPUT_DB_CONFIG=$GUS_HOME/data/DJob/DistribJobTasks/databaseCriteria.txt

INPUT_MGF=$(find $MGF_DIR -type f -name "*.mgf")
echo $INPUT_MGF


# Change to the Pipeline directory
#echo "$PWD"

java -jar $GUS_HOME/lib/java/proteoannotator.jar single_mode -searchInput $INPUT_SEARCH_CONFIG -databaseInput $INPUT_DB_CONFIG -inputMgf $INPUT_MGF -outputResultDir $OUTPUT_DIR  

