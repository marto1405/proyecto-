  clear all
  cls
  cap log close
  log using "C:\Users\Marto\Documents\econometria\ECONOMETRIA AVANZADA\Proyecto/.log", replace 
  global Bases "C:\Users\Marto\Documents\econometria\ECONOMETRIA AVANZADA\Proyecto\Bases"
  global Resultados "C:\Users\Marto\Documents\econometria\ECONOMETRIA AVANZADA\Proyecto\Resultados"
  
  /* Establecemos el directorio */
  
  use  "${Bases}/PANEL_CONFLICTO_Y_VIOLENCIA(2022)",clear
  
  /* Para este analisis  se utiliza  los años de 1993 a 2007 */
  
  drop if ano>=2009                

  /*
  Generamos  una variable de dummys que toma 1 para las distintas conversaciones 
  de paz del gobierno colombiano con los grupos de las farc para este caso se 
  toman las negociaciones en 1994-1996, 199-2002 y 2005-2006
  */
  
  gen treatment = .
  replace treatment = 1 if inrange(ano, 1999, 2002) & (tpobc_AUC == . | tpobc_AUC == 0) & (tpobc_FARC != . & tpobc_FARC != 0) & (tpobc_ELN == . | tpobc_ELN == 0)
  replace treatment = 0 if treatment == .
  
  tostring codmpio,gen(codmpio1)
  replace codmpio1 = "0" + codmpio1 if length(codmpio1)==4
  
  gen depto=substr(codmpio1,1,2)
  
  save "${Bases}\BF.dta",replace
  
  cd "${Bases}"
  spshape2dta "co_dep/co_dep",replace
  use co_dep, replace 
  rename (DPTO_CCDGO DPTO_CNMBR) (depto nombre)
  tempfile co_dep
  save `co_dep'
  
  use  "${Bases}\BF.dta",replace
  collapse (mean) tpobc_FARC,  by(depto )
  merge 1:1 dept  using `co_dep'
	
  #d;
  
	grmap tpobc_FARC using co_dep_shp,
			id(_ID)
			fcolor(Blues2)
			title("Promedio de asaltos a la pobalción civil por las FARC", size(small))
			subtitle("Entre 1993-2008 por departamento" , size(small) )
			ndf(gray)
			legend (position(7) ring(0))
			name(g1,replace);
  graph export "${Resultados}/mapa.png",as(png) replace;
  #d cr;
  
  use  "${Bases}\BF.dta",replace
  collapse (mean) secci_FARC,  by(depto )
  merge 1:1 dept  using `co_dep'
	
  #d;
  
	grmap secci_FARC using co_dep_shp,
			id(_ID)
			fcolor(Blues2)
			title("Promedio de secuestros a la pobalción civil por las FARC", size(small))
			subtitle("Entre 1993-2008 por departamento" , size(small) )
			ndf(gray)
			legend (position(7) ring(0))
			name(g1,replace);
  graph export "${Resultados}/mapa2.png",as(png) replace;
  #d cr;
  
  use  "${Bases}\BF.dta",replace
  
  /* Variables de interes*/
  
  sum secci_FARC tpobc_FARC,d
  outreg2 using "${Resultados}\Estadisticas.doc", sum(detail) replace ///
  keep(secci_FARC tpobc_FARC) eqkeep(N mean sd max p50 min)
  
  collapse (sum)secci_FARC (sum)tpobc_FARC, by(ano)
  sum
  #d;
  graph bar (mean) tpobc_FARC, over(ano, label(angle(45)))
    ytitle("Frecuencia") scheme(white ptol)
    graphregion(color(white))
    title("N° de asaltos a población civil por FARC") 
    bar(1, color(edkblue)) legend(off) 
	 blabel(bar, size(medium) color(black) position(outside) lwidth(vvvthick))
	note("{bf:Fuente:} Elaboración propia usando datos de la base PANEL_CONFLICTO_Y_VIOLENCIA(2022)");
	graph export "${Resultados}\grafico8.png", as(png) replace width(6000) height(3000) ;
  #d cr;
  
  #d;
  graph bar (mean) secci_FARC, over(ano, label(angle(45)))
    ytitle("Frecuencia") scheme(white ptol)
    graphregion(color(white))  
	 blabel(bar, size(medium) color(black) position(outside) lwidth(vvvthick))
    title("N° de secuestros a la población civil por FARC") 
    bar(1, color(edkblue)) legend(off) 
	note("{bf:Fuente:} Elaboración propia usando datos de la base PANEL_CONFLICTO_Y_VIOLENCIA(2022)");
	graph export "${Resultados}\grafico9.png", as(png) replace width(6000) height(3000) ;
  #d cr;
 
  
  use  "${Bases}\BF.dta",replace
  /* Generamos la variable que nos captura la turn on y turn off del tratamiento */
  
  bys codmpio: gen D0 = treatment[1]
  gen D_change = abs(treatment - D0) != 0
  bys codmpio: gen at_least_one_D_change = sum(D_change)
  
  /* Generasmos los controles y el primer periodo de tratamiento */
  
  bys codmpio: egen never_treated = max(at_least_one_D_change)
  replace never_treated = 1 - never_treated
  bys codmpio: egen F_g_temp = min(ano * D_change) if D_change != 0
  bys codmpio: egen F_g = mean(F_g_temp)
  sum ano
  replace F_g = r(max) + 1 if missing(F_g)
  gen subsample = (4 - mod(F_g, 4)) * (mod(F_g, 4) != 0) + 1
  replace subsample = 0 if at_least_one_D_change == 0
  
  /* En este caso no se pueden considerar missing values */
  
  keep if !missing(codmpio)
  
  /* Definimosque tenemos datos tipo panel */
  
  xtset codmpio ano
  
  /* Correr los modelos */
  
  reghdfe tpobc_FARC at_least_one_D_change , absorb(codmpio ano)
  outreg2 using "${Resultados}\Reg.doc", replace 
  
  reghdfe secci_FARC at_least_one_D_change , absorb(codmpio ano)
  outreg2 using "${Resultados}\Reg2.doc", replace
  
  did_multiplegt_dyn tpobc_FARC codmpio ano at_least_one_D_change,effects(8)
  frmttable using "${Resultados}/Tabla_2.1.doc", replace sdec(3) statmat(e(b)) ctitles("", "Efecto1", "Efecto2", "Efecto3", "Efecto4", "Efecto5", "Efecto6", "Efecto7", "Efecto8", "Efecto promedio") rtitles("Coeficiente")
  
    local effects = 2
  mat define res = J(4*`effects', 6, .)
  local r_effects ""
  forv j=1/4 {
    did_multiplegt_dyn secci_FARC codmpio ano at_least_one_D_change if inlist(subsample, 0, `j'), effects(`effects') graph_off
    forv i = 1/`effects'{
        mat adj = mat_res_XX[`i',1..6]
        forv c =1/6 {
            mat res[`j'+(`i'-1)*4,`c'] = adj[1, `c']
        }
	 }
  }
  
  mat list res
  mat res = (0,0,0,0,0,0) \ res
  svmat res
  gen rel_time = _n-1 if !missing(res1)
  
  #d;
  
  tw (rcap res3 res4 rel_time, lc(midgreen)) 
  ( connected res1 rel_time, mc(edkblue) lc(edkblue) ) , scheme(white ptol)
  ytitle("N° asaltos a poblacion civil por FARC por municipio", size(small)) 
  xtitle("Tiempo relativo al último período antes de que cambie el tratamiento (t=0)") 
  title("DID, desde el último período antes de que cambie el tratamiento (t=0) hasta t",size(small))
  graphregion(color(white)) name(graph1, replace)
  legend(off)
  note("{bf:Fuente:} Elaboración propia usando la base de datos PANEL_CONFLICTO_Y_VIOLENCIA(2022)");
  graph export "${Resultados}/grafico.png", replace width(800) height(500) as(png);
  
  #d cr;
  
  drop res*
  drop rel_time
  
  did_multiplegt_dyn secci_FARC codmpio ano at_least_one_D_change,effects(8) 
  frmttable using "${Resultados}/Tabla_2.2.doc", replace sdec(3) statmat(e(b)) ctitles("", "Efecto1", "Efecto2", "Efecto3", "Efecto4", "Efecto5", "Efecto6", "Efecto7", "Efecto8", "Efecto promedio") rtitles("Coeficiente")
  
  local effects = 2
  mat define res = J(4*`effects', 6, .)
  local r_effects ""
  forv j=1/4 {
    did_multiplegt_dyn secci_FARC codmpio ano at_least_one_D_change if inlist(subsample, 0, `j'), effects(`effects') graph_off
    forv i = 1/`effects'{
        mat adj = mat_res_XX[`i',1..6]
        forv c =1/6 {
            mat res[`j'+(`i'-1)*4,`c'] = adj[1, `c']
        }
	 }
  }
  
  mat list res
  mat res = (0,0,0,0,0,0) \ res
  svmat res
  gen rel_time = _n-1 if !missing(res1)
  
  #d;
  
  tw (rcap res3 res4 rel_time, lc(midgreen)) 
  ( connected res1 rel_time, mc(edkblue) lc(edkblue) ) , scheme(white ptol)
  ytitle("N° secuestros a poblacion civil por FARC por municipio", size(small)) 
  xtitle("Tiempo relativo al último período antes de que cambie el tratamiento (t=0)") 
  title("DID, desde el último período antes de que cambie el tratamiento (t=0) hasta t",size(small))
  graphregion(color(white)) name(graph1, replace)
  legend(off)
  note("{bf:Fuente:} Elaboración propia usando la base de datos PANEL_CONFLICTO_Y_VIOLENCIA(2022)");
  graph export "${Resultados}/grafico3.png", replace width(800) height(500) as(png);
  
  #d cr;
  
  /* Probar tendecncia paralelas a partir de prueba de placebo */
  
  drop res*
  replace treatment = 1 if ano == mod(codmpio - 1, 5) + 3 & mod(codmpio-1, 5) != 0
  
  scalar effects = 2
  scalar placebo = 1
  mat define res = J(4*placebo + 4 * effects, 7, .)
  forv j=1/4 {
    did_multiplegt_dyn tpobc_FARC codmpio ano at_least_one_D_change ///
     if inlist(subsample, 0, `j'), effects(`=effects') placebo(`=placebo') graph_off
    forv i = 1/`=effects' {
        mat adj = mat_res_XX[`i',1..6]
        forv c =1/6 {
            mat res[`j'+(`i'-1)*4,`c'] = adj[1, `c']
        }
        mat res[`j'+(`i'-1)*4,7] =`j'+(`i'-1)*4
    }
    forv i = 1/`=placebo' {
        mat adj = mat_res_XX[effects + 1 + `i',1..6]
        forv c =1/6 {
            mat res[(`i'+1)*4 - `j' + (4*(effects - 1) +1),`c'] = adj[1, `c']
        }
        mat res[(`i'+1)*4 - `j' + (4*(effects - 1) +1),7] = - ((`i'+1)*4 - `j')
		}
  }
  mat list res
  
  mat res = (0,0,0,0,0,0,0) \ res
  svmat res
  sort res7
  #d;
  
  tw (rcap res3 res4 res7, lc(midgreen)) 
  ( connected res1 res7, mc(edkblue) lc(edkblue) ) , scheme(white ptol)
  ytitle("N° asaltos a poblacion civil por FARC por municipio", size(small)) 
  xtitle("Tiempo relativo al último período antes de que cambie el tratamiento (t=0)") 
  title("DID, desde el último período antes de que cambie el tratamiento (t=0) hasta t",size(small))
  xlabel(-7(1)8)
  graphregion(color(white)) name(graph1, replace)
  legend(off)
  note("{bf:Fuente:} Elaboración propia usando la base de datos PANEL_CONFLICTO_Y_VIOLENCIA(2022)");
  graph export "${Resultados}/grafico2.png", replace width(800) height(500) as(png);
  
  #d cr;
  
  drop res*
  replace treatment = 1 if ano == mod(codmpio - 1, 5) + 3 & mod(codmpio-1, 5) != 0
  
  scalar effects = 2
  scalar placebo = 1
  mat define res = J(4*placebo + 4 * effects, 7, .)
  forv j=1/4 {
    did_multiplegt_dyn secci_FARC codmpio ano at_least_one_D_change ///
     if inlist(subsample, 0, `j'), effects(`=effects') placebo(`=placebo') graph_off
    forv i = 1/`=effects' {
        mat adj = mat_res_XX[`i',1..6]
        forv c =1/6 {
            mat res[`j'+(`i'-1)*4,`c'] = adj[1, `c']
        }
        mat res[`j'+(`i'-1)*4,7] =`j'+(`i'-1)*4
    }
    forv i = 1/`=placebo' {
        mat adj = mat_res_XX[effects + 1 + `i',1..6]
        forv c =1/6 {
            mat res[(`i'+1)*4 - `j' + (4*(effects - 1) +1),`c'] = adj[1, `c']
        }
        mat res[(`i'+1)*4 - `j' + (4*(effects - 1) +1),7] = - ((`i'+1)*4 - `j')
		}
  }
  mat list res
  
  mat res = (0,0,0,0,0,0,0) \ res
  svmat res
  sort res7
  #d;
  
  tw (rcap res3 res4 res7, lc(midgreen)) 
  ( connected res1 res7, mc(edkblue) lc(edkblue) ) , scheme(white ptol)
  ytitle("N° secuestros a poblacion civil por FARC por municipio", size(small)) 
  xtitle("Tiempo relativo al último período antes de que cambie el tratamiento (t=0)") 
  title("DID, desde el último período antes de que cambie el tratamiento (t=0) hasta t",size(small))
  xlabel(-7(1)8)
  graphregion(color(white)) name(graph1, replace)
  legend(off)
  note("{bf:Fuente:} Elaboración propia usando la base de datos PANEL_CONFLICTO_Y_VIOLENCIA(2022)");
  graph export "${Resultados}/grafico4.png", replace width(800) height(500) as(png);
  
  #d cr;
  
  cap log close 
  
