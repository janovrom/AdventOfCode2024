$data = Get-Content .\data.txt
$data = $data.ToCharArray() | ForEach-Object { [int]"$_" }

$sum = 0
$blockId = 0
$spaceIndex = 1
# Last is always a block. It won't make sense otherwise.
$last = $data.Length - 1

$id = 0
for ($i = 0; $i -lt $data.Length; $i+=1) {
    if ($i % 2 -eq 0) {
        # It's a block. Add to sum.
        $blockId = [int]($i / 2)

        for ($j = 0; $j -lt $data[$i]; $j+=1) {
            $sum += $id * $blockId
            $id += 1
        }
    } else {
        # It's an empty space. Move the last blocks here.
        $freeSpace = $data[$spaceIndex]

        if ($freeSpace -eq 0) {
            $spaceIndex += 2
            $freeSpace = $data[$spaceIndex]
        }

        $data[$spaceIndex] = 0
        while ($freeSpace -ne 0) {
            if ($last -le $spaceIndex) {
                break
            }

            $freeSpace-=1
            # Take last block and add to sum.
            
            $blockId = [int]($last / 2)
            $data[$last] -= 1
            $sum += $id * $blockId

            $id += 1
            
            if ($data[$last] -eq 0) {
                $last -= 2
            }
        }
    }
}

#0099811188827773336446555566
#009981118882777333644655556665
Write-Host
Write-Host $sum
Set-Clipboard $sum