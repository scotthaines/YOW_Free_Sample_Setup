;===============================
; file: yow_free_sample_setup.nsi
; created: 2015 12 30, Scott Haines
; edit: 22 Scott Haines
; date: 2016 02 24
; description:  This installs YOW Free Sample and Git if Git is not
;               already installed.
;-------------------------------
; Modern User Interface 2 (MUI2)
    !include "mui2.nsh"

; x64 bit OS detection
    !include "x64.nsh"

;-------------------------------
    !define MUI_ICON "..\data\yow_free_sample_green.ico"
    !define MUI_UNICON "..\data\yow_free_sample_red.ico"
;--------------------------------
;Version Information

    !define YFS_Version 1.0.0.0
    !define YFS_LongName "YOW Free Sample"
    !define YFS_ShortName "YFS"
    !define YFS_InstallerName "YOWFreeSampleSetup.exe"
    !define YFS_UninstallerName "uninstallYFS.exe"
    !define YFS_UninstallersDir "uninstallYFS"
    !define YFS_CompanyName "Friedbook"

    Name "${YFS_LongName}"
    OutFile "..\exe\${YFS_InstallerName}"

    VIProductVersion ${YFS_Version}
    VIAddVersionKey ProductName "${YFS_LongName}"
    VIAddVersionKey Comments "Your Own Web Free Sample (YFS) provides simple browser pages in a Git version control repository. Visit https://sites.google.com/site/friedbook/ for more information."
    VIAddVersionKey CompanyName ${YFS_CompanyName}
    VIAddVersionKey LegalCopyright "Public Domain"
    VIAddVersionKey FileDescription "${YFS_LongName} installer"
    VIAddVersionKey FileVersion ${YFS_Version}
    VIAddVersionKey ProductVersion ${YFS_Version}
    ; VIAddVersionKey InternalName "There is no internal name for the YFS installer."
    VIAddVersionKey LegalTrademarks "Friedbook is a Trademark of Scott Haines."
    VIAddVersionKey OriginalFilename "${YFS_InstallerName}"

    ; Initialize the INSTDIR.
    InstallDir ""
                                        ; An empty string here makes the
                                        ; Browser button work reasonably
                                        ; with the MUI_PAGE_CUSTOMFUNCTION_PRE
                                        ; function writing to INSTDIR.

    RequestExecutionLevel user
    AllowRootDirInstall false

;--------------------------------
; MUI Interface Configuration

    !define MUI_ABORTWARNING

;--------------------------------
; Language Selection Dialog Settings

    ;Remember the installer language
    !define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
    !define MUI_LANGDLL_REGISTRY_KEY  "Software\YOW\Free Sample"
    !define MUI_LANGDLL_REGISTRY_VALUENAME "InstallerUILanguage"
    !define MUI_LANGDLL_ALWAYSSHOW

;-------------------------------
; MUI pages
    !insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_PRE "ADirPre"
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "ADirLv"
    !insertmacro MUI_PAGE_DIRECTORY
; !define MUI_PAGE_CUSTOMFUNCTION_PRE "BDirPre"
; !define MUI_PAGE_CUSTOMFUNCTION_LEAVE "BDirLv"
;     !insertmacro MUI_PAGE_DIRECTORY
    !insertmacro MUI_PAGE_INSTFILES

Function .onInit

    Var /GLOBAL dirDraft
    ReadRegStr $0 HKCU "Software\YOW\Free Sample" "InstallLocationDraft"
    StrCpy $dirDraft "$0"

    Var /GLOBAL dirBackup
    ReadRegStr $0 HKCU "Software\YOW\Free Sample" "InstallLocationBackup"
    StrCpy $dirBackup "$0"

    Var /GLOBAL homeDir
    ReadEnvStr $homeDir HOMEDRIVE

    !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

Function ADirPre
    StrCmp "" "$dirDraft" AThen AElse
AThen:
        StrCpy $INSTDIR "$DOCUMENTS\draft\YFS"
        GoTo AEndIf
AElse:
        StrCpy $INSTDIR "$dirDraft"
        GoTo AEndIf
AEndIf:
FunctionEnd

; Function BDirPre
;     StrCmp "" "$dirBackup" BThen BElse
; BThen:
;         StrCpy $INSTDIR "$homeDir\backup\YFS"
;         GoTo BEndIf
; BElse:
;         StrCpy $INSTDIR "$dirBackup"
;         GoTo BEndIf
; BEndIf:
; FunctionEnd

Function ADirLv
        StrCpy $dirDraft $INSTDIR
FunctionEnd

; Function BDirLv
;         StrCpy $dirBackup $INSTDIR
; FunctionEnd

;-------------------------------
; MUI installer languages

    ; Offer the commonly spoken and well known languages.
    !insertmacro MUI_LANGUAGE "English"
    !insertmacro MUI_LANGUAGE "Arabic"
    !insertmacro MUI_LANGUAGE "Danish"
    !insertmacro MUI_LANGUAGE "Dutch"
    !insertmacro MUI_LANGUAGE "German"
    !insertmacro MUI_LANGUAGE "Greek"
    !insertmacro MUI_LANGUAGE "Farsi"
    !insertmacro MUI_LANGUAGE "Finnish"
    !insertmacro MUI_LANGUAGE "French"
    !insertmacro MUI_LANGUAGE "Hebrew"
; Including Hindi generates the following warning when the installer is built.
; 1 warning:
;  unknown variable/constant "" detected, ignoring (LangString ^BrowseBtn:1081)
;    !insertmacro MUI_LANGUAGE "Hindi"

    !insertmacro MUI_LANGUAGE "Indonesian"
    !insertmacro MUI_LANGUAGE "Italian"
    !insertmacro MUI_LANGUAGE "Norwegian"
    !insertmacro MUI_LANGUAGE "Portuguese"
    !insertmacro MUI_LANGUAGE "Russian"
    !insertmacro MUI_LANGUAGE "Spanish"
    !insertmacro MUI_LANGUAGE "SimpChinese"
    !insertmacro MUI_LANGUAGE "Swedish"
    !insertmacro MUI_LANGUAGE "Thai"
    !insertmacro MUI_LANGUAGE "TradChinese"
    !insertmacro MUI_LANGUAGE "Japanese"
    !insertmacro MUI_LANGUAGE "Korean"
    !insertmacro MUI_LANGUAGE "Vietnamese"

;--------------------------------
    ; ReserveFile MyPlugin.dll
    !insertmacro MUI_RESERVEFILE_LANGDLL ; Language selection dialog

;-------------------------------
; Installer section
; Install working copy (draft) of the YOW Free Sample repository.
Section "draft (required)" SecDraft
                                        ; Now there is a components page so the
                                        ; name is important.
    ; The RO means the section is a Read Only section so it is required.
    SectionIn RO
    SectionIn 1

    ; Initialize the temporary folder path.
    ; "This folder is automatically deleted when the installer exits."
    ; It variable is $PLUGINSDIR.
    InitPluginsDir

    ; Set output path to the installation directory.
;    SetOutPath $INSTDIR
    SetOutPath $dirDraft

    ;--------
    ; Install Git if it is not already installed.

    ; Determine the Git install location if it is installed.
    Var /Global GitInstallLocation
    Var /Global GitInstallCheckAB
    StrCpy $GitInstallCheckAB "CheckA"  ; This indicates first check.

TRY_AGAIN:
    StrCpy $GitInstallLocation "placeholder value"

    ; This RunningX64 macro stuff is dependent on x64.nsh.
    ${If} ${RunningX64}
        # 64 bit code
        SetRegView 64
    ${Else}
        # 32 bit code
        SetRegView 32
    ${EndIf}

    ; First look for Git installed for all users.
    ReadRegStr $GitInstallLocation HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1\ "InstallLocation"
    IfErrors REG_READ_FAILURE_A REG_READ_SUCCESS
REG_READ_FAILURE_A:

    ; Second look for Git installed just for the current user.
    ReadRegStr $GitInstallLocation HKCU Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1\ "InstallLocation"
    IfErrors REG_READ_FAILURE_B REG_READ_SUCCESS
REG_READ_FAILURE_B:

    ; Third look for a Git 32 bit install on a 64 bit OS and installed for all.
    ${If} ${RunningX64}
        # There is a chance that they installed the 32 bit Git.
        # Check for it as well.
        SetRegView 32
        ReadRegStr $GitInstallLocation HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1\ "InstallLocation"
        IfErrors REG_READ_FAILURE_C REG_READ_SUCCESS
REG_READ_FAILURE_C:

            # Fourth look for a Git 32 bit install on a 64 bit OS and installed
            # just for the current user.
            ReadRegStr $GitInstallLocation HKCU Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1\ "InstallLocation"
            IfErrors REG_READ_FAILURE_D REG_READ_SUCCESS
                Goto REG_READ_SUCCESS
    ${Else}
        StrCmpS $GitInstallCheckAB "CheckB" GIT_INSTALL_FAILED32 INSTALL_GIT32
GIT_INSTALL_FAILED32:
            MessageBox MB_OK "Git was not installed. ${YFS_LongName} install will halt now." /SD IDOK
            Abort "Git must be installed to install ${YFS_LongName}."

INSTALL_GIT32:
        # Assume by this that Git is not installed.
        MessageBox MB_OK "Git is not installed. When you press OK the Git installer will start. It is best to use the default Git installer settings presented to you unless you have clear reasons to use other settings."
;       MessageBox MB_OK "Install 32 bit Git."
        SetOutPath $PLUGINSDIR
        SetRegView 32
        File ..\data\Git-2.7.0-32-bit.exe
        ExecWait '"Git-2.7.0-32-bit.exe"' $0
;        SetOutPath $INSTDIR
        SetOutPath $dirDraft
;       Goto REG_READ_SUCCESS
        StrCpy $GitInstallCheckAB "CheckB"  ; This indicates second check.
        Goto TRY_AGAIN
    ${EndIf}

REG_READ_FAILURE_D:
    StrCmpS $GitInstallCheckAB "CheckB" GIT_INSTALL_FAILED64 INSTALL_GIT64
GIT_INSTALL_FAILED64:
    MessageBox MB_OK "Git was not installed. ${YFS_LongName} install will halt now." /SD IDOK
    Abort "Git must be installed to install ${YFS_LongName}."

INSTALL_GIT64:
    # Assume by this that Git is not installed.
    MessageBox MB_OK "Git is not installed. When you press OK the Git installer will start. It is best to use the default Git installer settings presented to you unless you have clear reasons to use other settings."
;   MessageBox MB_OK "Install 64 bit Git."
    SetOutPath $PLUGINSDIR
    SetRegView 64
    File ..\data\Git-2.7.0-64-bit.exe
    ExecWait '"Git-2.7.0-64-bit.exe"' $0
;    SetOutPath $INSTDIR
    SetOutPath $dirDraft
;   Goto REG_READ_SUCCESS
    StrCpy $GitInstallCheckAB "CheckB"  ; This indicates second check.
    Goto TRY_AGAIN

REG_READ_SUCCESS:
; The following message box is for debugging.
;   MessageBox MB_OK "Git is already installed. This is the Git install location: $GitInstallLocation"

    ;--------
    ; Clone YOW Free Sample into the install directory.
    ; Add files and folders to install here.

    ; This installs the YOW Free Sample Git repository.
    File install_repository.cmd
    File install_repository.sh

    ; Install the repository.
    ExecWait '"install_repository.cmd" $\"$GitInstallLocation$\"' $0
    ; If the return value is 0
    StrCmp "0" $0 0 INSTALLREPO_FAILURE
        ; Print success on cloning text.
        DetailPrint "Success: The repository is cloned."
        Goto INSTALL_CONTINUE
INSTALLREPO_FAILURE:
        ; Print an error message to the detail list.
        DetailPrint "Error: The repository is not cloned. Check that the clone source is"
        DetailPrint "available and the destination directory is empty. Try again."
        MessageBox MB_OK "Error: The repository is not cloned. Check that the clone source is available and the destination directory is empty. Try again." /SD IDOK
        Abort

INSTALL_CONTINUE:
    ; Install the rest of the files.
    CreateShortCut "${YFS_ShortName} draft.lnk" "$dirDraft\repository\web\index.html"

    ; Install the installer so people can easily see it.
    ; I think this is confusing for people who just want to
    ; use YOW Free Sample so the release version of this
    ; installer should not include this.
    File yow_free_sample_setup.nsi

    ; Install the script which is run during uninstall.
    ; During uninstall it deletes the YOW Free Sample Git repository.
    ; File uninstall_repository.cmd

    ; Remember the installation folder.
    WriteRegStr HKCU "Software\YOW\Free Sample" "InstallLocationDraft" "$dirDraft"
    WriteRegStr HKCU "Software\YOW\Free Sample" "InstallLocationBackup" "$dirBackup"

    ; Create the uninstaller.
    CreateDirectory "$dirDraft\${YFS_UninstallersDir}"
    WriteUninstaller "$dirDraft\${YFS_UninstallersDir}\${YFS_UninstallerName}"

SectionEnd

;-------------------------------
; Installer section
; Create the bare repository and push to it to initialize it and the
; push path of the draft repository.
Section "desktop shortcut" SecDesktopShortcut
    ; The 2 means the section is the second listed in the components page.
    SectionIn 2

    CreateShortCut "$DESKTOP\${YFS_ShortName} draft.lnk" "$dirDraft\repository\web\index.html"

SectionEnd

;--------------------------------
; Descriptions

  ; Language strings
  LangString DESC_SecDraft ${LANG_ENGLISH} "Edit these pages to learn and create your own pages."
  LangString DESC_SecDesktopShortcut ${LANG_ENGLISH} "Create a desktop shortcut to the YOW Free Sample home page."

  ; Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDraft} $(DESC_SecDraft)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktopShortcut} $(DESC_SecDesktopShortcut)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;-------------------------------
; Uninstaller section

Section "Uninstall"

    MessageBox MB_OKCANCEL|MB_ICONQUESTION|MB_DEFBUTTON2 "Uninstall complete removes data. Your changes will be lost. Do you want to uninstall?" IDOK WANTTO_UNINSTALL 0
        Quit
WANTTO_UNINSTALL:

    ; Delete the YOW Free Sample Git repository including changed files in it.
    RMDir /r /REBOOTOK "$INSTDIR\..\repository"

    ; Add files and folders to delete (uninstall) here.
    Delete "$INSTDIR\..\install_repository.cmd"
    Delete "$INSTDIR\..\install_repository.sh"
    Delete "$INSTDIR\..\yow_free_sample_setup.nsi"
    Delete "$INSTDIR\${YFS_UninstallerName}"

    Delete "$INSTDIR\..\${YFS_ShortName} draft.lnk"
    Delete "$DESKTOP\${YFS_ShortName} draft.lnk"

    ; The following removes the uninstaller's directory if it is now empty.
    RMDir "$INSTDIR"

    ; In this case no longer remember the last install directory.
    DeleteRegKey /ifempty HKCU "Software\YOW\Free Sample"

    ; The reboot is required to avoid anti-virus programs like ESET
    ; from making an install after an uninstall impossibly slow
    ; during the clone of the repository.
    MessageBox MB_YESNO|MB_ICONQUESTION "A reboot is required to complete the uninstall. Do you wish to the computer reboot now?" IDNO WANTTO_NOTREBOOT
        Reboot
WANTTO_NOTREBOOT:

SectionEnd

Function un.onInit

    !insertmacro MUI_UNGETLANGUAGE

FunctionEnd

;===============================
