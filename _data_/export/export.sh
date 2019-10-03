#! /bin/bash

sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"
export_data_dir="../db/"

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_



# ======== functions =============
function read_uint32_from_binfile
{
    pos=0
    ret=0
    head -c4 "$1" | hexdump -v -e '/1 "%u\n"' 2>/dev/null | while read c; do
        mul=0
        if [ $pos -eq 1 ]; then
            mul=8
        elif [ $pos -eq 2 ]; then
            mul=16
        elif [ $pos -eq 3 ]; then
            mul=24
        fi
        # echo $c
        addon=$(($c<<$mul))
        # echo "addon=""$addon"
        ret=$[ $ret + $addon ]
        if [ $pos -eq 3 ]; then
            echo "$ret"
        fi
        pos=$[ $pos + 1 ]
    done
}

function add_to_sqldb
{
    cd "$_HOME_"
    mkdir -p "$sqldb_dir"

    printf 'delete from drinks where
        datum='"'""$1""'"' and
        code='"'""$2""'"';
    \n' | sqlite3 -header -line "$sqldb_file" | grep -v '^$'

    printf 'insert into drinks (datum,code, anzahl) values
        ('"'""$1""'"','"'""$2""'"','"'""$3""'"')
    \n' | sqlite3 -header -line "$sqldb_file" | grep -v '^$'

}


# ======== functions =============

# -------- create stuff ----------
echo "create stuff"

cd "$_HOME_"
mkdir -p "$sqldb_dir"

printf 'create table IF NOT EXISTS drinks
(
datum     TEXT NOT NULL,
code      TEXT NOT NULL,
anzahl INTEGER NOT NULL,
PRIMARY KEY (datum, code)
);
\n'| sqlite3 -header -line "$sqldb_file" | grep -v '^$'

# -------- insert data in sqlite DB ----------
echo "insert data in sqlite DB"

cd "$_HOME_"
cd "$export_data_dir"

ls -1 | while read datedir ; do
    echo "- date:""$datedir"

    cd "$_HOME_"
    cd "$export_data_dir"
    cd "$datedir""/"
    ls -1 | while read code ; do
        echo -n "  + code:""$code -> "

        amount="$(read_uint32_from_binfile "$code" 2>/dev/null)"
        if [ "$amount" -gt "4000" ]; then
            echo "-ERROR-"
        else
            echo "$amount"
            add_to_sqldb "$datedir" "$code" "$amount" 2>/dev/null
        fi

        cd "$_HOME_"
        cd "$export_data_dir"
        cd "$datedir""/"
    done
done


