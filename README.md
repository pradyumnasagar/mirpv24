# miRPV: An automated pipeline for miRNA Prediction and Validation in silico

miRPV is an Automated tool that allows users to predict and validate microRNA from genome/gene sequence.
 
## miRPV Features:
* predict novel pre-miRNA from any given sequence
* predict secondary structure stability
* Predict authentic pre-miRNA 
* predict novel mature miRNA
* Predict the novel miRNA target

## Getting Started with miRPV

The installation has been tested on Ubuntu 18.04. If it has to be installed on another platform, please use the virtual machine image preinstalled with miRPV.
 
### System Requirement
* CPU: AMD64 (64bit)
* Memory: 2Gb RAM
* Storage: 5Gb
* Ubuntu 18.04

## INSTALLATION
1) Clone this repository
````
git clone https://github.com/pradyumnasagar/miRPV.git
````
````
cd miRPV
````

2) Install dependencies and create a conda environment (optional but recommended)

````
sudo apt install  cowsay enscript dialog build-essential manpages-dev
````

````
conda create -n miRPV python=2
````
````
conda activate miRPV
````
3) Run the installation script
The installer will ask root permission to install the following packages please provide it when asked.

HairpIndex, cowsay, enscript, dailog, build-essential, manpages-dev



````
bash install.sh -p  <path of miRPV folder>
````
4) Follow the on-screen guide
MATLAB Compiler Runtime (MCR) is used to Extract miRNA features, as it is Matlab code. Suppose it does not install via install.sh script install it separately from the Software directory.


### Usage
Once all the tools and dependence are installed correctly, run from the miRPV folder.
````
bash miRPV.sh
````

Provide the project name. 
* Give the input query fasta input (keep the fine in the miRPV directory).
* When asked to select the target prediction, select "Yes" or "NO."
* miRPV will ask to provide a reference sequence if the target prediction is selected. Keep the reference sequence in the miRPV folder and enter the name of the reference sequence in the terminal.
* After successful analysis, the results are saved in the output directory with the project name.



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
### Troubleshoot installation:
If there is any issue in installation, please check the failed package log, install the dependencies, and run again.



````
conda install Perl-cpan-shell
````
Getopt::Long 
````
conda install Perl-getopt-long
````
threads 
````
conda install Perl-threaded
````
threads::shared 
````
conda install Perl-mce-shared
````
CWD (CPAN) 
````
conda install Perl-pathtools
````
or

````
perl -MCPAN -e 'install CWD'
````
File::chdir 
````
conda install Perl-file-chdir
````
UNAFold
````
conda install -c bioconda oligoarrayaux
````

gfortran 
````
conda install -c anaconda gfortran_linux-64
````
libsvm 
````
conda install libsvm
````
ct2out 
````
gfortran ct2out.f -o ct2out 
````
or 
````
g77 -o ct2out ct2out.f
````
````
cp ct2out /bin/
````
### If you need to know more, please contact on :

http://slsdb.manipal.edu

mlsc@manipal.edu
