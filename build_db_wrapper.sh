#!/bin/sh

for i in `seq 1 10`; do
    time perl perl/listC.pl /scratch1/AudrisData/ALL/index_$i.db >index_$i.log 2>&1
done
