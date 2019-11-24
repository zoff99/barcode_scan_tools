#! /bin/bash


sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

echo ""
printf 'select distinct(d.code), c.description as desc, sum(d.anzahl) as anzahl
from drinks d, ean_codes c
where d.code=c.code
and c.valid=1
and d.datum BETWEEN "2019-10-10" AND "2200-01-01"
group by d.code
order by anzahl desc
\n'| sqlite3 -header "$sqldb_file"|grep -v '^$'|cut -d'|' -f 2-|awk -F"|" '{ printf "%-40s %s\n",$1,$2 }'
echo ""

