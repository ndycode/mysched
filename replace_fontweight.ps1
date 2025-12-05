$files = Get-ChildItem -Path "c:\projects\mysched\lib" -Filter "*.dart" -Recurse | Where-Object { $_.Name -ne "tokens.dart" }
$count = 0
foreach($f in $files) {
    $c = Get-Content $f.FullName -Raw
    if ($c -match "FontWeight\.w\d+") {
        $c = $c -replace 'FontWeight\.w800', 'AppTokens.fontWeight.extraBold'
        $c = $c -replace 'FontWeight\.w700', 'AppTokens.fontWeight.bold'
        $c = $c -replace 'FontWeight\.w600', 'AppTokens.fontWeight.semiBold'
        $c = $c -replace 'FontWeight\.w500', 'AppTokens.fontWeight.medium'
        $c = $c -replace 'FontWeight\.w400', 'AppTokens.fontWeight.regular'
        Set-Content $f.FullName -Value $c -Force -NoNewline
        $count++
    }
}
Write-Host "Updated $count files"
