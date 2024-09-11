$folderName = Split-Path -Path (Get-Location) -Leaf
if(-not ($folderName -match "phoenix-[\w]*-api")) {
    Write-Host "ERR: Repo name should conform to phoenix-{apiName}-api syntax" -BackgroundColor Red
    exit 1
}

$TextInfo = (Get-Culture).TextInfo
$apiname = $TextInfo.ToTitleCase(($folderName -Split '-')[1])
$templateTitleCase = "TEMPLATE"
$templateLowerCase = "L-TEMPLATE"

ForEach ($File in (Get-ChildItem -Recurse -File -Exclude *.ps1)) {
    if ($File.Directory -match 'obj') {
        continue
    }

    $content = (Get-Content $File)

    if ($content -match $templateLowerCase || $content -match $templateTitleCase) {
        $content -Replace $templateLowerCase,$apiName.ToLower() `
            -Replace $templateTitleCase,$apiName |
            Set-Content $File
    }

    if ($File.Name -match $templateTitleCase) {
        Write-Host "Renaming file: " + $File.Name
        Rename-Item -Path $File.FullName -NewName ($File.Name -replace $template,$apiName)
    }

    if ($File.Name -match $templateLowerCase) {
        Write-Host "Renaming file: " + $File.Name
        Rename-Item -Path $File.FullName -NewName ($File.Name -replace $template,$apiName.ToLower())
    }
}

ForEach ($Dir in (Get-ChildItem -Directory -Recurse)) {
    if ($Dir.Name -match $templateTitleCase) {
        Write-Host "Renaming directory: " + $Dir.Name
        Rename-Item -Path $Dir.FullName -NewName ($Dir.Name -replace $template,$apiName)
    }
    
    if ($Dir.Name -match $templateLowerCase) {
        Write-Host "Renaming directory: " + $Dir.Name
        Rename-Item -Path $Dir.FullName -NewName ($Dir.Name -replace $template,$apiName.ToLower())
    }
}

# update listener_rule_priority - needs to be different for each API
Write-Host "Listener rule priority must be different for each API"
Write-Host "What should the new listener rule priority be?"
$lrp = Read-Host
$mainTf = "./iac/deploys/$apiName-web/main.tf"
(Get-Content $mainTf) -Replace "listener_rule_priority = 4","listener_rule_priority = $lrp" |
    Set-Content $mainTf