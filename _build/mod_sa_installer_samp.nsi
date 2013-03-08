!include "MUI2.nsh"

!define MUI_ICON nsis\icon.ico
!define MUI_INSTALLCOLORS "DDDDDD 333333"
!define MUI_INSTFILESPAGE_COLORS "DDDDDD 333333"
!define MUI_INSTFILESPAGE_PROGRESSBAR colored
!define NAME 'mod_sa'
!define MP 'SA-MP'
!define MP_VERSION 'v0.3x R1'
!define VERSION 'v4.4.3.3'
!define M0D_AUTHOR 'by povargek for cheat-master.ru'

; create output directory if it doesn't exist
!system 'mkdir "..\_distro_installers\"'

Name "${NAME} ${VERSION}"
OutFile "..\_distro_installers\${NAME}.${VERSION}.${MP}.${MP_VERSION}.${M0D_AUTHOR}.Setup.exe"
SetCompressor /SOLID lzma
CRCCheck force
BrandingText "Visit ${NAME} at cheat-master.ru, Click Here"
CompletedText "${NAME} ${VERSION} for ${MP} ${MP_VERSION} setup finished"
ShowInstDetails show
ShowUninstDetails show
RequestExecutionLevel admin

; gimme some mo plugins
!addplugindir ".\nsis"

; music (yo dawg is unfunny)
!define BASSMOD_PATH ".\nsis"
!define BASSMOD_NAME "bassmod.dll"
!define BASSMOD_LOCATION "${BASSMOD_PATH}\${BASSMOD_NAME}"
!include "${BASSMOD_PATH}\nsisbassmodmacros.nsh"
ReserveFile "${BASSMOD_PATH}\bassmod.dll"
ReserveFile "${BASSMOD_PATH}\music.mod"
Function .onInit
	!insertmacro NSISBASSMOD_Init
	File "/oname=$PLUGINSDIR\music.mod" "${BASSMOD_PATH}\music.mod"
	!insertmacro NSISBASSMOD_MusicPlay "$PLUGINSDIR\music.mod"
FunctionEnd
Function .onGUIEnd
	BrandingURL::Unload
	!insertmacro NSISBASSMOD_MusicFree
	!insertmacro NSISBASSMOD_Free
FunctionEnd

; branding url
!define MUI_CUSTOMFUNCTION_GUIINIT onGUIInit
Function onGUIInit
 BrandingURL::Set /NOUNLOAD "0" "0" "200" "http://cheat-master.ru/"
FunctionEnd

; main installation screen variables
Page directory
DirText "Welcome to the installer for ${NAME} ${VERSION} for ${MP} ${MP_VERSION}.$\r$\n$\r$\nCheck out ${NAME} at cheat-master.ru for the lastest versions and information.  Just click the link on the bottom left." "Please select your GTA San Andreas directory."
InstallDir "$PROGRAMFILES\Rockstar Games\GTA San Andreas\"
InstallDirRegKey HKLM "SOFTWARE\Rockstar Games\GTA San Andreas\Installation" ExePath
Function .onVerifyInstDir
	IfFileExists $INSTDIR\gta_sa.exe +2
		Abort
FunctionEnd

; dump detail text to a log file
Function .onInstSuccess
	DumpLog::DumpLog "$INSTDIR\${NAME}_setup.log" .R0
FunctionEnd
Function .onInstFailed
	DumpLog::DumpLog "$INSTDIR\${NAME}_setup.log" .R0
FunctionEnd

; setup MUI
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Function DirectXUpdater
	; directx runtime upgrader
	DetailPrint "Updating DirectX 9.0c if needed.  Please wait... (this could take a few minutes)"
	SetDetailsPrint none
	File "/oname=$PLUGINSDIR\dxwebsetup.exe" ".\nsis\dxwebsetup.exe"
	ExecWait '"$PLUGINSDIR\dxwebsetup.exe" /Q' ; no matter what this always returns 0, stupid microsoft
	Delete "$PLUGINSDIR\dxwebsetup.exe"
	SetDetailsPrint both
	DetailPrint "DirectX 9.0c Done Updating"
FunctionEnd

; Install Sequence
Section "Install" SecDummy
	DetailPrint "Setup log created by ${NAME} ${VERSION} for ${MP} ${MP_VERSION} setup"

	SetOutPath "$INSTDIR"
	SetOverwrite on

	; delete old crap
	Delete samp.dll.bak
	Delete s0beit_hack.ini
	Delete s0beit_hack.log
	Delete s0beit_hack_a3v5.raw
	Delete m0d_s0beit_sa.raw
	Delete m0d_s0beit_sa_setup.log
	; delete new old crap
	Delete m0d_s0beit_sa.ini
	Delete m0d_s0beit_sa.log
	Delete m0d_s0beit_sa_all.log
	; delete from current previous installation
	Delete mod_sa_setup.log

	; install the basics
	File ..\bin\d3d9.dll
	File ..\bin\mod_sa.raw
	File ..\bin\mod_sa_ChangeLog.txt
	File ..\bin\speedo.png
	File ..\bin\needle.png

	; need to figure out how to patch this instead of overwriting every time
	File ..\bin\mod_sa.ini

	SetOutPath "$INSTDIR\data"
	SetOverwrite off
	File ..\bin\data\carmods.two
	File ..\bin\data\default.two
	File ..\bin\data\handling.two
	File ..\bin\data\shopping.two
	File ..\bin\data\timecyc.two
	File ..\bin\data\vehicles.two
	File ..\bin\data\surface.two
	SetOverwrite on

	; update DirectX from a function so it doesn't add to "Space required"
	Call DirectXUpdater

	WriteUninstaller "$INSTDIR\Uninstall_${NAME}.exe"
	
	; add game directory location to the registry even if it exists
	; just in case someone changed their installation location.
	; this should happen much more often than using more than one
	; copy of the game at a time.
	WriteRegStr HKLM "SOFTWARE\Rockstar Games\GTA San Andreas\Installation" "ExePath" $INSTDIR
SectionEnd

; Uninstall Sequence
Section "Uninstall"
	Delete "$INSTDIR\d3d9.dll"
	Delete "$INSTDIR\mod_sa.log"
	Delete "$INSTDIR\mod_sa_all.log"
	Delete "$INSTDIR\mod_sa.raw"
	Delete "$INSTDIR\speedo.png"
	Delete "$INSTDIR\needle.png"
	Delete "$INSTDIR\mod_sa_setup.log"

	; this should not be deleted
	;Delete "$INSTDIR\mod_sa.ini"
	; or these
	;Delete "$INSTDIR\data\carmods.two"
	;Delete "$INSTDIR\data\default.two"
	;Delete "$INSTDIR\data\handling.two"
	;Delete "$INSTDIR\data\shopping.two"
	;Delete "$INSTDIR\data\timecyc.two"
	;Delete "$INSTDIR\data\vehicles.two"
	;Delete "$INSTDIR\data\surface.two"
	
	Delete "$INSTDIR\Uninstall_${NAME}.exe"
SectionEnd
