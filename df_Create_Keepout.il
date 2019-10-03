/*==========================================================================
  程序名称：Create_Keepout
  程序功能：本程序用于两个VIA或者Though PIN之间创建Keepout shape;
             弹窗中输入Keepout的直径，会自动创建Keepout并加上ROUTES_ALLOWED，VIAS_ALLOWED属性；
  创建时间：2016年4月28日 
  作    者：df
==========================================================================
大致的思路是通过获取点选两个对象的坐标创建一条CLINE，再把CLINE转化为shape；
这类程序一般都是用下面几个函数来实现:
1.axlPolyFromDB获取CLINE或VIA的外形
2.axlPolyExpand将外形放大或缩小
3.axlDBCreateShape根据外形绘制SHAPE。
==========================================================================*/
 
axlCmdRegister("Create_Keepout" 'Create_Keepout ?cmdType "interactive" ?doneCmd 'Create_Keepout_done ?cancelCmd 'Create_Keepout_Cancel)
defun(Create_Keepout ()
      
      let((mypopup clinedbid polydbid )
      axlUIWPrint(nil "Create_Keepout V0.8")
      axlUIWPrint(nil "Written by df")
          notdone = t
		  dia=40.00
          
    mypopup = axlUIPopupDefine(nil
                (list (list "Done" 'Create_Keepout_done)
                                (list "Cancel" 'Create_Keepout_Cancel)))
            axlUIPopupSet(mypopup)

; #######################
; 以form的形式获取直径
; #######################
 df_From_file ="./df_CreateKeepout_From.form"
	    df_CreateKeepout_From = outfile( df_From_file "w" )
   fprintf(df_CreateKeepout_From "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(df_CreateKeepout_From "FORM\n")
   fprintf(df_CreateKeepout_From "FIXED\n")
   fprintf(df_CreateKeepout_From "PORT 29 20\n")
   fprintf(df_CreateKeepout_From "HEADER \"CreateKeepout_From\"\n")
  
   fprintf(df_CreateKeepout_From "TILE\n")
   fprintf(df_CreateKeepout_From "TEXT \"Diameter:\"\n")
   fprintf(df_CreateKeepout_From "TLOC 3 8\n")
   fprintf(df_CreateKeepout_From "ENDTEXT\n")
   
   fprintf(df_CreateKeepout_From "FIELD Diameter\n")
   fprintf(df_CreateKeepout_From "FLOC 10 8\n")
   fprintf(df_CreateKeepout_From "REALFILLIN 6 6\n")
   fprintf(df_CreateKeepout_From "ENDFIELD\n")
   
   fprintf(df_CreateKeepout_From "ENDTILE\n")
   fprintf(df_CreateKeepout_From "ENDFORM\n")
   close(df_CreateKeepout_From)
   df_CreateKeepout_From = axlFormCreate( (gensym) df_From_file '(e inner) 'df_CreateKeepout_From_action t )
   df_CreateKeepout_From = axlMiniStatusLoad( (gensym) df_From_file  'df_CreateKeepout_From_action )
   ;axlFormTest("df_CreateKeepout_From")
   axlFormSetField(df_CreateKeepout_From "Diameter" dia)
   
;#############################################################################   
;dia=atoi(axlUIPrompt("Enter Diameter" "50")) ;用弹窗的方式获取自定义的直径
;#############################################################################  
  
        while(notdone
        FirstPin = nil
        SecondPin = nil
        axlClearSelSet()
        axlSetFindFilter(?enabled list("noall" "VIAS" "pins") ?onButtons list("noall" "VIAS" "pins"))
        axlUIWPrint(nil "Please Select First.....")
        axlSingleSelectPoint()
        FirstPin = car(axlGetSelSet())
        axlClearSelSet()
        axlHighlightObject(FirstPin)
        when(notdone && FirstPin
        axlSetFindFilter(?enabled list("noall" "VIAS" "pins") ?onButtons list("noall" "VIAS" "pins"))
        axlUIWPrint(nil "Please Select Second.....")
        axlSingleSelectPoint()
        SecondPin = car(axlGetSelSet())
        axlClearSelSet()
        axlHighlightObject(SecondPin)
                 if(FirstPin != nil && SecondPin != nil then
                   clinedbid=caar(axlDBCreateLine(list(FirstPin->xy SecondPin->xy),dia,"PACKAGE GEOMETRY/ASSEMBLY_TOP"));Create Cline on the top.
                   polydbid=axlPolyFromDB(clinedbid ?endCapType 'ROUND);Poly
                   axlDeleteObject(clinedbid)
                   df_shape=axlDBCreateShape(car(polydbid) t "Route Keepout/all" nil)
                   axlDBAddProp(car(df_shape),  list("ROUTES_ALLOWED"))
                   axlDBAddProp(car(df_shape),  list("VIAS_ALLOWED"))
                   else 
                   axlUIWPrint(nil "Please Select via or pin....")
                    );end if
            axlDehighlightObject(FirstPin)
            axlDehighlightObject(SecondPin)
                        );end  when
         );end while
	));end defun
       
        
; ###############################
; Define the form action
; ###############################
defun(df_CreateKeepout_From_action (df_CreateKeepout_From)
       case(df_CreateKeepout_From->curField
              ("Diameter"
		       dia=df_CreateKeepout_From->curValue
		      )
	        );end case
     );end defun
	 

defun(Create_Keepout_done ()
                notdone = nil
                axlFinishEnterFun()
				axlFormClose( df_CreateKeepout_From )
				axlUIPopupSet(nil)
				axlFlushDisplay( )
                axlUIWPrint(nil "- Done -")
          )
defun(Create_Keepout_Cancel ()
                notdone = nil 
                axlCancelEnterFun()
				axlFormClose( df_CreateKeepout_From )
				axlUIPopupSet(nil)
				axlFlushDisplay( )
                axlUIWPrint(nil "- Cancel -")
     )