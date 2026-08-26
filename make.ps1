# Simple PowerShell script for a Web Component Project

$PROJECT = "CL-web-components"
$GIT_GROUP = "caltechlibrary"
$RELEASE_DATE = Get-Date -Format "yyyy-MM-dd"
$RELEASE_HASH = git log --pretty=format:'%h' -n 1
$HTML_PAGES = Get-ChildItem -Recurse -Filter *.html | Where-Object { $_.Name -notmatch 'test?.html' } | ForEach-Object { $_.FullName }
$DOCS = Get-ChildItem -Filter *.md | ForEach-Object { $_.Name }
$PACKAGE = Get-ChildItem -Filter *.go | ForEach-Object { $_.Name }
$VERSION = (Get-Content codemeta.json | ConvertFrom-Json).version
$BRANCH = git branch | Select-String '\*' | ForEach-Object { $_.Line.Split(' ')[-1] }
$OS = $env:OS
$PREFIX = $HOME
$EXT = if ($OS -eq "Windows_NT") { ".exe" } else { "" }

function Build {
    deno task build
}

function Hash {
    git log --pretty=format:'%h' -n 1
}

function Generate-Readme {
    cmt codemeta.json README.md
}

function Generate-VersionJs {
    # cmt can only write to the repository root; src/version.js is the
    # file mod.js imports and the one that gets bundled.
    cmt codemeta.json version.js
    Move-Item -Force version.js src/version.js
}

function Generate-Citation {
    cmt codemeta.json CITATION.cff
}

function Generate-About {
    cmt codemeta.json about.md
}

function Status {
    git status
}

function Save {
    param([string]$msg = "Quick Save")
    git commit -am $msg
    git push origin $BRANCH
}

function Refresh {
    git fetch origin
    git pull origin $BRANCH
}

function Clean {
    Remove-Item -Force *.bak -ErrorAction SilentlyContinue
    if (Test-Path dist) { Remove-Item -Recurse -Force dist }
    if (Test-Path testout) { Remove-Item -Recurse -Force testout }
}

# Main execution
switch ($args[0]) {
    "build" { Build }
    "hash" { Hash }
    "README.md" { Generate-Readme }
    "version.js" { Generate-VersionJs }
    "CITATION.cff" { Generate-Citation }
    "about.md" { Generate-About }
    "status" { Status }
    "save" { Save $args[1] }
    "refresh" { Refresh }
    "clean" { Clean }
    default { Write-Host "No valid target specified." }
}
