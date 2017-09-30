env-exporter
============

PowerShell script to export computer's environment variables to a file. Useful
for bookkeeping.

Usage:

```console
$ ./Export-Env.ps1 E:/Temp/env.json
```

It will save the file of the following format:

```json
[
    {
        "scope": "User",
        "variables": [
            { "name": "var1", "value": "value1" }
        ]
    },
    {
        "scope": "Machine",
        "variables": [
            { "name": "var1", "value": "value1" }
        ]
    }
}
```
