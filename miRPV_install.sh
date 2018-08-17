#!/bin/bash
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

#Set Path
miRPV_PATH=$1
miRPara_PATH=""$miRPV_PATH"/tools/miRPara/"
miRPara="$miRPV_PATH"/tools/miRPara/miRPara/miRPara/miRPara.pl
echo `date` | tee -a miRPV_install.log
echo "creating missing folders" | tee -a miRPV_install.log
mkdir -p "$miRPV_PATH"/tools/miRPara/
#mkdir -p "$miRPV_PATH"/tools/miniconda/
echo `date` | tee -a miRPV_install.log
echo "Running script as root to install missing packages" | tee -a miRPV_install.log

sudo echo "Testing dependencies installed" #Gain sudo permission
echo `date` | tee -a miRPV_install.log
echo "checking for anaconda package" | tee -a miRPV_install.log
##checks if conda is installed
if command -v conda >/dev/null; then
  #installs miRPara dependencies through conda
  echo `date` | tee -a miRPV_install.log
  echo "conda is installed, Installing other dependencies" | tee -a miRPV_install.log
  conda install -c bioconda perl-getopt-long
  if command -v cpan >/dev/null; then
    echo `date` | tee -a miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  else
    echo `date` | tee -a miRPV_install.log
    echo "cpan is not installed, installing cpan" | tee -a miRPV_install.log
    conda install -c bioconda perl-cpan-shell
    echo `date` | tee -a miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  fi
else
  #installs miniconda if not installed
  echo `date` | tee -a miRPV_install.log
  echo "Downloading and installing anaconda" | tee -a miRPV_install.log
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash Miniconda3-latest-Linux-x86_64.sh -b --license y -p "$miRPV_PATH"/tools/miniconda/
  echo "export PATH=""$miRPV_PATH"/tools/miniconda/bin:'$PATH'"" >> ~/.bashrc
  source ~/.bashrc
  conda install -c bioconda perl-getopt-long
  if command -v cpan >/dev/null; then
    echo `date` | tee -a miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  else
    echo `date` | tee -a miRPV_install.log
    echo "cpan is not installed, installing cpan" | tee -a miRPV_install.log
    conda install -c bioconda perl-cpan-shell
    echo `date` | tee -a miRPV_install.log
    echo "cpan is installed, installing perl dependences" | tee -a miRPV_install.log
    perl -MCPAN -e 'install Getopt::Long'
    perl -MCPAN -e 'install threads'
    perl -MCPAN -e 'install threads::shared'
    perl -MCPAN -e 'install Cwd'
    perl -MCPAN -e 'install File::chdir'
    perl -MCPAN -e 'install Algorithm::SVM'
  fi
fi

if command -v cpan >/dev/null; then
  echo `date` | tee -a miRPV_install.log
  echo "UNAFold is installed" | tee -a miRPV_install.log
else
  echo `date` | tee -a miRPV_install.log
  echo "UNAFold inatallation failed. Please install manually" | tee -a miRPV_install.log
fi

echo `date` | tee -a miRPV_install.log
echo "downloadin miRPara" | tee -a miRPV_install.log

#wget "https://github.com/pradyumnasagar/miRPara/archive/master.zip" -o "$miRPV_PATH"/tools/miRPara/miRPara.zip || echo "failed to download miRPara" && exit #download miRPara and store in miRPara dir in miRPV exit script if fails

wget "https://github.com/pradyumnasagar/miRPara/archive/master.zip" -o "$miRPara_PATH"/miRPara.zip || read -r -p "miRPara download failed. Closing installation in  500 seconds or press any key to close immediately" -t 500 -n 1 -s && echo "miRPara download failed." | tee -a miRPV_install.log && exit #download miRPara and store in miRPara dir in miRPV exit script if fails


cd "$miRPV_PATH"/tools/miRPara/
unzip "$miRPV_PATH"/tools/miRPara/miRPara.zip
cp "$miRPara_PATH"/miRPara/mirpara6.3.tar.gz "$miRPV_PATH"/tools/miRPara/
rm -rf "$miRPara_PATH"/miRPara/
tar -xzf mirpara6.3.tar.gz
mkdir -p "$miRPara_PATH"/required_packages/
mv "$miRPara_PATH"/miRPara/required_packages/unafold-3.8.tar.gz "$miRPara_PATH"/required_packages/unafold-3.8.tar.gz
tar -xzf "$miRPara_PATH"/required_packages/unafold-3.8.tar.gz
mv "$miRPara_PATH"/miRPara/required_packages/libsvm-3.14.tar.gz "$miRPara_PATH"/required_packages/libsvm-3.14.tar.gz
tar -xzf "$miRPara_PATH"/required_packages/libsvm-3.14.tar.gz
mkdir -p "$miRPara_PATH"/required_packages/ct2out/
mv "$miRPara_PATH"/miRPara/required_packages/ct2out/* "$miRPara_PATH"/required_packages/ct2out/

#install dependencies
##Install UNAFOLD id not installed
if command -v UNAFOLD.pl >/dev/null; then
  echo `date` | tee -a miRPV_install.log
  echo "UNAFold is installed" | tee -a miRPV_install.log
else
  echo `date` | tee -a miRPV_install.log
  echo "installing UNAFOLD" | tee -a miRPV_install.log
  cd "$miRPara_PATH"/required_packages/unafold-3.8/
  autoconf
  ./configure
  make
  sudo make install
  sudo cp "$miRPara_PATH"/required_packages/unafold-3.8/scripts/UNAFold.pl /use/bin/
  if command -v UNAFOLD.pl >/dev/null; then
    echo `date` | tee -a miRPV_install.log
    echo "UNAFold is installed" | tee -a miRPV_install.log
  else
    echo `date` | tee -a miRPV_install.log
    echo "UNAFold inatallation failed. Please install manually" | tee -a miRPV_install.log
  fi
fi

##install ct2out
cd "$miRPara_PATH"/required_packages/ct2out/
if command -v ct2out >/dev/null; then
  echo "ct2out exist"
else
  if command -v gfortran >/dev/null;then
    gfortran ct2out.f -o ct2out
    sudo cp ct2out /usr/bin/
    if command -v ct2out >/dev/null;then
      echo "ct2out is installed"
    else
      echo "ct2out installation failed please install manually"
      echo `date` | tee -a miRPV_install.log
