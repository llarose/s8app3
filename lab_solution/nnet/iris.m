## Copyright (c) 2014, Simon Brodeur
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without modification,
## are permitted provided that the following conditions are met:
## 
##  - Redistributions of source code must retain the above copyright notice, 
##    this list of conditions and the following disclaimer.
##  - Redistributions in binary form must reproduce the above copyright notice, 
##    this list of conditions and the following disclaimer in the documentation 
##    and/or other materials provided with the distribution.
##  - Neither the name of Simon Brodeur nor the names of its contributors 
##    may be used to endorse or promote products derived from this software 
##    without specific prior written permission.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
## ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
## WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
## IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
## INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
## NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
## OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
## POSSIBILITY OF SUCH DAMAGE.
##

## Author: Simon Brodeur <simon.brodeur@usherbrooke.ca>
## Université de Sherbrooke, APP3 S8GIA, A2014
## Octave 3.8.2

## Load the neural network toolbox
pkg load octave-fann

## Avoid Octave thinking this is a function file
1;

###############################################
# Define helper functions here
###############################################

## usage: OUT = scale_data(IN, MINMAX)
##
## Scale an input vector or matrix so that the values 
## are normalized in the range [-1, 1].
##
## Input:
## - IN, the input vector or matrix.
##
## Output:
## - OUT, the scaled input vector or matrix.
## - MINMAX, the original range of IN, used later as scaling parameters. 
##
function [out, minmax] = scale_data(in)
	N = size(in,1);
  minmax = [min(in)', max(in)'];
	minD = repmat(minmax(:,1),1,N)';
	maxD = repmat(minmax(:,2),1,N)';
	out = 2.*(in-minD)./(maxD-minD) - 1;
endfunction

## usage: OUT = descale_data(IN, MINMAX)
##
## Descale an input vector or matrix so that the values 
## are denormalized from the range [-1, 1].
##
## Input:
## - IN, the input vector or matrix.
## - MINMAX, the original range of IN. 
##
## Output:
## - OUT, the descaled input vector or matrix.
##
function out = descale_data(in,minmax)
	N = size(in,1);
	minD = repmat(minmax(:,1),1,N)';
	maxD = repmat(minmax(:,2),1,N)';
	
	out = ((in + 1)/2).*(maxD-minD) + minD;
endfunction

###############################################
# Define code logic here
###############################################

## Load iris data set from file
load 'iris.mat'

## Scale data and target dimensions to the proper range in [-1, 1]
[data,inScale] = scale_data(data);
[target,outScale] = scale_data(target);
scalingParameters = struct("inScale",inScale,"outScale",outScale);

## Create neural network
nbInputNodes = size(data,2);
nbHiddenNodes = 10;
nbOutputNodes = size(target,2);
net = fann_create([nbInputNodes, nbHiddenNodes, nbOutputNodes]);

## Define training parameters
parameters = struct( "TrainingAlgorithm", 'incremental', ...
                     "LearningRate", 0.1, ...
                     "ActivationHidden", 'SigmoidSymmetric', ...
                     "ActivationOutput", 'SigmoidSymmetric', ...
                     "TrainErrorFunction", 'linear', ...
                     "Momentum", 0.9);

%parameters = struct( "TrainingAlgorithm", 'rprop', ...
%                     "LearningRate", 0.7, ...
%                     "ActivationHidden", 'SigmoidSymmetric', ...
%                     "ActivationOutput", 'SigmoidSymmetric', ...
%                     "ActivationSteepnessHidden", 0.5, ...
%                     "ActivationSteepnessOutput", 0.5, ...
%                     "TrainErrorFunction", 'linear', ...
%                     "RPropIncreaseFactor", 1.2, ...
%                     "RPropDecreaseFactor", 0.5, ...
%                     "RPropDeltaMin", 0.0, ...
%                     "RPropDeltaMax", 50.0);

%parameters = struct( "TrainingAlgorithm", 'qprop', ...
%                     "LearningRate", 0.7, ...
%                     "ActivationHidden", 'SigmoidSymmetric', ...
%                     "ActivationOutput", 'SigmoidSymmetric', ...
%                     "ActivationSteepnessHidden", 0.5, ...
%                     "ActivationSteepnessOutput", 0.5, ...
%                     "TrainErrorFunction", 'linear', ...
%                     "QuickPropDecay", -0.0001, ...
%                     "QuickPropMu", 1.75);
fann_set_parameters(net, parameters);

## Perform training
train_data = struct("input", data, "target", target);
train_data = fann_shuffle_data(train_data);
fann_train(net, train_data, 'MaxIterations', 1000, 'DesiredError', 0.0001, 'IterationsBetweenReports', 10);

## Save network and scaling parameters to disk
fann_save(net,"iris.net");
save("-mat-binary", "iris-scale-param.mat", "scalingParameters");

## Test network (loading from disk)
net = fann_create("iris.net");
res = fann_run(net, data);
err = sum(abs(compet(res)-compet(target)))
