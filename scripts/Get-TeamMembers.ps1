$myDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Import param settings from config file
[xml]$ConfigFile = Get-Content "$myDir\Params.xml"

$collection = "/" + $ConfigFile.Configuration.Server.collection

$instance = $ConfigFile.Configuration.Server.url

$pat = $ConfigFile.Configuration.PAT 

$encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$pat"))
 
# Build the Team Project list 
# Ex.: https://{instance}/DefaultCollection/_apis/projects?api-version={version}[&stateFilter{string}&$top={integer}&skip={integer}]
$resource = '/projects'
$version = '1.0'
$listurl = 'http://' + $instance + $collection + '/_apis' + $resource + '?api-version=' + $version

$TPs = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat"}

# Build the Teams list 
# Ex.: https://{instance}/DefaultCollection/_apis/projects/{project}/teams?api-version={version}[&$top={integer}&$skip={integer}]
ForEach($TP in $TPs.value){
    $resource = '/projects/' + $TP.id + '/Teams'
    $version = '2.2'
    $listurl = 'http://' + $instance + $collection + '/_apis' + $resource + '?api-version=' + $version

    $Teams = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat"}

    Write-Output '=========================='
    Write-Output $TP.name
    Write-Output '=========================='
    
    ForEach($Team in $Teams.value){

        $resource = '/projects/' + $TP.id + '/Teams' + '/' + $Team.id + '/members'
        $version = '2.2'
        $listurl = 'http://' + $instance + $collection + '/_apis' + $resource + '?api-version=' + $version
        # GET https://{instance}/DefaultCollection/_apis/projects/{project}/teams/{team}/members?api-version={version}[&$to{integer}&$skip={integer}]

        $Members = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat"}

        Write-Output '++++++++++++++++++++++++++'
        Write-Output $Team.name
        Write-Output '++++++++++++++++++++++++++'
                
        Write-Output 'Membros: '
        ForEach($Member in $Members){
            Write-Output $Member.value.displayName
        }
    }
}

