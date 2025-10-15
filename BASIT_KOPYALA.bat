@echo off
echo ========================================
echo MALZEME BAZLI SISTEM DOSYALARI KOPYALANIYOR...
echo ========================================
echo.

REM Entity dosyalari (4 dosya)
echo [1/8] Entity dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\entities\*.dart" "lib\domain\entities\" /Y /I

REM Usecases (1 dosya)
echo [2/8] Usecase dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\usecases\*.dart" "lib\domain\usecases\" /Y /I

REM Rules (1 dosya)
echo [3/8] Rules dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\rules\*.dart" "lib\domain\rules\" /Y /I

REM Utils (1 dosya)
echo [4/8] Utils dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\utils\*.dart" "lib\domain\utils\" /Y /I

REM Data layer (1 dosya)
echo [5/8] Data layer dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\data\local\*.dart" "lib\data\local\" /Y /I

REM Application services (1 dosya)
echo [6/8] Application services kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\application\services\*.dart" "lib\application\services\" /Y /I

REM Assets data (2 dosya - JSON)
echo [7/8] Assets data dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\assets\data\*.json" "assets\data\" /Y /I
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\assets\manifest\*.json" "assets\manifest\" /Y /I

REM Test dosyalari (2 dosya)
echo [8/8] Test dosyalari kopyalaniyor...
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\test\test_*.dart" "test\" /Y /I

echo.
echo ========================================
echo TAMAMLANDI!
echo ========================================
echo.
echo Kopyalanan dosyalar:
echo - 4 entity dosyasi (besin_malzeme, chromosome, malzeme_miktar, ogun_sablonu)
echo - 1 usecase (malzeme_tabanli_genetik_algoritma)
echo - 1 rules dosyasi (validators)
echo - 1 utils dosyasi (meal_splitter)
echo - 1 data layer dosyasi (besin_malzeme_hive_service)
echo - 1 application service (ogun_optimizer_service)
echo - 2 JSON dosyasi (besin_malzemeleri_200, ogun_sablonlari)
echo - 1 manifest dosyasi (batch_manifest)
echo - 2 test dosyasi
echo.
pause
