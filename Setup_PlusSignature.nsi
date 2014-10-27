; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------

!define APP "PlusSignature"
!define COM "HIRAOKA HYPERS TOOLS, Inc."
!define VER "0.4"

!define TTL "${APP} for Windows Live Mail 2012"

!include "LogicLib.nsh"
!include "WordFunc.nsh"

!searchreplace APV "${VER}" "." "_"

; The name of the installer
Name "${TTL} ${VER}"

; The file to write
OutFile "Setup_${APP}_${APV}.exe"

; The default installation directory
InstallDir "$PROGRAMFILES\Windows Live\Mail"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "SOFTWARE\Microsoft\Windows Live Mail" "InstallRoot"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page license
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

LicenseData "README.rtf"

;--------------------------------

; The stuff to install
Section ""

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "bin\DEBUG\PlusSignature.exe"
  
  StrCpy $0 ""
  ReadRegStr $0 HKCR "WLMail.Url.Mailto\shell\open\command" ""
  ${If} $0 != ""
    ${WordReplace} "$0" "wlmail.exe" "PlusSignature.exe" "+" $1
    WriteRegExpandStr HKCR "WLMail.Url.Mailto\shell\open\command" "" $1
  ${EndIf}
  
  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\${COM}\${APP}" "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${TTL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\uninstall-${APP}.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall-${APP}.exe"
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  StrCpy $0 ""
  ReadRegStr $0 HKCR "WLMail.Url.Mailto\shell\open\command" ""
  ${If} $0 != ""
    ${WordReplace} "$0" "PlusSignature.exe" "wlmail.exe" "+" $1
    WriteRegExpandStr HKCR "WLMail.Url.Mailto\shell\open\command" "" $1
  ${EndIf}

  ; Remove files and uninstaller
  Delete "$INSTDIR\PlusSignature.exe"
  Delete "$INSTDIR\uninstall-${APP}.exe"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
  DeleteRegKey HKLM "SOFTWARE\${COM}\${APP}"

SectionEnd
