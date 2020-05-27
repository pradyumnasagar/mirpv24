#!/bin/bash
#######################################################
# Description :
# Following script is to run the miRPV pipeline
#
#
# Author: Pradyumna Jayaram and Vinayak Rao
# Date: (DD/MM/2020)
#
#
# Parameteres :
# Bash miRPV.sh <fasta_file>
#
########################################################
set -e
set -u
start=$(date +%s.%N)

source ~/.bashrc
#eval "$(conda shell.bash hook)"
conda activate py2

function usage
{
	echo "usage: bash miRPV.sh "
		echo "		Then enter the fasta file name "
	echo "   ";
	echo "  -fa | --fain			: fasta input of genome";
	echo "  -h  | --help			: Get help";
	echo "  -V  | --version		: Version ";
echo ""
echo ""
echo "By Pradyumna Jayraman and Vinayak Rao Copyright (C) 2020"
echo "Manipal School of Life Science Manipal. MAHE, 576104, India"
echo "Department of Cell and Molecular Biology, MSOLS, MAHE,"
echo "Departement of Bioinformatics, MSOLS, MAHE"
echo "Homepage:http:// slsdb.manipal.edu"
}

function version
{
echo ;	echo 'miRPV 1.0' ; echo
}

function parse_args
{
	# positional args
	args=()
	# named args
	while [ "$1" != "" ]; do
		case "$1" in
			-fa | --fain )           fain="$2";         shift ;;
			-V  | --version )        version;      shift ;;
			-h  | --help )           usage;             exit ;; # quit and show usage
			* )                      args+=("$1")               # if no match, add it to the positional args
		esac
		shift # move to next kv pair
	done
	# restore positional args
	set -- "${args[@]}"

	
	if [ -z "${fain}"]; then
		echo "Invalid arguments"
		usage
		exit;
	fi
	
}
function run
{
	parse_args "$@"

	echo "named arg: fain: $fain"
}
run "$@";

DIRECTORY=$(pwd)
echo "==================================================================="
figlet Welcome to miRPV Pipeline | lolcat
echo "==================================================================="



# Create Directory
mkdir -p $DIRECTORY/Output
mkdir -p $DIRECTORY/Output/mirpara
mkdir -p $DIRECTORY/Output/triplet_svm
mkdir -p $DIRECTORY/Output/maturebayes
mkdir -p $DIRECTORY/Output/miranda
mkdir -p $DIRECTORY/Output/miRPV_output

echo "Creating directory complete"
#echo "##########################################"
#echo "PLEASE ENTER THE FASTA FILE NAME"
#echo "##########################################"
#toilet HII
cowsay Please Enter the Fatsa file name | lolcat

read file

if [ -n "$file" ] ; then
	
	echo "1) Procesing the fasta file."
	echo `date`
	cp $file /$DIRECTORY/Script/ 
	cd  $DIRECTORY/Script/
	perl miRPara.pl $file
	cp *.out $DIRECTORY/Output/mirpara
	
echo "a) Converting miRPara output into Triplet_SVM input "

	sed '/^[[:blank:]]*#/d;s/#.*//' *.out > A1.txt
	awk '{print $1,$2}' A1.txt > A2.txt 
	awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' A2.txt > A3.txt
	sed 's/[A-Z]//g' A3.txt > A4.txt 
	sed -i '1~2 s/^/>/g' A4.txt
	awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' A4.txt > Pri_miRNA.txt
	RNAfold Pri_miRNA.txt > Secondary_Structure.txt
	cp Secondary_Structure.txt $DIRECTORY/Output/triplet_svm
	cp Pri_miRNA.txt $DIRECTORY/Output/miRPV_output
	cp Pri_miRNA.txt $DIRECTORY/Output/mirpara

echo "b)Converting miRPara output to get Mature_miRNA"

	sed '/^[[:blank:]]*#/d;s/#.*//' *.out > B1.txt
	awk '{print $3,$4}' B1.txt > B2.txt 
	awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' B2.txt > B3.txt
	sed -i '1~2 s/^/>/g' B3.txt
	awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' B3.txt > Mature_miRNAs.txt
	cp Mature_miRNAs.txt $DIRECTORY/Output/miranda
	
	rm -f A1.txt A2.txt A3.txt A4.txt B1.txt B2.txt B3.txt

echo "2) Procced to find the Real or Psudo Pri-miRNA"
	
	perl triplet_svm_classifier.pl Secondary_Structure.txt predict_format.txt 22
	#mv predict_format.txt $DIRECTORY/Script/libsvm-3.24
	#svm-predict predict_format.txt trainset_hsa163_cds168_unite.txt.model predict_result.txt
	#mv predict_format.txt predict_result.txt $DIRECTORY/Output/triplet_SVM
	#cd $DIRECTORY/Script
	mv 2.txt Real_miRNA.txt	
	RNAeval -v Real_miRNA.txt > Mature_Secondary_Structure.txt	
	cp Real_miRNA.txt Mature_Secondary_Structure.txt $DIRECTORY/Output/miRPV_output
	cp Real_miRNA.txt Mature_Secondary_Structure.txt $DIRECTORY/Output/maturebayes
	cp Real_miRNA.txt $DIRECTORY/Output/triplet_svm

echo "3) Next Step is to find Mature miRNA using Pri-miRNA"

echo `date`
	
	python matureBayes.py Real_miRNA.txt Mature_Secondary_Structure.txt Mature_miRNA.txt
	cp Mature_miRNA.txt $DIRECTORY/Output/maturebayes
	mv Mature_miRNA.txt $DIRECTORY/Output/miRPV_output

echo "4) Final micro-RNA target prediction"
	miranda Mature_miRNAs.txt sequence.fasta > Target.txt
	cp Target.txt $DIRECTORY/Output/miRPV_output
	mv Target.txt $DIRECTORY/Output/miranda
	rm -f 1.txt Mature_miRNAs.txt Mature_Secondary_Structure.txt Secondary_Structure.txt Pri_miRNA.txt *.out *.ps *.pmt *.fa Real_miRNA.txt

echo "5) Converting miRPV Output Into final Report"
	cd $DIRECTORY/Output/miRPV_output
	sed -i '1s/^/\n\n\n=========================================================================================\n\n2)"Pri-miRNAs obtain from the fasta file"\n\n/' Pri_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n2)"Real mi-RNAs and there Secondary Structure"\n\n/' Real_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n2)"Mature miRNAs"\n\n/' Mature_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n2)"Target.miRNAs"\n\n/' Target.txt

	grep -c ">" Pri_miRNA.txt > Pri.txt
	grep -c ">" Real_miRNA.txt > Real.txt
	grep -c ">" Mature_miRNA.txt > Mat.txt
	grep -c ">" Target.txt > Tar.txt
	
	sed -i '1s/^/Unique Pri-miRNA found in the sequence: /' Pri.txt
	sed -i '1s/^/Unique Real-miRNA found in the sequence: /' Real.txt
	sed -i '1s/^/Unique Mature-miRNA found in the sequence: /' Mat.txt
	sed -i '1s/^/Unique Target-miRNA found in the sequence: /' Tar.txt
	
	cat Pri.txt Real.txt Mat.txt Tar.txt > Sum.txt 
	touch Intro.txt
	echo "#miRNAs result by miRPV Pipeline " > Intro.txt
	echo "#By Pradyumna Jayaram and Vinayak Rao" >> Intro.txt 
	echo "#Reporting bugs to mlsc@manipal.edu" >> Intro.txt
	echo "#Manipal Academy of Higher Education Manipal, MAHE INDIA" >> Intro.txt
	echo "#Manipal School of Life Sciences Maniapl " >>  Intro.txt
	echo "#Departement of Cell and Molecular Biology " >> Intro.txt
	echo "#Departement of Bioinformatics MAHE " >> Intro.txt
	echo "#Homepage:http:// slsdb.manipal.edu" >> Intro.txt
	echo "#Facebook: Add Us " >> Intro.txt


	sed -i '1s/^/\nSUMMARY OF THE miRPV PIPELINE: \n\n /' Sum.txt

	cat Intro.txt Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Target.txt > miRPV_Output

	enscript miRPV_Output -o - | ps2pdf - miRPV_Out.pdf
	#unoconv -f pdf miRPV_Output 
	rm -f Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Target.txt Pri.txt Real.txt Mat.txt Tar.txt Mature_Secondary_Structure.txt Intro.txt miRPV_Output
	
	
sl


figlet Pipline is completed | lolcat
echo `date`

else
	echo "Input file is not a fasta file"
fi
echo "Pipeline is completed Please find the result in the output folder in miRPV Directory"
duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`

echo "Pipelline Execution Time: $execution_time"










	

