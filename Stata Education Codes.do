* Multilevel Modelling Stata for Modelling Education Data
*
*     DEPENDANT VARIABLE: EDUCATIONAL ATTAINMENT 
*
* 	    Estimating educational trends using cohort analysis
*           Operational dependent variable: educational attainment in single years 
*           LOTY Pierre Jean-Daniel, PhD student IFORD, 2023
******************************************************************************

use "C:\Users\Loty\Desktop\THESE\THESE\2023\SEPT 2023\METHODOLOGIE\SSE EDU\EDS 2011\HOUSEHOLD MEMBER\EDS CMR 2011 INDIV MEN P1.dta", clear

* I) Fichier d'analyse

*merge v012 (age at 1st birth from INDIVIDUAL DATASET)
merge 1:1  hv001 hv002 hvidx using "E:\THESE\THESE\2023\3 SEPT 2023\METHODOLOGIE\SSE EDU\EDS 2011\INDIVIDUAL\INDIVIDUS_MERGE.dta", keepusing(age1stbirth)

*Tableau 3.5 Répartition du niveau moyen d’étude selon les « cohortes » 
table gpeage, contents(freq mean edu sd edu) row

*Dichotomisation de la variable ICNVA
generate tpauvres = ICNV_abs==0
generate pauvres = ICNV_abs==1
generate riches = ICNV_abs==3
generate triches = ICNV_abs==4
*Création de la variable ssp (femmes): chomeur (0) agriculteur (4): ouvrier qual (8) commerçant (5) ouvrier non qual (9) ménagère (6): 
*clergé (2) services (7): managers (1)
gen ssp = v717
recode ssp (0 4=1) (8 3 5 9 6=2) (2 7 =3) (1=4)
gen ssp_male = mv717
recode ssp_male (0 4=1) (8 3 5 9 6=2) (2 7 =3) (1=4)
generate ssp_male1 = ssp_male==1
generate ssp_male2 = ssp_male==2
generate ssp_male3 = ssp_male==3
generate ssp_male4 = ssp_male==4
* Combiner ssp pour les hommes et les femmes
gen ssp_malefem1 = ssp1
replace ssp_malefem1 = ssp_male1 if  ssp_male1==1
gen ssp_malefem2 = ssp2
replace ssp_malefem2 = ssp_male2 if  ssp_male2==1
gen ssp_malefem3 = ssp3
replace ssp_malefem3 = ssp_male3 if  ssp_male3==1
gen ssp_malefem4 = ssp4
replace ssp_malefem4 = ssp_male4 if  ssp_male4==1
*Autres personnes n'ayant pas déclaré leur ssp
gen  ssp_malefem5 = 0
replace ssp_malefem5 =1 if  mv717==. & v717==.
*ssp_malefem
drop ssp_malefem
gen ssp_malefem = ssp
replace ssp_malefem = ssp_male if ssp==. & ssp_male != .
recode ssp_malefem (.=5)

*Création de la variable religion (femmes): catholique (1) protestant (2) other christian (5) other(96) : musulman (3) traditional religions (4) none (7)  
*catholique (1) protestant (2) musulman (3) traditional religions (4) other christian (5) none (7) other(96)   
gen religion = v130
recode religion (1 2 5 96=1) (3 4 7=2)
*Dichotomiser
gen religion1 = religion==1
gen religion2 = religion==2 
* Combiner religion pour les hommes et les femmes
gen religion_malefem1 = religion1
replace religion_malefem1 = religion_male1 if  religion_male1==1
gen religion_malefem2 = religion2
replace religion_malefem2 = religion_male2 if  religion_male2==1
*Autres personnes n'ayant pas déclaré leur religion
gen  religion_malefem3 = 0
replace religion_malefem3 =1 if  mv130==. & v130==.
*religion_malefem
drop religion
drop religion_male
drop religion_malefem
gen religion = v130
gen religion_male = mv130
gen religion_malefem = religion
replace religion_malefem = religion_male if religion==. & religion_male != .
recode religion_malefem (1 2 5=1) (3=0) (4=2) (7 96=3) (.=4) 
*Distribution des personnes ayant déclaré leur religion  
gen religion_malefem_m = religion_malefem
recode religion_malefem_m (4=.)

*Création de la variable parité atteinte: 0-4 (1): 5-10 (2): 11-15 (3): autres (4)   
*0 (0): 1-4 (1): 5-15 (2): missing (3)  
drop pariteaR
gen pariteaR = paritea
recode pariteaR (0=0) (1/4=1) (5/15=2) (.=3)
*recode pariteaR (.=3) if age < 50  
*recode pariteaR (.=4) if age >= 50
*paritemoy
bysort region_merged3 milres ICNV_abs sex: egen paritemoy = mean(pariteaR)
reg edu pariteaR1 pariteaR3 

*Création de la variable age à la 1ère naissance: 12-20 (1): 21-39 (2): autres (3)
*12-14 (0): 15-18 (1): 19-30 (2): 31-39 (3): autres (4)   
drop age1naiss
gen age1naiss = age1stbirth
recode age1naiss (12/14=0) (15/18=1) (19/30=2) (31/39=3)  
recode age1naiss (.=4) if taille_menR ==1
recode age1naiss (.=5) if taille_menR==0
*agemoy1naiss
bysort region_merged3 milres ICNV_abs sex: egen agemoy1naiss = mean(age1stbirth)

*Création de la variable taille du ménage : 1-7 (1): 8-43 (2)   
*1-7 (RAS): plus de 7 (8): missing (9)
drop taille_menR  
gen taille_menR = taille_men
recode taille_menR (1/7=1) (8/43=0) 
reg edu taille_menR 

*Création de la variable statut matrimonial: 0:célibataire (1): 1:marié (0): 3:veuf(ve) (3): 4:divorcé(e) (2)     
drop statutmatR
gen statutmatR = statutmat
recode statutmatR (0=1) (1=0) (4=2) (3=3) 
*taux de nuptialité
bysort region_merged3 milres ICNV_abs sex: egen tauxnuptialite = mean(statutmatR)
table statutmatR, contents(freq mean edu sd edu) row
reg edu statutmatR1 statutmatR3

*Analyse descriptive (type de localité): Création de la variable "moyedu_sseregionsexecohortes" 
*Evolution du niveau d'étude moyen selon le sse, la région, le milieu de résidence et le sexe)
bysort ICNV_abs3 region_merged2 milres femme cohortes_dec : egen  moyedu_sseregionmrsexecohortes = mean(edu)
bysort ICNV_abs3 region_merged2 milres femme: tab  cohortes_dec  moyedu_sseregionmrsexecohortes

* II) Modélisation; 
*Etape 0: Modèle 0 (nul): modèle à intersection aléatoire 
xtmixed edu ||  newgse3:, mle variance 
*Etape 1: Modèle 1: modèle à pente fixe
xtmixed edu cohortes_dec || newgse3:, mle variance
*Evolution sexospécifique du niveau d'étude 
predict u0, reffects
bysort femme egen u0_femme = mean(u0) 

*Graphe des droites parralèles (pente fixe)
predict predscore, fitted
egen pickone = tag(newgse3 cohortes_dec)
sort newgse3 cohortes_dec
twoway connected predscore cohortes_dec if pickone==1, connect(ascending) 
*Etape 2: Modèle 2 à pente aléatoire
xtmixed edu cohortes_dec ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
*Test du modèle 2 par rapport au modèle 1
display invchi2tail(2, 0.01)
*Obtenir le coefficient de corrélation entre la pente et l'intersection
estat recov, corr
*Obtenir les résidus de niveau 2 pour la pente et l'intersection
predict u1 u0, reffects
bysort region_merged2 milres richesse sex: tab u0 u1
* Représentation graphique du nuage de points
egen pickone = tag(newgse3) 
scatter u1 u0 if pickone==1, yline(0) xline(0) ytitle("Pente générationnelle: variable cohortes (u1j)") xtitle("Intercection (u0j)")
*Graphe des droites séquantes (pente aléatoire)
xtmixed edu cohortes_dec ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
predict predscore, fitted
egen multiplecohorts = tag(newgse3 cohortes_dec)
bysort newgse3 (cohortes_dec): replace multiplecohorts = 0 if cohortes_dec[_N]==cohortes_dec[1]
twoway line predscore cohortes_dec if multiplecohorts==1, connect(ascending)
*Graphe de la variance intergroupe en fonction de la cohorte
twoway function 4.556 + 0.294*x + 0.044*x^2, range(0 6)
*Etape 3: Modèle 3: variable " wealth3cat1" (statut socioéconomique)
xtmixed edu cohortes_dec  i.wealth3cat1 ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
*En utilisant les variables indicatrices pour le sse
xtmixed edu cohortes_dec   PauvresMoyens PlusRiches ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
*Etape 4: Modèle 4: variable "milre_gpe1" (milieu de résidence)
*Analyse descriptive: Création de la variable "moyedu_milrescohortes" (évolution du niveau d'étude moyen selon le milieu de résidence)
bysort  milre_gpe1 cohortes_dec : egen  moyedu_milrescohortes = mean(edu)
xtmixed edu cohortes_dec PauvresMoyens PlusRiches milre_gpe1 ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
*Etape 5: Modèle 5: variable "region_merged2" (trois grandes régions)
*Analyse descriptive: Création de la variable "moyedu_sseregioncohortes" (évolution du niveau d'étude moyen selon la région et le sse)
bysort wealth3cat1 region_merged2 cohortes_dec : egen  moyedu_sseregioncohortes = mean(edu)
bysort wealth3cat1  region_merged2: tab  cohortes_dec  moyedu_sseregioncohortes
xtmixed edu cohortes_dec PauvresMoyens PlusRiches milre_gpe1  septentrional metropoles ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
*Etape 4: Modèle 3: variable "femme"
*Analyse descriptive: évolution du niveau d'étude selon le sexe
xtmixed edu cohortes_dec PauvresMoyens PlusRiches milre_gpe1  septentrional metropoles femme ||  newgse3: cohortes_dec, covariance(unstructured) mle variance


*Analyse des résidus (adéquation du modèle de régression multiple saturé)
xtmixed edu cohortes_dec PauvresMoyens PlusRiches milre_gpe1  septentrional metropoles femme||  newgse3: cohortes_dec, covariance(unstructured) mle variance
drop estd estdrank estduniform estdnscore predscore resid resid_std
predict estd, rstandard
egen estdrank = rank(estd)
generate estduniform = estdrank/(_N + 1)
generate estdnscore = invnorm(estduniform)
scatter estd estdnscore
histogram estd, frequency
predict predscore
scatter estd predscore

*Diagnostic: normalité des résidus avec droite 1ère bissectrice 
predict resid, residuals
predict resid_std, rstandard
qnorm resid_std

*Modèles pour article CIPSA
*Modèle nul
xtmixed edu ||  newgse3:, mle variance
*Modèle à pente et intersection aléatoires + variables présentées au niveau contextuel
xtmixed edu cohortes_dec i.ICNV_abs milre_gpe1 i.region_merged3 femme ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
xtmixed edu cohortes_dec i.ICNV_abs milre_gpe1 i.region_merged3 femme i.ssp_malefem i.religion_malefem i.pariteaR i.age1naiss i.statutmatR i.taille_menR ||  newgse3: cohortes_dec, covariance(unstructured) mle variance
*Résidus de niveau 2
drop u1 u0
xtmixed edu cohortes_dec ||  newgse3: cohortes_dec, mle variance
predict u1 u0, reffects
*Résidus par type de localité (types de localités déjà caractérisés selon le degré de concentration de la pauvreté)  
drop moy_u1 moy_u0
bysort region_merged3 milres sex: egen moy_u1 = mean(u1)
bysort region_merged3 milres sex: egen moy_u0 = mean(u0)
*Moyennes des résidus selon le sexe
drop u0_sex u1_sex
bysort sex: egen u0_sex = mean(u0)
bysort sex: egen u1_sex = mean(u1)
*Analyse descriptive: évolution du niveau d'étude moyen selon le sexe
bysort sex cohortes_dec : egen  moyedu_sexecohortes = mean(edu)
bysort sex: tab  cohortes_dec  moyedu_sexecohortes
