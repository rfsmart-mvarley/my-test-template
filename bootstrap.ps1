$folderName = Split-Path -Path (Get-Location) -Leaf
$folderName = "phoenix-something-api"
if(-not ($folderName -match "phoenix-[\w]*-api")) {
    Write-Host "ERR: Repo name should conform to phoenix-{apiName}-api syntax" -BackgroundColor Red
    exit 1
}

$TextInfo = (Get-Culture).TextInfo
$apiname = $TextInfo.ToTitleCase(($folderName -Split '-')[1])
# $apiName = "TEMPLATE"
$template = "TEMPLATE"

ForEach ($File in (Get-ChildItem -Recurse -File -Exclude *.ps1)) {
    if ($File.Directory -match 'obj') {
        continue
    }

    if ($File.Name -eq "docker-compose.yml") {
        (Get-Content $File) -Replace $template,$apiName.ToLower() |
            Set-Content $File
    }
    else {
        (Get-Content $File) -Replace $template,$apiName |
            Set-Content $File
    }

    if ($File.Name -match $template) {
        Write-Host "Renaming file: " + $File.Name
        Rename-Item -Path $File.FullName -NewName ($File.Name -replace $template,$apiName)
    }
}

ForEach ($File in (Get-ChildItem -Directory)) {
    if ($File.Name -match $template) {
        Write-Host "Renaming directory: " + $File.Name
        Rename-Item -Path $File.FullName -NewName ($File.Name -replace $template,$apiName)
    }
}

# update listener_rule_priority - needs to be different for each API

# # create projects
# dotnet new webapi --name "Rfsmart.Phoenix.$apiName.Web" --use-controllers
# dotnet new classlib --name "Rfsmart.Phoenix.$apiName" 
# dotnet new nunit --name "Rfsmart.Phoenix.$apiName.Tests"

# # add classlib ref to web project
# dotnet add "Rfsmart.Phoenix.$apiName.Web/Rfsmart.Phoenix.$apiName.Web.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"

# # add classlib ref to test project
# dotnet add "Rfsmart.Phoenix.$apiName.Tests/Rfsmart.Phoenix.$apiName.Tests.csproj" reference "Rfsmart.Phoenix.$apiName/Rfsmart.Phoenix.$apiName.csproj"

# # create sln
# dotnet new sln --name "Rfsmart.Phoenix.$apiName.Api"
# dotnet sln add "Rfsmart.Phoenix.$apiName.Web"
# dotnet sln add "Rfsmart.Phoenix.$apiName"
# dotnet sln add "Rfsmart.Phoenix.$apiName.Tests"