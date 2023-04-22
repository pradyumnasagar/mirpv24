#!/bin/bash

#######################################################
# Description:
# This script runs the miRPV pipeline.
#
# Author: Pradyumna Jayaram, Vinayak Rao, and Kapaettu Satyamoorthy
#
# Parameters:
# Bash miRPV.sh <fasta_file>
#
########################################################

set -e
set -u

start=$(date +%s.%N)
echo "Start time: $(date)"

usage(){
cat << EOF
Usage: $0 
  Type the fasta file name:
Required:
  -i | --infile 	Input fasta file
Options:
  -h | --help	Show this message

File 
*.fasta, --Only fasta format sequences are allowed

By Pradyumna Jayraman and Vinayak Rao
Copyright (C) 2020 Manipal School of Life Science
Manipal.MAHE, 576104, India
Department of Cell and Molecular Biology, MSOLS, MAHE,
Department of Bioinformatics, MSOLS, MAHE.
Homepage: http://slsdb.manipal.edu
EOF
}

# Parse arguments
for arg in "$@"; do
  shift
  case "$arg" in
    "--help")	set -- "$@" "-h" ;;
    "--infile")	set -- "$@" "-i" ;;
    *)			set -- "$@" "$arg" ;;
  esac
done

# Handle options
while getopts "hi:o:" OPTION; do
  case $OPTION in
    i) infile="$OPTARG" ;;
    h) usage ; exit 0 ;;
    *) usage ; exit 1 ;;
  esac
done
# Create necessary directories
DIRECTORY=$(pwd)
echo "Creating directories..."
mkdir -p "$DIRECTORY"/Output/
mkdir -p "$DIRECTORY"/log
mkdir -p "$DIRECTORY"/Output/"$text"/mirpara
mkdir -p "$DIRECTORY"/Output/"$text"/triplet_svm
mkdir -p "$DIRECTORY"/Output/"$text"/maturebayes
mkdir -p "$DIRECTORY"/Output/"$text"/miranda
mkdir -p "$DIRECTORY"/Output/"$text"/miRPV_output
mkdir -p "$DIRECTORY"/Output/"$text"/hairplendex
echo "Directories created."
MATLAB_RUNTIME_PATH="/usr/local/MATLAB/MATLAB_Runtime/v98"

echo "=================================================================================================================================================================================================="
figlet "Welcome to miRPV Pipeline" | pv -qL 160
echo "=================================================================================================================================================================================================="

echo "Please enter the project name:"
read text




echo "Let's find some miRNAs!!!" | cowsay | lolcat 
echo "Please enter the fasta file name here" | pv -qL 20 

read -r inpute

# Check if input file is provided
if [ -z "${inpute:-}" ] ; then
    echo "Error: Input file not provided"
    exit 1
fi

# Check if input file exists
if [ ! -f "$inpute" ]; then
    echo "Error: Input file not found"
    exit 1
fi

echo "Processing to find Pri-miRNA" | tee -a "$DIRECTORY"/Output/log/"$text".log

# Copy input file to Script directory
cp "$inpute" "$DIRECTORY"/Script/ 

# Run miRPara
cd "$DIRECTORY"/build/miRPara/
cp -R models "$DIRECTORY"/Script
cd "$DIRECTORY"/Script/
perl miRPara.pl -t 12 "$inpute" 
cp ./*.out "$DIRECTORY"/Output/"$text"/mirpara

echo "Converting miRPara output into Triplet_SVM input " | tee -a "$DIRECTORY"/Output/log/"$text".log
date
# Convert miRPara output into Triplet_SVM input

# Remove comment lines and '#' characters, then process miRPara output
sed '/^[[:blank:]]*#/d;s/#.*//' ./*.out > A1.txt
awk '{print $1,$2}' A1.txt > A2.txt 
awk '{for(i=1;i<=NF;i++) printf "%s\n",$i}' A2.txt > A3.txt
sed 's/[A-Z]//g' A3.txt > A4.txt 

# Format output for Triplet_SVM and RNAfold
sed -i '1~2 s/^/>/g' A4.txt
awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' A4.txt > Pri_miRNA.txt
RNAfold Pri_miRNA.txt > Secondary_Structure.txt

# Copy output files to designated directories
cp Secondary_Structure.txt "$DIRECTORY"/Output/"$text"/triplet_svm
cp Pri_miRNA.txt "$DIRECTORY"/Output/"$text"/miRPV_output
cp Pri_miRNA.txt "$DIRECTORY"/Output/"$text"/mirpara

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"



echo "	b)Converting miRPara output to get Mature_miRNA"  | tee -a "$DIRECTORY"/log/"$text".log
date 
# Convert miRPara output to Mature_miRNA

awk '/^[^#]/{print $3,$4}' ./*.out | awk '{print ">"$0; getline; print}' | tr '[:lower:]' '[:upper:]' > Mature_miRNAs.txt
cp Mature_miRNAs.txt "$DIRECTORY"/Output/"$text"/miranda

# Remove temporary files
rm -f A1.txt A2.txt A3.txt A4.txt A6.txt

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


echo "2) Proceed to find the Real or Pseudo Pri-miRNA" | pv -qL 20  | tee -a "$DIRECTORY"/log/"$text".log
	
	perl triplet_svm_classifier.pl Secondary_Structure.txt predict_format.txt 22 > Real_miRNA.txt	
	RNAeval -v Real_miRNA.txt > Mature_Secondary_Structure.txt	
	cp Real_miRNA.txt Mature_Secondary_Structure.txt "$DIRECTORY"/Output/$text"/miRPV_output" "$DIRECTORY"/Output/"$text"/maturebayes "$DIRECTORY"/Output/"$text"/triplet_svm 
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"



echo "c) Converting real-miRNA output to HAIRPLENDEX input" | tee -a "$DIRECTORY"/log/"$text".log
date 

RNAfold Real_miRNA.txt | awk '{printf "%s%s", $0, (NR%3?FS:RS)}' > Hairplendex.txt
cp Hairplendex.txt "$DIRECTORY"/Output/"$text"/hairplendex
mv Hairplendex.txt "$DIRECTORY"/build/file

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"



# Add -1 to the beginning of each line in predict_format.txt
sed -i -e 's/^/-1 /' predict_format.txt

# Move predict_format.txt to the libsvm-3.14 directory
mv predict_format.txt "$DIRECTORY/build/libsvm-3.14/"

# Copy the model file to the libsvm-3.14 directory
cp "$DIRECTORY/build/triplet-svm-classifier060304/models/trainset_hsa163_cds168_unite.txt.model" "$DIRECTORY/build/libsvm-3.14/"

# Change directory to libsvm-3.14
cd "$DIRECTORY/build/libsvm-3.14/"

# Use svm-predict to predict the output and save it to predict_result.txt
svm-predict predict_format.txt trainset_hsa163_cds168_unite.txt.model predict_result.txt

# Move predict_result.txt to the output directory
mv predict_result.txt "$DIRECTORY/Output/$text/triplet_svm/"

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


MATLAB_RUNTIME_PATH="/usr/local/MATLAB/MATLAB_Runtime/v98"

date
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "3) Feature Extraction of Pri-miRNAs" | pv -qL 20  | tee -a "$DIRECTORY"/log/"$text".log
	cd "$DIRECTORY"/build/file
	if ./run_Fold_generator.sh "$MATLAB_RUNTIME_PATH" Hairplendex && ./run_Hairpindex_miRNA_analyzer.sh "$MATLAB_RUNTIME_PATH" Hairplendex; then
		rm -f Hairplendex.mat Hairplendex.txt
		mv Hairplendex_v_1_1.txt "$DIRECTORY"/Output/"$text"/miRPV_output
	else
		echo "Error: Failed to extract features from Pri-miRNAs" | tee -a "$DIRECTORY"/log/"$text".log
		exit 1
	fi

date

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "4) Procced to find Mature miRNA using Pri-miRNA" | pv -qL 20 | tee -a "$DIRECTORY"/log/"$text".log

date
	cd "$DIRECTORY"/Script/
	python2 matureBayes.py Real_miRNA.txt Mature_Secondary_Structure.txt "$DIRECTORY"/Output/"$text"/maturebayes/Mature_miRNA.txt
	cp "$DIRECTORY"/Output/"$text"/maturebayes/Mature_miRNA.txt "$DIRECTORY"/Output/"$text"/miRPV_output




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

if (dialog --title "Message" --defaultno --yesno "Want to predict Target of Mature miRNA? (If yes please keep the reference sequence in the folder)" 7 60); then
    cd "$DIRECTORY"/
    echo "======================================================="
    echo "Please enter the Reference Sequence name"
    echo "======================================================="
    read reference
    if [ -n "$reference" ] && [ -e "$DIRECTORY"/"$reference" ]; then
        echo "5) Final micro-RNA target prediction" | pv -qL 20 | tee -a "$DIRECTORY"/log/"$text".log
        date
        cp "$DIRECTORY"/"$reference" "$DIRECTORY"/Script/
        cd "$DIRECTORY"/Script/
        miranda Mature_miRNAs.txt "$reference" -trim T > Target.txt
        cp Target.txt "$DIRECTORY"/Output/"$text"/miRPV_output
        mv Target.txt "$DIRECTORY"/Output/"$text"/miranda
        rm -f 1.txt Mature_miRNAs.txt Mature_Secondary_Structure.txt Secondary_Structure.txt Pri_miRNA.txt ./*.out ./*.ps ./*.pmt ./*.fa Real_miRNA.txt ./*.fasta
    else
        echo "The Reference file not found. Please keep the file in miRPV folder."
    fi
fi




echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "6) Converting miRPV Output Into final Report" 
	cd "$DIRECTORY"/Output/"$text"/miRPV_output
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
	{
	echo "miRNAs prediction by miRPV Pipeline " 
	#echo "#By Pradyumna Jayaram and Vinayak Rao" 
	echo "Report bugs to mlsc@manipal.edu" 
	echo "Departement of Cell and Molecular Biology" 
	echo "Manipal School of Life Sciences Maniapl" 
	echo "Manipal Academy of Higher Education, Manipal, INDIA" 
	
	
	echo "Homepage: http://slsdb.manipal.edu" 
	} >> Intro.txt
	

	sed -i '1s/^/\nSUMMARY OF THE miRPV PIPELINE: \n\n/' Sum.txt

	cat Intro.txt Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Target.txt > miRPV_Output

	enscript miRPV_Output -o - | ps2pdf - miRPV_Out.pdf
	#unoconv -f pdf miRPV_Output 
	mv Hairplendex_v_1_1.txt Pri-miRNA_Features.xls
	cp Pri-miRNA_Features.xls "$DIRECTORY"/Output/"$text"/hairplendex
	rm -f Sum.txt Pri_miRNA.txt Real_miRNA.txt Mature_miRNA.txt Target.txt Pri.txt Real.txt Mat.txt Tar.txt Mature_Secondary_Structure.txt Intro.txt miRPV_Output 
		

else
	
	rm -f 1.txt Mature_miRNAs.txt Mature_Secondary_Structure.txt Secondary_Structure.txt Pri_miRNA.txt ./*.out ./*.ps ./*.pmt ./*.fa Real_miRNA.txt	
	echo "Converting miRPV Output Into final Report Without Target"  
	cd "$DIRECTORY"/Output/"$text"/miRPV_output
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
	cp Pri-miRNA_Features.xls "$DIRECTORY"/Output/"$text"/hairplendex
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
execution_time=`printf "%.2f seconds" "$duration"`

echo "Pipelline Execution Time: $execution_time"
	

