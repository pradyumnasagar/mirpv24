# Welcome to miRPV Pipeline

miRPV is an Automated pipeline for miRNA identification and validation of microRNAs from the user input genome/gene sequence.

## INTRODUCTION

----------------------------------------------------------------------------------------------

MicroRNAs play a central role in post-transcriptional gene regulation, which adjusts the cellular processes. MicroRNA are ~19-24 nt non-coding, endogenous RNAs that regulate gene expression by directing their target mRNAs for degradation or translational repression, which usually occur in 3' untranslated region (3'UTR). Accurate identification and cataloging of miRNA targets are crucial for understanding the functions of miRNA targets. To this end, numerous wet laboratory methodologies have developed, enabling validation of predicted miRNA interactions or high-performance screening and novel miRNA targets to be identified. Computational methods play essential roles in identifying new miRNAs due to the difficulty of systematically detecting miRNAs from a genome using standard experimental techniques. Analyzing the miRNAs from sequencing data is difficult as it requires compelling and convincing computational resources and bioinformatics expertise. There is a need for comparison and creation of the bioinformatics pipeline because of the complexity of choosing from complex bioinformatics algorithms. To overcome these limitations, we need a reliable and comprehensive analysis pipeline, which can automatically process the data with the integration of multiple tools within a pipeline; that's where miRPV comes into the picture. miRPV can use to identify novel miRNA from any given sequence; also, the identified miRNAs are computationally validated and compared with existing models.

The package can be downloaded from the miRPVs website:

http://slsdb.manipal.edu/miRPV/

## SYSTEM REQUIREMENT

----------------------------------------------------------------------------------------------

CPU: AMD64 (64bit), GHz Processor

Memory: 1Gb RAM

Storage: 5Gb

Internet access to download the files

Linux Environment: Installation has been tested on Ubuntu 16.04+

Software Dependencies Please note All the dependencies will be installed automatically by install.sh script. Root permission is required to install. If something goes wrong, please check the dependency and install it manually.


## INSTALLATION

----------------------------------------------------------------------------------------------

1) INSTALL Miniconda if not installed and create a new environment with python=2.7
Miniconda installing: https://docs.conda.io/en/latest/miniconda.html
Activate the environment before installing it.

2) The rest of the installation is straightforward, in miRPV package, you get a install.sh file just type:

$bash install.sh -p ~/Path/Were/miRPV Package/Present/

This installation might take a few minutes and install all the dependency require to run the Pipeline. If there is some installation error, examine the output above to identify the cause. Or you can install this dependence separately.

For Conda Users:
conda install perl-cpan-shell

Getopt::Long conda install perl-getopt-long

threads conda install perl-threaded

threads::shared conda install perl-mce-shared

CWD (CPAN) conda install perl-pathtools

or

perl -MCPAN -e 'install CWD'

File::chdir conda install perl-file-chdir

UNAFold

gfortran conda install -c anaconda gfortran_linux-64

libsvm conda install libsvm

ct2out gfortran ct2out.f -o ct2out or g77 -o ct2out ct2out.f

cp ct2out /bin/

3) MATLAB COMPILER RUNTIME (MCR):
MATLAB Compiler Runtime (MCR) is used to Extract miRNA features, as it is Matlab code. If it doesn't install via install.sh script install it separately from the Software directory.

4) Target Predication of Mature miRNA (OPTIONAL):
If you want to predict the target of mature miRNA, then download the reference sequence and keep ready in the Script folder in fasta format.

# USAGE OF miRPV

Once all the tools and dependence are install correctly, then Pipeline should be ready to use.

#### Conda environment should be activated(Python=2.7) before using the pipeline ######

** Just run from the miRPV folder:

$`bash miRPV.sh`
	`Enter the project name`
	
Provide the file name (After entering project name it will ask for a fasta file name or the sample which you are going to use. Sample file should be present where the miRPV.sh script is there)
	`<Type the fasta file name>` (Give the fasta file name)
	Eg. Test.fa (Then press Enter)

This will analyze the sample with different tools; it will take time according to the sample size.

After predicting, the mature miRNA terminal will pop-up with a dialog box to ask if target prediction is to be done?.
	1) If NO option is chosen, it will predict (Pri-miRNA, Real miRNA, Mature miRNA, and Feature of Pri-miRNA), present in the miRPV_output folder.
	2) If the YES option is chosen, keep the reference sequence in the Script folder of miRPV. Then enter the name of the reference sequence in the terminal. It will give output with a target sequence.

You will get to know when your sample run finishes when a train passes by that time you get to know that the Pipeline has run without any error. If any error occurs, examine the error and try to resolve it.

The new Directory is created Output directory in which five folders are created with each tool output. The final result of miRPV can found in the miRPV_output folder where you can see pdf file.

### If you need to know more, please contact on :

http://slsdb.manipal.edu

mlsc@manipal.edu
