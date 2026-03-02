$response = Invoke-WebRequest -Uri "http://localhost:3344/azure-wiki/" -UseBasicParsing
$html = $response.Content

Write-Host "=== VERIFICATION RESULTS ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: Progress Bar
if ($html -match 'aw-progress-bar') {
    Write-Host "[] Progress bar div found in HTML" -ForegroundColor Green
} else {
    Write-Host "[] Progress bar div MISSING" -ForegroundColor Red
}

# Check 2: Logo href
if ($html -match 'navbar__brand.*?href="(/azure-wiki/)"') {
    Write-Host "[] Logo href='/azure-wiki/' found" -ForegroundColor Green
} else {
    Write-Host "[] Logo href incorrect" -ForegroundColor Red
}

# Check 3: Root component with scroll handler
if ($html -match 'window\.scrollTo') {
    Write-Host "[] Scroll-to-top JavaScript found" -ForegroundColor Green
} else {
    Write-Host "[] Scroll-to-top JavaScript MISSING" -ForegroundColor Red
}

Write-Host ""
Write-Host "Opening browser for manual verification..." -ForegroundColor Yellow
Start-Process "http://localhost:3344/azure-wiki/"
