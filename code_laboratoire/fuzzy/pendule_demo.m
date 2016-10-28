## PENDULE_DEMO: Based on FISMAT
## FISMAT: Fuzzy Inference Systems toolbox for MATLAB
## (c) A. Lotfi, University of Queensland (Email: lotfia@s1.elec.uq.oz.au)
## 13-10-93

## Modified and adapted to Octave by Simon Brodeur <simon.brodeur@usherbrooke.ca>
## Université de Sherbrooke, APP3 S8GIA, A2014
## Octave 3.8.2

## Load fuzzy-logic toolbox
pkg load fuzzy-logic-toolkit

## Clear console and variables, close all figures
clc
close all
clear all

###############################################
# Define code logic here
###############################################

## TODO: Modify file 'pendule_demo.fis'
a=readfis('pendule_demo.fis');

## Set to 0 to disable plotting
SHOW_PLOTS=1;

if SHOW_PLOTS
  ## Display fuzzy sets for the linguistic variable "theta".
  plotmf(a,'input',1);

  ## Display fuzzy sets for the linguistic variable "theta_dot".
  plotmf(a,'input',2);

  ## Display fuzzy sets for the linguistic variable "Force".
  plotmf(a,'output',1);

  ## Generate three-dimensional plots for Rule Base.
  ## WARNING: very slow to produce figure!
   %gensurf(a,[1 2],1); view([140 37.5]);

  ## Show rules in human-readable form
  showrule(a);
endif

## Define the maximum number of simulation steps
## WARNING: the higher the number, the longer the simulation!
NSTEP_MAX=1000;

## Set to 0 to have a fixed initial state (pole angle at 20 degres),
## otherwise, pole angle will be randomly chosen in the interval [-20, 20].
RANDOM_POLE_ANGLE=1;

###############################################
# Simulation loop (DO NOT EDIT CODE BELOW!!!)
###############################################
figure('name','Simulation');

## Initial state: [cart position, cart velocity, pole angle , pole angular velocity]
if RANDOM_POLE_ANGLE
  pole_angle = rand() * 40 - 20;
  invpend_state_0=[-5,0,pole_angle,0]';
else
  invpend_state_0=[-5,0,20,0]';
endif

x=invpend_state_0(1);
theta=invpend_state_0(3);
x_data=[x-3 x-3 x+3 x+3 x-3];
force_data_x=[x x+20*sin(theta)];
force_data_y=[8 8+20*cos(theta)];

clf;
invpend_axes=axes('units','normal');
invpend_plot=plot(x_data,[4 8 8 4 4],force_data_x,force_data_y,'r',[-50,50],[2,2],'c');
axis([-50 50 0 40])
set(invpend_plot,'linewidth',5)
set(invpend_plot(3),'linewidth',20)
set(invpend_axes,'ytick',[])
xlabel('X position');title('Etu');

state=invpend_state_0;
for i=1:NSTEP_MAX
  pole_angle = state(3) - floor(state(3)/360) * 360;
  if pole_angle > 180
    pole_angle = pole_angle - 360;
  endif
  pole_vel = state(4);
  [force]=evalfis([pole_angle, pole_vel], a, 101, false);

	[state_dot]=invpend(state,force);
	state=state+ .05*state_dot;

	x_data=[state(1)-3 state(1)-3 state(1)+3 state(1)+3 state(1)-3];
	force_data_x=[state(1) state(1)+20*sin(state(3)*pi/180)];
	force_data_y=[8 8+20*cos(state(3)*pi/180)];

	set(invpend_plot(1),'xdata',x_data)
	set(invpend_plot(2),'xdata',force_data_x,'ydata',force_data_y)
  drawnow
  fflush(stdout);
end

disp('All done.')
