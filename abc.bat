@echo on
ca65.exe --cpu 6502 --listing --include-dir . abc.s
ld65.exe -C abc.cfg -m abc.map -o abc.prg abc.o
pause
REM xvic -ntsc -sound -memory none -cartA abc.a0
exit

