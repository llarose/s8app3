------------------------------
S8 - APP3 - P14 -
------------------------------
Date : 2016-11-07
Cours : GIA792 - I. A. Bio-inspirée - S8
UNIVERSITÉ DE SHERBROOKE

Étudiants : 
       Louis Pelletier
       Louis-Antoine Larose
       Maxime Gagné
 
Programme construit sur la base fourni par Simon Brodeur. 
  
Les dossiers suivants contiennent chacun une partie différente de la résolution problématique. 
Chaque section contient un fichier 'main' à éxécuter 

Section 
	1) drive-fuzzy
	Description: Permet de faire un contrôle de la voiture par logique floue.
	Exécution: Pour éxécuter le contrôle de la voiture par logique floue, ouvrir 'main_mamdani.m'  ou 'main_sugeno.m' et l'éxécuter sous Octave dans la machine virtuelle fournie dans le cadre de l'app3 du cours d'intelligence artificiel.

	2) drive-nnet
	Description: Permet de faire une contrôle de la voiture par réseau de neuronnes
	Exécution: Pour éxécuter le contrôle de la voiture par réseau de neuronnes, ouvrir 'main.m' et l'éxécuter sous Octave dans la machine virtuelle fournie dans le cadre de l'app3 du cours d'intelligence artificiel.

  Pour exécuter l'apprentissage, il faut que la variable "TRAIN" soit à "1"
  
	3) optimise-ga
	Description: Permet de faire une maximisation de la vitesse de la voiture ainsi qu'une minimisation de la consommation d'essence de la voiture.
	Exécution: Pour éxécuter l'optimination des différents mode, ouvrir 'main.m' et l'éxécuter sous Octave dans la machine virtuelle fournie dans le cadre de l'app3 du cours d'intelligence artificiel. 

	Pour exécuter la maximisation de la vitesse, il faut que la variable "MODE_SPORT" soit à "1" et "MODE_ECO" à "0".

	Pour le mode économie de carburant, il faut que la variable "MODE_SPORT" soit à "0" et "MODE_ECO" à 1.

	4) Système ANFIS
	Le pseudo code pour une implémentation ANFIS est disponible dans le fichier PSEUDO_CODE_ANFIS.txt
	Ce fichier ne s'exécute pas. 