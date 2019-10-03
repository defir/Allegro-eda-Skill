; -----------------------------------------------------------------------------
; Clear_user_layers.il
; -----------------------------------------------------------------------------
; Description:
;     Delete the userdefined layers;
; -----------------------------------------------------------------------------
; load("df_Clear_user_layers.il")
; Command>df_cul
; 2018-07-07 -- draft--
; defir.dong@foxmail.com
; -----------------------------------------------------------------------------

axlCmdRegister( "df_cul" `Clear_user_layers)

defun( Clear_user_layers ()
    ;====删除BOARD GEOMETRY多余层====
    ;1、获取自定义的层
     Blayers=axlSubclasses("BOARD GEOMETRY" ?field 'userDefined)   
     cnt_B1=length(Blayers)
    ;2、删除每个自定义层上的数据和层
     foreach(item Blayers
             q=strcat("BOARD GEOMETRY/" item)
             axlDeleteByLayer(q 'fixed) ;删除层上数据
	           db_layer=axlLayerGet(q)
	           axlDeleteObject(db_layer)  ;删除层
	            );end foreach
	      cnt_B2=length(axlSubclasses("BOARD GEOMETRY" ?field 'userDefined))
	      cnt_BG=cnt_B1-cnt_B2
	      axlMsgPut("--Delete BOARD GEOMETRY Layers count: %d" cnt_BG)  
	      
	    ;====删除PACKAGE GEOMETRY多余层====
	    Players=axlSubclasses("PACKAGE GEOMETRY" ?field 'userDefined)   
      cnt_P1=length(Players)
      foreach(item Players
             q=strcat("PACKAGE GEOMETRY/" item)
             axlDeleteByLayer(q 'fixed) ;删除层上数据
	           DP_layer=axlLayerGet(q)
	           axlDeleteObject(DP_layer)  ;删除层
	            );end foreach
	      cnt_P2=length(axlSubclasses("PACKAGE GEOMETRY" ?field 'userDefined))
	      cnt_PG=cnt_P1-cnt_P2
	      axlMsgPut("--Delete PACKAGE GEOMETRY Layers count: %d" cnt_PG) 
	      
	     ;====删除MANUFACTURING多余层====
	    Mlayers=axlSubclasses("MANUFACTURING" ?field 'userDefined)   
      cnt_M1=length(Mlayers)
      foreach(item Mlayers
             q=strcat("MANUFACTURING/" item)
             axlDeleteByLayer(q 'fixed) ;删除层上数据
	           DM_layer=axlLayerGet(q)
	           axlDeleteObject(DM_layer)  ;删除层
	            );end foreach
	      cnt_M2=length(axlSubclasses("MANUFACTURING" ?field 'userDefined))
	      cnt_M=cnt_M1-cnt_M2
	      axlMsgPut("--Delete MANUFACTURING Layers count: %d" cnt_M) 
         
         
       ;====删除ANALYSIS多余层====
	    Mlayers=axlSubclasses("ANALYSIS" ?field 'userDefined)   
      cnt_M1=length(Mlayers)
      foreach(item Mlayers
             q=strcat("ANALYSIS/" item)
             axlDeleteByLayer(q 'fixed) ;删除层上数据
	           DM_layer=axlLayerGet(q)
	           axlDeleteObject(DM_layer)  ;删除层
	            );end foreach
	      cnt_M2=length(axlSubclasses("ANALYSIS" ?field 'userDefined))
	      cnt_M=cnt_M1-cnt_M2
	      axlMsgPut("--Delete ANALYSIS Layers count: %d" cnt_M) 
	      
	       ;====删除DRAWING FORMAT多余层====
	    Mlayers=axlSubclasses("DRAWING FORMAT" ?field 'userDefined)   
      cnt_M1=length(Mlayers)
      foreach(item Mlayers
             q=strcat("DRAWING FORMAT/" item)
             axlDeleteByLayer(q 'fixed) ;删除层上数据
	           DM_layer=axlLayerGet(q)
	           axlDeleteObject(DM_layer)  ;删除层
	            );end foreach
	      cnt_M2=length(axlSubclasses("DRAWING FORMAT" ?field 'userDefined))
	      cnt_M=cnt_M1-cnt_M2
	      axlMsgPut("--Delete ANALYSIS Layers count: %d" cnt_M) 
	   
         );end defun
   
 