#!/bin/bash

set -u 
set -e

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

# software source

RANDFOLD_URL="http://bioinformatics.psb.ugent.be/supplementary_data/erbon/nov2003/downloads/randfold-2.0.tar.gz"
RANDFOLD_ARCHIVE=`basename "$RANDFOLD_URL"`
RANDFOLD_BUILD_DIR=`basename "$RANDFOLD_ARCHIVE" .tar.gz`

#VIENNA_RNA_URL="http://www.tbi.univie.ac.at/~ivo/RNA/ViennaRNA-1.8.4.tar.gz"
VIENNA_RNA_URL="http://www.tbi.univie.ac.at/RNA/packages/source/ViennaRNA-1.8.4.tar.gz"
VIENNA_RNA_ARCHIVE=`basename "$VIENNA_RNA_URL"`
VIENNA_RNA_BUILD_DIR=`basename "$VIENNA_RNA_ARCHIVE" .tar.gz`

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


# Install UNAFOLD if not installed
if command -v UNAFold.pl >/dev/null; then
	echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "UNAFold is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "installing UNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	cd "$miRPara_PATH"/required_packages/unafold-3.8/
	autoconf
	./configure
	make
	echo "running 'sudo make install'"
	sudo make install
	echo "running 'sudo cp "$miRPara_PATH"/required_packages/unafold-3.8/scripts/UNAFold.pl /usr/bin/'"
	sudo cp "$miRPara_PATH"/required_packages/unafold-3.8/scripts/UNAFold.pl /usr/bin/
	if command -v UNAFold.pl >/dev/null; then
		echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "UNAFold is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	else
		echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "UNAFold inatallation failed. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	fi
fi

# install ct2out
cd "$miRPara_PATH"/required_packages/ct2out/
if command -v ct2out >/dev/null; then
	echo "ct2out is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	if command -v gfortran >/dev/null;then
		gfortran ct2out.f -o ct2out
		cp ct2out "$miRPV_PATH"/bin/
	else

		conda install -c conda-forge fortran-compiler
		gfortran ct2out.f -o ct2out
		sudo cp ct2out "$miRPV_PATH"/bin/
	fi
fi
if command -v ct2out >/dev/null;then
	echo "ct2out is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "ct2out installation failed. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
fi

##install libSVM
cd "$miRPara_PATH"/required_packages/libsvm-3.14/
if command -v svm-predict >/dev/null; then
	echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "libSVM is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	make
	sudo cp svm-predict /usr/bin/
	if command -v svm-predict >/dev/null; then
		echo ""
	else
		echo `date` | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "libSVM failed to install. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	fi
fi


# Download Software
if [ ! -e "$SOURCES/$RANDFOLD_ARCHIVE" ] ; then 
	echo -n "Downloading Randfold - "
	$WGET --directory-prefix="$Tools" -nc "$RANDFOLD_URL"
fi

if [ ! -e "$SOURCES/$VIENNA_RNA_ARCHIVE" ] ; then 
	echo -n "Downloading ViennaRNA - "
	$WGET --directory-prefix="$Tools" -nc "$VIENNA_RNA_URL"
fi 

# Unpack Archives
if [ ! -d "$BUILD/$RANDFOLD_BUILD_DIR" ] ; then 
	set -x
	tar xvz --directory "$BUILD" -f "$Tools/$RANDFOLD_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$VIENNA_RNA_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$Tools/$VIENNA_RNA_ARCHIVE"
	set +x
fi

if [ ! -d "$BUILD/$MIRPARA_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$Tools/$mirpara"
	set +x
fi

if [ ! -d "$BUILD/$TRIPLET_SVM_CLASSIFIER_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$Tools/$triplet_svm_classifier"
	set +x
fi

if [ ! -d "$BUILD/$MATURE_BAYES_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$Tools/$Mature_Bayes"
	set +x
fi

if [ ! -d "$BUILD/$MIRANDA_BUILD_DIR" ] ; then 
	set -x
	tar xz --directory "$BUILD" -f "$Tools/$miRanda"
	set +x
fi
