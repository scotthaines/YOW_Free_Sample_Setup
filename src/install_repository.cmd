rem file: install_repository.cmd
rem created: 2016 01 06, Scott Haines
rem edit: 06 Scott Haines
rem date: 2016 01 12
rem This installs the YOW Free Sample Git repository by cloning it into
rem the directory named repository.

rem git clone https://github.com/scotthaines/yow_free_sample.git repository
git clone c:\projects\yow_free_sample repository
set STORE_ERRORLEVEL=%ERRORLEVEL%

rem if there is no error creating the repository
if %STORE_ERRORLEVEL% EQU 0 (
    rem Remove the remote origin to avoid unintended pushes YOW Free Sample
	rem on GitHub.
	cd repository
	git remote remove origin
	cd ..
)
rem pause
exit /B %STORE_ERRORLEVEL%
