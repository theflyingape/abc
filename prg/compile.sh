#!/bin/sh

ABC=`dirname $0`
PRG=$1

[ "${ABC}" = "." ] && ABC=$PWD

if [ -z "${PRG}" ]; then
	echo -n "Path to PRG? "
	read PRG
	[ -d "${PRG}" ] || exit 1
fi

cd ${PRG}
SRC=( *.s )
TITLE=`basename ${PRG}`

# dump former compiler outputs to avoid confusion
rm -f *.o *.lst *.map *.prg *.sym

for file in ${SRC[@]}; do

	ca65 --listing --include-dir ${ABC}/.. --include-dir . ${file}

done

# link and strip PRG load header for an 8KB cartridge image
set -o xtrace
ld65 -C vic.cfg -Ln ${TITLE}.sym -m ${TITLE}.map -o ${TITLE}.prg ${ABC}/../abc-slik.o *.o
set +o xtrace

sed -e '1,/^Segment/d' -e '1,1d' -e '/^Exports/,$d' ${TITLE}.map

