#! /bin/bash


sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_


printf 'select distinct d.code as "EAN"
from drinks d
where d.code not in (select code from ean_codes)
order by d.code
\n'| sqlite3 -header -line "$sqldb_file"|grep -v '^$'
echo ""

