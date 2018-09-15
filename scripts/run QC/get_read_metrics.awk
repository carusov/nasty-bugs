#!/usr/bin/awk -f

BEGIN {
    FS = "\t"
    OFS = ","
    minq = 30
    min_avg_read_length = 200
}

NR > 1 {
    sub(".*/", "", $1)
    sub("\\.fastq\\.*", "", $1)

    if ($6 >= minq && $9 >= cov && $2 >= min_avg_read_length){
	status = "pass"
	reason = ""
    }
    else {
	status = "fail"
	if ($6 < minq && $9 >= cov && $2 >= min_avg_read_length){
		reason = "low quality"
	}
	else if ($6 < minq && $9 >= cov && $2 <  min_avg_read_length){
		reason = "low quality low average read length"
	}
	else if ($6 >= minq && $9 >= cov && $2 <  min_avg_read_length){
		reason = "low average read length"
	}
    	else if ($6 >= minq && $9 < cov && $2 < min_avg_read_length){
		reason = "low coverage low average read length"
    	}
	else if ($6 <  minq && $9 < cov && $2 >= min_avg_read_length){
		reason = "low quality low coverage"
	}
	else{
		reason = "low coverage"
	}
    }

    print $0, status, reason
}
