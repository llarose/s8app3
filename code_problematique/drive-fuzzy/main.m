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

## Description: Solution DRIVE-FUZZY. 

## Université de Sherbrooke, APP3 S8GIA, A2014
## Octave 4.0.0

close all
clear all
clc
more off

## Load the fuzzy logic toolbox
pkg load fuzzy-logic-toolkit

## Load the TORCS simulator functions for drive/control applications
source ../torcs_drive.m

## FLAGS
SHOW_PLOTS = 1; # This flag enables render of memberships functions.

################################################
# Function for displaying membership functions #
################################################
function show_MF_direction(fis)
    plotmf(fis,'input',1);
    plotmf(fis,'input',2);
    plotmf(fis,'output',1);
    # gensurf(fis,[1 2],1); view([140 37.5]);
    showrule(fis);
end
function show_MF_gear(fis)
    plotmf(fis,'input',1);
    plotmf(fis,'output',1);
    # gensurf(fis,[1],1); view([140 37.5]);
    showrule(fis);
end
function show_MF_accel_brake(fis)
    plotmf(fis,'input',1);
    plotmf(fis,'input',2);
    plotmf(fis,'output',1);
    plotmf(fis,'output',2);
    # gensurf(fis,[1 2],1); view([140 37.5]);
    showrule(fis);
end

############################################################
# function Drive                                           #
#   compute actions to make based on the state of the car. #
############################################################
function action = drive(state,direction_fis,gear_fis,accel_brake_fis)
  
  shift  = 0.5; 
  
  # pretreatment data
  speed  = sqrt((state.speedX^2)+(state.speedY^2));
  
  # compute fuzzy values. 
  steer  = evalfis([state.angle, state.trackPos], direction_fis, 101, false);
  shift  = evalfis([state.rpm], gear_fis, 101, false);
  result = evalfis([speed,state.track(10)], accel_brake_fis, 101, false); 
  
  # NNET will fail if the fuzzy creates NAN (not a number)
  # These IFs are for debugging purposes. 
  # When printed out on consol, the developpers knows something when wrong
  # Essentially, this occurs when the car goes off the road. 
  if(isnan(steer))
    disp('steer is NAN');
  end
  if(isnan(shift))
    disp('shift is NAN');
  end
  if(isnan(speed))
    disp('steer is NAN');    
  end
  if(isnan(result(1)))
    disp('accel is NAN');
  end
  if(isnan(result(2)))
    disp('brake is NAN');
  end
  
  # The fuzzy logic does not compute a gear. 
  # It computes when should we shift the gear. 
  # if shift is bellow 0.5, we downshift.
  # if shift is over 0.5, we upshift.
  # if shift is egal 0.5, we keep the current gear. 
  gear = state.gear;
  if gear == 0 # From neutral to first gear. 
    gear = 1;
  elseif(shift > 0.5 && gear < 6) # up shift
    gear++;
  elseif(shift < 0.5 && gear > 1) # down shift. 
    gear--;
  endif
  
  # Returns a struct.
  action.accel  = result(1);
  action.brake  = result(2);
  action.gear   = gear;
  action.steer  = steer;
  
endfunction

## NOTE: the unwind_protect block is necessary to shutdown the simulator
##       if any error occurs in the code. DO NOT REMOVE IT!
unwind_protect
  
  ## Connect to simulation server.
  ## NOTE: This function is defined in the file torcs_drive.m
  startSimulator(mode='gui');

  ## LOAD FUZZY LOGIC
  direction_fis = readfis('direction_ctrl.fis'); 
  gear_fis =readfis('gear_ctrl.fis');
  accel_brake_fis =readfis('accel_brake_ctrl.fis'); 
  
  ## DISPLAY MEMBERSHIP FUNCTION. 
  if (SHOW_PLOTS == true)
    #show_MF_direction(direction_fis);
    #show_MF_gear(gear_fis);
    #show_MF_accel_brake(accel_brake_fis);
  end
  
  ## Loop indefinitely, or until:
  ## - The maximum number of laps is reached in the simulation.
  ## - Simulator is shutdown using the menu (press ESC during the simulation).
  ## - Octave is terminated by CTRL-C on the Command Window.
	counter = 1;
	lastAction = struct();
  
	while 1
    ## Grab the car state from the simulator.
    ## NOTE: This function is defined in the file torcs_drive.m
		[state, status] = waitForState();
		if strcmp(status,"running") == 0
			## Simulator is shutting down or no longer running, so exit.
			break;
		endif
	
    ## IMPORTANT: Because the fuzzy inference is slow with the toolbox, we may need to drop states
    ## Use STATE_DROP_RATE = 1 to disable state dropping.
		STATE_DROP_RATE = 2;
		if mod(counter,STATE_DROP_RATE) == 0 || counter == 1
      action = drive(state,direction_fis,gear_fis,accel_brake_fis);
		else
			action = lastAction;
		endif
		lastAction = action;
  
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
