 clear all
 cls
 cap log close
 global Bases "C:\Users\Marto\Documents\he2 multilaterales\Bases"
 global Resultados "C:\Users\Marto\Documents\he2 multilaterales\Resultados"
/* Importar base de datos ifecs*/
import delimited "${Bases}/Resultados__nicos_Saber_11_20250215.csv", clear 
save "${Bases}/saber.dta", replace
/* Destring de base */
use "${Bases}/saber.dta", clear
replace punt_matematicas = subinstr(punt_matematicas, ",", ".", .)
destring punt_matematicas, replace 
replace punt_ingles = subinstr(punt_ingles, ",", ".", .)
destring punt_ingles, replace 
*drop if punt_matematicas==. | punt_ingles==. | punt_global==.
save "${Bases}/saber1.dta", replace
use "${Bases}/saber1.dta", clear
tostring periodo, generate(periodo_str)
gen año = substr(periodo_str,1,4)
save "${Bases}/saber2.dta", replace
use "${Bases}/saber2.dta", clear
/* Quedarse con los años de 2017 a 2021 */
destring año, replace
drop if año<2018 | año>2021 
save "${Bases}/saberT.dta", replace
use "${Bases}/saberT.dta", clear
/* Collapsar base de datos */
collapse  (mean) punt_matematicas punt_ingles punt_global  , by(cole_cod_depto_ubicacion)
drop if cole_cod_depto_ubicacion==.
tostring cole_cod_depto_ubicacion,replace
replace cole_cod_depto_ubicacion = "0" + cole_cod_depto_ubicacion if strlen(cole_cod_depto_ubicacion) < 2
save "${Bases}/saber_coll_dept.dta", replace
spshape2dta "${Bases}/depto.shp",replace
  use depto, replace 
  rename (DPTO NOMBRE_DPT ) (cole_cod_depto_ubicacion nombre)
  tempfile co_dep
  save `co_dep'
  use  "${Bases}/saber_coll_dept.dta",replace
  merge 1:1 cole_cod_depto_ubicacion  using `co_dep'
  	
  #d;
  
	grmap punt_global using depto_shp,
		id(_ID)
		fcolor(Blues2)
		title("{bf: Promedio de puntaje global en el IFECS}", size(small))
		subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
		ndf(gray)
		note("{bf:Fuente:} Elaboración propia usando datos de la base del IFECS Resultados__nicos_Saber_11_20250215", size(vsmall))
		legend (position(7) ring(0))
		name(g1,replace);
  graph export "${Resultados}/mapa1.png",as(png) replace;
  
  grmap punt_global using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Promedio de puntaje matematicas en el IFECS}", size(small))
			subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos de la base del IFECS Resultados__nicos_Saber_11_20250215", size(vsmall))
			legend (position(7) ring(0))
			name(g2,replace);
  graph export "${Resultados}/mapa2.png",as(png) replace;
  
  grmap punt_global using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Promedio de puntaje ingles en el IFECS}", size(small))
			subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos de la base del IFECS Resultados__nicos_Saber_11_20250215", size(vsmall))
			legend (position(7) ring(0))
			name(g3,replace);
  graph export "${Resultados}/mapa3.png",as(png) replace;
  
  #d cr;
  /*
use "${Bases}/saber1.dta", clear
collapse  (mean) punt_matematicas punt_ingles punt_global  , by(cole_cod_mcpio_ubicacion cole_cod_depto_ubicacion)
drop if cole_cod_mcpio_ubicacion==.
tostring cole_cod_depto_ubicacion,replace
replace cole_cod_depto_ubicacion = "0" + cole_cod_depto_ubicacion if strlen(cole_cod_depto_ubicacion) < 2
tostring cole_cod_mcpio_ubicacion,replace
replace cole_cod_mcpio_ubicacion = "0" + cole_cod_mcpio_ubicacion if strlen(cole_cod_mcpio_ubicacion) < 5
gen municipio = substr(cole_cod_mcpio_ubicacion,3,.)
drop cole_cod_mcpio_ubicacion
save "${Bases}/saber_coll_munc.dta", replace
spshape2dta "${Bases}/mpio.shp",replace
  use mpio, replace 
  rename (MPIO NOMBRE_MPI DPTO NOMBRE_DPT) (municipio nombre2 cole_cod_depto_ubicacion nombre)
  tempfile mpio_dep
  save `mpio_dep'
  use  "${Bases}/saber_coll_munc.dta",replace
  merge 1:m municipio cole_cod_depto_ubicacion  using `mpio_dep'
  	
  #d;
  
	grmap punt_global using mpio_shp,
			id(_ID)
			fcolor(Blues2)
			title("Promedio de puntaje global en el IFECS", size(small))
			subtitle("Entre 2010-2022 por municipio" , size(small) )
			ndf(gray)
			legend (position(7) ring(0))
			name(g1,replace);
  graph export "${Resultados}/mapa3.png",as(png) replace;
  #d cr;
  */
 /* Cargar datos del DANE */
 
 use  "${Bases}\Tenencia y número de equipos de cómputo por sede educativa 2018.dta", clear
 append using "${Bases}\Tenencia y número de equipos de cómputo por sede educativa 2019.dta",force
 append using "${Bases}\Tenencia y número de equipos de computo por sede educativa 2020.dta"
 append using "${Bases}\Tenencía y número de equipos de computo por sede educativa 2021.dta"
 
 drop SEDECOM_CANT_PRESTA SEDECOM_CANT_SEDE
 gen usor=SEDECOM_CANTIDAD-SEDECOM_CANT_SINUSO
 save "${Bases}/tenencia y computos completa.dta", replace
 use "${Bases}/tenencia y computos completa.dta", clear
 *destring SEDE_CODIGO, replace
 rename (SEDE_CODIGO PERIODO_ANIO) (cole_cod_dane_sede año)
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
 save "${Bases}/final computo.dta", replace
 use "${Bases}/saberT.dta", clear
 collapse  (first)cole_cod_depto_ubicacion (mean) punt_matematicas punt_ingles punt_global  , by(cole_cod_dane_sede año)
 save "${Bases}/saberT collapse.dta", replace
 use  "${Bases}/final computo.dta", replace
 merge 1:1 cole_cod_dane_sede año using "${Bases}/saberT collapse.dta"
 keep if _merge==3
 drop _merge
 save "${Bases}/computo unida.dta", replace
 use "${Bases}/computo unida.dta", replace
 tostring cole_cod_depto_ubicacion,replace
 replace cole_cod_depto_ubicacion = "0" + cole_cod_depto_ubicacion if strlen(cole_cod_depto_ubicacion) < 2
 save "${Bases}/computo unida_f.dta", replace
 use "${Bases}/computo unida_f.dta", clear
 collapse (sum) tablet tabletno tabletr port portno portr compu compuno compur , by(año)
 save "${Bases}/computo unida_f_año.dta", replace
 use "${Bases}/computo unida_f.dta", clear
 collapse (sum) tablet tabletno tabletr port portno portr compu compuno compur , by(cole_cod_depto_ubicacion)
 gen tabletrealuso=(tabletr*100)/tablet
 gen portrealuso=(portr*100)/port
 gen compurealuso=(compur*100)/compu
  save "${Bases}/computo unida_f_mapa.dta", replace
 spshape2dta "${Bases}/depto.shp",replace
  use depto, replace 
  rename (DPTO NOMBRE_DPT ) (cole_cod_depto_ubicacion nombre)
  tempfile co_dep
  save `co_dep'
  use  "${Bases}/computo unida_f_mapa.dta",replace
  merge 1:1 cole_cod_depto_ubicacion  using `co_dep'
  	
  #d;
  
	grmap tabletrealuso using depto_shp,
		id(_ID)
		fcolor(Blues2)
		title("{bf: Porcentaje de tabletas usadas }", size(small))
		subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
		ndf(gray)
		note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
		legend (position(7) ring(0))
		name(g1,replace);
  graph export "${Resultados}/mapa4.png",as(png) replace;
  
  grmap portrealuso using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Porcentaje de portatiles usados}", size(small))
			subtitle("{bf:Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g2,replace);
  graph export "${Resultados}/mapa5.png",as(png) replace;
  
  grmap compurealuso using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Porcentaje de computadores usados}", size(small))
			subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g3,replace);
  graph export "${Resultados}/mapa6.png",as(png) replace;
  
  #d cr;
  /* Opción B */
  
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
 use "${Bases}/cod_dane.dta",clear
 collapse (first) cole_cod_depto_ubicacion , by(cole_cod_dane_sede año)
 merge 1:1 cole_cod_dane_sede año using "${Bases}/final computo.dta"
 keep if _merge==3
 drop _merge
 save "${Bases}/computo unida depto.dta", replace
 use "${Bases}/computo unida depto.dta", clear
 collapse (sum) tablet tabletno tabletr port portno portr compu compuno compur , by(cole_cod_depto_ubicacion)
 gen tabletrealuso=(tabletr*100)/tablet
 gen portrealuso=(portr*100)/port
 gen compurealuso=(compur*100)/compu
 save "${Bases}/computo unida depto_mapa.dta", replace
 spshape2dta "${Bases}/depto.shp",replace
  use depto, replace 
  rename (DPTO NOMBRE_DPT ) (cole_cod_depto_ubicacion nombre)
  tempfile co_dep
  save `co_dep'
  use  "${Bases}/computo unida depto_mapa.dta",replace
  merge 1:1 cole_cod_depto_ubicacion  using `co_dep'
  	
  #d;
  
	grmap tabletrealuso using depto_shp,
		id(_ID)
		fcolor(Blues2)
		title("{bf: Porcentaje de tabletas efectivamente usadas }", size(small))
		subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
		ndf(gray)
		note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
		legend (position(7) ring(0))
		name(g1,replace);
  graph export "${Resultados}/mapa4.png",as(png) replace;
  
  grmap portrealuso using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Porcentaje de portatiles efectivamente usados}", size(small))
			subtitle("{bf:Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g2,replace);
  graph export "${Resultados}/mapa5.png",as(png) replace;
  
  grmap compurealuso using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Porcentaje de computadores  efectivamente usados}", size(small))
			subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g3,replace);
  graph export "${Resultados}/mapa6.png",as(png) replace;
  
  #d cr;
  * otra base 
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
 use "${Bases}/cod_dane.dta",clear
 collapse (first) cole_cod_depto_ubicacion , by(cole_cod_dane_sede año)
 merge 1:1 cole_cod_dane_sede año using "${Bases}/edu_doce_f.dta"
 keep if _merge==3
 drop _merge
 collapse  (sum)  bachillerato tecnico licenciado posgrado sin , by(cole_cod_depto_ubicacion)
 save "${Bases}/edu_doc_f_mapa.dta",replace
 use  "${Bases}/edu_doc_f_mapa.dta",clear
 spshape2dta "${Bases}/depto.shp",replace
  use depto, replace 
  rename (DPTO NOMBRE_DPT) (cole_cod_depto_ubicacion nombre)
  tempfile co_dep
  save `co_dep'
  use  "${Bases}/edu_doc_f_mapa.dta",replace
  merge 1:1 cole_cod_depto_ubicacion  using `co_dep'
  	
  #d;
  
	grmap bachillerato using depto_shp,
		id(_ID)
		fcolor(Blues2)
		title("{bf: Cantidad de docentes con bachillerato }", size(small))
		subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
		ndf(gray)
		note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
		legend (position(7) ring(0))
		name(g1,replace);
  graph export "${Resultados}/mapa7.png",as(png) replace;
  
  grmap tecnico using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Cantidad de docentes con tecnico}", size(small))
			subtitle("{bf:Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g2,replace);
  graph export "${Resultados}/mapa8.png",as(png) replace;
  
  grmap licenciado using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Cantidad de docentes con licenciado o pegrado}", size(small))
			subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g3,replace);
  graph export "${Resultados}/mapa9.png",as(png) replace;
  
  grmap posgrado using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Cantidad de docentes con posgrado}", size(small))
			subtitle("{bf: Entre 2018-2021 por departamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g4,replace);
  graph export "${Resultados}/mapa10.png",as(png) replace;
  
  grmap sin using depto_shp,
			id(_ID)
			fcolor(Blues2)
			title("{bf: Cantidad de docentes sin ningún titulo}", size(small))
			subtitle("{bf: Entre 2018-2021 por despartamento}" , size(small) )
			ndf(gray)
			note("{bf:Fuente:} Elaboración propia usando datos del DANE", size(vsmall))
			legend (position(7) ring(0))
			name(g5,replace);
  graph export "${Resultados}/mapa11.png",as(png) replace;
  
  #d cr;
  use "${Bases}/tenencia y computos completa.dta", clear
  collapse (sum) SEDECOM_CANTIDAD SEDECOM_CANT_SINUSO usor , by(año EQUIPOCOM_ID)
  gen tipos=EQUIPOCOM_ID
  label define comput 1"Computador de escritorio" 2 "Computador portatil" 3 "Tabletas"
  label values tipos comput 
  gen porc=(usor*100)/SEDECOM_CANTIDAD
  
   #d;
  
  graph bar  (asis) porc , over(año) over(tipos)   bar(1, color(edkblue))
  ytitle("Porcentaje de computos utilizados") title("Número de computos utilizados por año")
  graphregion(color(white)) 
  blabel(bar, size(small)  format(%9.1f) angle(45))
  note("{bf:Fuente:} Elaboración propia usando datos del DANE");
  graph export "${Resultados}/grafico1.png", replace width(800) height(500) as(png);
  
  #d cr;	
  #d;
  
  graph bar  (asis) SEDECOM_CANTIDAD , over(año) over(tipos)   bar(1, color(edkblue))
  ytitle("Cantidad de computos disponibles") title("Número de computos disponibles por año")
  graphregion(color(white)) scheme(s2color)
  blabel(bar, size(vsmall)  angle(45))
  note("{bf:Fuente:} Elaboración propia usando datos del DANE");
  graph export "${Resultados}/grafico2.png", replace width(800) height(500) as(png);
  
  #d cr;	
  #d;
  
  graph bar  (asis)SEDECOM_CANT_SINUSO , over(año) over(tipos)   bar(1, color(edkblue))
  ytitle("Cantidad de computos no disponibles") title("Número de computos no disponibles por año")
  graphregion(color(white)) scheme(s2color)
  blabel(bar, size(vsmall)  angle(45))
  note("{bf:Fuente:} Elaboración propia usando datos del DANE");
  graph export "${Resultados}/grafico3.png", replace width(800) height(500) as(png);
  
  #d cr;	
  use "${Bases}/edu docente.dta",clear 
  use  "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2018.dta", clear
 append using "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2019.dta" , force
 append using "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2020.dta", force
 append using "${Bases}\Máximo nivel educativo alcanzado por los docente según rangos de edad por jornada 2021.dta"
  
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
	gen clase=1 if bachillerato==1
	replace clase=2 if tecnico==1
	replace clase=3 if licenciado==1
	replace clase=4 if posgrado==1
	replace clase=5 if sin==1
	replace clase=6 if clase==.
	label define comput2 1"Bachillerato" 2 "Tecnico" 3 "Licenciado" 4 "Posgrado" 5 "Sin titulo" 6 "Otro"
	label values clase comput2
	collapse (count) NIVELEDUCDOC_ID , by(PERIODO_ANIO clase)
	
   #d;
   graph pie, over(clase)  
   title("Composición de los docentes de 2018-2021")   
   plabel(_all percent, size(*1.5) color(white)) 
   graphregion(color(white)) scheme(s2color)
   note("{bf:Fuente:} Elaboración propia usando datos del DANE");
    graph export "${Resultados}/graficop.png", replace width(800) height(500) as(png);
  
  #d cr;
   
	
	 
 
 
 
 
 