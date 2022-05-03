#script to collect timestamp from buils and deployments
$personalToken = "joutda5axfaycwcipuugnfukjkdjzb6mw5cemrcqwo6b47ysfjra"
$minTime = "2022-4-01"
$maxTime = "2022-4-30"
$OutPath="deployments.csv"

$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
$header = @{authorization = "Basic $token"}


$urlProjects = "https://dev.azure.com/DEVOPScfn/_apis/projects?api-version=5.0"
$outputProjects = Invoke-RestMethod -Uri $urlProjects -Method Get -ContentType "application/json" -Headers $header


$outputProjects.value | ForEach-Object {
    $projectName = $($_.name)
    Write-host $projectName
    # Build Definitions API call
    $urlBuilds = "https://dev.azure.com/DEVOPScfn/$($_.name)/_apis/build/builds?minTime=$($minTime)&maxTime=$($maxTime)0&api-version=5.0"
    $outputBuilds = Invoke-RestMethod -Uri $urlBuilds -Method Get -ContentType "application/json" -Headers $header
    $outputBuilds.value | Sort-Object id -Descending|ForEach-Object {
        Add-Content -Path $OutPath -Value "$projectName, $($_.buildNumber), $($_.definition.name), $($_.result), $($_.startTime)"
    }
    # Release Definitions API call
    $urlReleases = "https://vsrm.dev.azure.com/DEVOPScfn/$($_.name)/_apis/release/deployments?minTime=$($minTime)&maxTime=$($maxTime)0api-version=6.0"
    $outputRelease = Invoke-RestMethod -Uri $urlReleases -Method Get -ContentType "application/json" -Headers $header
    $outputRelease.value | Sort-Object name|ForEach-Object {
        Add-Content -Path $OutPath -Value "$projectName, $($_.releaseDefinition.name), $($_.releaseEnvironment.name), $($_.deploymentStatus), $($_.completedOn)"
    }
}

