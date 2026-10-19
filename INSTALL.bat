@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title Samurai Warriors 2 - French translation : install

set "MOD=%~dp0"
set "MOD=%MOD:~0,-1%"
for %%i in ("%MOD%\..") do set "JEU=%%~fi"
rem archive extracted with an extra folder level (Windows "Extract all"): look one level higher
if not exist "%JEU%\sw2.exe" for %%i in ("%MOD%\..\..") do if exist "%%~fi\sw2.exe" set "JEU=%%~fi"
set "XD=%MOD%\tools\xdelta3.exe"
set "PATCHS=%MOD%\patches"
set "LISTE=%MOD%\patches\list.txt"
set "SAUV=%MOD%\backup"
set "FILES=%MOD%\files"
set "ANCIEN=%JEU%\SW2_Traduction_FR\sauvegarde_originaux"
set "FENETRE=1073741824"
set "ECHECS=0"
set "VERSION=?"
if exist "%PATCHS%\version.txt" set /p VERSION=<"%PATCHS%\version.txt"

echo.
echo  ============================================================
echo    Samurai Warriors 2 (PC) - French translation / Traduction française
echo  ============================================================
echo.

if not exist "%JEU%\sw2.exe" goto :err_dossier
if not exist "%XD%" goto :err_installeur
if not exist "%LISTE%" goto :err_patchs
(echo test> "%JEU%\_sw2fr_test.tmp") 2>nul || goto :err_droits
del "%JEU%\_sw2fr_test.tmp" >nul 2>&1

echo  Game folder / Dossier du jeu : %JEU%
echo  Translation version / Version de la traduction : %VERSION%
echo  Close the game before going on. / Fermez le jeu avant de continuer.
echo.

rem version 1.0 / 1.1 (dossier SW2_Traduction_FR) : on recupere sa sauvegarde des fichiers d'origine
if exist "%ANCIEN%" if not exist "%SAUV%" (
  move "%ANCIEN%" "%SAUV%" >nul 2>&1
  if exist "%SAUV%" (
    echo  Previous version found: its backup of the original files is now in
    echo  SW2_French_Translation\backup. You can delete the old SW2_Traduction_FR folder.
    echo  Ancienne version trouvée : sa sauvegarde des fichiers d'origine est maintenant
    echo  dans SW2_French_Translation\backup. Vous pouvez supprimer l'ancien dossier SW2_Traduction_FR.
    echo.
  )
)

echo  Checking game files, please wait... / Vérification des fichiers, patientez...
set "ERREURS=0"
set "A_FAIRE=0"
for /f "usebackq tokens=1-3 delims=|" %%a in ("%LISTE%") do (
  if not exist "%PATCHS%\%%a.xdelta" (
    echo    [MISSING PATCH / PATCH MANQUANT] %%a
    set /a ERREURS+=1
  ) else if not exist "%JEU%\%%a" (
    echo    [MISSING / MANQUANT] %%a
    set /a ERREURS+=1
  ) else (
    call :md5 "%JEU%\%%a"
    if /i "!H!"=="%%c" (
      echo    [UP TO DATE / DÉJÀ À JOUR] %%a
    ) else if /i "!H!"=="%%b" (
      echo    [OK] %%a
      set /a A_FAIRE+=1
    ) else (
      call :sauve_ok "%%a" "%%b"
      if "!SOK!"=="1" (
        echo    [UPDATE / MISE À JOUR] %%a
        set /a A_FAIRE+=1
      ) else (
        echo    [DIFFERENT VERSION / VERSION DIFFÉRENTE] %%a
        set /a ERREURS+=1
      )
    )
  )
)
echo.
if %ERREURS% gtr 0 goto :err_version
if %A_FAIRE%==0 (
  echo  The translation is already installed and up to date.
  echo  La traduction est déjà installée et à jour.
  call :police
  goto :fin
)

echo  Installing / Installation...
for /f "usebackq tokens=1-3 delims=|" %%a in ("%LISTE%") do (
  call :md5 "%JEU%\%%a"
  if /i "!H!"=="%%b" (
    call :appliquer "%%a"
  ) else if /i not "!H!"=="%%c" (
    call :mettre_a_jour "%%a"
  )
)
echo.
if %ECHECS% gtr 0 (
  echo  [WARNING / ATTENTION] %ECHECS% file^(s^) could not be translated; they were left as before.
  echo  %ECHECS% fichier^(s^) n'ont pas pu être traduits ; ils sont restés dans leur état précédent.
  goto :fin
)
echo %VERSION%> "%SAUV%\installed_version.txt"
call :police
echo  Install complete. Enjoy^^! / Installation terminée. Bon jeu ^^!
echo  Back to English: UNINSTALL.bat / Retour à l'anglais : UNINSTALL.bat
echo.
echo  Japanese Voices or Controller Mod: run their INSTALL.bat again now.
echo  VO japonaise ou mod manette : relancez maintenant leur INSTALL.bat.
goto :fin

:police
rem accent spacing plugin (in memory only): SW2FrenchFont.asi, loaded by dinput8.dll (Ultimate ASI Loader)
if not exist "%FILES%\SW2FrenchFont.asi" exit /b
copy /y "%FILES%\SW2FrenchFont.asi" "%JEU%\SW2FrenchFont.asi" >nul
if errorlevel 1 (
  echo    [FAILED / ÉCHEC] SW2FrenchFont.asi ^(game running?^) / ^(jeu ouvert ?^)
  exit /b
)
if not exist "%JEU%\dinput8.dll" (
  copy /y "%FILES%\dinput8.dll" "%JEU%\dinput8.dll" >nul
  echo added> "%MOD%\dinput8_added.txt"
)
echo    [OK] SW2FrenchFont.asi : accent spacing / espacement des accents
exit /b

:appliquer
rem first install: the original goes to the backup, the translated file is created in its place
set "REL=%~1"
for %%d in ("%SAUV%\%REL%") do if not exist "%%~dpd" mkdir "%%~dpd"
move /y "%JEU%\%REL%" "%SAUV%\%REL%" >nul
if errorlevel 1 (
  echo    [FAILED / ÉCHEC] %REL% : cannot back up the original / sauvegarde impossible
  set /a ECHECS+=1
  exit /b
)
echo    %REL%...
"%XD%" -d -B %FENETRE% -f -s "%SAUV%\%REL%" "%PATCHS%\%REL%.xdelta" "%JEU%\%REL%"
if errorlevel 1 (
  echo    [FAILED / ÉCHEC] %REL% : original put back / original remis en place
  del "%JEU%\%REL%" >nul 2>&1
  move /y "%SAUV%\%REL%" "%JEU%\%REL%" >nul
  set /a ECHECS+=1
  exit /b
)
echo    [OK] %REL%
exit /b

:mettre_a_jour
rem update of a previous version: start again from the original kept in the backup
set "REL=%~1"
echo    %REL%...
"%XD%" -d -B %FENETRE% -f -s "%SAUV%\%REL%" "%PATCHS%\%REL%.xdelta" "%JEU%\%REL%.new"
if errorlevel 1 (
  echo    [FAILED / ÉCHEC] %REL% : previous version kept / ancienne version conservée
  del "%JEU%\%REL%.new" >nul 2>&1
  set /a ECHECS+=1
  exit /b
)
move /y "%JEU%\%REL%.new" "%JEU%\%REL%" >nul
if errorlevel 1 (
  echo    [FAILED / ÉCHEC] %REL% : file in use ^(game running?^) / fichier utilisé ^(jeu ouvert ?^)
  del "%JEU%\%REL%.new" >nul 2>&1
  set /a ECHECS+=1
  exit /b
)
echo    [OK] %REL%
exit /b

:sauve_ok
rem SOK=1 when the backup of a previous install holds the expected original
set "SOK=0"
if not exist "%SAUV%\%~1" exit /b
set "H2=!H!"
call :md5 "%SAUV%\%~1"
if /i "!H!"=="%~2" set "SOK=1"
set "H=!H2!"
exit /b

:md5
set "H="
for /f "delims=" %%h in ('certutil -hashfile "%~1" MD5 ^| findstr /v ":"') do if not defined H set "H=%%h"
if defined H set "H=%H: =%"
exit /b

:err_dossier
echo  [ERROR / ERREUR] sw2.exe not found in / introuvable dans :
echo    %JEU%
echo  The SW2_French_Translation folder must be inside the game folder, next to sw2.exe.
echo  Le dossier SW2_French_Translation doit être dans le dossier du jeu, à côté de sw2.exe.
goto :fin

:err_installeur
echo  [ERROR / ERREUR] tools\xdelta3.exe is missing. Extract the whole "Installer"
echo  archive again. / tools\xdelta3.exe manque : ré-extrayez l'archive "Installer".
goto :fin

:err_patchs
echo  [ERROR / ERREUR] The patches are missing. This mod comes in 2 files on Nexus:
echo  "Installer" and "Patches". Download both and extract them into the game folder.
echo  Les patchs manquent. Ce mod est en 2 fichiers sur Nexus : "Installer" et
echo  "Patches". Téléchargez les deux et extrayez-les dans le dossier du jeu.
goto :fin

:err_droits
echo  [ERROR / ERREUR] Cannot write to the game folder.
echo  Right-click INSTALL.bat, then "Run as administrator".
echo  Impossible d'écrire dans le dossier du jeu.
echo  Clic droit sur INSTALL.bat, puis "Exécuter en tant qu'administrateur".
goto :fin

:err_version
echo  [ERROR / ERREUR] Your copy of the game does not match. Nothing was changed.
echo  Votre copie du jeu ne correspond pas. Aucun fichier n'a été modifié.
echo.
echo  This mod needs the original English PC version.
echo  If Japanese Voices or Controller Mod are installed, run their UNINSTALL.bat
echo  first, install the translation, then run their INSTALL.bat again.
echo  Ce mod nécessite la version PC anglaise d'origine.
echo  Si la VO japonaise ou le mod manette sont installés, lancez d'abord leur
echo  UNINSTALL.bat, installez la traduction, puis relancez leur INSTALL.bat.
goto :fin

:fin
echo.
pause
endlocal
