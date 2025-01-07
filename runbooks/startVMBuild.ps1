$MyPat = '<your-azure-devops-pat-with-build-read-and-execute-rights>'

$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("`:$MyPat"))

$Header = @{
"Authorization" = "Basic $B64Pat"
    }

$Parameters = @{
Method  = "POST"
Uri = "https://dev.azure.com/<your-organization>/<your-project-name>/_apis/build/builds?definitionId=<definition-id>&api-version=6.0
ContentType = "application/json"
}
Invoke-RestMethod @Parameters -Headers $Header