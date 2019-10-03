#! /bin/bash


sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_


printf 'select substr(datum,6,2) as ___monat,
sum(anzahl) as summe_bier_mate_zuckerlw
from drinks group by ___monat
\n'| sqlite3 -header -line "$sqldb_file"|grep -v '^$'
echo ""


printf 'select distinct(datum) as ""
from drinks
order by datum asc
\n' | sqlite3 -header -line "$sqldb_file"|grep -v '^$' \
| cut -d'=' -f2|tr -d ' ' \
| while read datum_day ; do

    echo
    echo "== $datum_day =="

    printf 'select printf("%%6d",d.anzahl),c.description as ""
    from drinks d,ean_codes c
    where d.datum='"'""$datum_day""'"'
    and d.code=c.code
    \n' | sqlite3 "$sqldb_file"|grep -v '^$'

    printf 'select printf("%%6d",sum(d.anzahl)), "===== Summe ==================" as ""
    from drinks d,ean_codes c
    where d.datum='"'""$datum_day""'"'
    and d.code=c.code
    \n' | sqlite3 "$sqldb_file"|grep -v '^$'


done



