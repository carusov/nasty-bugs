#!/usr/bin/awk -f

BEGIN {
    FS = "\t"
    OFS = ","
    minq = 30
    min_avg_read_length = 230
}

NR > 1 {
    sub(".*/", "", $1)
    sub("\\.fastq\\.*", "", $1)

    if ($6 >= minq && $2 >= min_avg_read_length){
	status = "pass"
	reason = "N/A"
    }
    else{
	status = "fail"
	if ($6 < minq && $2 >= min_avg_read_length){
            reason = "low quality"
	}
	else if ($6 >= minq && $2 < min_avg_read_length){
	    reason = "low average read length"
	}
	else{
	    reason = "low quality low average read length"
	}
    }

    print $0, status, reason

}
