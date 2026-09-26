# Rigenera le anteprime committate in docs/preview.
#
# I widget test di cattura scrivono di default in build/preview, cartella
# ignorata dal versionamento, cosi' un normale `flutter test` lascia l'albero
# pulito. Questo script e' la richiesta esplicita: valorizza AGGIORNA_ANTEPRIME
# e riesegue le sole catture, che sovrascrivono i PNG di docs/preview.
#
# Uso, dalla radice del repository:
#   .\tool\aggiorna_anteprime.ps1
# Poi si rivedono le differenze con `git diff --stat docs/preview` e si committa
# quello che si vuole tenere.

$ErrorActionPreference = 'Stop'

Write-Host 'Rigenero le anteprime in docs/preview...'
$env:AGGIORNA_ANTEPRIME = '1'
try {
    flutter test test/screenshot_capture_test.dart
    if ($LASTEXITCODE -ne 0) {
        throw "Le catture sono fallite, codice $LASTEXITCODE. Le anteprime non sono state aggiornate."
    }
}
finally {
    Remove-Item Env:\AGGIORNA_ANTEPRIME -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'Fatto. Anteprime aggiornate in docs/preview.'
Write-Host 'Rivedi le differenze con: git diff --stat docs/preview'
