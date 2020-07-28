# User Contributed tcWebHooks WebHook Template

Name | Detail
---- | ------
Template Description | *A slack template which includes changes*
Template Id | *slack.com-changes*
Contributor | github: netwolfuk

## Purpose
Enhanced slack.com template which lists changes as well.

## Example output
![Slack success](/webhook-templates/slack.com-changes/finished_with_changes.png)


## Installation/Configuration Instructions
**This template requires tcWebHooks 1.2**
1. Create a webhook endpoint in slack.
2. Create a TeamCity project parameter called `webhook.slackMapping`.
3. Create a webhook using the `slack.com-changes` template.

The `slackMapping` value maps git usernames to slack member Ids.
The content of the parameter should look like...
```
{
"git_user_name": "U0xxxxxx"
}
```

The member ID can be obtained from the "...more" section of a user's profile in the Slack app.

