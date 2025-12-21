param(
  [int]$MaxReleases = 30,
  [switch]$IncludePrerelease,
  [string]$Image = "clash-verge-rev",
  [string]$Platforms = "linux/amd64",
  [switch]$Push
)

$ErrorActionPreference = "Stop"

function Get-GitHubReleaseTagsFromHtml {
  param(
    [string]$Owner,
    [string]$Repo,
    [int]$MaxItems
  )

  $headers = @{
    "User-Agent" = "docker-clash-verge-rev-build-script"
    "Accept"     = "text/html"
  }

  $uri = "https://github.com/$Owner/$Repo/releases"

  $iwrArgs = @{
    Uri     = $uri
    Headers = $headers
    Method  = "GET"
  }
  if ($PSVersionTable.PSVersion.Major -lt 6) {
    $iwrArgs["UseBasicParsing"] = $true
  }

  $resp = Invoke-WebRequest @iwrArgs
  $html = $resp.Content

  $pattern = '/' + [regex]::Escape($Owner) + '/' + [regex]::Escape($Repo) + '/releases/tag/([0-9A-Za-z._-]+)'
  $matches = [regex]::Matches($html, $pattern)

  $seen = New-Object 'System.Collections.Generic.HashSet[string]'
  $tags = New-Object 'System.Collections.Generic.List[string]'

  foreach ($m in $matches) {
    $t = [uri]::UnescapeDataString($m.Groups[1].Value)
    if ([string]::IsNullOrWhiteSpace($t)) {
      continue
    }

    if ($seen.Add($t)) {
      if ($IncludePrerelease -or ($t -notmatch '-')) {
        $tags.Add($t) | Out-Null
      }
    }
  }

  return @($tags | Select-Object -First $MaxItems)
}

function Get-GitHubReleaseTagsFromAtom {
  param(
    [string]$Owner,
    [string]$Repo,
    [int]$MaxItems
  )

  $headers = @{
    "User-Agent" = "docker-clash-verge-rev-build-script"
    "Accept"     = "application/atom+xml"
  }

  $uri = "https://github.com/$Owner/$Repo/releases.atom"

  $iwrArgs = @{
    Uri     = $uri
    Headers = $headers
    Method  = "GET"
  }
  if ($PSVersionTable.PSVersion.Major -lt 6) {
    $iwrArgs["UseBasicParsing"] = $true
  }

  $resp = Invoke-WebRequest @iwrArgs
  [xml]$doc = $resp.Content

  $ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
  $ns.AddNamespace("a", "http://www.w3.org/2005/Atom")

  $nodes = $doc.SelectNodes("//a:feed/a:entry/a:title", $ns)
  $tags = foreach ($n in $nodes) {
    $t = $n.InnerText
    if (-not [string]::IsNullOrWhiteSpace($t)) {
      $t.Trim()
    }
  }

  return @($tags | Select-Object -First $MaxItems)
}

function Select-Version {
  param(
    [object[]]$Releases
  )

  $tags = @(
    $Releases |
      Where-Object { -not $_.draft } |
      Where-Object { $IncludePrerelease -or (-not $_.prerelease) } |
      ForEach-Object { $_.tag_name } |
      Where-Object { $_ }
  )

  if ($tags.Count -eq 0) {
    throw "No release tags found (maybe filtered out by draft/prerelease)."
  }

  Write-Host "Available versions:"
  for ($i = 0; $i -lt $tags.Count; $i++) {
    $n = $i + 1
    Write-Host ("{0,2}) {1}" -f $n, $tags[$i])
  }

  $raw = Read-Host "Select a version number (1-$($tags.Count), press Enter for 1)"
  if ([string]::IsNullOrWhiteSpace($raw)) {
    return $tags[0]
  }

  $idx = 0
  if (-not [int]::TryParse($raw, [ref]$idx)) {
    throw "Input is not an integer: $raw"
  }

  if ($idx -lt 1 -or $idx -gt $tags.Count) {
    throw "Input out of range: $idx"
  }

  return $tags[$idx - 1]
}

$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
  throw "docker command not found. Please install Docker Desktop and ensure 'docker' works in this terminal."
}

$platformList = @(
  ($Platforms -split "\s*,\s*") |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)

if (-not $Push -and $platformList.Count -gt 1) {
  throw "Multiple platforms specified ($Platforms) but -Push not set. Multi-platform buildx cannot --load locally; use -Push or build a single platform (e.g. -Platforms linux/amd64)."
}

Write-Host "Fetching releases from GitHub..."

$tags = Get-GitHubReleaseTagsFromHtml -Owner "clash-verge-rev" -Repo "clash-verge-rev" -MaxItems $MaxReleases

if ($tags.Count -eq 0) {
  Write-Host "No tags found on HTML page. Falling back to releases.atom..."
  $tags = Get-GitHubReleaseTagsFromAtom -Owner "clash-verge-rev" -Repo "clash-verge-rev" -MaxItems $MaxReleases
}

$tag = Select-Version -Releases (
  $tags | ForEach-Object {
    [pscustomobject]@{ tag_name = $_; draft = $false; prerelease = ($_ -match '-') }
  }
)

$version = $tag
if ($version.StartsWith("v")) {
  $version = $version.Substring(1)
}

$imageTag = "$Image`:$version"

$args = @(
  "buildx", "build",
  "--file", "Dockerfile",
  "--build-arg", "VERSION=$version",
  "--platform", ($platformList -join ","),
  "--tag", $imageTag,
  "."
)

if ($Push) {
  $args += "--push"
} else {
  $args += "--load"
}

Write-Host "About to execute: docker $($args -join ' ')"
& docker @args

if ($LASTEXITCODE -ne 0) {
  throw "docker buildx build failed (exit code: $LASTEXITCODE)."
}

Write-Host "Build completed: $imageTag"
