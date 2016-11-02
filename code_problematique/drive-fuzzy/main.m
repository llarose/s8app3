close all
clear all
clc
more off

## Load the fuzzy logic toolbox
pkg load fuzzy-logic-toolkit

## Load the TORCS simulator functions for drive/control applications
source ../torcs_drive.m

## FLAGS
SHOW_PLOTS=1;

###############################################
# Define helper functions here
###############################################
## Set to 0 to disable plotting

function show_MFA(fis)
    plotmf(fis,'input',1);
    plotmf(fis,'input',2);
    plotmf(fis,'output',1);
    % gensurf(a,[1 2],1); view([140 37.5]);
    showrule(fis);
end
function show_MFB(fis)
    plotmf(fis,'input',1);
    plotmf(fis,'output',1);
    showrule(fis);
end

function show_MFC(fis)
    plotmf(fis,'input',1);
    plotmf(fis,'input',2);
    plotmf(fis,'output',1);
    plotmf(fis,'output',2);
    showrule(fis);
end

###############################################
# Define code logic here
###############################################

function action = drive(state,a,b,c)
  
  
  steer  = evalfis([state.angle, state.trackPos], a, 101, false);
  shift  = 0.5;
  shift  = evalfis([state.rpm], b, 101, false);
  
  speed  = sqrt((state.speedX^2)+(state.speedY^2));
  result = evalfis([speed,state.track(10)], c, 101, false); 
  
  if(isnan(steer))
    disp('steer is NAN');
    disp(state.track(10));
    disp(steer);
  end
  if(isnan(shift))
    disp('shift is NAN');
    disp(state.rpm);
  end
  if(isnan(speed))
    disp('steer is NAN');
    disp(state.track(10));
    disp(state.speed);
  end
  if(isnan(result(1)))
    disp('accel is NAN');
    disp(state.track(10));
    disp(result(1));
  end
  if(isnan(result(2)))
    disp('brake is NAN');
    disp(state.track(10));
    disp(result(2));
  end
  
  gear = state.gear;
  if gear == 0
    gear = 1;
  elseif(shift > 0.5 && gear < 6)
    gear++;
  elseif(shift < 0.5 && gear > 1)
    gear--;
  endif
 
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

  ## FUZZY LOGIC
  a=readfis('racecarctrl.fis'); 
  b=readfis('speedcarctrl.fis');
  c=readfis('accelnbrakectrl.fis'); 
  #show_MFA(a);
  show_MFB(b);
  show_MFC(c);
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
      action = drive(state,a,b,c);
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
