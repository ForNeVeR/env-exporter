param (
    [Parameter(Mandatory = $true)]
    [string] $OutPath
)

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
        $scopeResult = @{}
        foreach ($name in $variables) {
            $value = $registryKey.GetValue(
                $name,
                $null,
                [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            if ($value -ne $null) {
                $scopeResult[$name] = $value
            }
        }

        $scopeResult
    } finally {
        $registryKey.Dispose()
    }
}

$result = @{}
$scopes | ForEach-Object {
    $result[$_.ToString()] = Get-EnvironmentVariables $_
}

$result | ConvertTo-Json | Out-File $OutPath -Encoding utf8
