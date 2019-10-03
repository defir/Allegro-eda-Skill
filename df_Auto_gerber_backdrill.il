;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;      程序名称： Auto_gerber
;      程序功能： 按照公司要求设置并自动生成gerber文件，然后根据格式打包。
;      创建时间：2014年12月10日 
;      作    者：dong.fang ma.chunqiang
;      使用说明：解压AutoPCBZip_V0.8.2.zip到D盘根目录；
;                新建文件夹D:/gerber/ 用于保存gerber文件和压缩包；
;                手工放入PCB工艺说明书(V0.8).xls；版本说明.txt;.DSN三个文件
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;版本记录：
;V0.1,目前只完成了自动打包功能(2014.12.10)
;V0.2,完成出图前设置，出图到打包的全部功能。只是可用，还需优化。（2014.12.22）
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

axlCmdRegister("Auto_gerber_BD", 'Auto_gerberzip_BD  ?cmdType "general") 
defun( Auto_gerberzip_BD ()
let( ()
     curdsnunit = axlGetParam("paramDesign")->units
		 curacc = axlGetParam("paramDesign")->accuracy
		   case(curdsnunit
	        ("mils"  dounit = 1 unitmode = "units_english")
		    ("millimeters" dounit = 40  unitmode = "units_metric")
			;(u can add other units)
            );case
		   
			if(isDir("d:/gerber")
			   then
			   changeWorkingDir("D:/gerber/")
			   sh("del /f /s /q  .\\*.log")
			   sh("del /f /s /q  .\\*.art")
			   sh("del /f /s /q  .\\*.drl")
			   else
			   createDir("D:/gerber/")
			  );if
			   axlSaveDesign(?noConfirm t)
			   
               _drillcustm()
			   quickdrlegend_bd()
			   _ncdrill_bd()
			   _placeout()
			   _gerberout()
			   _Export_pdf()
			  ;deleteFile("./drillcustm.scr")	
  			  ;deleteFile("./quicklegend.scr")	
			  ;deleteFile("./df_ncdrill.scr")
              sh("D:/AutoPCBZip.bat")	
             
		
  );let
  );defun
  
  
/* ---------------------------------
set the drill custm
--------------------------------- */
 defun( _drillcustm ()
 let( ()
         p = outfile("drillcustm.scr\n")
         fprintf(p "setwindow pcb\n")
		;fprintf(p "generaledit\n")
		 fprintf(p "ncdrill customization \n")
		;fprintf(p "generaledit\n")
		 fprintf(p "setwindow form.nc_drillcustomization\n")
		 fprintf(p "FORM nc_drillcustomization auto_symbols\n")
		 fprintf(p "FORM nc_drillcustomization done\n")
		;fprintf(p "fillin yes\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p "\n")
		 close(p)
		 axlShell("replay drillcustm.scr")

	   ))
 /* ---------------------------------
 set & place the drill legend
 --------------------------------- */
 defun( quickdrlegend_bd ()
 let( ()
         placloc()
         p = outfile("quicklegend.scr\n")
         fprintf(p "setwindow pcb\n")
		 fprintf(p "generaledit\n")
		 fprintf(p "ncdrill legend\n")
		 fprintf(p "setwindow form.nc_drilllegend\n")
		 ;fprintf(p "FORM nc_drilllegend backdrill_legends NO\n")
		 fprintf(p "FORM nc_drilllegend backdrill_legends YES\n")
		 fprintf(p "FORM nc_drilllegend done\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p loccmd)
		 fprintf(p "\n")
		 fprintf(p "generaledit\n")
		 close(p)
		 
		 axlShell("replay quicklegend.scr")
	   ))
	   
/* ---------------------------------
NC Drill
--------------------------------- */
 defun( _ncdrill_bd ()
 let( ()
         p = outfile("df_ncdrill.scr\n")
         fprintf(p "setwindow pcb\n")
		 fprintf(p "generaledit\n")
		 fprintf(p "nctape_full\n")
		 fprintf(p "setwindow form.nc_drill\n")
		 ;fprintf(p "FORM nc_drill backdrill_drilling NO\n")
		 fprintf(p "FORM nc_drill backdrill_drilling YES\n")
		 fprintf(p "FORM nc_drill execute\n")
		 fprintf(p "FORM nc_drill close\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p "generaledit\n")
		 fprintf(p "\n")
		 close(p)
		 
		 axlShell("replay df_ncdrill.scr")
		 ;sh("del /f /s /q  .\\*.drl,1")
		 ;sh("xcopy .\\*.drl  d:\\gerber")
		
	   ))
/* ---------------------------------
create place txt
--------------------------------- */
 defun( _placeout ()
 let( ()
         p = outfile("df_place.scr\n")
         fprintf(p "setwindow pcb\n")
		 ;fprintf(p "generaledit\n")
		 fprintf(p "plctxt out\n")
		 fprintf(p "setwindow form.plctxt\n")
		 fprintf(p "FORM plctxt body_center YES\n")
		 fprintf(p "FORM plctxt execute\n")
		 fprintf(p "FORM plctxt cancel\n")
		 fprintf(p "setwindow pcb\n")
		 ;fprintf(p "generaledit\n")
		 fprintf(p "\n")
		 close(p)
		 
		 axlShell("replay df_place.scr")
		 ;axlOSFileCopy("./place_txt.txt" "D:/gerber/place_txt.txt" nil)
	   ))
	   
/* ---------------------------------
create art files 
--------------------------------- */
 defun( _gerberout ()
 let( ()
         axlShapeDynamicUpdate(nil nil)
         p = outfile("df_gerberout.scr\n")
         fprintf(p "setwindow pcb\n")
		 fprintf(p "generaledit\n")
		 fprintf(p "artwork\n")
		 fprintf(p "setwindow form.film_control\n")
		 fprintf(p "FORM film_control general_parameters\n")
		 fprintf(p "FORM film_control gerber_rs274x YES\n")
		 fprintf(p "FORM film_control format_int_places 5\n")
		 fprintf(p "FORM film_control format_dec_places 5\n")
		  fprintf(p "FORM film_control film_control\n")
		 fprintf(p "FORM film_control general_parameters\n")
		 fprintf(p "FORM film_control film_control\n")
		 fprintf(p "FORM film_control select_all\n")
		 fprintf(p "FORM film_control create\n")
		 fprintf(p "setwindow text\n")
		 fprintf(p "close\n")
		 fprintf(p "setwindow form.film_control\n")
		 fprintf(p "FORM film_control ok\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p "generaledit\n")
		 fprintf(p "\n")
		 close(p)
		 
		 axlShell("replay df_gerberout.scr")
	
	   ))   
	   
/* ---------------------------------
Export Assembly PDF
 --------------------------------- */    
  defun( _Export_pdf ()
    let( ()
         p = outfile("Export_pdf.scr\n")
         fprintf(p "setwindow pcb\n")
		 fprintf(p "artwork\n")
		 fprintf(p "setwindow form.film_control\n")
		 fprintf(p "FORM film_control filmtree  ASSEMBLY_BOTTOM \n")
		 fprintf(p "FORM film_control mirror YES\n")
		 fprintf(p "FORM film_control ok\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p "pdf out\n")
		 fprintf(p "setwindow form.pdf_out\n")
		 fprintf(p "FORM pdf_out pdftree 'MULTISEL YES' ASSEMBLY_BOTTOM\n")
		 fprintf(p "FORM pdf_out pdftree  ASSEMBLY_BOTTOM\n")
		 fprintf(p "FORM pdf_out pdftree 'MULTISEL YES' ASSEMBLY_TOP \n")
		 fprintf(p "FORM pdf_out pdftree  ASSEMBLY_TOP\n")
		 fprintf(p "FORM pdf_out black_white YES\n")
		 fprintf(p "FORM pdf_out doc_separated YES\n")
		 fprintf(p "FORM pdf_out meta_data NO\n")
		 fprintf(p "FORM pdf_out export\n")
		 fprintf(p "FORM pdf_out cancel\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p "\n")
		 close(p)
		 axlShell("replay Export_pdf.scr")

	   ))
	   
/* ---------------------------------
define the findmax function
 --------------------------------- */      
defun( findmax (numlist)
let( ()
	  curlistl = length(numlist)
                maxt = nth(0 numlist)
				j = 1
				while(j<curlistl
				    tempt = nth(j numlist)
					if(maxt < tempt
					   maxt = tempt
					   )
					j= j +1
					)
		curmaxnum = maxt
		 ))

 /* ---------------------------------
define the findmin function
 --------------------------------- */	
defun( findmin (numlist) 
let( ()
	  curlistl = length(numlist)
                mint = nth(0 numlist)
				j = 1
				while(j<curlistl
				    tempt = nth(j numlist)
					if(mint > tempt
					   mint = tempt
					   )
					j= j +1
					)
		curminnum = mint
		 ))
 /* ---------------------------------
 calculate the spae to place the figure
 --------------------------------- */
defun( placloc ()
	  axlVisibleDesign(nil)
 	  axlVisibleLayer("Board Geometry/Outline" t)
 	  axlClearSelSet()
 	  axlSetFindFilter( ?enabled (list "noall" "lines" "shapes") , ?onButtons (list "lines" "shapes"))

 	  alloutline = axlGetSelSet(axlAddSelectAll())   ;may contions more than 1 path or polygon

	  polyoutline = list()
	  foreach(onel alloutline
	          if(equal(onel->objType "polygon")
			     then
			     polyoutline = append1(polyoutline onel)
				 alloutline = remd(onel alloutline)
			     )
			  pathoutlinem = alloutline
			  )
			  
		  
			  pathoutline = list()
			  
	 foreach(ones pathoutlinem
	         onesty = ones->objType
			 if( onesty == "path"
			    then
			    segpath = ones->segments    ;list of line &arc			
				pathoutlinem = remd(ones pathoutlinem)
				pathoutline = append(pathoutline segpath)
				else  ;line arc
				pathoutline = append(pathoutline car(ones))
				)
				)

			  xloclist = yloclist = list()

			  foreach(poly polyoutline
			         curbox = poly->bBox   
					 xlloc = caar(curbox)
					 ylloc = cadar(curbox)
					 xrloc = caadr(curbox)
					 yrloc = cadadr(curbox)
					 xloclist = append1(append1(xloclist xlloc) xrloc)
					 yloclist = append1(append1(yloclist ylloc) yrloc)
					 )
					 
			  foreach(path pathoutline
			  
                    ; curpath = car(path->segments) 
                    curpathtype = path->objType
					
					; path = nth(0 pathoutline)
					

					   
					if(curpathtype == "line"
					then
		            curlinesta = path->startEnd
		            xlloc = caar(curlinesta)
		            ylloc = cadar(curlinesta)
		            xrloc = caadr(curlinesta)
					yrloc = cadadr(curlinesta)
		            xloclist = append1(append1(xloclist xlloc) xrloc)
		            yloclist = append1(append1(yloclist ylloc) yrloc) 
					else
							if(curpathtype == "arc"
							then
						    curarcent = path->xy
		                    curarr = path->radius
		                    xlloc = car(curarcent)-curarr
		                    ylloc = cadr(curarcent)-curarr
		                    xrloc = car(curarcent)+curarr
		                    yrloc = cadr(curarcent)+curarr
		                    xloclist = append1(append1(xloclist xlloc) xrloc)
		                    yloclist = append1(append1(yloclist ylloc) yrloc)
							  )
					   ) ;end if
					 )  ;end foreach
					 
					 
					 
			         boxlx = findmin(xloclist)
					 boxly = findmin(yloclist)
			         boxrx = findmax(xloclist)
					 boxry = findmax(yloclist)
					 


				designbox = axlDBGetDesign()->bBox 
					 dsnxlloc = caar(designbox)
					 dsnylloc = cadar(designbox)
					 dsnxrloc = caadr(designbox)
					 dsnyrloc = cadadr(designbox)
					 
					 
					 lftlx = abs(dsnxlloc-boxlx)
					 lftly = abs(dsnylloc-boxly)
					 lftrx = abs(dsnxrloc-boxrx)
					 lftry = abs(dsnyrloc-boxry)
					 
					 
					 if(lftlx>lftrx
					 then
					 lftx = lftlx
					 ncdlocx = boxlx - 2800*(1.0 / dounit)
					 else
					 lftx = lftrx
					 ncdlocx = boxrx + 300*(1.0 / dounit)
					 )
					 lfty = lftry
					 ncdlocy = boxry + 50*(1.0 / dounit)
					 
					 loccmd = sprintf(nil "pick grid %f %f" ncdlocx ncdlocy)
					 

				; lftxn = 	(1.0 / dounit)*lftx
				; lftyn = 	(1.0 / dounit)*lfty
				
				if( lftx > (1.0 / dounit)* 3000.0
				then
				spaist = t
				else
				spaist = nil
					 )
			 )

