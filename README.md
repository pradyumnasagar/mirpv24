# miRPV: in silico miRNA Prediction and Validation Pipeline

miRPV is an Automated tool that allows users to predict and validate microRNA from genome/gene sequence.
 
## miRPV Features:
predict novel pre-miRNA from any given sequence
predict secondary structure stability
Predict authentic pre-miRNA 
predict novel mature miRNA
Predict the novel miRNA target

## Getting Started with miRPV

The installation has been tested on Ubuntu 18.04. If it has to be installed on another platform, please use the virtual machine image preinstalled with miRPV.
 
### System Requirement
CPU: AMD64 (64bit)
Memory: 2Gb RAM
Storage: 5Gb
Ubuntu 18.04

## INSTALLATION
1) Clone this repository
````
git clone https://github.com/pradyumnasagar/miRPV.git
````
````
cd miRPV
````

2) Install and create a conda environment (optional but recommended)
````
conda create -n miRPV python=2
````
````
conda activate miRPV
````
3) Run the installation script
````
bash install.sh -p  <path of miRPV folder>
````
4) Follow the on-screen guide
MATLAB Compiler Runtime (MCR) is used to Extract miRNA features, as it is Matlab code. Suppose it does not install via install.sh script install it separately from the Software directory.


### Usage
Once all the tools and dependence are installed correctly, run from the miRPV folder
````
bash miRPV.sh
````

Target Predication of Mature miRNA (optional):
To predict the target of mature miRNA, download the reference sequence and keep it ready in the Script folder in fasta format.

