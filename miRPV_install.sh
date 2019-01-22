#!/bin/bash
set -u
#set -x
#exec 1> miRPV.log
#exec 2>&1
#AUTHOR: Pradyumna Jayaram
#bash miRPV_install.sh </path/to/miRPV>

###prints help when -h is typed with script
if [ "$1" == "-h" ]; then
  echo -e "Usage:\nbash `basename $0` /path/to/miRPV"
  exit 0
fi

##prints help when miRPV path is not given
if [ "$1" == "" ]; then
  echo -e "Usage:\nbash `basename $0` /path/to/miRPV"
  exit 0
fi

cat "This version of miRPV works only on ubuntu System"
systemID='cat /etc/os-release | grep "^ID="|  awk -F "=" '{print $2}''

if [ "$systemID" == "ubuntu" ]; then
  echo ""
suelse "echo The tool currently verified on ubuntu system but you have $systemID some dependencies might not be installed which may break the pipeline"
fi


#Set Path
miRPV_PATH=$1
miRPara_PATH=""$miRPV_PATH"/tools/miRPara/"
miRPara="$miRPara_PATH"/miRPara/miRPara.pl
miRBAG_PATH="$miRPV_PATH"/tools/miRBAG/
echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
echo "creating missing folders" | tee -a "$miRPV_PATH"/miRPV_install.log
mkdir -p "$miRPV_PATH"/tools/miRPara/
mkdir -p "$miRPV_PATH"/tools/miRBAG/
#mkdir -p "$miRPV_PATH"/tools/miniconda/
echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
echo "Running script as root to install missing packages" | tee -a "$miRPV_PATH"/miRPV_install.log
sudo echo "Testing dependencies installed" #Gain sudo permission
echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
echo "checking for anaconda package" | tee -a "$miRPV_PATH"/miRPV_install.log
##checks if conda is installed
if command -v conda >/dev/null; then
  #installs miRPara dependencies through conda
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "conda is installed, Installing other dependencies" | tee -a "$miRPV_PATH"/miRPV_install.log
  conda install -c bioconda perl-getopt-long
  if command -v cpan >/dev/null; then
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  else
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "cpan is not installed, installing cpan" | tee -a "$miRPV_PATH"/miRPV_install.log
    conda install -c bioconda perl-cpan-shell
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  fi
else
  #installs miniconda if not installed
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "Downloading and installing anaconda" | tee -a "$miRPV_PATH"/miRPV_install.log
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash Miniconda3-latest-Linux-x86_64.sh -b --license y -p "$miRPV_PATH"/tools/miniconda/
  echo "export PATH=""$miRPV_PATH"/tools/miniconda/bin:'$PATH'"" >> ~/.bashrc
  source ~/.bashrc
  conda install -c bioconda perl-getopt-long
  if command -v cpan >/dev/null; then
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  else
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "cpan is not installed, installing cpan" | tee -a "$miRPV_PATH"/miRPV_install.log
    conda install -c bioconda perl-cpan-shell
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  fi
fi

if command -v conda >/dev/null; then
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "anaconda is installed" | tee -a "$miRPV_PATH"/miRPV_install.log
else
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "anaconda inatallation failed. Please install manually" | tee -a "$miRPV_PATH"/miRPV_install.log
fi

echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
echo "downloadin miRPara" | tee -a "$miRPV_PATH"/miRPV_install.log

#wget "https://github.com/pradyumnasagar/miRPara/archive/master.zip" -o "$miRPV_PATH"/tools/miRPara/miRPara.zip || echo "failed to download miRPara" && exit #download miRPara and store in miRPara dir in miRPV exit script if fails

wget "https://github.com/pradyumnasagar/miRPara/archive/master.zip" -O "$miRPara_PATH"/miRPara.zip || read -r -p "miRPara download failed. Closing installation in  500 seconds or press any key to close immediately" -t 500 -n 1 -s | echo "miRPara download failed." | tee -a "$miRPV_PATH"/miRPV_install.log | exit #download miRPara and store in miRPara dir in miRPV exit script if fails


cd "$miRPV_PATH"/tools/miRPara/
unzip "$miRPV_PATH"/tools/miRPara/miRPara.zip
mv "$miRPV_PATH"/tools/miRPara/miRPara-master "$miRPV_PATH"/tools/miRPara/miRPara
cp "$miRPara_PATH"/miRPara/miRPara/mirpara6.3.tar.gz "$miRPV_PATH"/tools/miRPara/
cp "$miRPara_PATH"/miRPara/miRPara/organisms.txt.gz "$miRPara_PATH"/miRPara/models/miRBase/current/organisms.txt.gz
cp "$miRPara_PATH"/miRPara/miRPara/mature.fa.gz "$miRPara_PATH"/miRPara/models/miRBase/current/mature.fa.gz
rm -rf "$miRPara_PATH"/miRPara/miRPara
tar -xzf mirpara6.3.tar.gz
mkdir -p "$miRPara_PATH"/required_packages/
mv "$miRPara_PATH"/miRPara/required_packages/unafold-3.8.tar.gz "$miRPara_PATH"/required_packages/unafold-3.8.tar.gz
cd "$miRPara_PATH"/required_packages/
tar -xzf "$miRPara_PATH"/required_packages/unafold-3.8.tar.gz
mv "$miRPara_PATH"/miRPara/required_packages/libsvm-3.14.tar.gz "$miRPara_PATH"/required_packages/libsvm-3.14.tar.gz
cd "$miRPara_PATH"/required_packages/
tar -xzf "$miRPara_PATH"/required_packages/libsvm-3.14.tar.gz
mkdir -p "$miRPara_PATH"/required_packages/ct2out/
mv "$miRPara_PATH"/miRPara/required_packages/ct2out/* "$miRPara_PATH"/required_packages/ct2out/

#install dependencies
##Install UNAFOLD id not installed
if command -v UNAFold.pl >/dev/null; then
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "UNAFold is installed" | tee -a "$miRPV_PATH"/miRPV_install.log
else
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "installing UNAFold" | tee -a "$miRPV_PATH"/miRPV_install.log
  cd "$miRPara_PATH"/required_packages/unafold-3.8/
  autoconf
  ./configure
  make
  sudo make install
  sudo cp "$miRPara_PATH"/required_packages/unafold-3.8/scripts/UNAFold.pl /usr/bin/
  if command -v UNAFold.pl >/dev/null; then
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "UNAFold is installed" | tee -a "$miRPV_PATH"/miRPV_install.log
  else
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "UNAFold inatallation failed. Please install manually" | tee -a "$miRPV_PATH"/miRPV_install.log
  fi
fi

##install ct2out
cd "$miRPara_PATH"/required_packages/ct2out/
if command -v ct2out >/dev/null; then
  echo "ct2out is installed" | tee -a "$miRPV_PATH"/miRPV_install.log
else
  if command -v gfortran >/dev/null;then
    gfortran ct2out.f -o ct2out
    sudo cp ct2out /usr/bin/
  else
    sudo apt-get install gfortran
    gfortran ct2out.f -o ct2out
    sudo cp ct2out /usr/bin/
  fi
fi
if command -v ct2out >/dev/null;then
  echo "ct2out is installed" | tee -a "$miRPV_PATH"/miRPV_install.log
else
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "ct2out installation failed. Please install manually" | tee -a "$miRPV_PATH"/miRPV_install.log
fi
##install libSVM
cd "$miRPara_PATH"/required_packages/libsvm-3.14/
if command -v svm-predict >/dev/null; then
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
  echo "libSVM is installed" | tee -a "$miRPV_PATH"/miRPV_install.log
else
  make
  sudo cp svm-predict /usr/bin/
  if command -v svm-predict >/dev/null; then
    echo ""
  else
    echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
    echo "libSVM failed to install. Please install manually" | tee -a "$miRPV_PATH"/miRPV_install.log
  fi
fi
cd "$miRPara_PATH"/
rm test/result/test.pmt
rm test/result/test_level_1.out
perl "$miRPara" test/test.fa
if [ ! -f "$miRPara_PATH"/test.pmt ]; then
  echo "Test result file not found! miRPara test failed. Resuming installation" | tee -a "$miRPV_PATH"/miRPV_install.log
else
  echo "miRPara test Successful" | tee -a "$miRPV_PATH"/miRPV_install.log
fi
if command -v fasta_formatter >/dev/null; then
  echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
else
  sudo apt-get install gcc g++ pkg-config wget
  sudo apt-get install fastx-toolkit
fi

##installing RNAFold for TripletSVM
cd "$miRPV_PATH"
operatingSystem=$(cat /etc/os-release | grep "^ID="|  awk -F "=" '{print $2}')
if ["$operatingSystem"="ubuntu"]
then
echo `date\n` | tee -a "$miRPV_PATH"/miRPV_install.log
echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/miRPV_install.log
cd "$"
wget "https://www.tbi.univie.ac.at/RNA/download/ubuntu/ubuntu_18_10/python-rna_2.4.11-1_amd64.deb"
