#!/usr/bin/awk -f

BEGIN {
    FS = "\t"
    OFS = ","
    minq = 30
}

NR > 1 {
    sub(".*/", "", $1)
    sub("\\.fastq\\.*", "", $1)

    if ($6 >= minq){
	status = "pass"
	reason = "N/A"
    }
    else{
	status = "fail"
	reason = "low quality"
    }

    print $0, status, reason

}
