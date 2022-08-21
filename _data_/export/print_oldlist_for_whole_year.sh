#! /bin/bash
#####################################################
#####################################################
#
# this script will generate the "old" "stricherlliste"
# as HTML document
# and as PDF document (using https://github.com/reingart/pyfpdf)
#
#       git clone https://github.com/reingart/pyfpdf.git
#       cd pyfpdf
#       sudo python setup.py install
#
# for 1 whole year
#
#####################################################
#####################################################


_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

if [ "$1""x" == "x" ]; then
    echo "Usage: $0 <YYYY>"
    exit 1
fi

year="$(echo "$1"|cut -d"-" -f1)"
mkdir -p ./year_archive/${year}/

for month in 01 02 03 04 05 06 07 08 09 10 11 12; do
    echo ${year}"-"${month}
    ./print_oldlist.sh ${year}"-"${month} > ./year_archive/${year}/strlliste_${year}"-"${month}.txt
    mv templist.html ./year_archive/${year}/strlliste_${year}"-"${month}.html
    mv templist.pdf ./year_archive/${year}/strlliste_${year}"-"${month}.pdf
    cp stylesheet.css tally-mark.regular* ./year_archive/${year}/
done

