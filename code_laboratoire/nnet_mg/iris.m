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



###############################################
# Define code logic here
###############################################

## Load iris data set from file
## TODO: Analyze the input data
load 'iris.mat'

## TODO : Apply any relevant transformation to the data
## (e.g. filtering, normalization, dimensionality reduction)

# appliquer la fonction de massage sur chaque colonne
for i = 1:4
  minValue = min(data(:,i));
  maxValue = max(data(:,i));
  for j = 1:150
  data(j,i) = (data(j,i) - minValue) / (maxValue - minValue);
  end
  
end

## Create neural network
## TODO : Tune the number and size of hidden layers 
nbHiddenNodes = 2;
nbInputNodes = size(data,2);
nbOutputNodes = size(target,2);
net = fann_create([nbInputNodes, nbHiddenNodes, nbOutputNodes]);

## Define training parameters
## TODO : Tune the training parameters
parameters = struct( "TrainingAlgorithm", 'incremental', ...
                     "LearningRate", 0.01, ...
                     "ActivationHidden", 'Sigmoid', ...
                     "ActivationOutput", 'Sigmoid', ...
                     "TrainErrorFunction", 'linear', ...
                     "Momentum", 0.1);
fann_set_parameters(net, parameters);

## Perform training
## TODO : Tune the maximum number of iterations and desired error 
train_data = struct("input", data, "target", target);
fann_train(net, train_data, 'MaxIterations', 10, 
                            'DesiredError', 0.1, 
                            'IterationsBetweenReports', 1);

## Save network and scaling parameters to disk
fann_save(net,"iris.net");

## Test network (loading from disk)
net = fann_create("iris.net");
res = fann_run(net, data);

## Print the number of classification errors from the training data
err = sum(abs(compet(res)-compet(target)))
