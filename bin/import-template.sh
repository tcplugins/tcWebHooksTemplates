#!/usr/bin/env bash

MY_RUN_DIR=`dirname $0`
MY_TEMPLATE_DIR="${MY_RUN_DIR}/../webhook-templates" 

MY_TEMPLATE_ID=""
MY_SERVER=""
MY_USERPASS=""

MY_EXTRACTED_ID="unknown"

function logErrorAndExit {
	echo "ERROR:  $@"
	exit 3; 
}

function extractIdAndNameFromTemplate {
    local TEMPLATE_FILE=$1
    MY_EXTRACTED_ID=`cat $TEMPLATE_FILE | tr -d '\r\n[:space:]' | grep -Po '^{"id":.*?[^\\\]",' | sed 's/^{\"id\":\"//'  | sed 's/\",$//'`
}

function checkFile { 
    echo "INFO:   Checking template in: ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}"
	if [ ! -r ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}/webhook-template.json ] ; then 
	    logErrorAndExit "The template file does not exist. Exiting..." 
	else
		extractIdAndNameFromTemplate ${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}/webhook-template.json
		if [ "${MY_TEMPLATE_ID}" != "${MY_EXTRACTED_ID}" ] ; then
			logErrorAndExit "The template exists but the template Id in the file \"${MY_EXTRACTED_ID}\" does not match the expected Id \"${MY_TEMPLATE_ID}\". Exiting..." 
		fi 
	fi
	echo "INFO:   Template file is present and matches ${MY_TEMPLATE_ID}"
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
         echo "WARN:   Curl returned an unexpected response code. Something went wrong updating the template from TeamCity"
	     printRelevantError $ACTUAL
	     exit 1;
	 fi
     
}

function uploadTemplate {
	MY_TEMPLATE_FILE=${MY_TEMPLATE_DIR}/${MY_TEMPLATE_ID}/webhook-template.json
	echo "INFO:   URL: ${MY_SERVER}/app/rest/webhooks/templates/id:${MY_TEMPLATE_ID}"
	
	{ EXIT_CODE=$( curl --silent --output /dev/stderr --write-out "%{http_code}" -u ${MY_USERPASS} \
	 -X GET \
	 -H "Accept:application/json" \
	 -H "Content-type: application/json" \
	 ${MY_SERVER}/app/rest/webhooks/templates/id:${MY_TEMPLATE_ID} \
	 ); } > /dev/null 2>&1 
	
	if [ $EXIT_CODE -eq 200 ] ; then 
		# The template exists, so PUT a new copy. 
		echo "INFO:   Template with that ID already exists in TeamCity. Using PUT to update it."
		{ EXIT_CODE=$( curl --silent --output /dev/stderr --write-out "%{http_code}" -u ${MY_USERPASS} \
		 -X PUT \
		 -H "Accept:application/json" \
		 -H "Content-type: application/json" \
		 ${MY_SERVER}/app/rest/webhooks/templates/id:${MY_TEMPLATE_ID} -d @${MY_TEMPLATE_FILE} \
		 ); } > /dev/null 2>&1 
	 
		checkResponseCode 200 $EXIT_CODE
		echo "INFO:   Template successfully updated with ID: ${MY_TEMPLATE_ID}"
	else
		echo "INFO:   No existing Template with that ID in TeamCity. Using POST to create it."
		{ EXIT_CODE=$( curl --silent --output /dev/stderr --write-out "%{http_code}" -u ${MY_USERPASS} \
		 -X POST \
		 -H "Accept:application/json" \
		 -H "Content-type: application/json" \
		 ${MY_SERVER}/app/rest/webhooks/templates -d @${MY_TEMPLATE_FILE} \
		 ); } > /dev/null 2>&1
		 
		 checkResponseCode 200 $EXIT_CODE
		 echo "INFO:   Template successfully created with ID: ${MY_TEMPLATE_ID}"
	fi

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

# Check if template file exists
# and exit it if it doesn't
checkFile

# Get the template from teamcity
uploadTemplate
