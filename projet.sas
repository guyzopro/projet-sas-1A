/*proc import datafile = 'C:\Users\gangoula\Desktop\SAS\Projet\ESS6e02_6.csv'
out = work.ess
dbms = CSV replace;
guessingrows=max;
run;
*/
LIBNAME don "C:\Users\gangoula\Desktop\SAS\Projet";
DATA don.ess06;
set ess;
run;

/* On déplace la base ess dans la bibliothèque work */

DATA ess;
	SET don.ess06;
RUN;

/*On ne conserve que les variables pertinentes*/

DATA base_travail (keep=dscrgrp dscrgnd dscrrlg dscrsex dscrntn dscretn dscrlng dscrage dscrrce dscrdsb dscrref dscroth dscrna dscrnap dscrdk happy sclmeet sclact stfgov trstplc trstplt);
	SET don.ess06;
Run;


/* On sauvegarde la base de travail don (elle est provisoirement dans le work) */
DATA don.base_travail;
	SET base_travail;
Run;

/* On cherche la proportion des personnes dans l'échantillon français qui considère appartenir à un groupe discriminé */
Proc Format;
	Value Discrimination
	1="Membre d'un groupe discriminé"
	2="Pas membre d'un groupe discriminé"
	7="Refus de répondre"
	8="Ne sais pas"
	9="Aucune réponse"
	;
Run;
title "Proportions des différents groupes dans l'échantillon";
PROC Freq data = don.base_travail;
table  dscrgrp;
format dscrgrp Discrimination.;
Run;

/* On veut représenter les proportions de discriminés en fonction de leurs critères de discrimination*/

/* Etape 1: Dans le work, on va créer une copie de notre base de travail où l'on ne retrouvera que les enregistrements des personnes qui se sentent discriminés*/

data discrimines;
set don.base_travail;
if dscrgrp=1;
run;

/* Etape 2: Dans cette nouvelle base de données on crèe une nouvelle variable (caracc) qui va nous permettre d'identifier le type de discrimination*/

data discrimines;
set discrimines;
Length carac$ 30;
if dscrgnd=1 then carac='Genre';
else if dscrrlg=1 then carac='Religion';
else if dscrsex=1 then carac='Orientation sexuelle';
else if dscrntn=1 then carac='Nationalité';
else if dscretn=1 then carac='Groupe ethnique';
else if dscrlng=1 then carac='Langue';
else if dscrage=1 then carac='Age';
else if dscrrce=1 then carac='Couleur de peau';
else if dscrdsb=1 then carac='Handicap';
else if dscrref=1 then carac='Refus de répondre';
else if dscroth=1 or dscrna=1 or dscrnap=1 or dscrdk=1 then carac='Autres';
Run;

/* Etape 3: On réalise un diagramme circulaire*/
title "Proportions des discriminés selon les critères de discrimination";
Proc Gchart Data = discrimines;
Pie carac / type = freq percent = inside otherslice=0;
Run;
Quit;


/* Création d'une nouvelle variable happy_score */

data don.base_travail;
set don.base_travail;
length happy_score$30;
if happy NE . and happy<=4 then happy_score='Pas heureux';
else if happy>4 and happy<=7 then happy_score='Heureux';
else happy_score='Très heureux';
run;


/*Visualisation de la distribution de happy_score entre les différents groupes discriminés et non*/



title "Distribution des catégories de la variable Happy_score chez les discriminés";
proc freq data=don.base_travail;
    tables happy_score / plots=freqplot;
	where dscrgrp=1;
run;
title "Distribution des catégories de la variable Happy_score chez les personnes non discriminés";
proc freq data=don.base_travail;
    tables happy_score / plots=freqplot;
	where dscrgrp=2;
run;


/*Moyenne de la var happy chez les personnes discriminés et celles non discriminés*/

title "Moyenne de la variable happy chez les personnes ne se sentant pas discriminés";
Proc means data = don.base_travail;
	where dscrgrp=1 and happy>=0 and happy<=10;
	var happy;
Run;


title "Moyenne de la variable happy chez les personnes se sentant discriminés";
Proc means data = don.base_travail;
	where dscrgrp=2 and happy>=0 and happy<=10;
	var happy;
Run;

/* Boite à moustache */
title "Boite de Tukey de la variable happy selon que les individus soient discriminés ou non";
Proc sort data = don.base_travail;
by dscrgrp;
Run;
Proc Boxplot data = don.base_travail;
where happy>=0 and happy<=10;
Plot happy*dscrgrp/ boxstyle = SCHEMATIC;
Run; Quit;


/*3*/

/*Confiance envers les institutions*/

/*How satisfied with the national government*/
title "A quel point faites-vous confiance au gouvernement (Personnes se sentant discriminés)?";
Proc Freq data = don.base_travail;
table stfgov;
where dscrgrp=1;
run;

title "A quel point faites-vous confiance au gouvernement (Personnes ne se sentant pas discriminés)?";
Proc Freq data = don.base_travail;
table stfgov;
where dscrgrp=2;
run;

/*Trust in the police (s'intérésser au valeurs extrêmes)*/
title "A quel point faites-vous confiance à la police (Personnes se sentant discriminés)?";
Proc Gchart Data = don.base_travail;
Pie trstplc / type = freq percent = inside otherslice=0;
where trstplc>=0 and trstplc<=10 and dscrgrp=1;
Run;
Quit;

title "A quel point faites-vous confiance à la police (Personnes ne se sentant pas discriminés)?";
Proc Gchart Data = don.base_travail;
Pie trstplc / type = freq percent = inside otherslice=0;
where trstplc>=0 and trstplc<=10 and dscrgrp=2;
Run;
Quit;


/*Trust in politicians*/


title "Distribution de la variable trstplt chez les personnes non discriminés";
proc freq data=don.base_travail;
    tables trstplt / plots=freqplot;
	where dscrgrp=2 and trstplt>=0 and trstplt<=10;
run;

title "Distribution de la variable trstplt chez les personnes discriminés";
proc freq data=don.base_travail;
    tables trstplt / plots=freqplot;
	where dscrgrp=1 and trstplt>=0 and trstplt<=10;
run;



/*4*/

/*Tu pourras introduire dans cette partie un sclmeet_score qui (vie fa*/

title "Distribution des catégories de la variable Happy_score chez les personnes discriminées qui ont une vie sociale riche ";
proc freq data=don.base_travail;
    tables happy_score / plots=freqplot;
	where dscrgrp=1 and sclmeet>=4 and sclmeet<=7;
run;

title "Distribution des catégories de la variable Happy_score chez les personnes discriminées qui ont une faible vie sociale";
proc freq data=don.base_travail;
    tables happy_score / plots=freqplot;
	where dscrgrp=1 and sclmeet>=1 and sclmeet<=3;
run;







