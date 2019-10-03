;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;      程序名称： Quick_ART_set
;      程序功能：根据叠层生成Available Films。
;      创建时间：2014年12月15日 
;      作    者：dong.fang
 ;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
/*     程序应用基础：1、需要提前正确设置Layout Cross Section；
                     2、需要手动操作一次NC Drill...（仅第一次时）

*/
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;版本记录：
;V0.1,初步实现功能(2014.12.15)
;V0.11修改代码，1、使用rexMatchp命令判断是否为TOP&BOTTOM相关层；
;               2、使用sprintf(s_lcont "%d" layercont)转化数字为字符串；(2014.12.15)
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+


axlCmdRegister("quickartset02" 'quickartset02)


;------------------------------主程序--------------------------
procedure(quickartset02()
      let(()
	        ;==================删除原有film层===========
			  axlDeleteObject(axlGetParam("artwork"))
			  
			;==================生成NCDRILL&ETCH层===========
			 layerlist = axlGetParam("paramLayerGroup:ETCH")->groupMembers
             layercont = length(layerlist)
             sprintf(s_lcont "%d" layercont)
             drilllayer = strcat("MANUFACTURING/NCLEGEND-1-"  s_lcont)
             drilllayerlist = list("BOARD GEOMETRY/OUTLINE" "BOARD GEOMETRY/DIMENSION"  "MANUFACTURING/NCDRILL_LEGEND" "MANUFACTURING/NCDRILL_FIGURE" "MANUFACTURING/PHOTOPLOT_OUTLINE")
			 drillname = "NC_DRILL"
             layercheck = axlIsLayer(drilllayer) 
			
			if((layercheck == nil) ;判断是否已经生成过NC drill;
			then 
			axlUIConfirm("Please NC drill first")

			 else
             while((layercont >= 1) 
            
                     layeradd = list("BOARD GEOMETRY/OUTLINE" strcat("ETCH/",car(layerlist)) 
                                   strcat("VIA CLASS/",car(layerlist)) strcat("PIN/",car(layerlist)))
                     layername = car(layerlist)					
                     Filmcreat(layername layeradd) 
                       layercont = layercont-1
                       layerlist = cdr(layerlist)
                   );end while	
                 
             posbdrillist = axlGetParam("paramLayerGroup:MANUFACTURING")->groupMembers ;获取NCLEGEND-1-？  
             posbdrilltotal = length(posbdrillist)
			 numdrl = 0
             while((posbdrilltotal-1 >= numdrl)
			        posbdrillayer = nth(numdrl posbdrillist)
			        if(strncmp("NCLEGEND" posbdrillayer 8) == 0
			        drilllayerlist = append1(drilllayerlist strcat("MANUFACTURING/" posbdrillayer)) ;生成NCLEGEND-1-？
			           );end if  
			           
			           if(strncmp("NCBACKDRILL" posbdrillayer 11) == 0
			        drilllayerlist = append1(drilllayerlist strcat("MANUFACTURING/" posbdrillayer)) ;生成NCBACKDRILL-1-？
			           );end if 

			       numdrl = numdrl+1
			       );end while
		   Filmcreat(drillname     drilllayerlist);生成NCDRILL&ETCH层
		   
           ;=====================生成Pastemask层=====================================
           Filmcreat("PASTEMASK_TOP" '("BOARD GEOMETRY/OUTLINE" "PIN/PASTEMASK_TOP" "PACKAGE GEOMETRY/PASTEMASK_TOP"))
           Filmcreat("PASTEMASK_BOTTOM" '("BOARD GEOMETRY/OUTLINE" "PIN/PASTEMASK_BOTTOM" "PACKAGE GEOMETRY/PASTEMASK_BOTTOM"))
           ;=====================生成SOLDERMASK_TOP&SOLDERMASK_BOTTOM=======================
           Filmcreat("SOLDERMASK_TOP" '("BOARD GEOMETRY/OUTLINE" 
		                                "VIA CLASS/SOLDERMASK_TOP" "PIN/SOLDERMASK_TOP" 
								        "PACKAGE GEOMETRY/SOLDERMASK_TOP" "BOARD GEOMETRY/SOLDERMASK_TOP" ))
           Filmcreat("SOLDERMASK_BOTTOM"   '("BOARD GEOMETRY/OUTLINE" 
                                             "VIA CLASS/SOLDERMASK_BOTTOM" "PIN/SOLDERMASK_BOTTOM" 
								             "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" "BOARD GEOMETRY/SOLDERMASK_BOTTOM" ))
           ;=====================生成SILKSCREEN_TOP&SILKSCREEN_BOTTOM=======================
           Filmcreat("SILKSCREEN_TOP"  '("BOARD GEOMETRY/OUTLINE"  
                                         "REF DES/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" 
								         "BOARD GEOMETRY/SILKSCREEN_TOP" ))
           Filmcreat("SILKSCREEN_BOTTOM"  '("BOARD GEOMETRY/OUTLINE"  
                                            "REF DES/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
							            	"BOARD GEOMETRY/SILKSCREEN_BOTTOM" ))
		   ;=====================生成ASSEMBLY_TOP&ASSEMBLY_BOTTOM=======================
           Filmcreat("ASSEMBLY_TOP"  '("BOARD GEOMETRY/OUTLINE"  
                                       "REF DES/ASSEMBLY_TOP" "PACKAGE GEOMETRY/ASSEMBLY_TOP"))
           Filmcreat("ASSEMBLY_BOTTOM"  '("BOARD GEOMETRY/OUTLINE"  
                                          "REF DES/ASSEMBLY_BOTTOM" "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" ))
         );end if 
		 );end let
		 );end defun


;-----------------------定义FilmCreate函数 -------------------------------

procedure( Filmcreat(FilmName artList)
      let(()
     ;====================判断是否负片层==========================
		   if( strncmp(nth(1 artList) "ETCH/" 4) == 0 
		       then
		          if(axlIsLayerNegative(nth(1 artList)) == t  
			      then
			      artworknum = 0
			      else
	 			  artworknum = 1
				  );end if
				else
				artworknum = 1 
			 );end if
		   
	 ;====================判断是否去掉无用焊盘=========================	   
		   if(rexMatchp("TOP" FilmName)|| 
		      rexMatchp("BOTTOM" FilmName)|| 
			  FilmName == "NCDRILL"
		      then
			  n_supp_unconnect = 0
			  else
			  n_supp_unconnect = 1
			  );end if
		
		       
          (axlfcreate FilmName list(0 0 0 500 5000 artworknum 0 0 n_supp_unconnect 0 0 1 1) artList)
		  
         );end let
		 );end procedure