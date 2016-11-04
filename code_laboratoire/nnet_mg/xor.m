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

## XOR data set
data = [0,0; 0,1; 1,0; 1,1];
target = [0; 1; 1; 0];

## Create neural network
nbInputNodes = size(data,2);
nbHiddenNodes = 2;
nbOutputNodes = size(target,2);
net = fann_create([nbInputNodes, nbHiddenNodes, nbOutputNodes]);

## Define training parameters

## WARNING: Incremental learning doesn't seem to work for this example!
%parameters = struct( "TrainingAlgorithm", 'incremental', ...
%                     "LearningRate", 0.1, ...
%                     "ActivationHidden", 'Sigmoid', ...
%                     "ActivationOutput", 'Sigmoid', ...
%                     "TrainErrorFunction", 'linear', ...
%                     "Momentum", 0.5);

parameters = struct( "TrainingAlgorithm", 'rprop', ...
                     "LearningRate", 0.7, ...
                     "ActivationHidden", 'Sigmoid', ...
                     "ActivationOutput", 'Sigmoid', ...
                     "ActivationSteepnessHidden", 0.5, ...
                     "ActivationSteepnessOutput", 0.5, ...
                     "TrainErrorFunction", 'TanH', ...
                     "RPropIncreaseFactor", 1.2, ...
                     "RPropDecreaseFactor", 0.5, ...
                     "RPropDeltaMin", 0.0, ...
                     "RPropDeltaMax", 50.0);

%parameters = struct( "TrainingAlgorithm", 'qprop', ...
%                     "LearningRate", 0.7, ...
%                     "ActivationHidden", 'Linear', ...
%                     "ActivationOutput", 'Sigmoid', ...
%                     "ActivationSteepnessHidden", 0.5, ...
%                     "ActivationSteepnessOutput", 0.5, ...
%                     "TrainErrorFunction", 'TanH', ...
%                     "QuickPropDecay", -0.0001, ...
%                     "QuickPropMu", 1.75);
                     
fann_set_parameters(net, parameters);

## Perform training
train_data = struct("input", data, "target", target);
train_data = fann_shuffle_data(train_data);
fann_train(net, train_data, 'MaxIterations', 1000, 
                            'DesiredError', 0.0001, 
                            'IterationsBetweenReports', 1);

## Save network and scaling parameters to disk
fann_save(net,"xor.net");

## Test network (loading from disk)
net = fann_create("xor.net");
res = fann_run(net, data);

## Print the number of classification errors from the training data
err = sum(abs(round(res)-target))
