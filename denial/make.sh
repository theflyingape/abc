#!/bin/sh
#
# VIC 20: Awesome Boot Cartridge
#   a convenience script
#   written by Robert Hurst <robert@hurst-ri.us>
#

# which year
[ -n "$1" ] && YEAR="$1" || exit

# which format: d64, d71, or d81
[ -n "$2" ] && OUTPUT="$2" || OUTPUT="vic20-denial-${YEAR}.d64"
DISK=${OUTPUT##*.}
[ -z "${DISK}" ] && DISK="d64"
LABEL="${YEAR} denial vic"

# create new floppy disk image
[ -f ${OUTPUT} ] && rm -fv ${OUTPUT}

c1541 <<-EOD
	format "${LABEL},20" ${DISK} "${OUTPUT}"
	attach "${OUTPUT}"
	write "../abc.prg" "abc"
	quit
EOD

# copy programs into floppy disk image 
for PRG in ${YEAR}/*.prg; do

	VIC="`basename "${PRG%.*}"`"

	c1541 <<-EOD
		attach "${OUTPUT}"
		write "${PRG}" "`echo ${VIC} | tr [:upper:] [:lower:]`"
		quit
	EOD

done

echo 
echo 
echo DIRECTORY LISTING OF ${OUTPUT}
c1541 "${OUTPUT}" -dir

