$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Import param settings from config file
[xml]$ConfigFile = Get-Content "$myDirParams.xml"

$collection = "/" + $ConfigFile.Server.collection

$instance = $ConfigFile.Server.url

$pat = $ConfigFile.PAT 

$encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$pat"))
 
# Build the Team Project list 
# Ex.: https://{instance}/DefaultCollection/_apis/projects?api-version={version}[&stateFilter{string}&$top={integer}&skip={integer}]
$resource = '/projects'
$version = '1.0'
$listurl = 'http://' + $instance + $collection + '/_apis' + $resource + '?api-version=' + $version

# Call the REST API
$resp = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat"}
 
Write-Output $resp.value