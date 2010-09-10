
@echo off

rem write out the ignore list
echo .svn >> ignore.txt
echo .png >> ignore.txt
echo .ztmp >> ignore.txt

rem Copy the content folder without .svn to the Export folder two directories up.
xcopy .\content Export\addons\ZingerContent /EXCLUDE:ignore.txt /E /C /I /F /R /Y

rem delete the ignore list
del ignore.txt


pushd Export\addons\ZingerContent

rem move particles out of the content
xcopy .\particles ..\..\particles /E /C /I /F /R /Y
rmdir /S /Q .\particles

rem write the info.txt
echo "AddonInfo" >> info.txt
echo { >> info.txt
echo 	"name" "Zinger Content" >> info.txt
echo 	"version" "" >> info.txt
echo 	"up_date" "" >> info.txt
echo 	"author_name" "Arcadium Software" >> info.txt
echo 	"author_email" "" >> info.txt
echo 	"author_url" "" >> info.txt
echo 	"info" "Development content pack for Zinger." >> info.txt
echo } >> info.txt

popd


rem zip the pack up
del ContentPack.zip
7z a -tzip ContentPack.zip .\Export\* -r


rem done with the temporary export
rmdir /S /Q Export
