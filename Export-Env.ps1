param (
    [Parameter(Mandatory = $true)]
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'

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
        $registryKey.GetValueNames() | Sort-Object | ForEach-Object {
            $name = $_
            $value = $registryKey.GetValue(
                $name,
                $null,
                [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            @{ name = $name; value = $value }
        }
    } finally {
        $registryKey.Dispose()
    }
}

$scopes = @(
    [EnvironmentVariableTarget]::Machine
    [EnvironmentVariableTarget]::User
)

$scopes | Sort-Object | ForEach-Object {
    $values = Get-EnvironmentVariables $_
    @{ scope = $_.ToString(); variables = $values }
} | ConvertTo-Json -Depth 3 | Out-File $OutPath -Encoding utf8
