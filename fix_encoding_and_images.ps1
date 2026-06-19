# Read original file with CORRECT UTF-8 encoding
$originalPath = "TranDucHuy_Portfolio_v2.html"
$content = [System.IO.File]::ReadAllText((Resolve-Path $originalPath).Path, [System.Text.Encoding]::UTF8)

# --- 1. Extract CSS ---
if ($content -match "(?s)<style>(.*?)</style>") {
    $css = $Matches[1].Trim()
    $css = $css -replace 'margin-top\.5rem', 'margin-top:.5rem'
    [System.IO.File]::WriteAllText("style.css", $css, [System.Text.Encoding]::UTF8)
    Write-Output "CSS extracted with UTF-8 encoding"
}

# --- 2. Extract JS ---
if ($content -match "(?s)<script>(.*?)</script>") {
    $js = $Matches[1].Trim()
    [System.IO.File]::WriteAllText("main.js", $js, [System.Text.Encoding]::UTF8)
    Write-Output "JS extracted with UTF-8 encoding"
}

# --- 3. Extract base64 images to files ---
$null = New-Item -ItemType Directory -Path "images" -Force
$imgPaths = @(
    "images/campaign-visual.jpg",
    "images/kaiserin-project.jpg",
    "images/kaiserin-creative-1.jpg",
    "images/kaiserin-creative-2.jpg",
    "images/kaiserin-creative-3.jpg",
    "images/kaiserin-creative-4.jpg",
    "images/kaiserin-creative-5.jpg",
    "images/kaiserin-analytics-1.jpg",
    "images/kaiserin-analytics-2.jpg",
    "images/kaiserin-analytics-3.jpg",
    "images/kaiserin-analytics-4.jpg",
    "images/kaiserin-analytics-5.jpg",
    "images/kaiserin-analytics-6.jpg",
    "images/kaiserin-result-1.jpg",
    "images/kaiserin-result-2.jpg",
    "images/kaiserin-result-3.jpg",
    "images/kaiserin-result-4.jpg",
    "images/kaiserin-result-5.jpg",
    "images/kaiserin-result-6.jpg",
    "images/kaiserin-result-7.jpg",
    "images/kaiserin-result-8.jpg",
    "images/kaiserin-result-9.jpg",
    "images/kaiserin-photo-1.jpg",
    "images/kaiserin-photo-2.jpg",
    "images/kaiserin-photo-3.jpg",
    "images/kaiserin-photo-4.jpg",
    "images/kaiserin-photo-5.jpg",
    "images/kaiserin-photo-6.jpg",
    "images/kaiserin-photo-7.jpg",
    "images/viettel-dashboard.jpg",
    "images/viettel-social-1.jpg",
    "images/viettel-social-2.jpg",
    "images/viettel-social-3.jpg",
    "images/viettel-social-4.jpg",
    "images/viettel-local-1.jpg",
    "images/viettel-local-2.jpg",
    "images/viettel-local-3.jpg",
    "images/viettel-event-1.jpg",
    "images/viettel-event-2.jpg",
    "images/viettel-product-1.jpg",
    "images/viettel-product-2.jpg",
    "images/viettel-product-3.jpg",
    "images/viettel-tv360-1.jpg",
    "images/viettel-tv360-2.jpg",
    "images/viettel-entertainment-1.jpg",
    "images/viettel-entertainment-2.jpg",
    "images/viettel-news-1.jpg",
    "images/viettel-news-2.jpg",
    "images/cert-react.jpg",
    "images/cert-mobile-intro.jpg",
    "images/cert-uiux.jpg",
    "images/cert-flutter.jpg",
    "images/cert-software-intro.jpg",
    "images/cert-git.jpg",
    "images/cert-ios.jpg",
    "images/cert-android.jpg",
    "images/cert-mobile-publishing.jpg"
)

# Find all base64 image data and extract to files
$base64Regex = [regex]'src="data:image/[^;]+;base64,([^"]+)"'
$base64Matches = $base64Regex.Matches($content)
Write-Output "Found $($base64Matches.Count) base64 images to extract"

for ($idx = 0; $idx -lt $base64Matches.Count -and $idx -lt $imgPaths.Count; $idx++) {
    $b64data = $base64Matches[$idx].Groups[1].Value
    $bytes = [System.Convert]::FromBase64String($b64data)
    [System.IO.File]::WriteAllBytes($imgPaths[$idx], $bytes)
    Write-Output "Saved: $($imgPaths[$idx]) ($($bytes.Length) bytes)"
}

# --- 4. Clean HTML ---
$html = $content

# Replace <style>...</style> with <link>
$html = [regex]::Replace($html, '(?s)<style>.*?</style>', '<link rel="stylesheet" href="style.css">')

# Replace <script>...</script> with <script src>
$html = [regex]::Replace($html, '(?s)<script>.*?</script>', '<script src="main.js"></script>')

# Replace base64 images with file paths
$imgIdx = 0
$evaluator = [System.Text.RegularExpressions.MatchEvaluator] {
    param($m)
    if ($script:imgIdx -lt $script:imgPaths.Count) {
        $path = $script:imgPaths[$script:imgIdx]
        $script:imgIdx++
        return "src=""$path"""
    }
    return $m.Value
}
$script:imgIdx = 0
$script:imgPaths = $imgPaths
$html = [regex]::Replace($html, 'src="data:image/[^"]+"', $evaluator)

# --- 5. Fix invalid onclick event handlers with I("...") placeholders ---
$html = [regex]::Replace($html, 'onclick="openLB\(\s*\+\s*I\("[^"]+"\)\s*\+\s*\)""', 'onclick="openLB(this.querySelector(''img'').src)"')


# Write clean HTML with proper UTF-8 encoding (no BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Output ""
Write-Output "=== DONE ==="
Write-Output "index.html: $((Get-Item index.html).Length) bytes"
Write-Output "style.css: $((Get-Item style.css).Length) bytes"  
Write-Output "main.js: $((Get-Item main.js).Length) bytes"
Write-Output "images/ folder: $((Get-ChildItem images).Count) files"
