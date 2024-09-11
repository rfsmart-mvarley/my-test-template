$folderName = Split-Path -Path (Get-Location) -Leaf
if(-not ($folderName -match "phoenix-[\w]*-api")) {
    Write-Host "ERR: Repo name should conform to phoenix-{apiName}-api syntax" -BackgroundColor Red -ForegroundColor Black
    exit 1
}

$TextInfo = (Get-Culture).TextInfo
$apiname = $TextInfo.ToTitleCase(($folderName -Split '-')[1])

# create projects
Write-Host "Creating SLN files..." -BackgroundColor Yellow -ForegroundColor Black

dotnet new webapi --name "Rfsmart.Phoenix.$apiName.Web" --use-controllers
dotnet new classlib --name "Rfsmart.Phoenix.$apiName" 
dotnet new nunit --name "Rfsmart.Phoenix.$apiName.UnitTests"
dotnet new nunit --name "Rfsmart.Phoenix.$apiName.IntegrationTests"

# add classlib ref to web project
dotnet add "Rfsmart.Phoenix.$apiName.Web/Rfsmart.Phoenix.$apiName.Web.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"

# add classlib ref to test projects
dotnet add "Rfsmart.Phoenix.$apiName.UnitTests/Rfsmart.Phoenix.$apiName.UnitTests.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"
dotnet add "Rfsmart.Phoenix.$apiName.IntegrationTests/Rfsmart.Phoenix.$apiName.IntegrationTests.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"

# create sln
dotnet new sln --name "Rfsmart.Phoenix.$apiName.Api"
dotnet sln add "Rfsmart.Phoenix.$apiName.Web"
dotnet sln add "Rfsmart.Phoenix.$apiName"
dotnet sln add "Rfsmart.Phoenix.$apiName.UnitTests"
dotnet sln add "Rfsmart.Phoenix.$apiName.IntegrationTests"

Move-Item -Path "./Tests-Dockerfile" -Destination "./Rfsmart.Phoenix.$apiName.IntegrationTests/Dockerfile"
Move-Item -Path "./Web-Dockerfile" -Destination "./Rfsmart.Phoenix.$apiName.Web/Dockerfile"

# install required tools
dotnet tool restore

Write-Host "SLN files created!" -BackgroundColor Green -ForegroundColor Black

Write-Host "Updating deploy/iac files..." -BackgroundColor Yellow -ForegroundColor Black

$templateTitleCase = "TEMPLATE"
$templateLowerCase = "TEMP-LATE"

ForEach ($File in (Get-ChildItem -Recurse -File -Exclude *.ps1)) {
    if ($File.Directory -match 'obj' -or $File.Name -eq "pull_request_template.md") {
        continue
    }

    $content = (Get-Content $File)

    if ($content -match $templateLowerCase -or $content -match $templateTitleCase) {
        $n = $File.Name
        Write-Host "Updating $n..."

        $content -Replace $templateLowerCase,$apiName.ToLower() `
            -Replace $templateTitleCase,$apiName |
            Set-Content $File
    }
}

# rename iac directory
Rename-Item -Path "./iac/deploys/$templateLowerCase-web" -NewName ($apiName.ToLower() + "-web")

# update listener_rule_priority - needs to be different for each API
Write-Host "Listener rule priority must be different for each API. Enter new priority:" -BackgroundColor red -ForegroundColor Black
$lrp = Read-Host
$mainTf = "./iac/deploys/$apiName-web/main.tf"
(Get-Content $mainTf) -Replace "listener_rule_priority = 4","listener_rule_priority = $lrp" |
    Set-Content $mainTf

Write-Host "Deploy/iac files updated!" -BackgroundColor Green -ForegroundColor Black