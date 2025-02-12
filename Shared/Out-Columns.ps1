﻿# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

<#
.SYNOPSIS
    Outputs a table of objects with certain values colorized
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Out-Columns {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]
        $Properties,

        [Parameter(Mandatory = $false, Position = 1)]
        [scriptblock[]]
        $ColorizerFunctions = @(),

        [Parameter(Mandatory = $false)]
        [int]
        $IndentSpaces = 0,

        [Parameter(Mandatory = $false)]
        [ref]
        $StringOutput
    )

    begin {
        $objects = New-Object System.Collections.ArrayList
        $padding = 2
        $stb = New-Object System.Text.StringBuilder
    }

    process {
        foreach ($thing in $InputObject) {
            [void]$objects.Add($thing)
        }
    }

    end {
        if ($objects.Count -gt 0) {
            $props = $null

            if ($null -ne $Properties) {
                $props = $Properties
            } else {
                $props = $objects[0].PSObject.Properties.Name
            }

            $colWidths = New-Object int[] $props.Count

            for ($i = 0; $i -lt $props.Count; $i++) {
                $colWidths[$i] = $props[$i].Length
            }

            foreach ($thing in $objects) {
                for ($i = 0; $i -lt $props.Count; $i++) {
                    $val = $thing."$($props[$i])"
                    if ($null -ne $val) {
                        $width = $thing."$($props[$i])".ToString().Length
                        if ($width -gt $colWidths[$i]) {
                            $colWidths[$i] = $width
                        }
                    }
                }
            }

            Write-Host
            [void]$stb.Append([System.Environment]::NewLine)

            Write-Host (" " * $IndentSpaces) -NoNewline
            [void]$stb.Append(" " * $IndentSpaces)

            for ($i = 0; $i -lt $props.Count; $i++) {
                Write-Host ("{0,$(-1 * ($colWidths[$i] + $padding))}" -f $props[$i]) -NoNewline
                [void]$stb.Append("{0,$(-1 * ($colWidths[$i] + $padding))}" -f $props[$i])
            }

            Write-Host
            [void]$stb.Append([System.Environment]::NewLine)

            Write-Host (" " * $IndentSpaces) -NoNewline
            [void]$stb.Append(" " * $IndentSpaces)

            for ($i = 0; $i -lt $props.Count; $i++) {
                Write-Host ("{0,$(-1 * ($colWidths[$i] + $padding))}" -f ("-" * $props[$i].Length)) -NoNewline
                [void]$stb.Append("{0,$(-1 * ($colWidths[$i] + $padding))}" -f ("-" * $props[$i].Length))
            }

            Write-Host
            [void]$stb.Append([System.Environment]::NewLine)

            $defaultFgColor = (Get-Host).ui.rawui.ForegroundColor

            foreach ($o in $objects) {
                Write-Host (" " * $IndentSpaces) -NoNewline
                [void]$stb.Append(" " * $IndentSpaces)
                for ($i = 0; $i -lt $props.Count; $i++) {
                    $val = $o."$($props[$i])"
                    $fgColor = $defaultFgColor
                    if ($i -lt $ColorizerFunctions.Length -and $null -ne $ColorizerFunctions[$i]) {
                        $result = $ColorizerFunctions[$i].Invoke($val)
                        if (-not [string]::IsNullOrEmpty($result)) {
                            $fgColor = $result
                        }
                    }
                    Write-Host ("{0,$(-1 * ($colWidths[$i] + $padding))}" -f $o."$($props[$i])") -NoNewline -ForegroundColor $fgColor
                    [void]$stb.Append("{0,$(-1 * ($colWidths[$i] + $padding))}" -f $o."$($props[$i])")
                }

                Write-Host
                [void]$stb.Append([System.Environment]::NewLine)
            }

            Write-Host
            [void]$stb.Append([System.Environment]::NewLine)

            if ($null -ne $StringOutput) {
                $StringOutput.Value = $stb.ToString()
            }
        }
    }
}
