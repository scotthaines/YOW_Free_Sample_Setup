rem file: uninstall_repository.cmd
rem created: 2016 01 06, Scott Haines
rem edit: 02 Scott Haines
rem date: 2016 01 07
rem This unconditionally completely removes the YOW Free Sample
rem Git repository and its directory named "repository".
rem It /s removes all subdirectories and /q does not prompt
rem for approval. The % ~ dp0 directory path is the path
rem of this .cmd file.

rmdir "%~dp0repository" /s /q

rem Run next pause line for debugging.
rem pause
