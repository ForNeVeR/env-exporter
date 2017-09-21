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
{
    "User": {
        "var1": "value1"
    },
    "Machine": {
        "var2": "value2"
    }
}
```
