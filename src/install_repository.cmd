rem file: install_repository.cmd
rem created: 2016 01 06, Scott Haines
rem edit: 07 Scott Haines
rem date: 2016 01 31
rem This installs the YOW Free Sample Git repository by cloning it into
rem the directory named repository.

rem git clone https://github.com/scotthaines/yow_free_sample.git repository
rem git clone c:\projects\yow_free_sample repository
rem "C:\Program Files\Git\bin\"bash install_repository.sh
%1bin\bash install_repository.sh
set STORE_ERRORLEVEL=%ERRORLEVEL%

rem rem if there is no error creating the repository
rem if %STORE_ERRORLEVEL% EQU 0 (
rem     rem Remove the remote origin to avoid unintended pushes YOW Free Sample
rem 	rem on GitHub.
rem 	cd repository
rem 	git remote remove origin
rem 	cd ..
rem )
rem pause
exit /B %STORE_ERRORLEVEL%
