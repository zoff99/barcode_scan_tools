#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

cd "$_HOME_"

rsync -avz pi@bcecht01:/home/pi/barcode_scan/db .
