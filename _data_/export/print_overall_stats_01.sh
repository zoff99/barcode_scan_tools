#! /bin/bash


sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_


days_span=$(printf 'select julianday(max(d.datum)) - julianday(min(d.datum)) as _days_
from drinks d, ean_codes c
where d.code=c.code
and c.valid=1
and d.datum BETWEEN "2019-10-05" AND "2200-01-01"
\n'| sqlite3 -header "$sqldb_file"|grep -v '^$'|tail -1|tr -dc '[0-9.,]' 2>/dev/null|tr ',' '.')

echo ""
echo ""
echo ""
echo ""

echo "====================================================================="
echo "Verbrauch pro 30 Tage (mit Daten der letzten $days_span Tage)"
echo "====================================================================="

echo ""
printf 'select distinct(d.code), c.description as desc, c.per_crate as pc,
CAST(
(
((
(sum(d.anzahl) * 30.0 / '"$days_span"' / c.per_crate )
) * 10
+ 5 )
/ 10 )
as INTEGER
)
as kisten
from drinks d, ean_codes c
where d.code=c.code
and c.valid=1
and d.datum BETWEEN "2019-10-05" AND "2200-01-01"
group by d.code
order by kisten desc
\n'| sqlite3 -header "$sqldb_file"|grep -v '^$'|cut -d'|' -f 2-|awk -F"|" '{ printf "%-45s %s\n",$1,$3 }'

echo "-----------------------------------------------------"

printf '
select cast(sum(a.nums) as INTEGER) as "SUMME Kisten pro 30 Tage" from
(
select
(
CAST(
(
(sum(d.anzahl) * 30.0 / '"$days_span"' / c.per_crate )
)
as FLOAT
)
) as nums
from drinks d, ean_codes c
where d.code=c.code
and c.valid=1
and d.datum BETWEEN "2019-10-05" AND "2200-01-01"
group by d.code
) a
\n'| sqlite3 -header "$sqldb_file"|grep -v '^$'|cut -d'|' -f 2-|awk -F"|" '{ printf "%-45s %s\n",$1,$3 }'
echo ""




echo "====================================================================="
echo "Verbrauch der letzten $days_span Tage"
echo "====================================================================="


echo ""
printf 'select distinct(d.code), c.description as desc, sum(d.anzahl) as flaschen
from drinks d, ean_codes c
where d.code=c.code
and c.valid=1
and d.datum BETWEEN "2019-10-05" AND "2200-01-01"
group by d.code
order by flaschen desc
\n'| sqlite3 -header "$sqldb_file"|grep -v '^$'|cut -d'|' -f 2-|awk -F"|" '{ printf "%-45s %s\n",$1,$2 }'
echo ""

