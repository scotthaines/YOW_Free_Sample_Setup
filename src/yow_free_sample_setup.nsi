;===============================
; file: yow_free_sample_setup.nsi
; created: 2015 12 30, Scott Haines
; edit: 08 Scott Haines
; date: 2016 01 20
; description:  This installs YOW Free Sample and Git if it is not
;				already installed.
;-------------------------------
; Modern User Interface 2 (MUI2)
    !include "mui2.nsh"

; x64 bit OS detection
    !include "x64.nsh"

;-------------------------------
    Name "YOW Free Sample"
    OutFile "..\exe\YOWFreeSampleSetup.exe"

    InstallDir "$DOCUMENTS\YOW\Free Sample"

    InstallDirRegKey HKCU "Software\YOW\Free Sample" ""

    RequestExecutionLevel admin

;--------------------------------
; MUI Interface Configuration

    !define MUI_ABORTWARNING

;-------------------------------
; MUI pages
    !insertmacro MUI_PAGE_DIRECTORY
    !insertmacro MUI_PAGE_INSTFILES

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

Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

;ReserveFile MyPlugin.dll
!insertmacro MUI_RESERVEFILE_LANGDLL ;Language selection dialog

;-------------------------------
; Installer section
; In this installer this is the one and only installer section.
Section "Dummy Section" SecDummy
                                        ; There is no components page so the
                                        ; name is not important

    ; Set output path to the installation directory.
    SetOutPath $INSTDIR

    ; Clone YOW Free Sample into the install directory.
;    IfFileExists "$INSTDIR\LogicLib.nsi" 0 BranchTest69
;    MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to overwrite $INSTDIR\LogicLib.nsi?" IDNO NoOverwrite ; skipped if file doesn't exist
;    BranchTest69:
; more
;  MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to skip the rest of this section?" IDYES EndTestBranch
;  EndTestBranch:

	Var /Global GitInstallLocation
	StrCpy $GitInstallLocation "example value"

	; The RunningX64 macro stuff is dependent on x64.nsh.
    ${If} ${RunningX64}
        # 64 bit code
        SetRegView 64
    ${Else}
        # 32 bit code
        SetRegView 32
    ${EndIf}

	ReadRegStr $GitInstallLocation HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1\ "InstallLocation"
    IfErrors REG_READ_FAILURE REG_READ_SUCCESS
REG_READ_FAILURE:
		; Reading the Git install location from the registry failed.
		; Assume by this that Git is not installed.
		MessageBox MB_OK "Git is not installed. When you press OK the Git installer will start. It is best to use the default Git installer settings presented to you unless you have reasons to use other settings."
		${If} ${RunningX64}
		    # Install the 64 bit Git.
        ${Else}
            # Install the 32 bit Git.
        ${EndIf}

REG_READ_SUCCESS:
	MessageBox MB_OK "This is the Git install location: $GitInstallLocation"

    ; Add files and folders to install here.

    ; This installs the YOW Free Sample Git repository.
    File install_repository.cmd

    ; Install the repository.
;    ExecWait '"install_repository.cmd" $\"$GitInstallLocation$\"' $0
;    ExecWait '"install_repository.cmd" jkl_mno' $0
     ExecWait '"install_repository.cmd"' $0
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

    ; Install the script which is run during uninstall.
	; During uninstall it deletes the YOW Free Sample Git repository.
    File uninstall_repository.cmd

    ; Install the installer so people can easily see it.
	; I think this is confusing for people who just want to
	; use YOW Free Sample so the release version of this
	; installer should not include this.
    File yow_free_sample_setup.nsi

    ; Remember the installation folder.
    WriteRegStr HKCU "Software\YOW\Free Sample" "" $INSTDIR

    ; Create the uninstaller.
    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;-------------------------------
; Uninstaller section

Section "Uninstall"

    MessageBox MB_OKCANCEL|MB_ICONQUESTION|MB_DEFBUTTON2 "Uninstall complete removes data. Your changes will be lost. Do you want to uninstall?" IDOK WANTTO_UNINSTALL 0
        Quit
WANTTO_UNINSTALL:

    ; Delete the YOW Free Sample Git repository.
    ExecWait "$INSTDIR\uninstall_repository.cmd"

    ; Add files and folders to delete (uninstall) here.
    Delete "$INSTDIR\install_repository.cmd"
    Delete "$INSTDIR\uninstall_repository.cmd"
    Delete "$INSTDIR\yow_free_sample_setup.nsi"
    Delete "$INSTDIR\Uninstall.exe"

    RMDir "$INSTDIR\repository"
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
;===============================
