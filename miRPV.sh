#!/bin/bash
#######################################################
# Description :
# Following script is to run the miRPV pipeline
#
#
# Author: Pradyumna Jayaram (pradyumna.j.ram@gmail.com)
# Date: (DD/MM/2020)
#
#
# Parameteres :
# Bash miRPV.sh <fasta_file>
#
########################################################
set -e
set -u

usage(){
cat << EOF

usage: $0 
	ii give the fasta file name

Required:
	-i | --infile 	Input fasta file

Options:
	-h | --help	Show this message

File 
*.fasta, --Only fasta format sequences are allowed

By Pradyumna Jayraman (@gmail.com) and Vinayak Rao (@gmail.com) Copyright (C) 2020

Manipal Scchool of Life Science Manipal. Manipal, 576104, India
Department of Cell and Molecular Biology MAHE,
Departement of Bioinformatics MAHE.

Homepage: 
Faceebook:
Instagram
Snapchat:
 

EOF
}

for arg in "$@"; do 
	shift
	case "$arg" in
		"--help")	set -- "$@" "-h"  ;;
		"--infile")	set -- "$@" "-i"  ;;
		*)		set -- "$@" "$arg"  ;;
	esac
done

while getopts "hi:o:" OPTION ;do
	case $OPTION in
		i) infile=$OPTARG  ;;
		h) usage ; exit 0  ;;
	esac
done

# Create Directory
mkdir -p $output_dir
mkdir -p $output_dir/mirpara
mkdir -p $output_dir/triplet_svm
mkdir -p $output_dir/maturebayes
mkdir -p $output_dir/miranda
mkdir -p $output_dir/miRPV_output

echo "creating directory complete"


echo "Please give the fasta file"
read file

if [ -n "$file" ] ; then
	
	echo "1) Procesing the fasta file"
	cp $file /$SCRIPT_DIRECTORY/
	cd  $SCRIPT_DIRECTORY/
	perl miRPara.pl $file
	cp *.out ~/$output_dir/mirpara
	
echo "a) Converting miRPara output into Triplet_SVM input"

	sed '/^[[:blank:]]*#/d;s/#.*//' *.out > A1.txt
	awk '{print $1,$2}' A1.txt > A2.txt 
	awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' A2.txt > A3.txt
	sed 's/[A-Z]//g' A3.txt > A4.txt 
	sed -i '1~2 s/^/>/g' A4.txt
	awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' A4.txt > Pri_miRNA.txt
	RNAfold Pri_miRNA.txt > Secondary_Structure.txt
	RNAeval -v Secondary_Structure.txt > Mature_Secondary_Structure.txt
	cp Secondary_Structure.txt $output_dir/triplet_svm
	cp Pri_miRNA.txt Mature_Secondary_Structure.txt $output_dir/maturebayes
	cp Pri_miRNA.txt Mature_Secondary_Structure.txt $output_dir/miRPV_output

echo "b)Converting miRPara output to get Mature_miRNA"

	sed '/^[[:blank:]]*#/d;s/#.*//' *.out > B1.txt
	awk '{print $3,$4}' B1.txt > B2.txt 
	awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' B2.txt > B3.txt
	sed -i '1~2 s/^/>/g' B3.txt
	awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' B3.txt > Mature_miRNA.txt
	cp Mature_miRNA.txt $output_dir/miranda
	
	rm -f A1.txt A2.txt A3.txt A4.txt B1.txt B2.txt B3.txt

echo "2) Procced to find the Real or Psudo Pri-miRNA"
	
	perl triplet_svm_classifier.pl Secondary_Structure.txt predict_format.txt 
	#mv predict_format.txt ~/Downloads/miRPv/Scriptlibsvm-3.24
	#svm-predict predict_format.txt trainset_hsa163_cds168_unite.txt.model predict_result.txt
	mv 2.txt Real_miRNA.txt		
	cp Real_miRNA.txt $output_dir/miRPV_output
	mv Real_miRNA.txt $output_dir/miranda

echo "3) Next Step is to find Mature miRNA using Pri-miRNA"
	
	python matureBayes.py A5.txt Mature_Secondary_Structure.txt Mature_miRNA.txt
	cp Mature_miRNA.txt $output_dir/maturebayes
	mv Mature_miRNA.txt $output_dir/miRPV_output

echo " 4) Final micro-RNA target prediction"
	miranda Mature_miRNA.txt sequence.fasta > Target.txt
	cp Target.txt $output_dir/miRPV_output
	mv Target.txt $output_dir/miranda
	rm -f 1.txt Mature_miRNA.txt Mature_Secondary_Structure.txt Secondary_Strucuture.txt 

echo "Pipeline is completed  !!!!!\n Please find the result in the output folder in miRPV Directory"

else
	echo "Input file is not a fasta file"
fi










	

