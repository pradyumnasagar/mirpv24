#!/bin/bash
#set -euox pipefail
#set -u 
set -e
#unset PS1

start=$(date +%s.%N)
INSTALL_SCRIPT=$(readlink -f $0)
INSTALL_DIRECTORY=`dirname "$INSTALL_SCRIPT"`
SCRIPT_DIRECTORY="$INSTALL_DIRECTORY/Script"

#software to install
MIRPARA_URL="https://github.com/weasteam/miRPara/raw/master/miRPara/mirpara6.3.tar.gz"
MIRPARA_ARCHIVE=`basename "$MIRPARA_URL"`
MIRPARA_BUILD_DIR=`basename "$MIRPARA_ARCHIVE" .tar.gz`

TRIPLET_SVM_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/triplet-svm-classifier.tar.gz"
TRIPLET_SVM_ARCHIVE=`basename "$TRIPLET_SVM_URL"`
TRIPLET_SVM_BUILD_DIR=`basename "$TRIPLET_SVM_ARCHIVE" .tar.gz`

MATURE_BAYES_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/Mature_Bayes.tar.gz"
MATURE_BAYES_ARCHIVE=`basename "$MATURE_BAYES_URL"`
MATURE_BAYES_BUILD_DIR=`basename "$MATURE_BAYES_ARCHIVE" .tar.gz`

MIRANDA_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/miRanda.tar.gz"
MIRANDA_ARCHIVE=`basename "$MIRANDA_URL"`
MIRANDA_BUILD_DIR=`basename "$MIRANDA_ARCHIVE" .tar.gz`

VIENNA_RNA_URL="https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_4_x/ViennaRNA-2.4.14.tar.gz"
VIENNA_RNA_ARCHIVE=`basename "$VIENNA_RNA_URL"`
VIENNA_RNA_BUILD_DIR=`basename "$VIENNA_RNA_ARCHIVE" .tar.gz`

LIBSVM_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/libsvm-3.14.tar.gz"
LIBSVM_ARCHIVE=`basename "$LIBSVM_URL"`
LIBSVM_BUILD_DIR=`basename "$LIBSVM_ARCHIVE" .tar.gz`

CT2OUT_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/ct2out.zip"
CT2OUT_ARCHIVE=`basename  "$CT2OUT_URL"`
CT2OUT_BUILD_DIR=`basename "$CT2OUT_ARCHIVE" .zip`

UNAFOLD_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/unafold-3.8.tar.gz"
UNAFOLD_ARCHIVE=`basename "$UNAFOLD_URL"`
UNAFOLD_BUILD_DIR=`basename "$UNAFOLD_ARCHIVE" .tar.gz`

GETOPT_LONG_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/Getopt-Long-2.51.tar.gz"
GETOPT_LONG_ARCHIVE=`basename "$GETOPT_LONG_URL"`
GETOPT_LONG_BUILD_DIR=`basename "$GETOPT_LONG_ARCHIVE" .tar.gz`

ALGORITHM_SVM_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/Algorithm-SVM-0.13.zip"
ALGORITHM_SVM_ARCHIVE=`basename "$ALGORITHM_SVM_URL"`
ALGORITHM_SVM_BUILD_DIR=`basename "$ALGORITHM_SVM_ARCHIVE" .zip`

FILE_CHIDER_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/File-chdir-0.1010.tar.gz"
FILE_CHIDER_ARCHIVE=`basename "$FILE_CHIDER_URL"`
FILE_CHIDER_BUILD_DIR=`basename "$FILE_CHIDER_ARCHIVE" .tar.gz`

PATH_LINK_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/PathTools-3.75.tar.gz"
PATH_LINK_ARCHIVE=`basename "$PATH_LINK_URL"`
PATH_LINK_BUILD_DIR=`basename "$PATH_LINK_ARCHIVE" .tar.gz`

THREADS_URL="https://github.com/vinayakrao28/Bash-/raw/master/Software/threads-2.21.tar.gz"
THREADS_ARCHIVE=`basename "$THREADS_URL"`
THREADS_BUILD_DIR=`basename "$THREADS_ARCHIVE" .tar.gz`

HAIRPLENDEX_URL="https://sourceforge.net/projects/hairpin/files/HAirpin.tar.xz/download"
HAIRPLENDEX_ARCHIVE=`basename "$HAIRPLENDEX_URL"`
HAIRPLENDEX_BUILD_DIR=`basename "$HAIRPLENDEX_ARCHIVE" .tar.xz`

# Exit Trapping

completeCheck() { 
	EXITCODE=$?

	if [ ! $EXITCODE == 0 ] ; then 
		set +x
		echo ""
		echo "Install Failed."
		echo "---------------------------------------------------------------------------------------------------------"
		echo "Please examine the output above to identify the cause."
		echo "If you're uncertain about how to interpret the error message, please forward it pradyumna.j.ram@gmail.com or vinayakrao28@gmail.com"
		echo "and we'll attempt to help you identify the problem."
		echo ""
	fi

	exit $EXITCODE
}


trap completeCheck EXIT

# Usage and command line parsing

usage() { 
	echo ""
	echo "$0 -p /path/to/miRPV directory"
	echo "  -p the install directory for miRPara and it's dependencies."
	echo "  -h this usage description"
	echo ""
	exit 0
}

PREFIX=''
BUILD=''
TOOLS=''


while getopts ":p:h:" o; do
	case "${o}" in
		p)
			PREFIX=`readlink -f "${OPTARG}"`
			TOOLS="$PREFIX/tools"
			BUILD="$PREFIX/build"
			;;
		*)
			usage
			;;
	esac
done

set +e
if [ -z "$PREFIX" ] ; then 
	usage
fi
set -e 

echo "This version of miRPV works best on ubuntu System. However, it can be tried in other linux system at your own risk"
systemID=sudo cat /etc/os-release | grep "^ID="| awk -F "=" '{print $2}'

if [[ "$systemID" -eq "ubuntu" ]]; then
	echo "Current System is ubuntu continue to installing dependencies"
else
	echo "The tool currently verified on ubuntu system but you have $systemID some dependencies might not be installed which may break the pipeline"
fi



# Create the install directory

# create install path

if [ ! -d $PREFIX ] ; then 
	set -x
	`mkdir "$PREFIX"`
	set +x
fi

# Create the Tools directory

if [ ! -d "$TOOLS" ] ; then 
	set -x
	`mkdir "$TOOLS"`
	set +x
fi 

# create the build directory

if [ ! -d "$BUILD" ] ; then 
	set -x
	`mkdir "$BUILD"`
	set +x
fi

# Check base dependencies

# checking for WGET
set +e
WGET=`which wget`
set -e
if [ ! -x "$WGET" ]; then
	echo "Unable to find wget in your PATH"
	exit 1
fi

# checking for UNZIP
set +e
UNZIP=`which unzip`
set -e
if [ ! -x "$UNZIP" ]; then
	echo "Unable to find unzip in your PATH"
	exit 1
fi

# checking for make
set +e
MAKE=`which make`
set -e
if [ ! -x "$MAKE" ]; then
	echo "Unable to find make in your PATH"
	exit 1
fi

# Installing some of the tools
sudo apt-get -y install lolcat
sudo apt-get -y install cowsay
sudo apt-get -y install figlet
sudo apt-get -y install enscript
sudo apt-get -y install dialog
sudo apt-get -y install pv
sudo apt -y install sl
sudo apt -y install gfortran
sudo apt -y install make
sudo apt -y install build-essential
sudo apt-get -y install g++
sudo apt-get -y install manpages-dev

#dpkg -s python &> /dev/null
#if [ $? -eq 0 ]; then
#echo "Python is installed"
#else
 #   sudo apt -y install python
#fi
##caused error in ubuntu 20.04

	


if [ ! -e "$TOOLS/$MIRPARA_ARCHIVE" ] ; then 
	echo -n "Downloading miRPra - "
	$WGET --directory-prefix="$TOOLS" -nc "$MIRPARA_URL"
fi

if [ ! -e "$TOOLS/$TRIPLET_SVM_ARCHIVE" ] ; then 
	echo -n "Downloading Triplet_SVM - "
	$WGET --directory-prefix="$TOOLS" -nc "$TRIPLET_SVM_URL"
fi

if [ ! -e "$TOOLS/$MATURE_BAYES_ARCHIVE" ] ; then 
	echo -n "Downloading MatureBayes - "
	$WGET --directory-prefix="$TOOLS" -nc "$MATURE_BAYES_URL"
fi

if [ ! -e "$TOOLS/$MIRANDA_ARCHIVE" ] ; then 
	echo -n "Downloading Miranda - "
	$WGET --directory-prefix="$TOOLS" -nc "$MIRANDA_URL"
fi

if [ ! -e "$TOOLS/$VIENNA_RNA_ARCHIVE" ] ; then 
	echo -n "Downloading Vienna_RNA- "
	$WGET --directory-prefix="$TOOLS" -nc "$VIENNA_RNA_URL"
fi

if [ ! -e "$TOOLS/$LIBSVM_ARCHIVE" ] ; then
	echo -n "Downloading Libsvm"
	$WGET --directory-prefix="$TOOLS" -nc "$LIBSVM_URL"
fi

if [ ! -e "$TOOLS/$CT2OUT_ARCHIVE" ] ; then
	echo -n "Downloading ct2out"
	$WGET --directory-prefix="$TOOLS" -nc "$CT2OUT_URL"
fi

if [ ! -e "$TOOLS/$UNAFOLD_ARCHIVE" ] ; then
	echo -n "Downloading UNAfold"
	$WGET --directory-prefix="$TOOLS" -nc "$UNAFOLD_URL"
fi

if [ ! -e "$TOOLS/$THREADS_ARCHIVE" ] ; then
	echo -n "Downloading THREADS"
	$WGET --directory-prefix="$TOOLS" -nc "$THREADS_URL"
fi

if [ ! -e "$TOOLS/$PATH_LINK_ARCHIVE" ] ; then
	echo -n "Downloading Path_Link"
	$WGET --directory-prefix="$TOOLS" -nc "$PATH_LINK_URL"
fi

if [ ! -e "$TOOLS/$FILE_CHIDER_ARCHIVE" ] ; then
	echo -n "Downloading File_Chider"
	$WGET --directory-prefix="$TOOLS" -nc "$FILE_CHIDER_URL"
fi

if [ ! -e "$TOOLS/$ALGORITHM_SVM_ARCHIVE" ] ; then
	echo -n "Downloading Algorithm_SVM"
	$WGET --directory-prefix="$TOOLS" -nc "$ALGORITHM_SVM_URL"
fi

if [ ! -e "$TOOLS/$GETOPT_LONG_ARCHIVE" ] ; then
	echo -n "Downloading Getopt_Long"
	$WGET --directory-prefix="$TOOLS" -nc "$GETOPT_LONG_URL"
fi

if [ ! -e "$TOOLS/$HAIRPLENDEX_ARCHIVE" ] ; then
	echo -n "Downloading Hairplendex - "
	$WGET --directory-prefix="$TOOLS" -c "$HAIRPLENDEX_URL" -O "$TOOLS"/HAirpindex.tar.xz
fi


# Unpack Archives


if  [  ! -d "$BUILD/$GETOPT_LONG_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$GETOPT_LONG_ARCHIVE"
	set +x
fi

if  [  ! -d "$BUILD/$ALGORITHM_SVM_BUILD_DIR" ] ; then
	set -x
	"$UNZIP" -d "$BUILD"  "$TOOLS/$ALGORITHM_SVM_ARCHIVE"
	set +x
fi

if  [  ! -d "$BUILD/$FILE_CHIDER_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$FILE_CHIDER_ARCHIVE"
	set +x
fi

if  [  ! -d "$BUILD/$PATH_LINK_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$PATH_LINK_ARCHIVE"
	set +x
fi

if  [  ! -d "$BUILD/$THREADS_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$THREADS_ARCHIVE"
	set +x
fi


if  [  ! -d "$BUILD/$MIRPARA_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$MIRPARA_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$TRIPLET_SVM_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$TRIPLET_SVM_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$MATURE_BAYES_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$MATURE_BAYES_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$MIRANDA_BUILD_DIR" ] ; then
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$MIRANDA_ARCHIVE"
	set +x
fi


if [ ! -d "$BUILD/$VIENNA_RNA_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$VIENNA_RNA_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$LIBSVM_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$LIBSVM_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$CT2OUT_BUILD_DIR" ] ; then 
	set -x
	"$UNZIP" -d "$BUILD"  "$TOOLS/$CT2OUT_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$UNAFOLD_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$TOOLS/$UNAFOLD_ARCHIVE"
	set +x
fi


# Making of Script Directory

mkdir -p $PREFIX/Script
cd $PREFIX/build/miRPara
cp miRPara.pl $PREFIX/Script

cd $PREFIX/build/triplet-svm-classifier060304
cp 1_check_query_content.pl 2_get_stemloop.pl 2_get_stemloop.pl 2_get_stemloop.pl 3_step_triplet_coding_for_queries.pl 4_libsvm_format.pl triplet_svm_classifier.pl $PREFIX/Script

cd $PREFIX/build/MatureBayesCode/src
cp bayesianClassifier.txt matureBayes.py $PREFIX/Script

#INSTALL SOFTWARE

#Hairplendex

echo "Installing Hairplendex"
echo "================================================================================================================================================================================================="
echo "1) Type ./Hairpindex_installer.install when the terminal goes to root directory wait till it loads" | lolcat
echo "2) Just click NEXT option for path /usr/local/MATLAB/MATLAB_Runtime/v98" | lolcat
echo "3) Write exit in the terminal" | lolcat
echo "4) Click exit if it dosen't processd after installing" | lolcat
echo "5) If it ask again for installation cancel the installation it will proccesed for next installation" | lolcat
echo "=================================================================================================================================="


cd $PREFIX/tools
tar -xf HAirpindex.tar.xz
mv file $PREFIX/build
cd $PREFIX/build/file
sudo su
sudo ./Hairpindex_installer.install

#Getopt
echo "Installing Getopt"
if [ ! -e "$BUILD/$GETOPT_LONG_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/Getopt-Long-2.51"
	perl Makefile.PL
	sudo make 
	sudo make test
	sudo make install
	set +x
fi

#Algorith_SVM
echo "Installing Algorithm_SVM"
if [ ! -e "$BUILD/$ALGORITHM_SVM_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/Algorithm-SVM-0.13"
	perl Makefile.PL
	sudo make 
	sudo make test
	sudo make install
	set +x
fi

#File_Chidel
echo "Installing File_Chider "
if [ ! -e "$BUILD/$FILE_CHIDER_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/File-chdir-0.1010"
	perl Makefile.PL
	sudo make 
	sudo make test
	sudo make install
	set +x
fi

#Path_Link
echo "Installing Path_Link"
if [ ! -e "$BUILD/$PATH_LINK_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/PathTools-3.75"
	perl Makefile.PL
	sudo make 
	sudo make test
	sudo make install
	set +x
fi

#Threads
echo "Installing Threads"
if [ ! -e "$BUILD/$THREADS_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/threads-2.21"
	perl Makefile.PL
	sudo make 
	sudo make test
	sudo make install
	set +x
fi


#ViennaRNA
echo "Installing ViennaRNA"
if [ ! -e "$BUILD/$VIENNA_RNA_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/ViennaRNA-2.4.14"
	./configure
	make
	make check
	sudo make install
	set +x
fi

#UNAfol

mkdir -p "$PREFIX"/bin

 echo "Installing UNAfold "
if [ ! -e "$BUILD/$UNAFOLD_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/unafold-3.8"
	./configure
	make
	#echo "running sudo make install"
	sudo make install
	echo "running"
	cd "$BUILD/unafold-3.8/scripts"
	sudo cp -r UNAFold.pl /bin/
	sudo cp -r UNAFold.pl "$PREFIX" /bin
	set +x
fi


#LIBSVM 

if [ ! -e "BUILD/$LIBSVM_BUILD_DIR/makefile" ] ; then
	set -x 
	cd "$BUILD/libsvm-3.14"
	make
	sudo cp -r svm-predict /bin/
	sudo cp svm-predict "$PREFIX"/bin/
	set +x
fi


# Miranda 

if [ ! -e "$BUILD/$MIRANDA_BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/miRanda-3.3a"
	./configure 
	sudo make install
	set +x
fi

#ct2out

if [ ! -e "$BUILD/$CT2OUT_BUILD_DIR/" ] ; then
	set -x
	cd "$BUILD/ct2out"
	gfortran ct2out.f -o ct2out
	sudo cp -r ct2out /bin/
	cp ct2out "$PREFIX"/bin/
	set +x
fi


mkdir -p $PREFIX/Script
cd $PREFIX//build/miRPara
cp miRPara.pl $PREFIC/Script

cd $PREFIX/
#chmod ugo+x "$PREFIX/bin/"*



echo "Pipeline installation is complete"

echo " "

echo " "

echo " Usage bash miRPV.sh \n Then give the fasta file name: "

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`

echo "Pipelline Execution Time: $execution_time"
