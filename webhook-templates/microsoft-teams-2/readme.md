# User Contributed tcWebHooks WebHook Template

Name | Detail
---- | ------
Template Description | *Microsoft Teams (light)*
Template Id | *microsoft-teams-2*
Contributor | jacobjohnston (github), netwolfuk (github)

## Purpose
A template for interacting with the Microsoft Teams Group Chat Software.
Currently just supports the started, success and failed events.
Pull requests welcome for adding other events or enhancing the message.

## Example output
![Teams failure](/webhook-templates/microsoft-teams-2/screenshot.png)
## Installation/Configuration Instructions
After installing this template in TeamCity, follow these instructions to create a Incoming Webhook URL in a Microsoft Teams channel and create a Webhook in TeamCity

1. Open Microsoft Teams.
1. Open the channel you want to post to from TeamCity.
1. Click the **...** menu on the right of the channel name then select **Connectors**.
1. In the connector list, on **Incoming Webhook** click the **Configure** button.
1. On the opening dialog enter a name for the Incoming Webhook, e.g. TeamCity.
1. Optionally, upload an image representing TeamCity.
1. Click **Create** button. Microsoft Teams will then show the Webhook Incoming URL.
1. Copy the URL which is created into the clipboard.
1. In another browser tab or window, create a new WebHook in TeamCity. See [Creating-a-WebHook](https://github.com/tcplugins/tcWebHooks/wiki/Creating-a-WebHook) for details.
1. Copy and paste the URL from the Microsoft Teams dialog into the WebHook dialog.
1. Set the WebHook _Payload Format_ to **Microsoft Teams (light) (JSON)**.
1. Choose the WebHook _Build Events_ you want to post to your Microsoft Teams channel.   
1. Click Save, and then trigger a build. You should see messages appear in the Microsoft Teams channel.