rem file: build.cmd
rem created: 2015 12, Scott Haines
rem edit: 15, Scott Haines
rem date: 2017 09 11
rem description: Build the installer .exe from its .nsi source file.
rem input: The input percent 1 parameter should be a .nsi file in
rem        the ..\src directory.

rem If the ..\exe output directory does not already exist
dir ..\exe /AD
if 0 NEQ %ERRORLEVEL% (
    rem Make the ..\exe output directory.
    mkdir ..\exe
)

rem Delete a previous installer .exe if it exists.
rem This makes it clear whether this build succeeded or not.
del ..\exe\YOWFreeSampleSetup_2_3_0.exe

rem If the ..\log build log file directory does not already exist
dir ..\log /AD
if 0 NEQ %ERRORLEVEL% (
    rem Make the ..\log build log file directory.
    mkdir ..\log
)

rem Delete a previous build .log file if it exists.
rem This makes the build .log file is from the last run of the build.
del ..\log\build.log

rem Find NSIS Unicode and run its install builder.
dir "C:\Program Files\NSIS\Unicode\makensis.exe" /A-D
if 0 EQU %ERRORLEVEL% (
    "C:\Program Files\NSIS\Unicode\makensis.exe" ..\src\%1 /O..\log\build.log
	goto :COMMONEXIT
)
dir "C:\Program Files (x86)\NSIS\Unicode\makensis.exe" /A-D
if 0 EQU %ERRORLEVEL% (
    "C:\Program Files (x86)\NSIS\Unicode\makensis.exe" ..\src\%1 /O..\log\build.log
	goto :COMMONEXIT
)
@echo build.cmd script error:
@echo     The NSIS Unicode install builder was not found on the computer.
:COMMONEXIT
rem If the installer .exe is not created
dir ..\exe\YOWFreeSampleSetup_2_3_0.exe /A-D
if 0 EQU %ERRORLEVEL% (
	@echo Run the installer ..\exe\YOWFreeSample.exe now to test it.
    @echo The build succeeded.
	@echo The installer .exe was created.
) else (
    @echo The build failed.
	@echo The installer .exe was not created.
)
pause
