# MEGA BATCH OLUŞTURUCU - 4'ten 19'a kadar tüm batch'leri oluştur

$batches = @(
    "mega_yemek_batch_4_ogle.dart",
    "mega_yemek_batch_5_ogle.dart",
    "mega_yemek_batch_6_ogle.dart",
    "mega_yemek_batch_7_ogle.dart",
    "mega_yemek_batch_8_aksam.dart",
    "mega_yemek_batch_9_aksam.dart",
    "mega_yemek_batch_10_aksam.dart",
    "mega_yemek_batch_11_aksam.dart",
    "mega_yemek_batch_12_ara_ogun_1.dart",
    "mega_yemek_batch_13_ara_ogun_1.dart",
    "mega_yemek_batch_14_ara_ogun_1.dart",
    "mega_yemek_batch_15_ara_ogun_2.dart",
    "mega_yemek_batch_16_ara_ogun_2.dart",
    "mega_yemek_batch_17_ara_ogun_2.dart",
    "mega_yemek_batch_18_ara_ogun_2.dart",
    "mega_yemek_batch_19_ara_ogun_2.dart"
)

$i = 4
foreach ($batch in $batches) {
    Write-Host "[$i/19] $batch ..." -ForegroundColor Cyan
    dart $batch
    $i++
}

Write-Host "`n=== TAMAMLANDI! ===" -ForegroundColor Green
Write-Host "Şimdi Migration'ı güncelle - SADECE MEGA YEMEKLER!" -ForegroundColor Yellow
