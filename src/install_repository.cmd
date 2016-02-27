rem file: install_repository.cmd
rem created: 2016 01 06, Scott Haines
rem edit: 09 Scott Haines
rem date: 2016 02 27
rem This installs the YOW Free Sample Git repository by cloning it into
rem the directory named repository.
rem The percent 1 parameter is the Git program path.
rem The percent 2 parameter is the install path.

rem Save the current directory path.
set YFSTempDir=%~dp0

rem Move to the installation directory.
cd %2

rem The following is a commented out pause for debugging.
rem pause

%1bin\bash %YFSTempDir%install_repository.sh
set STORE_ERRORLEVEL=%ERRORLEVEL%

exit /B %STORE_ERRORLEVEL%
