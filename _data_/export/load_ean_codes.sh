#! /bin/bash

sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"

# -------------------------------------
# see: https://opengtindb.org/index.php
# and: https://www.codecheck.info/so-gehts/start
# -------------------------------------

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_



# ======== functions =============
function add_to_sqldb
{
    cd "$_HOME_"
    mkdir -p "$sqldb_dir"

    printf 'delete from ean_codes where
        code='"'""$1""'"';
    \n' | sqlite3 -header -line "$sqldb_file" | grep -v '^$'

    printf 'insert into ean_codes (code,description,volume,valid,type) values
        ('"'""$1""'"','"'""$2""'"','"'""$3""'"','"'""$4""'"','"'""$5""'"')
    \n' | sqlite3 -header -line "$sqldb_file" | grep -v '^$'

}


# ======== functions =============

# -------- create stuff ----------
echo "create stuff"

cd "$_HOME_"
mkdir -p "$sqldb_dir"

printf 'create table IF NOT EXISTS ean_codes
(
code        TEXT NOT NULL,
description TEXT NOT NULL,
volume   INTEGER NOT NULL,
valid    INTEGER NOT NULL,
type        TEXT NOT NULL,
PRIMARY KEY (code)
);
\n'| sqlite3 -header -line "$sqldb_file" | grep -v '^$'

# -------- insert data in sqlite DB ----------
echo "insert data in sqlite DB"

cd "$_HOME_"

cat ean_codes.txt | while read codes_descr ; do

    valid=$(echo "$codes_descr"|cut -d":" -f 1 2>/dev/null)
    typ=$(echo "$codes_descr"|cut -d":" -f 2 2>/dev/null)
    vol=$(echo "$codes_descr"|cut -d":" -f 3 2>/dev/null)
    code=$(echo "$codes_descr"|cut -d":" -f 4 2>/dev/null)
    descr=$(echo "$codes_descr"|cut -d":" -f 5 2>/dev/null)
    echo "- code:""$code"" -> ""$vol""L ""$descr"

    if [ "$code""x" == "x" ]; then
        echo "-ERROR-"
    else
        if [ "$descr""x" == "x" ]; then
            echo "-ERROR-"
        else
            if [ "$vol""x" == "x" ]; then
                vol=0
            fi

            if [ "$valid""x" == "x" ]; then
                valid=0
            fi

            if [ "$typ""x" == "x" ]; then
                typ=z
            fi

            add_to_sqldb "$code" "$descr" "$vol" "$valid" "$typ" 2>/dev/null
        fi
    fi

    cd "$_HOME_"
done


