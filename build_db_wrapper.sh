#!/bin/sh

for i in `seq 0 10`; do
    /usr/bin/time perl perl/listC.pl /scratch1/AudrisData/ALL/index_$i.db >index_$i.log 2>&1
done
