# miRPV: An Automated Pipeline for miRNA Prediction and Validation In Silico

miRPV is an automated tool that enables users to predict and validate microRNAs from genome/gene sequences. 
## miRPV Features:
* Predict novel pre-miRNA from any given sequence
* Predict secondary structure stability
* Predict authentic pre-miRNA
* Predict novel mature miRNA
* Predict novel miRNA targets

## Getting Started with miRPV

The installation has been tested on Ubuntu 18.04. If you wish to install it on another platform, please use the virtual machine image preinstalled with miRPV. 
### System Requirement
* CPU: AMD64 (64bit)
* Memory: 2Gb RAM
* Storage: 5Gb
* Ubuntu 18.04

## INSTALLATION
1) Clone this repository. If git is not installed, run: 

````
sudo apt install git
````
Then, clone the repository:

````
git clone https://github.com/pradyumnasagar/miRPV.git
````
And navigate to the miRPV directory:


````
cd miRPV
````

2) Install the dependencies: 

````
sudo apt install -y cowsay enscript dialog build-essential manpages-dev curl gfortran
````
3) Create a conda environment:
````
conda create -n miRPV python=2
````
````
conda activate miRPV
````
4) Run the installation script. The installer will ask for root permission to install the following packages. Please provide it when prompted:

* HairpIndex
* cowsay
* enscript
* dialog
* build-essential
* manpages-dev


````
bash install.sh -p  <path of miRPV folder>
````
5) Follow the on-screen guide. If MATLAB Compiler Runtime (MCR) is not installed via the install.sh script, please install it separately from the Software directory.

### Usage
Once all the tools and dependencies are installed correctly, activate the Conda environment and run miRPV from the miRPV folder:
````
conda activate miRPV
````

````
bash miRPV.sh
````
* Provide a project name and input query fasta input (keep the file in the miRPV directory). 
* When asked to select the target prediction, select "Yes" or "No." 
* If the target prediction is selected, miRPV will ask for a reference sequence. 
* Keep the reference sequence in the miRPV folder and enter its name in the terminal. 
* After successful analysis, the results are saved in the output directory with the project name.




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
### Troubleshoot installation:
If there is an issue with the installation, please check the failed package log, install the dependencies, and try again:


````
conda install Perl-cpan-shell
conda install Perl-getopt-long
conda install Perl-threaded
conda install Perl-mce-shared
conda install Perl-pathtools

````

# Alternatively, you can install CWD from CPAN


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


````
cp ct2out /bin/
````
### If you require more assistance, please contact:

http://slsdb.manipal.edu

mlsc@manipal.edu
