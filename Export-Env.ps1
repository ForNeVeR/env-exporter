param (
    [Parameter(Mandatory = $true)]
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'

$scopes = @(
    [EnvironmentVariableTarget]::Machine
    [EnvironmentVariableTarget]::User
)

function Get-EnvironmentVariables($scope) {
    $registryKey =
        if ($scope -eq [EnvironmentVariableTarget]::Machine) {
            [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
                'SYSTEM\CurrentControlSet\Control\Session Manager\Environment')
        } elseif ($scope -eq [EnvironmentVariableTarget]::User) {
            [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
        } else {
            throw "Unknown registry scope: $scope"
        }

    try {
        $variables = $registryKey.GetValueNames()
        [Collections.ArrayList] $scopeResult = @()
        $variables | Sort-Object | ForEach-Object {
            $name = $_
            $value = $registryKey.GetValue(
                $name,
                $null,
                [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            if ($value -ne $null) {
                $scopeResult.Add(@{ name = $name; value = $value }) | Out-Null
            }
        }

        $scopeResult
    } finally {
        $registryKey.Dispose()
    }
}

[Collections.ArrayList] $result = @()
$scopes | Sort-Object | ForEach-Object {
    $values = Get-EnvironmentVariables $_
    $result.Add(@{ scope = $_.ToString(); variables = $values }) | Out-Null
}

$result | ConvertTo-Json -Depth 3 | Out-File $OutPath -Encoding utf8
