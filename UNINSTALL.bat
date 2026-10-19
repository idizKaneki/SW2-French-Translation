@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title Samurai Warriors 2 - French translation : uninstall

set "MOD=%~dp0"
set "MOD=%MOD:~0,-1%"
for %%i in ("%MOD%\..") do set "JEU=%%~fi"
if not exist "%JEU%\sw2.exe" for %%i in ("%MOD%\..\..") do if exist "%%~fi\sw2.exe" set "JEU=%%~fi"
set "SAUV=%MOD%\backup"
set "ECHECS=0"

echo.
echo  ============================================================
echo    Samurai Warriors 2 (PC) - French translation : uninstall
echo    Traduction française : désinstallation
echo  ============================================================
echo.
echo  Japanese Voices or Controller Mod installed? Run their UNINSTALL.bat first.
echo  VO japonaise ou mod manette installés ? Lancez d'abord leur UNINSTALL.bat.
echo.

if not exist "%JEU%\sw2.exe" (
  echo  [ERROR / ERREUR] sw2.exe not found / introuvable : !JEU!
  goto :fin
)
if not exist "%SAUV%" (
  call :police
  echo  No backup found: the translation does not seem to be installed.
  echo  Aucune sauvegarde trouvée : la traduction ne semble pas installée.
  goto :fin
)
(echo test> "%JEU%\_sw2fr_test.tmp") 2>nul || (
  echo  [ERROR / ERREUR] Cannot write to the game folder: right-click UNINSTALL.bat,
  echo  "Run as administrator". / Impossible d'écrire dans le dossier du jeu : clic
  echo  droit sur UNINSTALL.bat, "Exécuter en tant qu'administrateur".
  goto :fin
)
del "%JEU%\_sw2fr_test.tmp" >nul 2>&1
call :police

echo  Putting the original English files back / Remise en place des fichiers anglais...
for /r "%SAUV%" %%f in (*) do (
  set "F=%%f"
  set "REL=!F:%SAUV%\=!"
  if /i not "!REL!"=="installed_version.txt" call :restaurer "!REL!"
)
echo.
if %ECHECS% gtr 0 (
  echo  [WARNING / ATTENTION] %ECHECS% file^(s^) could not be restored ^(game running?^).
  echo  %ECHECS% fichier^(s^) n'ont pas pu être restaurés ^(jeu ouvert ?^).
  echo  The backup is kept / La sauvegarde est conservée : !SAUV!
  goto :fin
)
rmdir /s /q "%SAUV%" >nul 2>&1
echo  Uninstall complete: the game is back in English.
echo  Désinstallation terminée : le jeu est revenu en anglais.
goto :fin

:police
rem accent spacing plugin; dinput8.dll only if this mod added it and no other .asi remains
if exist "%JEU%\SW2FrenchFont.asi" del "%JEU%\SW2FrenchFont.asi" >nul 2>&1
if exist "%JEU%\SW2FrenchFont.log" del "%JEU%\SW2FrenchFont.log" >nul 2>&1
if exist "%MOD%\dinput8_added.txt" (
  dir /b "%JEU%\*.asi" >nul 2>&1 || del "%JEU%\dinput8.dll" >nul 2>&1
  del "%MOD%\dinput8_added.txt" >nul 2>&1
)
exit /b

:restaurer
move /y "%SAUV%\%~1" "%JEU%\%~1" >nul
if errorlevel 1 (
  echo    [FAILED / ÉCHEC] %~1
  set /a ECHECS+=1
  exit /b
)
echo    [RESTORED / RESTAURÉ] %~1
exit /b

:fin
echo.
pause
endlocal
