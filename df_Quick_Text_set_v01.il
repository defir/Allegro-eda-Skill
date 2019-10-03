;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;      程序名称： Quick_Text_set
;      程序功能：按照恒为要求设置1-16号字体大小，并把当前工程的丝印修改为2号字体。
;      创建时间：2014年12月11日 
;      作    者：dong.fang
 ;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ 
;                                            Width  Height LineSpace PhotoWidth CharSpace  
/*   目前的字体要求：1号字，PIN_Number        5      10       10          2          0;
                     2号字，RefDes/Assembly   10     15       15          2          2;
					           3号字，RefDes/Silkscreen 20     30       25          5          5;
                     其他字号暂未要求；
					 加工要求：PhotoWidth Min 5mil
					           
*/
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;版本记录：
;V0.1,自动设置pin_number,REF DES/assembly,REF DES/SILKSCREEN字号(2014.12.12)
;
;
;
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
axlCmdRegister("quick_textset" 'quicktext)

;get the old layer display,for recover
defun( quicktext ()
let( (curdsnunit)
		  curdsnunit = axlGetParam("paramDesign")->units
		   case(curdsnunit
	        ("mils"  du = 1)
		    ("millimeters" du = 0.0254 )
			;(u can add other units)
		      )
old_visList = axlVisibleGet()
setTextSize()
changeRefDes()
axlVisibleSet(old_visList)
))


;set the textblock size
defun( setTextSize ()
      let(()
	  p = axlGetParam("paramTextBlock:1")
	 	   p->width = 5*du 
	  	   p->height = 10*du 
	  	   p->lineSpace = 10*du 
	 	   p->photoWidth = 2*du
		 	  p->charSpace = 0
		 	  	  	  axlSetParam(p)
       	;set the text_block size 1;
		
	   p = axlGetParam("paramTextBlock:2")
	 	   p->width = 10*du 
	  	   p->height = 15*du 
	  	   p->lineSpace = 15*du
	 	   p->photoWidth = 2*du
	  	 p->charSpace = 2*du
	 	   	  	         axlSetParam(p)
       	;set the text_block size 2;
		
	  p = axlGetParam("paramTextBlock:3")
	 	   p->width = 20*du
	  	   p->height = 30*du
	  	   p->lineSpace = 25*du 	   
	  	   p->photoWidth = 5*du
         p->charSpace = 5*du
  	     axlSetParam(p)
       	;set the text_block size 3;
		
	  Text_need = '("4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16")
	  foreach(text_block Text_need
	 	   p = axlGetParam(strcat("paramTextBlock:" text_block))
	 	   block_pl = atoi(text_block) ;change string to num   (1.0/du)
	 	   p->width = (5 + 5*block_pl)*du
	  	   p->height = (15 + 5*block_pl)*du
	  	   p->lineSpace = 25*du
	 	   p->photoWidth = (4 + block_pl)*du
	 	   p->charSpace = 5*du
	  	  axlSetParam(p)	
	 	   )
		 )
	  )
	  
	  
;;change the resdes 
defun( changeRefDes ()
       let(() 
	  axlVisibleDesign(nil)
	  axlVisibleLayer("PACKAGE GEOMETRY/PIN_NUMBER" t)
	  axlVisibleLayer("pin/top" t)
	  axlVisibleLayer("pin/bottom" t)
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  allrefs = axlGetSelSet(axlAddSelectAll())
	  foreach(i allrefs   
	          axlDBChangeText(i nil 1)
	          )
      ;change the PACKAGE GEOMETRY/PIN_NUMBER to text_block 1 ;	
	   
	   
	  axlVisibleDesign(nil)
	  axlVisibleLayer("REF DES/assembly_TOP" t)
	  axlVisibleLayer("REF DES/assembly_BOTTOM" t)
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  allrefs = axlGetSelSet(axlAddSelectAll())
	  foreach(i allrefs   
	          axlDBChangeText(i nil 2)
	          )
      ;change the resdes of assembly to text_block 2 ;	
	   
	   
	  axlVisibleDesign(nil)
	  axlVisibleLayer("REF DES/SILKSCREEN_TOP" t)
	  axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t)
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  allrefs = axlGetSelSet(axlAddSelectAll())
	  foreach(i allrefs   
	          axlDBChangeText(i nil 3)
	          )
	  ;change the resdes of silkscreen to text_block 3 ;
	  
	  axlVisibleDesign(nil)
	  axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
	  axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  allrefs = axlGetSelSet(axlAddSelectAll())
	  foreach(i allrefs   
	          axlDBChangeText(i nil 3)
	          )
	  ;change the package geometry silkscreen to text_block 3 ;
			  
			  
			  
		)
	)
	  