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

## Description: Algorithme génétique pour l'optimisation de la vitesse et de la consommation d'essence. 

## Université de Sherbrooke, APP3 S8GIA, A2016
## Octave 4.0.0

source ../torcs_opt.m

## Pour utiliser le mode sport, mettre MODE_SPORT a 1 et l'autre a 0. 
## Pour utiliser le mode eco, mettre MODE_ECO a 1 et l'autre a 0.
MODE_SPORT = 1;
MODE_ECO = 0;

###############################################
# Define helper functions here
###############################################

## Utilisation: FITNESS = evaluateFitness(maxSpeed, fuelConsumption, cvalues, mode)
##
## Evalue le fitness selon le mode choisi. Pour le mode sport, on tente de maximiser la vitesse
## maximale en faisant tendre les paramètres vers des valeurs susceptible de l'améliorer. Pour le
## mode économique on minimise la consommation d'essence. Pour son fitness, on utilise 1/consommation.                                           
##
## Entrées:
## - maxSpeed, la vitesse maximale atteinte
## - fuelConsumption, consommation d'essence en litres
## - cvalues, vecteur contenant les ratios des vitesses, le ratio du différentiel et les angles des ailerons
## - mode, le mode de la simulation (sport = 1, economique = 0)
##
## Sortie:
## - FITNESS, Pour le mode sport, on optimise la vitesse maximale et pour le mode économique on minimise la consommation
##            d'essence
##
function fitness = evaluateFitness(maxSpeed, fuelConsumption, dist, mode)

  fitness = 0;
  
  if mode == 1
    fitness = maxSpeed;
  elseif mode == 0
    fitness = 1/(fuelConsumption/(dist/1000));  ##On veut la consommation en L/Km
  endif;
  
  if(maxSpeed < 100 && dist < 1000) ##On s'assure d'avoir parcouru au moins 1km 
      fitness = 1;                  ##et d'avoir atteint 100 km/h
  endif;
endfunction

## utilisation: POPULATION = initializePopulation(NB_PARAMS, POPSIZE, NBITS)
##
## Initialise la population, ou chaque individu est encoder de facon binaire
##
## Entrées:
## - NB_PARAMS, le nombre de paramètres à optimiser.
## - POPSIZE, la grosseur de la population.
## - NBITS, le nombre de bits par individu utiliser pour l'encodage.
##
## Sortie:
## - POPULATION, une matrice binaire dont les lignes correspondent a des indivius encodés.
##
function population = initializePopulation(numparams, popsize, nbits=8)
    ## Les paramètres doivent etre dans l'intervalle [0,1] alors
    ## les valeurs sont générées aléatoirement entre [0,1].
    population = zeros(popsize,numparams*nbits);
    for i=1:popsize
        cvalues = rand(1,numparams);
        population(i,:) = encodeIndividual(cvalues, nbits);
    endfor
endfunction

## utilisation: OUT = descale_data(IN, MINMAX)
##
## Dénormalisation des données en entrées qui sont entre dans 
## l'intervalle [0,1] pour les remettres dans leur intervalle 
## respectif.
##
## Entrées:
## - IN, le vecteur d'entrée
## - MINMAX, les intervalles originaux des entrées
##
## Sortie:
## - OUT, le vecteur d'entrée dénormalisé.
##
function out = descale_data(in,minmax)
	N = size(in,1);
	minD = repmat(minmax(:,1),1,N)';
	maxD = repmat(minmax(:,2),1,N)';
	
  out = (maxD-minD).*(in - 1) + maxD;
endfunction

## utilisation: BVALUES = encodeIndividual(CVALUES, NBITS)
##
## Encode un individu contenant des valeurs continues vers un vecteur de valeurs binaire.
##
## Entrées:
## - CVALUES, vecteur de valeurs continues.
## - NBITS, nombre de bits utilisées pour l'encodage.
##
## Sortie:
## - BVALUES, vecteur binaire de l'individu encodé
##
function bvalues = encodeIndividual(cvalues, nbits);
	      NB_PARAMS = length(cvalues);
        if(cvalues(1) > 0.3)
          cvalues(1) = (0 + 0.3) * rand(1,1); ## On veut que les rations soient croissant
        endif;
        if(cvalues(2) < cvalues(1) || cvalues(2) > 0.35)
          cvalues(2) = (0 + 0.35) * rand(1,1);
        endif;
        if(cvalues(3) < cvalues(2) || cvalues(3) > 0.4)
          cvalues(3) = (0 + 0.4) * rand(1,1);
        endif;
        if(cvalues(4) < cvalues(3) || cvalues(4) > 0.45)
          cvalues(4) = (0 + 0.45) * rand(1,1);
        endif;
        if(cvalues(5) < cvalues(4) || cvalues(5) > 0.5)
          cvalues(5) = (0 + 0.5) * rand(1,1);
        endif;
        if(cvalues(7) > 0.5)
          cvalues(7) = (0 + 0.5) * rand(1,1);
        endif;
        if(cvalues(8) > 0.5)
          cvalues(8) = (0 + 0.5) * rand(1,1);
        endif;
        bvalues = ufloat2bin(cvalues, nbits);
        bvalues = reshape(bvalues', 1, NB_PARAMS*nbits);
endfunction

## utilisation: CVALUES = decodeIndividual(BVALUES, NB_PARAMS)
##
## Décodage du vecteur binaire d'un individu vers un vecteur de valeurs continues.
##
## Entrées:
## - BVALUES, vecteur binaire de l'individu encodé.
## - NB_PARAMS, nombres de paramètres par individu.
##
## Sorties:
## - CVALUES, un vecteur de valeur continues représentant les paramètres.
##
function cvalues = decodeIndividual(ind, NB_PARAMS);
	nbits = round(length(ind) / NB_PARAMS);
	bvalues = reshape(ind, nbits, NB_PARAMS)';
	cvalues = bin2ufloat(bvalues, nbits);
endfunction

## utilisation: PAIRS = doSelection(POPULATION, FITNESS, NUMPAIRS)
##
## Faire la sélection de pairs d'invidu à partir de la population
##
## Entrées:
## - POPULATION, matrice binaire représentant la population. Chaque ligne est un individu.
## - FITNESS, un vecteur contenant les valeurs de fitness de la population.
## - NUMPAIRS, le nombre de pairs d'individu à générer.
##
## Sortie:
## - PAIRS, un tableau de cellule avec une matrice [IND1; IND2] pour chaque paire. 
##
function pairs = doSelection(population, fitness, numPairs)
	
	## Trie de la population par fitness
	sortedPopulation = sortrows([population, fitness'], -(size(population,2)+1));
	fitness = sortedPopulation(:,end);
	population = sortedPopulation(:,1:end-1);

	## S'assurer que la fitness est positive
	fitness = fitness - min(fitness);
	
  fitness = fitness.^2;
  
  fitProb = cumsum(fitness) / sum(fitness);

	## Effectue une sélection par roulette
	pairs = cell(1,numPairs);
	for i=1:numPairs
		idx1 = find(fitProb > rand())(1);
		idx2 = find(fitProb > rand())(1);
		pairs{i} = [population(idx1,:); population(idx2,:)];
	endfor

endfunction

## utilisation: [NIND1,NIND2] = doCrossover(IND1, IND2, CROSSOVERPROB, CUTPOINTMOD)
##
## Effectue l'opération de croisement entre deux individus, avec une certaine probabilité
## et une contrainte sur l'endroit de coupe.
##
## Entrées:
## - IND1, vecteur binaire du 1er individu encodé.
## - IND2, vecteur binaire du 2e individu encodé.
## - CROSSOVERPROB, probabilité de croisement.
## - CUTPOINTMOD, une contraite modulo pour l'endroit de coupe.
##
## Sorties:
## - NIND1, un vecteur binaire encodant le 1er nouvel individu.
## - NIND2, un vecteur binaire encodant le 2e nouvel individu.
##
function [nind1,nind2] = doCrossover(ind1, ind2, crossoverProb, cutPointMod=8)
	nind1 = ind1;
	nind2 = ind2;
	if crossoverProb > rand() 
		## Prendre une endroit aléatoire de croisement
		idx = randint(1,1,size(ind1,2)/cutPointMod) * cutPointMod;
		nind1 = [ind1(1:idx), ind2(idx+1:end)];
		nind2 = [ind2(1:idx), ind1(idx+1:end)];
	endif
endfunction

## utilisations: [NPOPULATION] = doMutation(POPULATION, MUTATIONPROB)
##
## Effectue une mutation sur la population.
##
## Entrées:
## - POPULATION, matrice binaire représentant la population. Chaque ligne est un individu.
## - MUTATIONPROB, probabilité de mutation.
##
## Sortie:
## - NPOPULATION, la nouvelle population.
##
function npopulation = doMutation(population, mutationProb)
	mutatedBits = rand(size(population)) < mutationProb;
	npopulation = xor(population, mutatedBits);
endfunction

## utilisation: [BVALUE] = ufloat2bin(CVALUE, NBITS)
##
## Convertit une valeur continue (float) vers une valeur binaire.
##
## Entrées:
## - CVALUE, vecteur de valeurs continues. Les valeurs doivent etre dans
##           l'interval [0,1].
## - NBITS, nombre de bits utilisés pour l'encodage.
##
## Sortie:
## - BVALUE, la représentation binaire de la valeur continue. Si l'entrée est un vecteur,
##           la sortie est une matrice dont les lignes représentent les éléments de CVALUES.
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

## utilisation: [CVALUE] = bin2ufloat(BVALUE, NBITS)
##
## Convertit de binaire à continue (float)
##
## Entrées:
## - BVALUE, représentation binaire des valeurs continues. Peut etre une vecteur ou une
##           matrice dont les lignes représentent les valeurs encodées.
##           Les valeurs doivent etre dans l'interval [0,1].
## - NBITS, le nombre de bits utilisés pour l'encodage.
##
## Sortie:
## - CVALUE, vecteur de valeurs continues représentant les paramètres. les lgines de
##   la matrice de sorite correspondent aux éléments de CVALUES. 
##
function cvalue = bin2ufloat(bvalue, nbits)
   ivalue = sum(bvalue .* repmat(2.^[0:size(bvalue,2)-1],size(bvalue,1),1),2)';
   cvalue = ivalue / (2^nbits - 1);
endfunction


###############################################
# Définition de la logique de programmation
###############################################

% Connect to simulation server
startSimulator(mode='nogui');

unwind_protect
  ## Paramètres pour l'encodage de la population
  popsize = 40;
  nbits=16;
  population = initializePopulation(NB_PARAMS,popsize,nbits);
  
  ## Paramètres pour l'optimisation
  numGenerations = 40;
  mutationProb = 0.005;
  crossoverProb = 0.6;
  bestIndividual = [];
  bestIndividualFitness = -1e10;
  bestGeneration = 1;
  maxFitnessRecord = zeros(1,numGenerations);
  overallMaxFitnessRecord = zeros(1,numGenerations);
  avgMaxFitnessRecord = zeros(1,numGenerations);
  
  bestSpeed = 0;
  bestFuel = 1;
  # Boucle selon le nombre de générations
  for i=1:numGenerations

    # Générer un vecteur de paramètres aléatoires (dans le bon interval)
    # (see NB_PARAMS, MAX_PARAM_VALUES and MIN_PARAM_VALUES constants)
    disp(sprintf('Generating new parameter vector (no.%d)', i));

    # Évaluer la fitness pour tout les individus
    fitness = zeros(1,popsize);
    minmax = [0.0, 5.0; 0.0, 5.0; 0.0, 5.0; 0.0, 5.0; 0.0, 5.0; 1.0, 10.0; 0.0, 90.0; 0.0, 90.0];
    for p=1:popsize
      ## Convertir la population encodée en valeurs continues
      cvalues = decodeIndividual(population(p,:), NB_PARAMS);
      cvalues = (descale_data(cvalues,minmax));
      # Effectuer l'évaluation des paramètres
      [result, status] = evaluateParameters(cvalues, maxEvaluationTime=1000);
   
      ## Calcul de la fitness
      if MODE_SPORT
        fitness(p) = evaluateFitness(result.topspeed, result.fuelUsed, result.distraced, 1);
      elseif MODE_ECO
        fitness(p) = evaluateFitness(result.topspeed, result.fuelUsed, result.distraced, 0);
      endif;
    endfor
  
    ## Conserver le meilleur individu à travers toutes les générations
    bestFitness = max(fitness);
    if bestFitness > bestIndividualFitness
      idx = find(fitness == max(fitness));
      bestIndividual = population(idx,:);
      bestIndividualFitness = bestFitness;
      bestGeneration = i;
    endif
    bestOfGen(i,:) = decodeIndividual(bestIndividual, NB_PARAMS);
    ## Enregistrer le progrès
    maxFitnessRecord(i) = max(fitness);
    overallMaxFitnessRecord(i) = bestIndividualFitness;
    avgMaxFitnessRecord(i) = sum(fitness)/length(fitness);
  
    ## Afficher le progrès
    disp(sprintf('Generation no.%d: best fitness is %f, average is %f', i, maxFitnessRecord(i), avgMaxFitnessRecord(i)));
    disp(sprintf('Overall best fitness is %f', bestIndividualFitness));

    numPairs = popsize/2;
    newPopulation = zeros(size(population));
    pairs = doSelection(population, fitness, numPairs);
    for p=1:numPairs
      ## Obtenir les individus de la paire.
      ind1 = pairs{p}(1,:);
      ind2 = pairs{p}(2,:);
      
      ## Effectuer un croisement et placer les individus dans la nouvelle population
      [nind1,nind2] = doCrossover(ind1, ind2, crossoverProb, cutPointMod=nbits);
      newPopulation(2*p-1:2*p,:) = [nind1; nind2];
    endfor

    ## Appliquer la mutation à toute la poulation
    newPopulation = doMutation(newPopulation, mutationProb);
    
    ## Remplacer la population par la nouvelle
    population = newPopulation;  
  endfor
  
  stopSimulator();
  
  ## Afficher le meilleur individu
disp('##################################################');
disp('Best individual (decoded values):');
disp(descale_data(decodeIndividual(bestIndividual, NB_PARAMS),minmax));
disp('##################################################');

## Display plot of fitness over generations
## Afficher le graphique de la fitness sur les générations
figure();
n = 1:numGenerations;
plot (n, maxFitnessRecord, '-r', ...
      n, overallMaxFitnessRecord, '-b', ...
      n, avgMaxFitnessRecord, '--k');
if MODE_SPORT
title('Valeur de la fitness à travers les générations pour mode sport');
elseif MODE_ECO
title('Valeur de la fitness à travers les générations pour mode economique');
endif;
xlabel('Générations');
ylabel('Valeur de la fitness');
legend({'Max génération','Max global','Moyenne de la génération'}, 'location', 'southeast');

## Montre l'évolution des paramètres en prenant le meilleur individu de chaque itération
figure();
plot(bestOfGen)
legend('2e','3e','4e','5e','6e','diff','av','arr');

## Correspond à la meilleure vitesse et la meilleure consommation d'essence
## obtenue à travers toute les générations.
disp('##################################################');
if MODE_SPORT
disp('Fastest speed over 1km (Km/h):');
disp(overallMaxFitnessRecord(numGenerations));
elseif MODE_ECO
disp('Least fuel used over 1km (L/Km):');
disp(1/overallMaxFitnessRecord(numGenerations));
endif;
disp('##################################################');
  
unwind_protect_cleanup
	% Close the simulator
	stopSimulator();
  disp('All done.');
end_unwind_protect
