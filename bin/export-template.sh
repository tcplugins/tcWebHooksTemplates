#!/usr/bin/env bash

MY_RUN_DIR=`dirname $0`
MY_TEMPLATE_DIR="${MY_RUN_DIR}/../webhook-templates" 

MY_TEMPLATE_ID=""
MY_SERVER=""
MY_USERPASS=""

MY_EXTRACTED_ID="unknown"
MY_EXTRACTED_DESCRIPTION="unknown"


function checkDir { 
    echo "INFO:   Template will be downloaded into: ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}"
	if [  -d ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID} ] ; then 
	    echo "WARN:   The download folder already exists. Any existing template file will be overwritten."
	else
		mkdir -p ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID} 
		if [  ! -d ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID} ] ; then 
			echo "ERROR:  Failed to create destination folder: ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}"
			exit 2;
		fi
	fi
}

function checkDownloadedFile { 
	if [ ! -r  $1 ] ; then
	    echo "ERROR:  The template file does not appear to have been downloaded properly."
	    echo "INFO:   Template file not found in $1" 
	else
	    echo "INFO:   Success: The template has been downloaded into: ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}"
	fi
}

function printRelevantError {
    local HTTP_CODE=$1
    case $HTTP_CODE in
    404)
      echo "ERROR:  404 - The template with id \"${MY_TEMPLATE_ID}\" was not found on the TeamCity server."
      ;;
    401)
      echo "ERROR:  401 - The user supplied does not have permission to access TeamCity"
      ;;
    000)
      echo "ERROR:  000 - It looks like curl was not able to connect to TeamCity"
      echo "INFO:   Please check the teamcity address was correct: ${MY_SERVER}"
      ;;
    *)
      echo "ERROR:  An unknown error occured. HTTP Response was: $HTTP_CODE"
      ;;
  esac    
}

function checkResponseCode {
    local EXPECTED=$1
    local ACTUAL=$2
    
     if [ $EXPECTED -ne $ACTUAL ] ; then
         echo "WARN:   Curl returned an unexpected response code. Something went wrong downloading the template from TeamCity"
	     printRelevantError $ACTUAL
	     exit 1;
	 fi
     
}

function logErrorAndExit {
	echo "INFO:   Cleaning up file in $TEMP_TEMPLATE_FILE"	
	rm -f $TEMP_TEMPLATE_FILE
	echo "ERROR:  $@"
	exit 3; 
}

function extractIdAndNameFromTemplate {
    local TEMPLATE_FILE=$1
    MY_EXTRACTED_ID=`grep -Po '^{"id":.*?[^\\]",' $TEMPLATE_FILE  | sed 's/^{\"id\":\"//'  | sed 's/\",$//'`
    MY_EXTRACTED_DESCRIPTION=`grep -Po '"description":.*?[^\\]",' $TEMPLATE_FILE  | sed 's/\"description\":\"//'  | sed 's/\",$//'`
    
}

function checkIdMatches {
	local EXPECTED=$1
	local ACTUAL=$2
	if [ "$EXPECTED" != "$ACTUAL" ] ; then
	    echo "ERROR:  The ID in the downloaded file does not match the one requested."
	    echo "INFO:   Expecting: $EXPECTED  but found: $ACTUAL"
	    echo "INFO:   The downloaded file will not be copied into ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}"
	    logErrorAndExit "Cleaning up file in $TEMP_TEMPLATE_FILE"
	fi 
}

function getTemplate {
	TEMP_TEMPLATE_FILE=`mktemp` || logErrorAndExit "Could not create temp working file"
	MY_TEMPLATE_FILE=${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}/webhook-template.json
	echo "INFO:   URL: ${MY_SERVER}/app/rest/webhooks/templates/id:${MY_TEMPLATE_ID}"
	
	{ EXIT_CODE=$( curl --silent --output /dev/stderr --write-out "%{http_code}" -u ${MY_USERPASS} \
	 -X GET \
	 -H "Accept:application/json" \
	 -H "Content-type: application/json" \
	 ${MY_SERVER}/app/rest/webhooks/templates/id:${MY_TEMPLATE_ID}?fields=\$long,content \
	 ); } > ${TEMP_TEMPLATE_FILE} 2>&1 
	 
	checkResponseCode 200 $EXIT_CODE
	extractIdAndNameFromTemplate $TEMP_TEMPLATE_FILE
	checkIdMatches $MY_TEMPLATE_ID $MY_EXTRACTED_ID
	cp $TEMP_TEMPLATE_FILE $MY_TEMPLATE_FILE
	checkDownloadedFile $MY_TEMPLATE_FILE
}

function promptForUnsetOptions { 
	if [ -z ${MY_TEMPLATE_ID} ] ; then
	   echo "Please enter templateId:"
	   read MY_TEMPLATE_ID
	fi
	
	if [ -z ${MY_SERVER} ] ; then
	   echo "Please enter the teamcity base url:"
	   echo "eg: http://my-teamcity-server:8111"
	   read MY_SERVER
	fi
	
	if [ -z ${MY_USERPASS} ] ; then
	   echo "Please enter teamcity username and password seperated by colon:"
	   echo "This is the usual curl user:pass format. eg,  user:pass"
	   read MY_USERPASS
	fi
}

############
# 
# Main starts here
#
############


# Fistly, loop over commandline args
# and set any options passed in.
while getopts ":u:s:t:" opt; do
  case $opt in
    u)
      MY_USERPASS=$OPTARG
      ;;
    s)
      MY_SERVER=$OPTARG
      ;;
    t)
      MY_TEMPLATE_ID=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# If there are options missing, 
# ask the user for them: 
promptForUnsetOptions

# Check if destination dir exists
# and create it if it doesn't
checkDir

# Get the template from teamcity
getTemplate

# Create README if it doesn't already exist
generateReadmeFile