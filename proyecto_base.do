 clear all
 cls
 cap log close
 global Bases "C:\Users\Marto\Documents\he2 multilaterales\Bases"
 global Resultados "C:\Users\Marto\Documents\he2 multilaterales\Resultados"
 
 /* Cargar la base del ifecs */
 import delimited "${Bases}/Resultados__nicos_Saber_11_20250215.csv", clear 
 save "${Bases}/saber.dta", replace
 /* Destring de base */
 use "${Bases}/saber.dta", clear
 replace punt_matematicas = subinstr(punt_matematicas, ",", ".", .)
 destring punt_matematicas, replace 
 replace punt_ingles = subinstr(punt_ingles, ",", ".", .)
 destring punt_ingles, replace 
 tostring periodo, generate(periodo_str)
 gen año = substr(periodo_str,1,4)
 destring año, replace
 drop if año<2018 | año>2021 
 tostring cole_cod_dane_sede, replace format(%12.0f)
 save "${Bases}/saberT.dta", replace
 /* Cargar datos del DANE */
 use  "${Bases}\Tenencia y número de equipos de cómputo por sede educativa 2018.dta", clear
 append using "${Bases}\Tenencia y número de equipos de cómputo por sede educativa 2019.dta",force
 append using "${Bases}\Tenencia y número de equipos de computo por sede educativa 2020.dta"
 append using "${Bases}\Tenencía y número de equipos de computo por sede educativa 2021.dta"
 gen usor=SEDECOM_CANTIDAD-SEDECOM_CANT_SINUSO
 rename (SEDE_CODIGO PERIODO_ANIO) (cole_cod_dane_sede año)
 drop SEDECOM_CANT_PRESTA SEDECOM_CANT_SEDE
 save "${Bases}/tenencia y computos completa.dta", replace
 keep if EQUIPOCOM_ID==1
 save "${Bases}/tenencia escritorio.dta", replace
 use "${Bases}/tenencia y computos completa.dta", replace
 keep if EQUIPOCOM_ID==2
 save "${Bases}/tenencia portatil.dta", replace
 use "${Bases}/tenencia y computos completa.dta", replace
 keep if EQUIPOCOM_ID==3
 save "${Bases}/tableta.dta", replace
 use "${Bases}/tenencia escritorio", clear
 collapse  (sum) SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor , by(cole_cod_dane_sede año)
 rename (SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor) (compu compuno compur)
 save "${Bases}/tenencia escritorio collapse.dta", replace
 use"${Bases}/tenencia portatil.dta", replace
 collapse  (sum) SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor , by(cole_cod_dane_sede año)
 rename (SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor) (port portno portr)
 save "${Bases}/portatil collapse.dta", replace
 use"${Bases}/tableta.dta", replace
 collapse  (sum) SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor , by(cole_cod_dane_sede año)
 rename (SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor) (tablet tabletno tabletr)
 save "${Bases}/tableta collapse.dta", replace
 merge 1:1 cole_cod_dane_sede año using "${Bases}/portatil collapse.dta",nogenerate
 merge 1:1 cole_cod_dane_sede año using "${Bases}/tenencia escritorio collapse.dta",nogenerate
 replace tablet=0 if tablet==.
 replace tabletno=0 if tabletno==.
 replace tabletr=0 if tabletr==.
 replace port=0 if port==.
 replace portno=0 if portno==.
 replace portr=0 if portr==.
 replace compu=0 if compu==.
 replace compuno=0 if compuno==.
 replace compur=0 if compur==.
 drop if cole_cod_dane_sede ==""
 save "${Bases}/final computo.dta", replace
 
 * Cargar la base de puntajes Saber
use "${Bases}/saberT.dta", clear

* Realizar el merge con la base de computo
merge m:1 cole_cod_dane_sede año using "${Bases}/final computo.dta"

* Revisar los resultados del merge
tab _merge

* Si solo queremos las observaciones que coinciden en ambas bases
keep if _merge == 3

* Eliminar la variable de merge
drop _merge

* Guardar la base final
save "${Bases}/saber_computo.dta", replace
 
 use  "${Bases}\Carátula única sede educativa 2018.dta", clear
 append using "${Bases}\Carátula única sede educativa 2019.dta",force
 append using "${Bases}\Carátula única sede educativa 2020.dta"
 append using "${Bases}\Caratula única sede educativa 2021.dta"
 keep SEDE_CODIGO PERIODO_ANIO CODIGOINTERNODEPTO 
 rename (SEDE_CODIGO PERIODO_ANIO CODIGOINTERNODEPTO) (cole_cod_dane_sede año cole_cod_depto_ubicacion)
 tostring cole_cod_depto_ubicacion,replace
 replace cole_cod_depto_ubicacion = "0" + cole_cod_depto_ubicacion if strlen(cole_cod_depto_ubicacion) < 2
 *destring cole_cod_dane_sede, replace
 *drop if cole_cod_dane_sede==.
 save "${Bases}/cod_dane.dta", replace
 
 use  "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2018.dta", clear
 append using "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2019.dta" , force
 append using "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2020.dta", force
 append using "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2021.dta"
 keep SEDE_CODIGO PERIODO_ANIO NIVELEDUCDOC_ID
 rename (SEDE_CODIGO PERIODO_ANIO) (cole_cod_dane_sede año)
 save "${Bases}/edu docente.dta",replace	
 use "${Bases}/edu docente.dta",clear 
 gen bachillerato=1 if NIVELEDUCDOC_ID==1 | NIVELEDUCDOC_ID==2
 replace bachillerato=0 if bachillerato==.
 gen tecnico=1 if NIVELEDUCDOC_ID==6 | NIVELEDUCDOC_ID==5
 replace tecnico=0 if tecnico==.
 gen licenciado=1 if NIVELEDUCDOC_ID==8 | NIVELEDUCDOC_ID==7
 replace tecnico=0 if tecnico==.
 gen posgrado=1 if NIVELEDUCDOC_ID==9| NIVELEDUCDOC_ID==10
 replace posgrado=0 if posgrado==.
 gen sin=1 if NIVELEDUCDOC_ID==14
 replace sin=0 if sin==.
 collapse  (sum)  bachillerato tecnico licenciado posgrado sin , by(cole_cod_dane_sede año)
 save "${Bases}/edu_doce_f.dta",replace
 
 use "${Bases}/saber_computo.dta", clear
 describe cole_cod_dane_sede año
 use "${Bases}/edu_doce_f.dta", clear
 describe cole_cod_dane_sede año
 
 use "${Bases}/edu_doce_f.dta", clear
 merge 1:m cole_cod_dane_sede año using "${Bases}/saber_computo.dta"
 tab _merge
 save "${Bases}/Base_Final.dta",replace

 use "${Bases}/cod_dane.dta",clear
 collapse (first) cole_cod_depto_ubicacion , by(cole_cod_dane_sede año)
 merge 1:1 cole_cod_dane_sede año using "${Bases}/edu_doce_f.dta"
 keep if _merge==3
 drop _merge
 
 use "${Bases}/edu_doce_f.dta", clear
 collapse  (sum)  bachillerato tecnico licenciado posgrado sin , by(cole_cod_depto_ubicacion)
 save "${Bases}/edu_doc_f_mapa.dta",replace
 
 
 