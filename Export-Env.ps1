param (
    [Parameter(Mandatory = $true)]
    [string] $OutPath
)

[System.EnvironmentVariableTarget[]] $scopes = @(
    'Machine'
    'User'
)

$result = @{}
$scopes | ForEach-Object {
    $result[$_.ToString()] = [Environment]::GetEnvironmentVariables($_)
}

$result | ConvertTo-Json | Out-File $OutPath -Encoding utf8
