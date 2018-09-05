#!/usr/bin/awk -f

BEGIN {
    FS = ","
    OFS = "\t"
}

/^\[Data\]/ {
    data = 1
}

{
    if (header == 1)
	print $9, $1
}

/^Sample_ID/ {
    if (data == 1)
	header = 1
}

