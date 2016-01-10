rem file: install_repository.cmd
rem created: 2016 01 06, Scott Haines
rem edit: 05 Scott Haines
rem date: 2016 01 10
rem This installs the YOW Free Sample Git repository by cloning it into
rem the directory named repository.

rem git clone https://github.com/scotthaines/yow_free_sample.git repository
git clone c:\projects\yow_free_sample repository
@echo Error level is %ERRORLEVEL%
rem pause
exit /B %ERRORLEVEL%
