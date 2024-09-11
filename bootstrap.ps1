$folderName = Split-Path -Path (Get-Location) -Leaf
if(-not ($folderName -match "phoenix-[\w]*-api")) {
    Write-Host "ERR: Repo name should conform to phoenix-{apiName}-api syntax" -BackgroundColor Red
    exit 1
}

$TextInfo = (Get-Culture).TextInfo
$apiname = $TextInfo.ToTitleCase(($folderName -Split '-')[1])
$templateTitleCase = "TEMPLATE"
$templateLowerCase = "TEMP-LATE"

ForEach ($File in (Get-ChildItem -Recurse -File -Exclude *.ps1)) {
    if ($File.Directory -match 'obj' -or $File.Name -eq "pull_request_template.md") {
        continue
    }

    $content = (Get-Content $File)

    if ($content -match $templateLowerCase -or $content -match $templateTitleCase) {
        $content -Replace $templateLowerCase,$apiName.ToLower() `
            -Replace $templateTitleCase,$apiName |
            Set-Content $File
    }
}

# rename iac directory
Rename-Item -Path "./iac/deploys/$templateLowerCase-web" -NewName ($apiName.ToLower() + "-web")

# update listener_rule_priority - needs to be different for each API
Write-Host "Listener rule priority must be different for each API. Enter new priority:" -BackgroundColor red
$lrp = Read-Host
$mainTf = "./iac/deploys/$apiName-web/main.tf"
(Get-Content $mainTf) -Replace "listener_rule_priority = 4","listener_rule_priority = $lrp" |
    Set-Content $mainTf

# create projects
dotnet new webapi --name "Rfsmart.Phoenix.$apiName.Web" --use-controllers
dotnet new classlib --name "Rfsmart.Phoenix.$apiName" 
dotnet new nunit --name "Rfsmart.Phoenix.$apiName.Tests"

# add classlib ref to web project
dotnet add "Rfsmart.Phoenix.$apiName.Web/Rfsmart.Phoenix.$apiName.Web.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"

# add classlib ref to test project
dotnet add "Rfsmart.Phoenix.$apiName.Tests/Rfsmart.Phoenix.$apiName.Tests.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"

# create sln
dotnet new sln --name "Rfsmart.Phoenix.$apiName.Api"
dotnet sln add "Rfsmart.Phoenix.$apiName.Web"
dotnet sln add "Rfsmart.Phoenix.$apiName"
dotnet sln add "Rfsmart.Phoenix.$apiName.Tests"