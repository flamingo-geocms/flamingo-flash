/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component Theme
* A Theme defines a group of layers that can be switched on without having to check the boxes in the legend.
* A Theme can be set by selecting a theme from the ThemeSelector Component. 
* A theme can also be set in the url (http://www.bla.nl?thema=all).  
* When no Theme is given in the url the viewer will start with the default Theme (name="default"). 
* This is the first Theme defined in the ThemeSelector component.
* Other preset Theme's are the themes with the name="none" and name="all". Theme "none" switches off all
* the layers except the ones defined by the persistentlayerids attribute of the ThemeSelector. Theme "all"
* switches on all layers of the map.
* @file flamingo/tpc/classes/flamingo/gui/Theme.as  (sourcefile)
* @file flamingo/fmc/Theme.fla (sourcefile)
* @file flamingo/fmc/Theme.swf (compiled component, needed for publication on internet)
* @configstring label Label text for the choices in the ThemeSelector combobox.
*/

/** @tag <fmc:Theme> 
* This tag defines a theme instance. 
* @class gui.Theme extends AbstractComponent 
* @hierarchy child node of ThemeSelector 
* @example
       <fmc:ThemeSelector id="themeselector"   left="right -230"   top="top" width="230"  borderwidth="0" listlength="8"
            listento="map" persistentlayerids="risicokaart.39,risicokaart.10,risicokaart.9,risicokaart.4,risicokaart.5,risicokaart.38,risicokaart.3,risicokaart.12,
            risicokaart.2,risicokaart.0,risicokaart.14,risicokaart.maptipsgevstoffen,risicokaart.Bedrijven,risicokaart.Dissolve_provincies,risicokaart.Outline_nederland">
            <fmc:Theme  name="default"  layerids="risicokaart.risico_installatie_10-6,risicokaart.risico_inrichting_10-6,risicokaart.risico_installatie_10-5,.....">
                <string id="label" en="Choose a theme..." nl="Kies een thema...."/>
            </fmc:Theme>
            <fmc:Theme  name="none" > 
                <string id="label" en="Show none" nl="Niets tonen"/>
            </fmc:Theme>
            <fmc:Theme name="all" > 
                <string id="label" en="Show all" nl="Alles tonen"/>
            </fmc:Theme>   
            <fmc:Theme name="veiligheidsafstanden" layerids="risicokaart.risico_installatie_10-6,risicokaart.risico_inrichting_10-6,....">
                <string id="label" nl="Veiligheidsafstanden" en="Risks and effects"
                    de="Risiken und Auswirkungen" fr="Risques et conséquences"/> 
            </fmc:Theme>
`			....
		</fmc:ThemeSelector>
* @attr layerids Comma seperated list of layer ids that are in the Theme.
*/
 
 
import gismodel.*;



import core.AbstractComponent;

class gui.Theme extends AbstractComponent  {
    private var componentID:String = "Theme";
    private var layerIds:String = null;
	private var themeLayers:Array;
	private var map:Object; 
    
    function setAttribute(name:String, value:String):Void {     
        if(name="layerids"){
        	layerIds = value;
        }    
    }
    
    function getLabel():String {
        return _global.flamingo.getString(this,"label");
    }  
    
    function getName():String {
        return name;
    }  
    
    function go():Void {
		var mapStr:String = getParent().getMapId();	
        var sublayer:String = '';
    	themeLayers = new Array();
    	if(layerIds==undefined){
  			return;		 
    	}
    	var a:Array = _global.flamingo.asArray(this.layerIds);
		for (var j:Number = 0; j<a.length; j++) {
			var layername:String = null;
			if (a[j].indexOf(".", 0) == -1) {
				layername = mapStr+"_"+a[j];
				sublayer = "";
			} else {	
				layername  = mapStr+"_"+a[j].split(".")[0];
				sublayer = a[j].split(".")[1];
			}
			var item:Object = new Object();
			item["layername"] = layername;
			item["sublayer"] = sublayer;
			themeLayers[layername + "." + sublayer] = item;
		}
		getParent().themeReady();
    }
    
    function getThemelayers():Array {
        return themeLayers;
    }
    
    function isIn(lyr:String):Boolean {
    	if(themeLayers[lyr] != null){
    		return true;
    	} else {
    		return false;
    	}	
    }
    	 
    	
    
    
}
