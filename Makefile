# vim: set noet ts=8:

ASM = 64tass
AFLAGS = --case-sensitive --ascii --m6502 -Wshadow -Wbranch-page \
	 --vice-labels --labels labels.txt

KOALA = focus4.kla

PROGRAM = main.prg
SOURCES = main.s
DATA = sprites-stretched.bin

all: $(PROGRAM)


sprites-stretched.bin: $(KOALA) convert.py
	$(SH) ./convert.py

$(PROGRAM): $(SOURCES) $(DATA) convert.py
	$(ASM) $(AFLAGS) -D USE_SYSLINE=1 $< -o $@



.PHONY: clean
clean:
	rm -f $(PROGRAM)
	rm -f sprites-stretched.bin

