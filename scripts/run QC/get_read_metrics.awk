#!/usr/bin/awk -f

BEGIN {
    FS = "\t"
    OFS = ","
    minq = 30
}

NR > 1 {
    sub(".*/", "", $1)
    sub("\\.fastq\\.*", "", $1)

    if ($6 >= minq && $9 >= cov){
	status = "pass"
	reason = "N/A"
    }
    else{
	status = "fail"
	if ($6 < minq){
	    reason = "low quality"
	    if ($9 < cov){
		reason = reason"| low coverage"
	    }
	}
	else{
	    reason = "low coverage"
	}
    }

    print $0, status, reason

}
