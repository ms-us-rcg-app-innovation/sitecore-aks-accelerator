param(
    [Parameter(Mandatory = $true)]
    [string]$Server,
    [Parameter(Mandatory = $true)]
    [string]$User,
    [Parameter(Mandatory = $true)]
    [string]$Password
)

sqlcmd -S tcp:$Server,1433 -U $User -P $Password -i create_user.sql -d Sitecore.Core -v username=coreuser
sqlcmd -S tcp:$Server,1433 -U $User -P $Password -i create_user.sql -d Sitecore.Experienceforms -v username=formsuser
sqlcmd -S tcp:$Server,1433 -U $User -P $Password -i create_user.sql -d Sitecore.Master -v username=masteruser
sqlcmd -S tcp:$Server,1433 -U $User -P $Password -i create_user.sql -d Sitecore.Web -v username=webuser