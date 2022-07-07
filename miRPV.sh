#!/bin/bash
#######################################################
# Description :
# Following script is to run the miRPV pipeline
#
#
# Author: Pradyumna Jayaram,  Vinayak Rao and Kapaettu Satyamoorthy
#
#
# Parameteres :
# Bash miRPV.sh <fasta_file>
#
########################################################
set -e
set -u
start=$(date +%s.%N)

#source ~/.bashrc
#eval "$(conda shell.bash hook)"
#conda activate py2

usage(){
cat << EOF
usage: $0 
	Type the fasta file name:
Required:
	-i | --infile 	Input fasta file
Options:
	-h | --help	Show this message
	
File 
*.fasta, --Only fasta format sequences are allowed
#By Pradyumna Jayraman and Vinayak Rao Copyright (C) 2020
Manipal Scchool of Life Science Manipal.MAHE, 576104, India
Department of Cell and Molecular Biology, MSOLS, MAHE,
Departement of Bioinformatics, MSOLS, MAHE.
Homepage:http://slsdb.manipal.edu
 
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
		i) infile="$OPTARG"  ;;
		h) usage ; exit 0  ;;
	esac
done


DIRECTORY=$(pwd)
echo "=================================================================================================================================================================================================="
figlet Welcome to miRPV Pipeline | pv -qL 160 #| lolcat 
echo "=================================================================================================================================================================================================="

echo "Please give the project name" | lolcat
read text
# Create Directory
mkdir -p $DIRECTORY/Output/
mkdir -p $DIRECTORY/log
mkdir -p $DIRECTORY/Output/$text/mirpara
mkdir -p $DIRECTORY/Output/$text/triplet_svm
mkdir -p $DIRECTORY/Output/$text//maturebayes
mkdir -p $DIRECTORY/Output/$text/miranda
mkdir -p $DIRECTORY/Output/$text/miRPV_output
mkdir -p $DIRECTORY/Output/$text/hairplendex

echo "Creating directory complete" 
#echo "##########################################"
#echo "PLEASE ENTER THE FASTA FILE NAME"
#echo "##########################################"
#toilet HII | pv -qL 120 | lolcat
cowsay Lets find some miRNAs!!! | lolcat 
echo "Please enter the fasta file name here" | pv -qL 20 

read inpute

if [ -n "$inpute" ] ; then
	
	echo "1) Processing to find Pri-miRNA" | pv -qL 20 | tee -a $DIRECTORY/log/$text.log
	
	cp $inpute /$DIRECTORY/Script/ 
	cd $DIRECTORY/build/miRPara/
	cp -R models $DIRECTORY/Script
	cd  $DIRECTORY/Script/
	perl miRPara.pl -t 12 $inpute 
	cp *.out $DIRECTORY/Output/$text/mirpara

	
echo "	a) Converting miRPara output into Triplet_SVM input " | tee -a $DIRECTORY/log/$text.log
				 echo `date` 

	sed '/^[[:blank:]]*#/d;s/#.*//' *.out > A1.txt
	awk '{print $1,$2}' A1.txt > A2.txt 
	awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' A2.txt > A3.txt
	sed 's/[A-Z]//g' A3.txt > A4.txt 
	sed -i '1~2 s/^/>/g' A4.txt
	awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' A4.txt > Pri_miRNA.txt
	RNAfold Pri_miRNA.txt > Secondary_Structure.txt
	cp Secondary_Structure.txt $DIRECTORY/Output/$text/triplet_svm
	cp Pri_miRNA.txt $DIRECTORY/Output/$text/miRPV_output
	cp Pri_miRNA.txt $DIRECTORY/Output/$text/mirpara
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

echo "	b)Converting miRPara output to get Mature_miRNA"  | tee -a $DIRECTORY/log/$text.log
				 echo `date` 

	sed '/^[[:blank:]]*#/d;s/#.*//' *.out > B1.txt
	awk '{print $3,$4}' B1.txt > B2.txt 
	awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' B2.txt > B3.txt
	sed -i '1~2 s/^/>/g' B3.txt
	awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' B3.txt > Mature_miRNAs.txt
	cp Mature_miRNAs.txt $DIRECTORY/Output/$text/miranda
	
	rm -f A1.txt A2.txt A3.txt A4.txt B1.txt B2.txt B3.txt A6.txt
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "2) Procced to find the Real or Psudo Pri-miRNA" | pv -qL 20  | tee -a $DIRECTORY/log/$text.log
	
	perl triplet_svm_classifier.pl Secondary_Structure.txt predict_format.txt 22
	
	#cd $DIRECTORY/Script
	mv 2.txt Real_miRNA.txt	
	RNAeval -v Real_miRNA.txt > Mature_Secondary_Structure.txt	
	cp Real_miRNA.txt Mature_Secondary_Structure.txt $DIRECTORY/Output/$text/miRPV_output
	cp Real_miRNA.txt Mature_Secondary_Structure.txt $DIRECTORY/Output/$text/maturebayes
	cp Real_miRNA.txt $DIRECTORY/Output/$text/triplet_svm 
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


echo "	c)Converting real-miRNA output to HAIRPLENDEX input"  | tee -a $DIRECTORY/log/$text.log
date 
	RNAfold Real_miRNA.txt > A5.txt
	awk '{printf "%s%s",$0,(NR%3?FS:RS)}' A5.txt > Hairplendex.txt
	#awk '$2 = toupper($2)' A6.txt > Hairplendex.txt
	cp Hairplendex.txt  $DIRECTORY/Output/$text/hairplendex
	mv Hairplendex.txt  $DIRECTORY/build/file
	#rm -f A5.txt

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

	sed -i -e 's/^/-1 /' predict_format.txt
	mv predict_format.txt $DIRECTORY/build/libsvm-3.14
	cd $DIRECTORY/build/triplet-svm-classifier060304/models
	cp trainset_hsa163_cds168_unite.txt.model $DIRECTORY/build/libsvm-3.14
	cd $DIRECTORY/build/libsvm-3.14
	svm-predict predict_format.txt trainset_hsa163_cds168_unite.txt.model predict_result.txt
	mv predict_format.txt predict_result.txt $DIRECTORY/Output/$text/triplet_svm


echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		
echo `date`
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "3) Feature Extraction of Pri-miRNAs" | pv -qL 20  | tee -a $DIRECTORY/log/$text.log
	cd $DIRECTORY/build/file
	 ./run_Fold_generator.sh /usr/local/MATLAB/MATLAB_Runtime/v98 Hairplendex
	 ./run_Hairpindex_miRNA_analyzer.sh /usr/local/MATLAB/MATLAB_Runtime/v98 Hairplendex
	rm -f Hairplendex.mat Hairplendex.txt
	mv Hairplendex_v_1_1.txt $DIRECTORY/Output/$text/miRPV_output

echo `date`

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "4) Procced to find Mature miRNA using Pri-miRNA" | pv -qL 20 | tee -a $DIRECTORY/log/$text.log

echo `date`
	cd $DIRECTORY/Script/
	python matureBayes.py Real_miRNA.txt Mature_Secondary_Structure.txt Mature_miRNA.txt
	cp Mature_miRNA.txt $DIRECTORY/Output/$text/maturebayes
	mv Mature_miRNA.txt $DIRECTORY/Output/$text/miRPV_output
	
echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

if (dialog --title "Message" --defaultno --yesno  "Want to predict Target of Mature miRNA? (If yes please keep the refrence sequence in the folder " 7 60)
# message box will have the size  60x7 characters

then 
	cd $DIRECTORY/
	echo "======================================================="
	echo "Please enter the Reference Sequence name"
	echo "======================================================="
	read reference
		if [ -n "$reference" ] ; then
			echo "5) Final micro-RNA target prediction" | pv -qL 20  | tee -a $DIRECTORY/log/$text.log
			date
			cp $reference /$DIRECTORY/Script/
			cd $DIRECTORY/Script/	
			miranda Mature_miRNAs.txt $reference -trim T > Target.txt
			cp Target.txt $DIRECTORY/Output/$text/miRPV_output
			mv Target.txt $DIRECTORY/Output/$text/miranda
			rm -f 1.txt Mature_miRNAs.txt Mature_Secondary_Structure.txt Secondary_Structure.txt Pri_miRNA.txt *.out *.ps *.pmt *.fa Real_miRNA.txt *.fasta
		else
			echo "The Reference file not found. Please keep the file in miRPV folder "
		fi

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "6) Converting miRPV Output Into final Report" 
	cd $DIRECTORY/Output/$text/miRPV_output
	sed -i '1s/^/\n\n\n=========================================================================================\n\n1)"Pri-miRNAs obtain from the fasta file"\n\n/' Pri_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n2)"Real mi-RNAs and there Secondary Structure"\n\n/' Real_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n3)"Mature miRNAs"\n\n/' Mature_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n4)"Target.miRNAs"\n\n/' Target.txt

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
#	echo "#By Pradyumna Jayaram and Vinayak Rao" >> Intro.txt 
	echo "#Reporting bugs to mlsc@manipal.edu" >> Intro.txt
	echo "#Manipal Academy of Higher Education Manipal, MAHE INDIA" >> Intro.txt
	echo "#Manipal School of Life Sciences Maniapl " >>  Intro.txt
	echo "#Departement of Cell and Molecular Biology " >> Intro.txt
	echo "#Departement of Bioinformatics MAHE " >> Intro.txt
	echo "#Homepage:http://slsdb.manipal.edu" >> Intro.txt
	

	sed -i '1s/^/\nSUMMARY OF THE miRPV PIPELINE: \n\n /' Sum.txt

	cat Intro.txt Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Target.txt > miRPV_Output

	enscript miRPV_Output -o - | ps2pdf - miRPV_Out.pdf
	#unoconv -f pdf miRPV_Output 
	mv Hairplendex_v_1_1.txt Pri-miRNA_Features.xls
	cp Pri-miRNA_Features.xls $DIRECTORY/Output/$text/hairplendex
	rm -f Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Target.txt Pri.txt Real.txt Mat.txt Tar.txt Mature_Secondary_Structure.txt Intro.txt miRPV_Output 
		

else
	
	rm -f 1.txt Mature_miRNAs.txt Mature_Secondary_Structure.txt Secondary_Structure.txt Pri_miRNA.txt *.out *.ps *.pmt *.fa Real_miRNA.txt	
	echo "Converting miRPV Output Into final Report Without Target"  
	cd $DIRECTORY/Output/$text/miRPV_output
	sed -i '1s/^/\n\n\n=========================================================================================\n\n1)"Pri-miRNAs obtain from the fasta file"\n\n/' Pri_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n2)"Real mi-RNAs and there Secondary Structure"\n\n/' Real_miRNA.txt
	sed -i '1s/^/\n\n\n=========================================================================================\n\n3)"Mature miRNAs"\n\n/' Mature_miRNA.txt

	grep -c ">" Pri_miRNA.txt > Pri.txt
	grep -c ">" Real_miRNA.txt > Real.txt
	grep -c ">" Mature_miRNA.txt > Mat.txt

	sed -i '1s/^/Unique Pri-miRNA found in the sequence: /' Pri.txt
	sed -i '1s/^/Unique Real-miRNA found in the sequence: /' Real.txt
	sed -i '1s/^/Unique Mature-miRNA found in the sequence: /' Mat.txt

	cat Pri.txt Real.txt Mat.txt > Sum.txt 
	touch Intro.txt
	{
	echo "miRNAs prediction by miRPV Pipeline " 
#	echo "#By Pradyumna Jayaram and Vinayak Rao" 
	echo "Report bugs to mlsc@manipal.edu" 
	echo "Departement of Cell and Molecular Biology" 
	echo "Manipal School of Life Sciences Maniapl" 
	echo "Manipal Academy of Higher Education, Manipal, INDIA" 
	
	
	echo "Homepage: http://slsdb.manipal.edu" 
	} >> Intro.txt

	sed -i '1s/^/\nSUMMARY OF THE miRPV PIPELINE:\n\n/' Sum.txt
	cat Intro.txt Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt  > miRPV_Output

	enscript miRPV_Output -o - | ps2pdf - miRPV_Out.pdf
	#unoconv -f pdf miRPV_Output 
	mv Hairplendex_v_1_1.txt Pri-miRNA_Features.xls
	cp Pri-miRNA_Features.xls $DIRECTORY/Output/$text/hairplendex
	rm -f Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Pri.txt Real.txt Mat.txt Mature_Secondary_Structure.txt Intro.txt miRPV_Output	
	


fi

sl

figlet Prediction Complete | pv -qL 120 | lolcat 
date

else
	echo "Input file is not a fasta file"
fi
echo "Thank You for using miRPV" | pv -qL 20 
echo ""
echo "Please find the reults in Output directory"
echo ""
duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`

echo "Pipelline Execution Time: $execution_time"
	

