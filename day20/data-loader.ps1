function LoadTestData() {
    $data = Get-Content .\test-data.txt

    return ParseData $data
}

function LoadData() {
    $data = Get-Content .\data.txt

    return ParseData $data
}

function ParseData($data) {
    $maze = @()
    $max = 999999999

    $empty = $max
    $wall = -1

    $result = @{}

    for ($i = 0; $i -lt $data.Length; $i++) {
        $mazeRow = @()
        for ($j = 0; $j -lt $data[$i].Length; $j++) {
            if ($data[$i][$j] -eq 'S') {
                $start = [PSCustomObject]@{
                    'x' = $i
                    'y' = $j
                }
                $result += @{
                    'start' = $start
                }
                $mazeRow += $empty
            } elseif ($data[$i][$j] -eq 'E') {
                $end = [PSCustomObject]@{
                    'x' = $i
                    'y' = $j
                }
                $result += @{
                    'end' = $end
                }
                $mazeRow += $empty
            } elseif ($data[$i][$j] -eq '#') {
                $mazeRow += $wall
            } else {
                $mazeRow += $empty
            }
        }
        $maze += ,$mazeRow
    }

    $result += @{
        'maze' = $maze
    }

    return [pscustomobject]$result
}