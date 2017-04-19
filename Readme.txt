Replication_HLM.m is the main file. It produces results in the paper for the various parameter settings reported in the paper.
Main steps are:
a) Model computation. 
b) Model simulation.
c) Recovery of model parameters (eg production function)
d) Compiles the neccessary statistics (for presentation)
e) Generates the main figures used in the paper.
f) Taking the output from the German Social Security Data, generates figures in paper.

Steps (a) to (c) are performed for each parameterization, (eg benchmark, on job search, match quality shocks, high beta etc). 
All output is saved to an Output folder. Step (d) Compiles this data. Step (e) Generates figures from this data.

All the code is in the Source folder. 

Subfolders are as follows:
EXE        : This is Fortran source code for the ranking algorithm. 
FDZCode    : This is code executed on IAB servers for empirical results. master.do is the main file which calls Stata and Matlab code.
matlab_bgl : This is a package obtained from https://www.cs.purdue.edu/homes/dgleich/packages/matlab_bgl/
MEX        : Source code for MEX files.


