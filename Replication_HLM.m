% This replication was performed on MATLAB R2012a
% This needs to be run from the \CODE folder
clear
addpath Source

%Benchmark Case
HLM('benchmark')
HLM('smallfirms')
HLM('highbeta')
HLM('shortsample')
HLM('matchquality')
HLM('ojs')

mkdir('Output\benchmark');
!move Output\benchmark* Output\benchmark\.
compileData('Output\benchmark')

mkdir('Output\highbeta');
!move Output\highbeta* Output\highbeta\.
compileData('Output\highbeta')

mkdir('Output\smallfirms');
!move Output\smallfirms* Output\smallfirms\.
compileData('Output\smallfirms')

mkdir('Output\shortsample');
!move Output\shortsample* Output\shortsample\.
compileData('Output\shortsample')

mkdir('Output\matchquality');
!move Output\matchquality* Output\matchquality\.
compileData('Output\matchquality')

mkdir('Output\ojs');
!move Output\ojs* Output\ojs\.
compileData('Output\ojs')

makeProdError
benchmarkFigures
ojsFigures
matchqualityFigures
highbetaFigures
shortsampleFigures
smallfirmsFigures
plotDataFromIAB
