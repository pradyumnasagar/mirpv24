#!/usr/bin/perl -w
$starttime=time();

$input_file_1 = $ARGV[0];
$input_file_2 = $ARGV[1];
$input_parameter_1 = $ARGV[2];

print "1 step: check if the queries contains other characters except ACGU...\n";
if( system ("perl 1_check_query_content.pl $input_file_1 1.txt") ){
	print "Fatal Error : in 1_check_query_content.pl\n";
	exit(1);
}

print "2 step: check if the queries contains multiple loops...\n";
if( system ("perl 2_get_stemloop.pl 1.txt 2.txt $input_parameter_1") ){
	print "Fatal Error : in 2_get_miRNAs_without_multiple_loops.pl\n";
	exit(1);
}

print "3 step: coding queries as triplet elements...\n";
if( system ("perl 3_step_triplet_coding_for_queries.pl 2.txt 3.txt") ){
	print "Fatal Error : in 3_step_triplet_coding_for_queries.pl\n";
	exit(1);
}

print "4 step: make a format file for libsvm to carry out prediction...\n";
if( system ("perl 4_libsvm_format.pl 3.txt $input_file_2") ){
	print "Fatal Error : in 4_libsvm_format.pl\n";
	exit(1);
}
print "5 step: delete temp files\n";
system ("rm -f 3.txt");

$complete_time = time()-$starttime;
print "Run Completed $complete_time seconds\n";
print "done!\n";
#######################################
