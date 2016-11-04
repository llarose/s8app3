## Copyright (c) 2016, Simon Brodeur
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
## IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECTP
## INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
## NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
## OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
## POSSIBILITY OF SUCH DAMAGE.
##

## Author: Simon Brodeur <simon.brodeur@usherbrooke.ca>

## Modified by : Louis-Antoine Larose <louis-antoine.larose@usherbrooke.ca>
##               Maxime Gagne <maxime.gagne@usherbrooke.ca>
##               Louis Pelletier <louis.pelletier@usherbrooke.ca>

## Description: Solution DRIVE- NNET
##              the neural network is based on the result from the drive-fuzzy

## Université de Sherbrooke, APP3 S8GIA, A2014
## Octave 4.0.0
clear all 
close all
clc
more off

## Load the neural-network toolbox
pkg load octave-fann

## Load the TORCS simulator functions for drive/control applications
source ../torcs_drive.m

## FLAGS
TRAIN = 1; # This flag enables the training. 

######################
# Utilitary function #
######################

## usage: OUT = scale_data(IN, MINMAX)
## Authors: Simon Brodeur 
## Modified by : Louis-Antoine Larose
##
## Scale an input vector or matrix so that the values 
## are normalized in the range [-1, 1].
##
## Input:
## - IN, the input vector or matrix.
## - inMinMax, force the values to use for scaling. 
##
## Output:
## - OUT, the scaled input vector or matrix.
## - MINMAX, the original range of IN, used later as scaling parameters. 
##
function [out, minmax] = scale_data(in, inMinMax)
	
  N = size(in,1);
  if inMinMax==0 
    minmax = [min(in)', max(in)'];
  else 
    minmax = [inMinMax];
  end
    minD = repmat(minmax(:,1),1,N)';
    maxD = repmat(minmax(:,2),1,N)';
    out = 2.*(in-minD)./(maxD-minD) - 1;   
endfunction

## usage: OUT = descale_data(IN, MINMAX)
## Authors: Simon Brodeur 
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

if TRAIN==1
  ## Load trained neural network
  load 'dataset/all.mat';

  ## Create neural network
  nbInputNodes  = 6; # Angle, RPM, SpeedX, Track, TrackPos, Gear 
  nbOutputNodes = 4; # Brake, accel, gear, steer
  nbHiddenNodes = nbInputNodes*nbOutputNodes;
  
  net = fann_create([nbInputNodes, nbHiddenNodes, nbOutputNodes]);
                       
  parameters = struct( "TrainingAlgorithm", 'rprop', ...
                       "LearningRate", 0.7, ...
                       "ActivationHidden", 'SigmoidSymmetric', ...
                       "ActivationOutput", 'SigmoidSymmetric', ...
                       "ActivationSteepnessHidden", 0.9, ...
                       "ActivationSteepnessOutput", 0.3, ...
                       "TrainErrorFunction", 'linear', ...
                       "RPropIncreaseFactor", 1.2, ...
                       "RPropDecreaseFactor", 0.5, ...
                       "RPropDeltaMin", 0.0, ...
                       "RPropDeltaMax", 50.0);
                       
  fann_set_parameters(net, parameters);
  
  ## formating data from recorded files
  for i=1:length(data)
    stimulus(i,:) = [data(i).angle, ...
                     data(i).rpm, ...
                     sqrt(data(i).speedX^2+data(i).speedY^2), ...
                     data(i).track(10),...
                     data(i).trackPos, ...
                     data(i).gear];
                    
    expected(i,:) = [data(i).accelCmd, ...
                     data(i).brakeCmd, ...
                     data(i).gearCmd,...
                     data(i).steerCmd];
                         
  end
  
  ## Scale data and target dimensions to the proper range in [-1 1]
  [data,   inScale]    = scale_data(stimulus,0);
  [target, outScale]   = scale_data(expected,0);
  scalingParameters  = struct("inScale", inScale, "outScale", outScale);
  
  ## Perform training
  train_data = struct("input", data, "target", target);
  train_data = fann_shuffle_data(train_data);
  fann_train(net, train_data, 'MaxIterations', 2500, 'DesiredError', 0.0001, 'IterationsBetweenReports', 100);

  ## Save network and scaling parameters
  fann_save(net,"torcs.net");
  save("-mat-binary","torcs-scale-params.mat", "scalingParameters");
 
endif

## NOTE: the unwind_protect block is necessary to shutdown the simulator
##       if any error occurs in the code. DO NOT REMOVE IT!
unwind_protect
  ## Connect to simulation server.
  ## NOTE: This function is defined in the file torcs_drive.m
  startSimulator(mode='gui');

  ## Loop indefinitely, or until:
  ## - The maximum number of laps is reached in the simulation.
  ## - Simulator is shutdown using the menu (press ESC during the simulation).
  ## - Octave is terminated by CTRL-C on the Command Window.
	counter = 1;
  
  # LOAD NEURAL NETWORK
  net = fann_create("torcs.net");
  load("torcs-scale-params.mat");
  
	while 1
    ## Grab the car state from the simulator.
    ## NOTE: This function is defined in the file torcs_drive.m
		[state, status] = waitForState();
		if strcmp(status,"running") == 0
			## Simulator is shutting down or no longer running, so exit.
			break;
		endif
    
    ## Test network (loading from disk)
    data =[state.angle, ...
           state.rpm, ...
           sqrt(state.speedX^2+state.speedY^2), ...
           state.track(10),...
           state.trackPos,...
           state.gear];
    
    for i=1:length(data)
      data(:,i) = scale_data(data(:,i),scalingParameters.inScale(i,:));
    end
    
    # Perform calculation of outputs. 
    res = fann_run(net, data); 
    
    # Scale data original range. 
    accel = descale_data(res(1), scalingParameters.outScale(1,:));
    brake = descale_data(res(2), scalingParameters.outScale(2,:));
    gear  = descale_data(res(3), scalingParameters.outScale(3,:));
    steer = descale_data(res(4), scalingParameters.outScale(4,:));
    
    # create struct for TORCS. 
    action = struct();
	  action.steer = steer;
		action.gear = round(gear); # the gear can't be a float. 
		action.accel = accel;
		action.brake = brake;
	
    ## Send an action to be executed by the simulator.
    ## NOTE: This function is defined in the file torcs_drive.m
    applyAction(action);
		
		## Record the current state and action in the internal saving buffer.
    ## NOTE: This function is defined in the file torcs_drive.m
		doRecord(state, action)
    
    ## Perform a saving operation every 100 recorded states.
		if mod(counter,100) == 0
			disp(sprintf("Saved %d states: distance raced = %1.1f km", counter, state.distRaced/1000.0));
      ## Save all recorded data accumulated so far.
      ## NOTE: This function is defined in the file torcs_drive.m
			saveRecordedData('data/recorded.mat');
		endif
		counter = counter + 1;
	endwhile
	
  ## Save all recorded data accumulated during the simulation to disk.
  ## NOTE: This function is defined in the file torcs_drive.m
	saveRecordedData('data/recorded.mat');
  
unwind_protect_cleanup
  ## NOTE: this block of code is called on exit
	## Close the simulator
	stopSimulator();
  disp('All done.');
end_unwind_protect
