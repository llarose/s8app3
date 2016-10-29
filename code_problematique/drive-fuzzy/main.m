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

function show_MF(a)
    ## Display fuzzy sets for the linguistic variable "theta".
    plotmf(a,'input',1);
    ## Display fuzzy sets for the linguistic variable "theta_dot".
    plotmf(a,'input',2);
    ## Display fuzzy sets for the linguistic variable "Force".
    plotmf(a,'output',1);
    % gensurf(a,[1 2],1); view([140 37.5]);
    showrule(a);
end

###############################################
# Define code logic here
###############################################

function action = drive(state,a)
  [steer]=evalfis([state.angle, state.trackPos], a, 101, false);
  action.accel  = 0.4;
  action.brake  = 0;
  action.gear   = 1;
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
  show_MF(a);

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
		STATE_DROP_RATE = 3;
		if mod(counter,STATE_DROP_RATE) == 0 || counter == 1
      action = drive(state,a);
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
