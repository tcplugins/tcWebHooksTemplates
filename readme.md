
# tcWebHooksTemplates - A collection of WebHook Templates for the tcWebHooks TeamCity plugin

This GitHub repository is a place to share and discover WebHook Templates.

Have a browse of the [webhook-templates](./webhook-templates/) area, and see if there are any templates you'd like to install.

### Importing a WebHook Template from this repository

This is the process of taking a `webhook-template.json` file, and uploading it into TeamCity.
This is achieved using the tcWebHook REST API. If the tcWebHook REST API plugin is not installed in TeamCity, you will need to do that first. See the [tcWebHook Installation instructions](https://github.com/tcplugins/tcWebHooks/wiki/Installing).

#### Obtaining the templates

Just Git clone this repository, or download the repository and unzip it. The templates are located under the *webhook-templates* folder. 

#### Importing a WebHook Template using the import-template.sh script
Note: The script does not need to be run on the same computer as the TeamCity server

Requirements: 
1. A unix based computer, eg a Mac, or Linux or other Unix based OS, or a Windows computer with one of the many posix shells installed (eg, cygwin, git-bash, etc).
2. Standard unix tools, including bash, curl, grep, tr
3. http or https access to TeamCity

##### Run the import script

The import script takes three arguments. If they are not present on the commndline, the script will prompt for them.

A template's templateId, is shown near to top of the page when viewing a template in the webUI. Go to `/webhooks/templates.html` in TeamCity and click `view` on a template to see the template details.
  
- `-u username:password` : This a teamcity account with admin privileges. Username and password are colon seperated as per usual cURL syntax.
- `-s teamcity-server-url` : The server address for TeamCity. Please don't include the trailing slash.
- `-t templateId` : The templateId of the template to upload. The script will look for it in a directory (folder) of the same name under `webhook-templates`. The script also checks that the ID inside the template JSON file matches the name of the directory (folder).


```
./tcWebHooksTemplates/bin/import-template.sh -u netwolfuk:xxxxxxxx -s http://teamcity:8111 -t stride_simple
INFO:   Checking template in: ./tcWebHooksTemplates/bin/../webhook-templates/stride_simple
INFO:   Template file is present and matches stride_simple
INFO:   URL: http://teamcity:8111/app/rest/webhooks/templates/id:stride_simple
INFO:   Template with that ID already exists in TeamCity. Using PUT to update it.
INFO:   Template successfully updated with ID: stride_simple

```

#### Importing a WebHook Template manually via the REST API

**Creating a new template with POST**

To create a new template, POST to `/app/rest/webhooks/templates`

```
curl -X POST -H "Content-Type: application/json" -u "netwolfuk:xxxxxxxx" -d @tcWebHooksTemplates/webhook-templates/stride_simple/webhook-template.json http://teamcity:8111/app/rest/webhooks/templates

```
The response will contain the new template (in XML format unless you request json with `-H "Accept: application/json"`)

**Updating an existing template with PUT**

To replace an existing template, PUT to `/app/rest/webhooks/templates/id:templateId`

```
curl -X PUT -H "Content-Type: application/json" -u "netwolfuk:xxxxxxxx" -d @tcWebHooksTemplates/webhook-templates/stride_simple/webhook-template.json http://teamcity:8111/app/rest/webhooks/templates/id:stride_simple
```
The response will contain the updated template (in XML format unless you request json with `-H "Accept: application/json"`)

#### Modifying a template in TeamCity

Once a template is imported, it's possible to make changes to it from within TeamCity to further refine it. For information about editing WebHook Templates, please see the [WebHook-Templates-:-Web-UI](https://github.com/tcplugins/tcWebHooks/wiki/WebHook-Templates-%3A-Web-UI) section on the tcWebHooks wiki.

#### Exporting a WebHook Template using the export-template.sh script
Note: The script does not need to be run on the same computer as the TeamCity server

Requirements: 
1. A unix based computer, eg a Mac, or Linux or other Unix based OS, or a Windows computer with one of the many posix shells installed (eg, cygwin, git-bash, etc).
2. Standard unix tools, including bash, curl, grep, tr
3. http or https access to TeamCity

##### Run the export script

The export script takes three arguments. If they are not present on the commndline, the script will prompt for them.

A template's templateId, is shown near to top of the page when viewing a template in the webUI. Go to `/webhooks/templates.html` in TeamCity and click `view` on a template to see the template details.
  
- `-u username:password` : This a teamcity account with admin privileges. Username and password are colon seperated as per usual cURL syntax.
- `-s teamcity-server-url` : The server address for TeamCity. Please don't include the trailing slash.
- `-t templateId` : The templateId of the template to download. The script will create a directory (folder) of the same name under `webhook-templates`. The script copies a `readme.md` into that directory in case you want to share the template.


```
./tcWebHooksTemplates/bin/export-template.sh -u netwolfuk:xxxxxxxx -s http://teamcity:8111 -t stride_simple
INFO:   Template will be downloaded into: ./tcWebHooksTemplates/bin/../webhook-templates/stride_simple
INFO:   URL: http://teamcity:8111/app/rest/webhooks/templates/id:stride_simple
INFO:   Success: The template has been downloaded into: ./tcWebHooksTemplates/bin/../webhook-templates/stride_simple
INFO:   Generating readme.md file in ./tcWebHooksTemplates/bin/../webhook-templates/stride_simple
```
