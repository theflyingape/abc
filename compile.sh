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
C1541=$(which c1541 2> /dev/null) || C1541="flatpak run --command=c1541 net.sf.VICE"
XVIC=$(which xvic 2> /dev/null) || XVIC="flatpak run --command=xvic net.sf.VICE"

# dump former compiler outputs to avoid confusion
rm -f *.o *.lst *.map [!abc]*.pr? *.sym

while [ "${YN}" != "y" -a "${YN}" != "n" ]; do
	echo -n "Compile programs (Y/N)? " && read -N1 YN
	echo
	YN=`echo ${YN} | tr [:upper:] [:lower:]`
done

###
###	compile/link program(s)
###
if [ "${YN}" = "y" ]; then

for TITLE in ${ABC[@]}; do

	SRC=${TITLE%.*}
	set -o xtrace
	ca65 --listing "${SRC}.lst" --include-dir . ${TITLE}
	set +o xtrace

done

# link ABC with components, and strip PRG load header for an 8KB cartridge image
set -o xtrace
ld65 -C abc.cfg -Ln abc.sym -m abc.map -o abc.prg abc.o abc-*.o
set +o xtrace
dd if=abc.prg of=abc.a0 bs=1 skip=2
sed -e '1,/^Segment/d' -e '1,1d' -e '/^Exports/,$d' abc.map

cd prg

for TITLE in ${GAMES[@]}; do

	[ -f ${TITLE}.s ] || continue

	echo 
	echo "Compiling '${TITLE}' ... "

	SRC=${TITLE%.*}
	set -o xtrace
	ca65 --listing "${SRC}.lst" --include-dir . ${TITLE}.s
	ld65 -C basic+8k.cfg -Ln ${TITLE}.sym -m ${TITLE}.map -o ${TITLE}.prg ${TITLE}.o
	set +o xtrace

	#sed -e '1,/^Segment/d' -e '1,1d' -e '/^Exports/,$d' ${TITLE}.map

done

cd -

###
###	create new floppy disk image
###
if [ -f abc.prg ]; then

echo

[ -f ${OUTPUT} ] && rm -fv ${OUTPUT}

$C1541 <<-EOD
	format "${LABEL},20" ${DISK} "${OUTPUT}"
	write "abc.prg" "abc"
	quit
EOD

# copy any extra programs into floppy disk image
for PRG in extra/*.prg; do
	VIC="`basename "${PRG%.*}"`"
	$C1541 <<-EOD
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

		$C1541 <<-EOD
			attach "${OUTPUT}"
			write "${PRZ}" "${VIC}"
			quit
		EOD
	fi
done

echo
YN=

fi

fi

echo
echo DIRECTORY LISTING OF ${OUTPUT}
$C1541 "${OUTPUT}" -dir


###
###	launch emulator
###
while [ "${ABC}" != "a" -a "${ABC}" != "b" -a "${ABC}" != "c" ]; do
	echo -n "Attach ABC with ${OUTPUT} ([A]bort/[B]oot/[C]art)? " && read -N1 ABC
	echo
	ABC=`echo ${ABC} | tr [:upper:] [:lower:]`
done

# original old school expanded rig with a manual boot
[ "${ABC}" = "b" ] && $XVIC -default \
	-ntsc -kernal "kernal.901486-06.bin" -memory all -autoload abc +basicload \
	-windowxpos "80" -windowypos "80" -windowwidth "1200" -windowheight "1048" \
	-drivesound +confirmonexit +VICdscan \
	-drive8truedrive -drive8type 1541 -8 "${OUTPUT}" \
	-drive9truedrive -drive9type 1541 \
	-drive10truedrive -drive10type 1571 \
	-drive11truedrive -drive11type 1581 \
	-keybuf "rem [restore] for abc\n"
# gnu skool loaded with the cart and use local filesystem as drive
[ "${ABC}" = "c" ] && $XVIC -default \
	-ntsc -kernal "kernal.901486-06.bin" -memory all -cartA abc.a0 \
	-windowxpos "80" -windowypos "80" -windowwidth "1200" -windowheight "1048" \
	-drivesound +confirmonexit +VICdscan \
	+drive8truedrive -drive8type 1540 -trapdevice8 \
	-drive9truedrive -drive9type 1541 \
	-drive10truedrive -drive10type 1571 \
	-drive11truedrive -drive11type 1581

exit
