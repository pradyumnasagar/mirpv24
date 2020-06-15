Files to Package for Standalone 
================================
-Fold_generator 
-run_Fold_generator.sh (shell script for temporarily setting environment variables and 
                        executing the application)
   -to run the shell script, type
   
     ./run_Fold_generator.sh <mcr_directory> <Input filename without extension>
       ex:
 >      ./run_Fold_generator.sh /mathworks/home/application/v98 Input_file
       
	<mcr_directory> is the directory 
    where version 9.8 of the MATLAB Runtime is installed or the directory where 
    MATLAB is installed on the machine. <Input filename without extension> is the 
    arguments you want to pass to your application. For example, 

    If you have version 9.8 of the MATLAB Runtime installed in 
    /mathworks/home/application/v98, and input file name is Input_file.txt 
     run the shell script as:
    
 >      ./run_Fold_generator.sh /mathworks/home/application/v98 Input_file
       
    If you have MATLAB installed in /mathworks/devel/application/matlab, 
    run the shell script as:
    
>       ./run_Fold_generator.sh /mathworks/devel/application/matlab Input_file
       









If you were unable to use the installer provided 
download and install the Linux version of the MATLAB Runtime for R2020a 
from the following link on the MathWorks website:

    https://www.mathworks.com/products/compiler/mcr/index.html
   

