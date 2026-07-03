@echo off

for %%f in (*) do (
	if "%%~xf" == "" (
		ren "%%f" "%%f.jpg"
	)
)

echo Done!
pause
