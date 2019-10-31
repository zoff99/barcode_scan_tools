#! /bin/bash


sqldb_dir="./sqldb/"
sqldb_file="$sqldb_dir"/"geiger.sqlite"

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

if [ "$1""x" == "x" ]; then
    echo "Usage: $0 <YYYY-MM>"
    exit 1
fi


month="$(echo "$1"|cut -d"-" -f2)"
year="$(echo "$1"|cut -d"-" -f1)"
monat_long_name="$(date -d "$year/$month/01" +%B)"

case $month in
    0[13578]|10|12) days=31;;
    0[469]|11)	    days=30;;
    *)	(( year % 400 )) && days=29 || days=28
esac

#           2019-09-01 | Bier    0 | Mate    0 | ZWasser    0
    printf '                                                  \n'
    printf '           | Bier      | Mate      | ZWasser      \n'
    printf '__________________________________________________\n'

echo '
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="./stylesheet.css" charset="utf-8">
<style>
table, th, td {
  border: 2px solid black;
  border-collapse: collapse;
}
</style>
<style type="text/css">
	.td2 {
	font-family: 'tally_markregular';
    font-size: 35px;
	}
</style>
</head>
<body>

<font size="3">
<table width="100%" border="1">
    <tr width="100%">
        <td width="15%"><font size="4"><b>'"$monat_long_name"'</b></font></td>
        <td><font size="4"><b>Bier</b></font></td>
        <td><font size="4"><b>Mate</b></font></td>
        <td><font size="4"><b>ZWasser</b></font></td>
    </tr>
    <tr>' > templist.html


for (( c=1; c<=$days; c++ )); do

    day="$c"
    if [ $c -lt 10 ]; then
        day="0""$c"
    fi

    cur_datum="$year""-""$month""-""$day"
    # echo "== $cur_datum =="

    b_count=$(printf 'select sum(d.anzahl) as ""
    from drinks d, ean_codes c
    where d.datum='"'""$cur_datum""'"'
    and c.type='"'"'b'"'"'
    and c.code=d.code
    and c.valid='"'"'1'"'"'
    \n' | sqlite3 "$sqldb_file"|grep -v '^$')

    if [ "$b_count""x" == "x" ]; then
        b_count=0
    fi

    m_count=$(printf 'select sum(d.anzahl) as ""
    from drinks d, ean_codes c
    where d.datum='"'""$cur_datum""'"'
    and c.type='"'"'m'"'"'
    and c.code=d.code
    and c.valid='"'"'1'"'"'
    \n' | sqlite3 "$sqldb_file"|grep -v '^$')

    if [ "$m_count""x" == "x" ]; then
        m_count=0
    fi

    z_count=$(printf 'select sum(d.anzahl) as ""
    from drinks d, ean_codes c
    where d.datum='"'""$cur_datum""'"'
    and c.type='"'"'z'"'"'
    and c.code=d.code
    and c.valid='"'"'1'"'"'
    \n' | sqlite3 "$sqldb_file"|grep -v '^$')

    if [ "$z_count""x" == "x" ]; then
        z_count=0
    fi

    printf '%s |    %4d   |    %4d   |   %4d\n' "$cur_datum" "$b_count" "$m_count" "$z_count"


    echo -n ' 
        <td><font size="4"><b>'"$cur_datum"'</b></font></td>
        <td class="td2"><b>' >> templist.html

    if [ $m_count != 0 ]; then
        fives=$(($b_count / 5))
        ones=$(($b_count % 5))

        for (( y=1; y<=$fives; y++ )); do
            echo -n 'E' >> templist.html
        done

        if [ $fives == 0 ]; then
            echo -n '<span style="padding-left:3px">' >> templist.html
        fi

        for (( y=1; y<=$ones; y++ )); do
            echo -n 'A' >> templist.html
        done
    fi

    echo '</b></td>' >> templist.html
    echo -n '        <td class="td2"><b>' >> templist.html

    if [ $m_count != 0 ]; then
        fives=$(($m_count / 5))
        ones=$(($m_count % 5))

        for (( y=1; y<=$fives; y++ )); do
            echo -n 'E' >> templist.html
        done

        if [ $fives == 0 ]; then
            echo -n '<span style="padding-left:3px">' >> templist.html
        fi

        for (( y=1; y<=$ones; y++ )); do
            echo -n 'A' >> templist.html
        done
    fi

    echo '</b></td>' >> templist.html
    echo -n '        <td class="td2"><b>' >> templist.html

    if [ $m_count != 0 ]; then
        fives=$(($z_count / 5))
        ones=$(($z_count % 5))

        for (( y=1; y<=$fives; y++ )); do
            echo -n 'E' >> templist.html
        done

        if [ $fives == 0 ]; then
            echo -n '<span style="padding-left:3px">' >> templist.html
        fi

        for (( y=1; y<=$ones; y++ )); do
            echo -n 'A' >> templist.html
        done
    fi

    echo '</b></td>' >> templist.html
    echo '</tr>' >> templist.html

done


echo '
</table>
</font>
</body>
</html>
' >> templist.html
