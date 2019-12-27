# vim: set noet ts=8:

ASM = 64tass
AFLAGS = --case-sensitive --ascii --m6502 -Wshadow -Wbranch-page \
	 --vice-labels --labels labels.txt


PROGRAM = main.prg
SOURCES = main.s




all: $(PROGRAM)

$(PROGRAM): $(SOURCES) #find-gaps.awk
	#$(ASM) $(AFLAGS) $< -o $@ | awk -f find-gaps.awk
	$(ASM) $(AFLAGS) -D USE_SYSLINE=1 $< -o $@


.PHONY: clean
clean:
	rm -f $(PROGRAM)

