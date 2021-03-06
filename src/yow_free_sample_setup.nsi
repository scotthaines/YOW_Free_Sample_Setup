;===============================
; file: yow_free_sample_setup.nsi
; created: 2015 12 30, Scott Haines
; edit: 62 Scott Haines
; date: 2018 04 02
; description:  This installs YOW Free Sample and Git if Git is not
;               already installed.
;-------------------------------
; Modern User Interface 2 (MUI2)
    !include "mui2.nsh"

; x64 bit OS detection
    !include "x64.nsh"                  ; Note that mui2.nsh or x64.nsh
                                        ; must include LogicLib.nsh to
                                        ; allow the {If} below to work.
    !include "FileFunc.nsh"

;-------------------------------
    !define MUI_ICON "..\data\yow_free_sample_green.ico"

;--------------------------------
; Version Information

    !define YFS_Version 2.4.0.0
    !define YFS_LongName "YOW Free Sample"
    !define YFS_ShortName "YFS"
    !define YFS_InstallerName "YOWFreeSampleSetup_2_4_0.exe"

    ; Blank the branding text which by default appears as
    ; 'Nullsoft Install System v2.46.5-Unicode'.
    BrandingText /TRIMRIGHT " "

    Name "${YFS_LongName}"
    OutFile "..\exe\${YFS_InstallerName}"

    VIProductVersion ${YFS_Version}
    VIAddVersionKey ProductName "${YFS_LongName}"
    VIAddVersionKey Comments "Your Own Web Free Sample (YFS) provides simple browser pages in a Git version control repository. Visit https://sites.google.com/site/friedbook/ for more information."
    VIAddVersionKey LegalCopyright "Public Domain"
    VIAddVersionKey FileDescription "${YFS_LongName} installer"
    VIAddVersionKey FileVersion ${YFS_Version}
    VIAddVersionKey ProductVersion ${YFS_Version}
    VIAddVersionKey LegalTrademarks "Friedbook, $\"Your Own Web$\" and YOW are Trademarks of Scott Haines."
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

    Var /GLOBAL dirDraft

; The following define makes the show details displayed before the
; finish page.
!define MUI_FINISHPAGE_NOAUTOCLOSE

!define MUI_WELCOMEPAGE_TEXT "Setup will guide you through the installation of $(^NameDA).$\r$\n$\r$\nEdit YOW Free Sample to write Your Own Web.$\r$\n$\r$\n$_CLICK"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\data\yow_free_sample_green.bmp"
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_HEADER_TEXT "Public Domain Dedication"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the dedication Deed and Legal Code before installing $(^NameDA)."
!define MUI_LICENSEPAGE_TEXT_TOP "Press Page Down to see the rest of the dedication."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "$_CLICK"
!define MUI_LICENSEPAGE_BUTTON "&Next >"
    !insertmacro MUI_PAGE_LICENSE "..\data\Public_Domain_Dedication.txt"
!define MUI_PAGE_CUSTOMFUNCTION_PRE "ReadStoredChoices"
    !insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_PRE "ADirPre"
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "ADirLv"
    !insertmacro MUI_PAGE_DIRECTORY
    !insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "&Open Home page (index.html) folder."
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "$dirDraft\repository\index.html"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "&Display Home page."
!define MUI_PAGE_CUSTOMFUNCTION_PRE "AFinPre"
    !insertmacro MUI_PAGE_FINISH

Function LaunchLink
    Exec '"$WINDIR\explorer.exe" /e,$dirDraft\repository'
FunctionEnd

    Var /GLOBAL homeDir

Function ADirPre
    ${If} "" == "$dirDraft"
        ; This is the default install location.
        StrCpy $INSTDIR "$DOCUMENTS\drafts\${YFS_ShortName}"
    ${Else}
        StrCpy $INSTDIR "$dirDraft"
    ${EndIf}
FunctionEnd

Function ADirLv
    ; If the directory is empty or not found
    ${DirState} $INSTDIR $R0
    ${If} 1 != $R0
        ; Use the selected directory.
        StrCpy $dirDraft $INSTDIR
    ${Else}
        ; Make the user try again.
        MessageBox MB_OK "The destination folder must be empty or not exist. Enter another destination folder." /SD IDOK
        Abort
    ${EndIf}

FunctionEnd

;-------------------------------
; MUI installer languages

    ; Offer many languages.
    !insertmacro MUI_LANGUAGE "English"
    !insertmacro MUI_LANGUAGE "Arabic"
    !insertmacro MUI_LANGUAGE "German"
    !insertmacro MUI_LANGUAGE "French"
    !insertmacro MUI_LANGUAGE "Italian"
    !insertmacro MUI_LANGUAGE "Russian"
    !insertmacro MUI_LANGUAGE "Spanish"
    !insertmacro MUI_LANGUAGE "SimpChinese"
    !insertmacro MUI_LANGUAGE "TradChinese"
    !insertmacro MUI_LANGUAGE "Japanese"
    !insertmacro MUI_LANGUAGE "Korean"
    !insertmacro MUI_LANGUAGE "Vietnamese"

;--------------------------------
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
        File ..\data\Git-2.16.2-32-bit.exe
        File ..\data\GitInf.txt
        ExecWait '"Git-2.16.2-32-bit.exe" /LOADINF=GitInf.txt' $0
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
    File ..\data\Git-2.16.2-64-bit.exe
    File ..\data\GitInf.txt
    ExecWait '"Git-2.16.2-64-bit.exe" /LOADINF=GitInf.txt' $0
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
    SetOutPath $PLUGINSDIR
    File install_repository.cmd
    File install_repository.sh

    ; Install the repository.
    ExecWait '"install_repository.cmd" $\"$GitInstallLocation$\" $\"$dirDraft$\"' $0
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
    SetOutPath $dirDraft

    File "..\data\Public_Domain_Dedication.txt"

    ; Get the last folder name in the dirDraft path.
    ${GetFileName} "$dirDraft" $R0
    ; Name the shortcut with the last folder's name.
    CreateShortCut "$R0.lnk" "$dirDraft\repository\index.html"

    ; Remember the installation folder.
    WriteRegStr HKCU "Software\YOW\Free Sample" "InstallLocation" "$dirDraft"

    Call WriteShortcutChoice

    Call WriteSearchInstallChoice

SectionEnd

;-------------------------------
; Installer section
; Create the desktop shortcut.
Section "desktop shortcut" SecDesktopShortcut
    ; The 2 means the section is the second listed in the components page.
    SectionIn 2

    ; Get the last folder name in the dirDraft path.
    ${GetFileName} "$dirDraft" $R0
    CreateShortCut "$DESKTOP\$R0.lnk" "$dirDraft\repository\index.html"

SectionEnd

;-------------------------------
; Installer section
; Install DocFetcher Portable with Index.
Section "Install Search with Index" SecInstallDFPSearchWithIndex
    ; The 3 means the section is the third listed in the components page.
    SectionIn 3

    ; Install DocFetcherPortableWithIndexSetup*.exe so it can be run on
    ; successful exit to this installer.
    SetOutPath $PLUGINSDIR
    File ..\data\DocFetcherPortableWithIndexSetup_1_4_0.exe

SectionEnd

;--------------------------------
; Descriptions

  ; Language strings
  LangString DESC_SecDraft ${LANG_ENGLISH} "Install YOW Free Sample pages and their Git repository. It is a clone of their repository on GitHub.$\r$\n$\r$\nEdit and commit these pages to create Your Own Web of pages."
  LangString DESC_SecDesktopShortcut ${LANG_ENGLISH} "Create a desktop shortcut to the YOW Free Sample (YFS) home page."
  LangString DESC_SecInstallDFPSearchWithIndex {LANG_ENGLISH} "Launch the DocFetcher Portable with Index Setup to install Search with an Index to these YOW Free Sample (YFS) pages.$\r$\n$\r$\nUpdate the YFS index when you change the content."

  ; Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDraft} $(DESC_SecDraft)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktopShortcut} $(DESC_SecDesktopShortcut)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecInstallDFPSearchWithIndex} $(DESC_SecInstallDFPSearchWithIndex)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

Function .onInit

    Var /GLOBAL getParams
    Var /GLOBAL getDefault
    ${GetParameters} $getParams
    ${GetOptions} $getParams "/default=" $getDefault
    ; If /default=all is a command line parameter.
    ${If} "all" == "$getDefault"
        ; Remove all of the installer's registry settings.
        ; These are setup UI language and install path.
        DeleteRegKey /ifempty HKCU "Software\YOW\Free Sample"
    ${EndIf}
    ReadRegStr $0 HKCU "Software\YOW\Free Sample" "InstallLocation"
    StrCpy $dirDraft "$0"

    ReadEnvStr $homeDir HOMEDRIVE

    !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

Function WriteShortcutChoice
    ; Write the desktop shortcut creation choice to the registry.
    ; This is used to set the initial choice during the next install.
    SectionGetFlags ${SecDesktopShortcut} $0
    IntOp $0 $0 & ${SF_SELECTED}
    ${If} $0 == ${SF_SELECTED}
        WriteRegStr HKCU "Software\YOW\Free Sample" "CreateDesktopShortcut" "true"
    ${Else}
        WriteRegStr HKCU "Software\YOW\Free Sample" "CreateDesktopShortcut" "false"
    ${EndIf}
FunctionEnd

Function ReadStoredChoices
    ; Read all stored choices from the registry.
    ; 
    ; Read the desktop shortcut creation choice from the registry.
    ReadRegStr $0 HKCU "Software\YOW\Free Sample" "CreateDesktopShortcut"
    ; "" is returned if no entry exists. This makes 'else' checked default.
    ${If} $0 == "false"
        ; Lower the selected flag.
        SectionGetFlags ${SecDesktopShortcut} $0
        IntOp $0 $0 & ${SECTION_OFF}
        SectionSetFlags ${SecDesktopShortcut} $0
    ${Else}
        ; Raise the selected flag.
        SectionGetFlags ${SecDesktopShortcut} $0
        IntOp $0 $0 | ${SF_SELECTED}
        SectionSetFlags ${SecDesktopShortcut} $0
    ${EndIf}

    ; Read the search install choice from the registry.
    ReadRegStr $0 HKCU "Software\YOW\Free Sample" "InstallSearch"
    ; "" is returned if no entry exists. This makes 'else' checked default.
    ${If} $0 == "false"
        ; Lower the selected flag.
        SectionGetFlags ${SecInstallDFPSearchWithIndex} $0
        IntOp $0 $0 & ${SECTION_OFF}
        SectionSetFlags ${SecInstallDFPSearchWithIndex} $0
    ${Else}
        ; Raise the selected flag.
        SectionGetFlags ${SecInstallDFPSearchWithIndex} $0
        IntOp $0 $0 | ${SF_SELECTED}
        SectionSetFlags ${SecInstallDFPSearchWithIndex} $0
    ${EndIf}
FunctionEnd

Function WriteSearchInstallChoice
    ; Write the search install choice to the registry.
    ; This is used to set the initial choice during the next install.
    SectionGetFlags ${SecInstallDFPSearchWithIndex} $0
    IntOp $0 $0 & ${SF_SELECTED}
    ${If} $0 == ${SF_SELECTED}
        WriteRegStr HKCU "Software\YOW\Free Sample" "InstallSearch" "true"
    ${Else}
        WriteRegStr HKCU "Software\YOW\Free Sample" "InstallSearch" "false"
    ${EndIf}
FunctionEnd

Function AFinPre
    SectionGetFlags ${SecInstallDFPSearchWithIndex} $R3
    IntOp $R4 $R3 & ${SF_SELECTED}
    ; If install search is selected
    ${If} $R4 != 0
        MessageBox MB_OK "Per your $\"Install Search with Index$\" selection the $\"DocFetcher Portable with Index Setup$\" will run when you Finish this setup." /SD IDOK
    ${EndIf}
FunctionEnd

Function .onInstSuccess
    SectionGetFlags ${SecInstallDFPSearchWithIndex} $R3
    IntOp $R4 $R3 & ${SF_SELECTED}
    ; If install search is selected
    ${If} $R4 != 0
        ; Run search with index installer. 
        ; Hide its display of the install directory page.
        Exec '"$PLUGINSDIR\DocFetcherPortableWithIndexSetup_1_4_0.exe" /default=installDir'
    ${EndIf}
FunctionEnd

;===============================
