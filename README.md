# miRPV
miRPV is an Automated pipeline for miRNA identification and validation of microRNAs from user input genome/gene sequence.


#note
Installer installs anaconda and creates an environment

## Minimum System Requirement
CPU: AMD64 (64 bit), 1 GHz Processor

Memory: 1 Gb RAM

Storage: 5 Gb

Internet access to download the files

Linux Environment: Installations have been tested on Ubuntu 16.04+

#Software Dependencies
Please note All the dependencies will be installed automatically by miRPV_install.sh script

Root permission is required to install
1) python-rna_2.4.11-1_amd64.deb
2) gcc
3) g++
4) pkg-config
5) wget
6) fastx-toolkit
7) unafold
8)
9)
10)
11)
12)


If some something goes wrong please check the dependency and install manually

#### MATLAB Compiler Runtime (MCR)

#### MiniConda

#### MiRPara:

##### CPAN
`conda install perl-cpan-shell`

1) Getopt::Long
`conda install perl-getopt-long`

2) threads
`conda install perl-threaded`

3) threads::shared
`conda install perl-mce-shared`

4) CWD (CPAN)
`conda install perl-pathtools`

or

`perl -MCPAN -e 'install CWD'`

5) File::chdir
`conda install perl-file-chdir`

6) UNAFold

7) gfortran
`conda install -c anaconda gfortran_linux-64`

8) libsvm
`conda install libsvm`

9) ct2out
`gfortran ct2out.f -o ct2out`
 or
`g77 -o ct2out ct2out.f`

`cp ct2out miRPV_PATH/bin/`

10)
