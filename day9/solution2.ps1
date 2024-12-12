$data = Get-Content .\data.txt
$data = $data.ToCharArray() | ForEach-Object { [int]"$_" }
$ids = 0..$data.Length
for ($i = 1; $i -lt $data.Length; $i+=1) {
    $ids[$i] = $ids[$i - 1] + $data[$i - 1]
}

$sum = 0
# Last is always a block. It won't make sense otherwise.
$last = $data.Length - 1

for ($i = $last; $i -gt 0; $i-=2) {
    # Take last and try to move it into empty space.
    for ($j = 1; $j -lt $i; $j+=2) {
        if ($data[$j] -ge $data[$i]) {
            # Fill the space, update the start index
            $data[$j] -= $data[$i]
            
            $id = $ids[$j]
            $blockId = [int]($i / 2)
            for ($k = 0; $k -lt $data[$i]; $k+=1) {
                $sum += $id * $blockId
                $id += 1
            }
            
            $ids[$j] += $data[$i]
            # Null the last so that in won't cause issues later.
            $data[$i] = 0
            break
        }
    }
}

for ($i = 0; $i -lt $data.Length; $i+=2) {
    $blockId = [int]($i / 2)
    $id = $ids[$i]
    for ($j = 0; $j -lt $data[$i]; $j+=1) {
        $sum += $id * $blockId
        $id += 1
    }
}

Write-Host $sum
Set-Clipboard $sum