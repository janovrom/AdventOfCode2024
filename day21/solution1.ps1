. ".\data-loader.ps1"

$data = LoadDataPart2

# For any keyborad, the robot starts at A.
# The robot can move up, down, left, or right.
# The robot can't move to a key X.
# Keyboard for first robot
# 7 8 9
# 4 5 6
# 1 2 3
# X 0 A

# Keyboard for second and third robot
# X ^ A
# < V >

function FloodFill($x, $y, $data, $steps, $visited) {
    if ($x -lt 0 -or $x -ge $data.Length -or $y -lt 0 -or $y -ge $data[0].Length) {
        return
    }

    if ($data[$x][$y] -eq 'X') {
        return
    }

    if ($visited[$x][$y] -le $steps) {
        return
    }

    $visited[$x][$y] = $steps

    $steps += 1
    FloodFill ($x - 1) $y $data $steps $visited
    FloodFill ($x + 1) $y $data $steps $visited
    FloodFill $x ($y - 1) $data $steps $visited
    FloodFill $x ($y + 1) $data $steps $visited
}

function IndexOf($data, $value) {
    for ($i = 0; $i -lt $data.Length; $i++) {
        for ($j = 0; $j -lt $data[$i].Length; $j++) {
            if ($data[$i][$j] -eq $value) {
                return $i, $j
            }
        }
    }

    throw "Value $value not found"
}

function GetAllShortestPaths($x, $y, $data, $steps, $visited, $path, $pathSet) {
    if ($x -lt 0 -or $x -ge $data.Length -or $y -lt 0 -or $y -ge $data[0].Length) {
        return
    }

    if ($data[$x][$y] -eq 'X') {
        return
    }

    if ($visited[$x][$y] -ne $steps) {
        return
    }

    if ($visited[$x][$y] -eq 0) {
        # We reached the end but we calculated from end
        $path = ReverseMovement $path
        [void]$pathSet.Add($path)
        return
    }

    $steps -= 1

    GetAllShortestPaths ($x - 1) $y $data $steps $visited ($path + '^') $pathSet
    GetAllShortestPaths ($x + 1) $y $data $steps $visited ($path + 'v') $pathSet
    GetAllShortestPaths $x ($y - 1) $data $steps $visited ($path + '<') $pathSet
    GetAllShortestPaths $x ($y + 1) $data $steps $visited ($path + '>') $pathSet
}

function FloodFillMovementKeyboard() {
    $keyboard = @(
        @('X', '^', 'A'),
        @('<', 'v', '>')
    )

    $letters = @('A', 'v', '^', '<', '>')

    $lookup = @{}

    foreach ($l0 in $letters) {
        foreach ($l1 in $letters) {
            $x0, $y0 = IndexOf $keyboard $l0
            $x1, $y1 = IndexOf $keyboard $l1

            $visited = @(
                @(-1, 100, 100),
                @(100, 100, 100)
            )

            FloodFill $x0 $y0 $keyboard 0 $visited

            $steps = $visited[$x1][$y1]
            $pathSet = New-Object System.Collections.Generic.HashSet[string]
            GetAllShortestPaths $x1 $y1 $keyboard $steps $visited "" $pathSet
            if ($pathSet.Count -eq 0) {
                throw "No path found for $l0 $l1"
            }
            $lookup += @{"$l0$l1" = $pathSet}
        }
    }

    return $lookup
}

function FloodFillKeyboard() {
    $keyboard = @(
        @('7', '8', '9'),
        @('4', '5', '6'),
        @('1', '2', '3'),
        @('X', '0', 'A')
    )

    $letters = @('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A')

    $lookup = @{}
    foreach ($l0 in $letters) {
        foreach ($l1 in $letters) {
            if ($l0 -eq $l1) {
                continue
            }

            $x0, $y0 = IndexOf $keyboard $l0
            $x1, $y1 = IndexOf $keyboard $l1

            $visited = @(
                @(100, 100, 100),
                @(100, 100, 100),
                @(100, 100, 100),
                @(-1, 100, 100)
            )

            FloodFill $x0 $y0 $keyboard 0 $visited

            $steps = $visited[$x1][$y1]
            $pathSet = New-Object System.Collections.Generic.HashSet[string]
            GetAllShortestPaths $x1 $y1 $keyboard $steps $visited "" $pathSet
            $lookup += @{"$l0$l1" = $pathSet}
        }
    }

    return $lookup
}

function ReverseMovement($value) {
    $result = ""
    $value = $value -split '' | Where-Object { $_ -ne '' }
    for ($i = $value.Length - 1; $i -ge 0; $i--) {
        $c = $value[$i]
        if ($c -eq '^') {
            $result += 'v'
        }
        elseif ($c -eq 'v') {
            $result += '^'
        }
        elseif ($c -eq '<') {
            $result += '>'
        }
        elseif ($c -eq '>') {
            $result += '<'
        }
        else {
            $result += $c
        }
    }

    return $result
}

function ShortestMovement($code, $codeLookup, $movementLookup, $depth, $visited) {
    if ($depth -eq $global:data.searchDepth) {
        return $code.Length
    }

    $cacheKey = "$code,$depth"
    if ($visited.ContainsKey($cacheKey)) {
        return $visited[$cacheKey]
    }

    $current = 'A'
    $result = 0
    $code =  $code -split '' | Where-Object { $_ -ne '' }
    foreach ($c in $code) {
        $key = $current + $c
        if ($codeLookup.ContainsKey($key)) {
            $movement = 1000000000000000

            foreach ($path in $codeLookup[$key]) {
                $path += 'A'
                
                $shortestPath = ShortestMovement $path $movementLookup $movementLookup ($depth + 1) $visited $length
                if ($movement -gt $shortestPath) {
                    $movement = $shortestPath
                }
            }

            $result += $movement
        }
        else {
            throw "Invalid key $key"
        }

        $current = $c
    }

    $visited[$cacheKey] = $result

    return $result
}

function VisualizeMovement($movement) {
    $keyboard = @(
        @('X', '^', 'A'),
        @('<', 'v', '>')
    )

    $x = 0
    $y = 2

    $movement = $movement -split '' | Where-Object { $_ -ne '' }
    foreach ($c in $movement) {
        if ($c -eq '^') {
            $x--
        }
        elseif ($c -eq 'v') {
            $x++
        }
        elseif ($c -eq '<') {
            $y--
        }
        elseif ($c -eq '>') {
            $y++
        }
        if ($c -eq 'A') {
            $keyboard[$x][$y]
        }
    }
}

function VisualizeCode($movement) {
    $keyboard = @(
        @('7', '8', '9'),
        @('4', '5', '6'),
        @('1', '2', '3'),
        @('X', '0', 'A')
    )

    $x = 3
    $y = 2

    $movement = $movement -split '' | Where-Object { $_ -ne '' }
    foreach ($c in $movement) {
        if ($c -eq '^') {
            $x--
        }
        elseif ($c -eq 'v') {
            $x++
        }
        elseif ($c -eq '<') {
            $y--
        }
        elseif ($c -eq '>') {
            $y++
        }
        if ($c -eq 'A') {
            $keyboard[$x][$y]
        }
    }
}

$codeLookup = FloodFillKeyboard
$movementLookup = FloodFillMovementKeyboard

$sum = 0
$visited = New-Object 'System.Collections.Generic.Dictionary[string,long]'
foreach ($code in $data.codes) {
    $shortest = ShortestMovement $code $codeLookup $movementLookup 0 $visited

    # Write-Host $shortestPath
    Write-Host "Code: $code Length: $($shortest)"
    $sum += $shortest * [long]$code.Substring(0, 3)
}

Write-Host $sum
Set-Clipboard $sum