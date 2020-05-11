#!/bin/bash

set -u 
set -e

INSTALL_SCRIPT=$(readlink -f $0)
INSTALL_DIRECTORY=`dirname "$INSTALL_SCRIPT"`
SCRIPT_DIRECTORY="$INSTALL_DIRECTORY/Script"
TOOLS_DIRECTORY="$INSTALL_DIRECTORY/Tools"

#software to install
MIRPARA_LOCATION="$TOOLS_DIRECTORY/mirpara.tar.gz"
MIRPARA_ARCHIVE= `basename "$MIRPARA_LOCATION"`
MIRPARA_BUILD_DIR=`basename "$MIRPARA_ARCHIVE" .tar.gz`

TRIPLET_SVM_LOCATION="$TOOLS_DIRECTORY/triplet-svm-classifier.tar.gz"
TRIPLET_SVM_ARCHIVE= `basename "$TRIPLET_SVM_LOCATION"`
TRIPLET_SVM_BUILD_DIR=`basename "$TRIPLET_ARCHIVE" .tar.gz`

MATURE_BAYES_LOCATION="$TOOLS_DIRECTORY/Mature_Bayes.tar.gz"
MATURE_BAYES_ARCHIVE= `basename "$MATURE_BAYES_LOCATION"`
MATURE_BAYES_BUILD_DIR=`basename "$MATURE_BAYES_ARCHIVE" .tar.gz`

MIRANDA_LOCATION="$TOOLS_DIRECTORY/miRanda.tar.gz"
MIRANDA_ARCHIVE= `basename "$MIRANDA_LOCATION"`
MIRANDA_BUILD_DIR=`basename "$MIRANDA_ARCHIVE" .tar.gz`

VIENNA_RNA_LOCATION="$TOOLS_DIRECTORY/ViennaRNA.tar.gz"
VIENNA_RNA_ARCHIVE= `basename "$VIENNA_RNA_LOCATION"`
VIENNA_RNA_BUILD_DIR=`basename "$VIENNA_RNA_ARCHIVE" .tar.gz`

# Exit Trapping

completeCheck() { 
	EXITCODE=$?

	if [ ! $EXITCODE == 0 ] ; then 
		set +x
		echo ""
		echo "Install Failed."
		echo "---------------------------------------------------------------------------------------------------------"
		echo "Please examine the output above to identify the cause."
		echo "If you're uncertain about how to interpret the error message, please forward it pradyumna.j.ram@gmail.com"
		echo "and we'll attempt to help you identify the problem."
		echo ""
	fi

	exit $EXITCODE
}


trap completeCheck EXIT

# Usage and command line parsing

usage() { 
	echo ""
	echo "$0 -p /path/to/install"
	echo "  -p the install directory for miRPara and it's dependencies."
	echo "  -h this usage description"
	echo ""
	exit 0
}

PREFIX=''
BUILD=''
TOOLS_DIRECTORY=''


while getopts ":p:h:" o; do
	case "${o}" in
		p)
			PREFIX=`readlink -f "${OPTARG}"`
			TOOLS_DIRECTORY="$PREFIX/Tools"
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
systemID='cat /etc/os-release | grep "^ID="|  awk -F "=" '{print $2}''
VERSION_ID='cat /etc/os-release | grep "^VERSION_ID="|  awk -F "=" '{print $2}''


if [[ "$systemID" -eq "ubuntu" ]]; then
	echo "installing dependencies"
else
	echo "The tool currently verified on ubuntu system but you have $systemID some dependencies might not be installed which may break the pipeline"
fi

##checks if conda is installed
echo "checking for anaconda/miniconda package" | tee -a "$PREFIX"
set +e
CONDA='which conda'
set -e
if [ ! -x "$CONDA"]; then
	#installs miRPara dependencies through conda
	echo `date` | tee -a "$PREFIX"
	echo "conda is installed, Installing other dependencies" | tee -a "$PREFIX"
	conda update conda -y
	conda create --name miRPV python=2.7
	conda activate miRPV
	conda install -c bioconda perl-getopt-long
	#searching for cpan
	set +e
	CPAN='which cpan'
	set -e
	if [ ! -x "CPAN"]; then
		echo `date` | tee -a "$PREFIX"
		echo "cpan is installed, installing perl dependences" | tee -a "$PREFIX"
		perl -MCPAN -e 'install threads'
		perl -MCPAN -e 'install threads::shared'
		perl -MCPAN -e 'install Cwd'
		perl -MCPAN -e 'install File::chdir'
		perl -MCPAN -e 'install Algorithm::SVM'
	else
		echo `date` | tee -a "$PREFIX"
		echo "cpan is not installed, installing cpan" | tee -a "$PREFIX"
		conda install -c bioconda perl-cpan-shell
		echo `date` | tee -a "$PREFIX"
		echo "cpan is installed, installing perl dependences" | tee -a "$PREFIX"
		perl -MCPAN -e 'install threads'
		perl -MCPAN -e 'install threads::shared'
		perl -MCPAN -e 'install Cwd'
		perl -MCPAN -e 'install File::chdir'
		perl -MCPAN -e 'install Algorithm::SVM'
	fi
else
	#installs miniconda if not installed

	#software source
	Miniconda_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
	Miniconda_Archive= basename "$Miniconda_URL"
	Miniconda_BUILD_DIR= basename "$Miniconda_Archive" .sh
	
	# Download Software
	if [ ! -e "$TOOLS/$Miniconda_Archive" ] ; then 
	echo -n "Downloading Miniconda - "
	$WGET --directory-prefix="$Tools" -nc "$Miniconda_URL"

	#Install software
	if [ ! -e "$BULID/$Miniconda_BUILD_DIR" ] ; then
		set -x
		cd "$BUILD/$Miniconda_BUILD_DIR	bash Miniconda3-latest-Linux-x86_64.sh -b --license y --prefix"="$PREFIX"
		source ~/.bashrc
		set +x
	fi

		conda update conda -y
		conda create --name miRPV python=2.7
		conda activate miRPV
		conda install -c bioconda perl-getopt-long
		#searching for cpan
		set +e
		CPAN='which cpan'
		set -e
		if [ ! -x "CPAN"]; then
			echo `date` | tee -a "$PREFIX"
			echo "cpan is installed, installing perl dependences" | tee -a "$PREFIX"
			perl -MCPAN -e 'install threads'
			perl -MCPAN -e 'install threads::shared'
			perl -MCPAN -e 'install Cwd'
			perl -MCPAN -e 'install File::chdir'
			perl -MCPAN -e 'install Algorithm::SVM'
		else
			echo `date` | tee -a "$PREFIX"
			echo "cpan is not installed, installing cpan" | tee -a "$PREFIX"
			conda install -c bioconda perl-cpan-shell
			echo `date` | tee -a "$PREFIX"
			echo "cpan is installed, installing perl dependences" | tee -a "$PREFIX"
			perl -MCPAN -e 'install threads'
			perl -MCPAN -e 'install threads::shared'
			perl -MCPAN -e 'install Cwd'
			perl -MCPAN -e 'install File::chdir'
			perl -MCPAN -e 'install Algorithm::SVM'
		fi
fi



# Create the install directory

# create install path

if [ ! -d $PREFIX ] ; then 
	set -x
	`mkdir "$PREFIX"`
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

# Unpack Archives

if [ ! -d "$BUILD/$MIRPARA_BUILD_DIR"] ; then
	set -x
	tar xvz --directory "$BUILD" -f "$TOOLS_DIRECTORY/$MIRPARA_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$TRIPLET_SVM_BUILD_DIR"] ; then
	set -x
	tar xvz --directory "$BUILD" -f "$TOOLS_DIRECTORY/$TRIPLET_SVM_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$MATURE_BAYES_BUILD_DIR"] ; then
	set -x
	tar xvz --directory "$BUILD" -f "$TOOLS_DIRECTORY/$MATURE_BAYES_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$MIRANDA_BUILD_DIR"] ; then
	set -x
	tar xvz --directory "$BUILD" -f "$TOOLS_DIRECTORY/$MIRANDA_ARCHIVE"
	set +x
fi


#INSTALL SOFTWARE

# Install UNAFOLD if not installed
echo "check if UNAFOLD is install" | tee -a "$PREFIX"
set +e
UNAFOLD=`RNAfold`
set -e
if [ ! -x "$UNAFOLD"]; then

	echo `date` | tee -a "$PREFIX"
	echo "UNAFold is installed" 
else
	echo `date` | tee -a "$PREFIX"
	echo "installing UNAFold" | tee -a "$PREFIX"
	cd "$BUILD"/mirpara/required_packages/
	tar xvz unafold-3.8
	cd unafold-3.8
	autoconf
	./configure
	make
	echo "running 'sudo make install'"
	sudo make install
	echo "running"
	sudo cp "$BUILD"/mirpara/required_packages/unafold-3.8/scripts/UNAFold.pl" "$PREFIX/bin/

fi

# install ct2out
echo "check if ct2out is installed" | tee -a "$PREFIX"
set +e  
CT2OUT=`which ct2out`
set -e
if [ ! -x "$CT2OUT"] ; then
	
	echo `date` | tee -a "$PREFIX"
	echo "ct2out is installed" 	
else
	echo "installing ct2out" 
	cd "$BUILD"/mirpara/required_packages/ct2out/"
	gfortran ct2out.f -o ct2out
	cp ct2out "$PREFIX/bin/
else

	conda install -c conda-forge fortran-compiler
	gfortran ct2out.f -o ct2out
	sudo cp ct2out $PREFIX/bin/
	
fi
if [ ! -x "$CT2OUT"] ; then
	
	echo `date` | tee -a "$PREFIX"
	echo "ct2out is not installed. Please install manually" 	
fi


##install libSVM
echo "check if libSVM is installed"
set +e
LIBSVM=`which svm-predict`
set -e
if [ ! -x "$LIBSVM"] ; then
	echo `date` | tee -a "$PREFIX"
	echo "libSVM is installed"
else
	cd "$BUILD/mirpara/required_package/"
	tar xvz libsvm-3.14.tar.gz
	cd libsvm-3.14
	make
	sudo cp svm-predict $PREFIX/usr/bin/	
	
	if [ ! -x "$LIBSVM"] ; then
		echo `date` | tee -a "$PREFIX"
		echo "libSVM is installed"
	else
		echo `date` | tee -a "$PREFIX"
		echo "libSVM failed to install. Please install manually"
	fi
fi



# Miranda 

if [ ! -e "$BUILD/$MIRANDA__BUILD_DIR/makefile" ] ; then
	set -x
	cd "$BUILD/$MIRANDA_BUILD_DIR"
	./configure --prefix="$PREFIX"
	make install
	set +x
fi

#Reference sequence

echo " "

echo "checking..."

echo " Pipeline INSTALLED Successfully"


echo "$SCRIPT_DIRECTORY/miRPV.sh" 

echo " "


echo "Upon completion, results will be available in $INSTALL_DIRECTORY/sample_output"

echo " "







