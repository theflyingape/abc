#!/bin/sh
#
# VIC 20: Awesome Boot Cartridge
#   a convenience script to build a floppy image
#   written by Robert Hurst <robert@hurst-ri.us>
#

# pass target floppy name and which format: d64, d71, or d81
[ -n "$1" ] && OUTPUT="$1" || OUTPUT="abc.d64"
DISK=${OUTPUT##*.}
[ -z "${DISK}" ] && DISK="d64"
LABEL="awesome boot vic"

###
###	compile/link cartridge and module(s)
###
ABC=( abc.s abc-*.s )

# dump former compiler outputs to avoid confusion
rm -f *.o *.lst *.map *.pr? *.sym

for TITLE in ${ABC[@]}; do

	set -o xtrace
	ca65 --listing --include-dir . ${TITLE}
	set +o xtrace

done

# link ABC with components, and strip PRG load header for an 8KB cartridge image
set -o xtrace
ld65 -C abc.cfg -Ln abc.sym -m abc.map -o abc.prg abc.o abc-*.o
set +o xtrace
dd if=abc.prg of=abc.a0 bs=1 skip=2
sed -e '1,/^Segment/d' -e '1,1d' -e '/^Exports/,$d' abc.map

while [ "${YN}" != "y" -a "${YN}" != "n" ]; do
	echo -n "Compile programs (Y/N)? " && read -N1 YN
	echo
	YN=`echo ${YN} | tr [:upper:] [:lower:]`
done


###
###	compile/link program(s)
###
if [ "$YN" = "y" ]; then

cd prg

for TITLE in ${GAMES[@]}; do

	[ -f ${TITLE}.s ] || continue

	echo 
	echo "Compiling '${TITLE}' ... "

	set -o xtrace
	ca65 --listing --include-dir . ${TITLE}.s
	ld65 -C basic+8k.cfg -Ln ${TITLE}.sym -m ${TITLE}.map -o ${TITLE}.prg ${TITLE}.o
	set +o xtrace

	#sed -e '1,/^Segment/d' -e '1,1d' -e '/^Exports/,$d' ${TITLE}.map

done

cd -

fi


###
###	create new floppy disk image
###
if [ -f abc.prg ]; then

echo

[ -f ${OUTPUT} ] && rm -fv ${OUTPUT}

c1541 <<-EOD
	format "${LABEL},20" ${DISK} "${OUTPUT}"
	write "abc.prg" "abc"
	quit
EOD

# copy any extra programs into floppy disk image
for PRG in extra/*.prg; do
	VIC="`basename "${PRG%.*}"`"
	c1541 <<-EOD
		attach "${OUTPUT}"
		write "${PRG}" "${VIC}"
		quit
	EOD
done

# copy programs into floppy disk image 
for PRG in prg/*.prg; do

	VIC="`basename "${PRG%.*}"`"
	PRZ="`basename "${PRG%.*}.prz"`"

	if [ -s $PRG ]; then
		BYTES=`stat --printf '%s' $PRG`
		[ $BYTES -gt 3585 ] && T=52 || T=20
		bin/exomizer sfx basic -t $T $PRG -o $PRZ

		c1541 <<-EOD
			attach "${OUTPUT}"
			write "${PRZ}" "${VIC}"
			quit
		EOD
	fi
done

echo 
echo 
echo DIRECTORY LISTING OF ${OUTPUT}
c1541 "${OUTPUT}" -dir

YN=

fi


###
###	launch emulator
###
while [ "${YN}" != "y" -a "${YN}" != "n" ]; do
	echo -n "Attach ABC with ${OUTPUT} (Y/N)? " && read -N1 VIC
	echo
	YN=`echo ${VIC} | tr [:upper:] [:lower:]`
done

[ "${VIC}" = "y" ] && xvic -ntsc -memory all -cartA abc.a0 -10 "${OUTPUT}"
[ "${VIC}" = "Y" ] && xvic -ntsc -memory all -autoload abc.prg -8 "${OUTPUT}" -keybuf "rem [restore] for abc\n"

exit

