## Copyright (c) 2014, Simon Brodeur
## All rights reserved.
## hrtsh
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

% Avoid Octave thinking this is a function file
1;

## Clear console and variables, close all figures
clc
close all
clear all
more off

###############################################
# Define helper functions here
###############################################

## usage: FITNESS = evaluateFitness(X, Y)
##
## Evaluate the 2-dimensional 'peak' function
##
## Input:
## - X, the x coordinate
## - Y, the y coordinate
##
## Output:
## - FITNESS, the value of the 'peak' function at coordinates (X,Y)
##
function fitness = evaluateFitness(x, y)
  ## The 2-dimensional function to optimize
  
	fitness = (1-x).^2.*exp(-x.^2-(y+1).^2)-(x-x.^3-y.^5).*exp(-x.^2-y.^2);
endfunction

## usage: POPULATION = initializePopulation(NUMPARAMS, POPSIZE, NBITS)
##
## Initialize the population as a matrix, where each individual is a binary string.
##
## Input:
## - NUMPARAMS, the number of parameters to optimize.
## - POPSIZE, the population size.
## - NBITS, the number of bits per indivual used for encoding.
##
## Output:
## - POPULATION, a binary matrix whose rows correspond to encoded individuals.
##
function population = initializePopulation(numparams, popsize, nbits=8)
	
  ## TODO: initialize the population
  ## il faut choisir la population de maniere aleatoire
  
  population = rand(popsize,1);
  poupulation_bin = encodeIndividual(population, nbits);

endfunction

## usage: BVALUES = encodeIndividual(CVALUES, NBITS)
##
## Encode an individual from a vector of continuous values to a binary string.
##
## Input:
## - CVALUES, a vector of continuous values representing the parameters.
## - NBITS, the number of bits per indivual used for encoding.
##
## Output:
## - BVALUES, a binary vector encoding the individual.
##
function bvalues = encodeIndividual(cvalues, nbits);
	
  ## TODO: encode individuals into binary vectors
  for i =1:length(cvalues)
    bvalues(i) =  ufloat2bin(cvalues(i), nbits);
  end
  #bvalues = zeros(length(cvalues), numparams*nbits);
endfunction

## usage: CVALUES = decodeIndividual(BVALUES, NUMPARAMS)
##
## Decode an individual from a binary string to a vector of continuous values.
##
## Input:
## - BVALUES, a binary vector encoding the individual.
## - NUMPARAMS, the number of parameters for an individual.
##
## Output:
## - CVALUES, a vector of continuous values representing the parameters.
##
function cvalues = decodeIndividual(ind, numparams);
	
  ## TODO: decode individuals from binary vectors
  
  for i = 1:length(ind)
    cvalues(i) = bin2ufloat(ind, numparams);
  end
endfunction

## usage: PAIRS = doSelection(POPULATION, FITNESS, NUMPAIRS)
##
## Select pairs of individuals from the population.
##
## Input:
## - POPULATION, the binary matrix representing the population. Each row is an individual.
## - FITNESS, a vector of fitness values for the population.
## - NUMPAIRS, the number of pairs of individual to generate.
##
## Output:
## - PAIRS, a cell array with a matrix [IND1; IND2] for each pair. 
##
function pairs = doSelection(population, fitness, numPairs)
	
	## TODO: Sort the population by fitness

	## TODO: Make sure fitness is positive

	## TODO: Perform a roulette-wheel selection
  
  pairs = {[population(1,:); population(2,:)]};
endfunction

## usage: [NIND1,NIND2] = doCrossover(IND1, IND2, CROSSOVERPROB, CUTPOINTMOD)
##
## Perform a crossover operation between two individuals, with a given probability
## and constraint on the cutting point.
##
## Input:
## - IND1, a binary vector encoding the first individual.
## - IND2, a binary vector encoding the second individual.
## - CROSSOVERPROB, the crossover probability.
## - CUTPOINTMOD, a modulo-constraint on the cutting point. For example, to only allow cutting
##   every 4 bits, set value to 4.
##
## Output:
## - NIND1, a binary vector encoding the first new individual.
## - NIND2, a binary vector encoding the second new individual.
##
function [nind1,nind2] = doCrossover(ind1, ind2, crossoverProb, cutPointMod=1)
	
  ## TODO: Perform a crossover between two individuals
  nind1 = ind1;
  nind2 = ind2;
endfunction

## usage: [NPOPULATION] = doMutation(POPULATION, MUTATIONPROB)
##
## Perform a mutation operation over the entire population.
##
## Input:
## - POPULATION, the binary matrix representing the population. Each row is an individual.
## - MUTATIONPROB, the mutation probability.
##
## Output:
## - NPOPULATION, the new population.
##
function npopulation = doMutation(population, mutationProb)

	## TODO: Apply mutation to the population
  npopulation = population;
endfunction

## usage: [BVALUE] = ufloat2bin(CVALUE, NBITS)
##
## Perform a mutation operation over the entire population.
##
## Input:
## - CVALUE, a scalar or vector of continuous values representing the parameters.
##   The values must be a real non-negative float in the interval [0,1]!
## - NBITS, the number of bits used for encoding.
##
## Output:
## - BVALUE, the binary representation of the continuous value. If CVALUES was a vector,
##   the output is a matrix whose rows correspond to the elements of CVALUES.
##
function bvalue = ufloat2bin(cvalue, nbits)
  ivalue = round(cvalue * (2^nbits-1));

  bvalue = zeros(length(cvalue), nbits);
  for i=1:length(cvalue)
    ivalue = round(cvalue(i) * (2^nbits-1));
  if ivalue > 2^nbits-1
    bvalue(i,:) = ones(1, nbits);
  elseif ivalue < 0
    bvalue(i,:) = zeros(1, nbits);
  else
    bitmask = uint32(2.^[0:nbits-1]);
    bvalue(i,:) = bitand(ivalue, bitmask) ~=0;
  endif
  end 
endfunction

## usage: [CVALUE] = bin2ufloat(BVALUE, NBITS)
##
## Perform a mutation operation over the entire population.
##
## Input:
## - BVALUE, the binary representation of the continuous values. Can be a single vector or a matrix whose
##   rows represent independent encoded values.
##   The values must be a real non-negative float in the interval [0,1]!
## - NBITS, the number of bits used for encoding.
##
## Output:
## - CVALUE, a scalar or vector of continuous values representing the parameters.
##   the output is a matrix whose rows correspond to the elements of CVALUES.
##
function cvalue = bin2ufloat(bvalue, nbits)
   ivalue = sum(bvalue .* repmat(2.^[0:size(bvalue,2)-1],size(bvalue,1),1),2)';
   cvalue = ivalue / (2^nbits - 1);
endfunction

###############################################
# Define code logic here
###############################################

## Set to 0 to disable realtime plotting of landscape and population.
## This is much faster!
SHOW_LANDSCAPE=1;

## The parameters for encoding the population
numparams = 2;

## TODO : adjust population size and encoding precision
popsize = 10;
nbits=16;

population = initializePopulation(numparams,popsize,nbits);

if SHOW_LANDSCAPE
  ## Plot function to optimize
  figure('name',['Function landscape']);
  xymin = -3.0;
  xymax = 3.0;
  [x,y]=meshgrid(xymin:.25:xymax,xymin:.25:xymax);
  z=eval('evaluateFitness(x,y)');
endif

## TODO : Adjust optimization meta-parameters
numGenerations = 15;
mutationProb = 0.05;
crossoverProb = 0.3;

bestIndividual = [];
bestIndividualFitness = -1e10;
bestGeneration = 1;
maxFitnessRecord = zeros(1,numGenerations);
overallMaxFitnessRecord = zeros(1,numGenerations);
avgMaxFitnessRecord = zeros(1,numGenerations);
for i=1:numGenerations

  if SHOW_LANDSCAPE
    ## Plot landscape
    mesh(x,y,z)
    axis([-3 3 -3 3 -1 4])
    hold;
    xlabel('x');
    ylabel('y');
    zlabel('Fitness');
    hold on;
    for p=1:popsize
        cvalues = decodeIndividual(population(p,:), numparams);
        fitness = evaluateFitness(cvalues(1), cvalues(2));
        scatter3(cvalues(1),cvalues(2),fitness+0.01,20,'r','filled')
        plot(cvalues(1),cvalues(2),'k.','markersize',8)
    endfor
    pause(0.2)
    hold;
  endif
  
	## Evaluate fitness function for all individuals in the population
	fitness = zeros(1,popsize);
	for p=1:popsize
		## Convert population to float values
		cvalues = decodeIndividual(population(p,:), numparams);
 
		## Calculate fitness
		fitness(p) = evaluateFitness(cvalues(1), cvalues(2));
	endfor
	
	## Save best individual across all generations
	bestFitness = max(fitness);
	if bestFitness > bestIndividualFitness
		idx = find(fitness == max(fitness));
		bestIndividual = population(idx,:);
		bestIndividualFitness = bestFitness;
		bestGeneration = i;
	endif
	
	## Record progress information
	maxFitnessRecord(i) = max(fitness);
	overallMaxFitnessRecord(i) = bestIndividualFitness;
	avgMaxFitnessRecord(i) = sum(fitness)/length(fitness);
	
	## Display progress information
	disp(sprintf('Generation no.%d: best fitness is %f, average is %f', i, maxFitnessRecord(i), avgMaxFitnessRecord(i)));
	disp(sprintf('Overall best fitness is %f', bestIndividualFitness));

	numPairs = popsize/2;
	newPopulation = zeros(size(population));
	pairs = doSelection(population, fitness, numPairs);
	for p=1:length(pairs)
		## Get individuals from pair
		ind1 = pairs{p}(1,:);
		ind2 = pairs{p}(2,:);
		
		## Perform a cross-over and place individuals in the new population
		[nind1,nind2] = doCrossover(ind1, ind2, crossoverProb, cutPointMod=nbits);
		newPopulation(2*p-1:2*p,:) = [nind1; nind2];
	endfor

	## Apply mutation to all individuals in the population
	newPopulation = doMutation(newPopulation, mutationProb);
	
	## Replace current population with the new one
	population = newPopulation;
endfor

## Display best individual
disp('##################################################');
disp('Best individual (decoded values):');
disp(decodeIndividual(bestIndividual, numparams));
disp('##################################################');

## Display plot of fitness over generations
figure();
n = 1:numGenerations;
plot (n, maxFitnessRecord, '-r', ...
      n, overallMaxFitnessRecord, '-b', ...
      n, avgMaxFitnessRecord, '--k');
title('Fitness value over generations');
xlabel('Generation');
ylabel('Fitness value');
legend({'Generation Max','Overall Max','Generation Average'}, 'location', 'southeast');

disp('All done.');
