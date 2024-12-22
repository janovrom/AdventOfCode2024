. ".\data-loader.ps1"

$data = LoadTestData

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

function CodeToMovement($codes) {
    # Get the movement pattern when starting at A
    # The robot can't move to X
    # Result is a sequence of movements that visually corresponds to the keyboard
    # I'll always move up first, then horizontally

    $lookup = @{
        "AA" = ''
        "A0" = '<'
        "A1" = '^<<'
        "A2" = '^<'
        "A3" = '^'
        "A4" = '^^<<'
        "A5" = '^^<'
        "A6" = '^^'
        "A7" = '^^^<<'
        "A8" = '^^^<'
        "A9" = '^^^'
        "01" = '^<'
        "02" = '^'
        "03" = '^>'
        "04" = '^^<'
        "05" = '^^'
        "06" = '^^>'
        "07" = '^^^<'
        "08" = '^^^'
        "09" = '^^^>'
        "12" = '>'
        "13" = '>>'
        "14" = '^'
        "15" = '>^'
        "16" = '^>>'
        "17" = '^^'
        "18" = '^^>'
        "19" = '^^>>'
        "23" = '>'
        "24" = "^<"
        "25" = '^'
        "26" = '^>'
        "27" = '^^<'
        "28" = '^^'
        "29" = '^^>'
        "34" = '^<<'
        "35" = '^<'
        "36" = '^'
        "37" = '^^<<'
        "38" = '^^<'
        "39" = '^^'
        "45" = '>'
        "46" = '>>'
        "47" = '^'
        "48" = '>^'
        "49" = '^>>'
        "56" = '>'
        "57" = '^<'
        "58" = '^'
        "59" = '^>'
        "67" = '^<<'
        "68" = '^<'
        "69" = '^'
        "78" = '>'
        "79" = '>>'
        "89" = '>'
    }

    $result = ""
    $current = 'A'
    $code = $code -split '' | Where-Object { $_ -ne '' }
    foreach ($c in $code) {
        $key = $current + $c
        # Lookup the key and the move to A

        if ($lookup.ContainsKey($key)) {
            $movement = $lookup[$key]
        }
        else {
            $key = $c + $current
            if (-not $lookup.ContainsKey($key)) {
                throw "Invalid key $key"
            }

            $movement = ReverseMovement $lookup[$key]
        }

        $result += $movement
        $result += 'A'

        $current = $c
    }

    return $result
}

function ReverseMovement($value) {
    $result = ""
    $value = $value -split '' | Where-Object { $_ -ne '' }
    for ($i = $value.Length - 1; $i -ge 0; $i--) {
        $c = $value[$i]
        if ($c -eq '^') {
            $result += 'V'
        }
        elseif ($c -eq 'V') {
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

function MovementToMovement($code) {
    # For this lookup I'll always go down first, then horizontally
    $lookup = @{
        "AA" = ''
        "A^" = '<'
        "A<" = 'V<<'
        "AV" = 'V<'
        "A>" = 'V'
        "^<" = 'V<'
        "^V" = 'V'
        "^>" = 'V>'
        "<V" = '>'
        "<>" = '>>'
        "V>" = '>'
        "<<" = ''
        ">>" = ''
        "VV" = ''
        "^^" = ''
    }

    $current = 'A'
    $result = ""
    $code =  $code -split '' | Where-Object { $_ -ne '' }
    foreach ($c in $code) {
        $key = $current + $c
        # Lookup the key and the move to A

        if ($lookup.ContainsKey($key)) {
            $movement = $lookup[$key]
        }
        else {
            $key = $c + $current
            if (-not $lookup.ContainsKey($key)) {
                throw "Invalid key $key"
            }

            $movement = ReverseMovement $lookup[$key]
        }

        $result += $movement
        $result += 'A'

        $current = $c
    }

    return $result
}

function VisualizeMovement($movement) {
    $keyboard = @(
        @('X', '^', 'A'),
        @('<', 'V', '>')
    )

    $x = 0
    $y = 2

    $movement = $movement -split '' | Where-Object { $_ -ne '' }
    foreach ($c in $movement) {
        if ($c -eq '^') {
            $x--
        }
        elseif ($c -eq 'V') {
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
        elseif ($c -eq 'V') {
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

$sum = 0
foreach ($code in $data.codes) {
    $first = CodeToMovement $code
    Write-Host (VisualizeCode $first -join '')
    $second = MovementToMovement $first
    Write-Host (VisualizeMovement $second -join '')
    $third =  MovementToMovement $second
    Write-Host (VisualizeMovement $third -join '')
    Write-Host "$code : $first : $second : $third"
    Write-Host "Length: $($third.Length) * $([int]$code.Substring(0, 3))"
    $sum += $third.Length * [int]$code.Substring(0, 3)
}

Write-Host $sum
Set-Clipboard $sum