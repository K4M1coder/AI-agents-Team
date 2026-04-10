Set-Location "e:\AI agents Team"

$managerPath = ".github/agents/agent-manager.agent.md"
$managerLines = Get-Content -Path $managerPath

$frontStart = -1
$frontEnd = -1
for ($i = 0; $i -lt $managerLines.Count; $i++) {
  if ($managerLines[$i].Trim() -eq "---") {
    if ($frontStart -lt 0) {
      $frontStart = $i
    } else {
      $frontEnd = $i
      break
    }
  }
}

if ($frontStart -lt 0 -or $frontEnd -lt 0) {
  throw "Unable to parse frontmatter in $managerPath"
}

$toolsLine = $null
for ($i = $frontStart; $i -le $frontEnd; $i++) {
  if ($managerLines[$i] -like "tools:*") {
    $toolsLine = $managerLines[$i]
    break
  }
}

if (-not $toolsLine) {
  throw "Unable to find tools line in $managerPath"
}
$updatedCount = 0

Get-ChildItem ".github/agents" -Filter "*.agent.md" | ForEach-Object {
  $path = $_.FullName
  $lines = Get-Content -Path $path
  $content = ($lines -join "`r`n")
  $newContent = $content

  $toolsIndex = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like "tools:*") {
      $toolsIndex = $i
      break
    }
  }

  if ($toolsIndex -ge 0) {
    $lines[$toolsIndex] = $toolsLine
    $newContent = ($lines -join "`r`n")
  } else {
    $descIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -like "description:*") {
        $descIndex = $i
        break
      }
    }

    if ($descIndex -ge 0) {
      $prefix = @()
      $suffix = @()
      if ($descIndex -ge 0) {
        $prefix = $lines[0..$descIndex]
      }
      if ($descIndex + 1 -le $lines.Count - 1) {
        $suffix = $lines[($descIndex + 1)..($lines.Count - 1)]
      }
      $lines = @($prefix + $toolsLine + $suffix)
      $newContent = ($lines -join "`r`n")
    } else {
      throw "No insertion anchor (tools/description) found in $path"
    }
  }

  if ($newContent -ne $content) {
    Set-Content -Path $path -Value $newContent -Encoding utf8
    Write-Output "UPDATED $($_.Name)"
    $updatedCount++
  }
}

Write-Output "DONE updated=$updatedCount"
