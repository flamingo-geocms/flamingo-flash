/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component ThemePicker
* A combobox component that gives you the possibility to select a theme (defined by a Theme component). 
* A Theme defines a group of layers that can be switched on without having to check the boxes in the legend. 
* All other layers will be switched off except the ones listed in the persitentlayerids attribute. 
* A theme can also be set in the url (http://www.bla.nl?thema=all).  
* The ThemeSelector should listen to a map component.
* @file flamingo/tpc/classes/flamingo/gui/ThemePicker.as  (sourcefile)
* @file flamingo/fmc/ThemePicker.fla (sourcefile)
* @file flamingo/fmc/ThemePicker.swf (compiled component, needed for publication on internet)
* @configstring label Label text for the combobox.
*/

/** @tag <fmc:ThemePicker> 
* This tag defines a themePicker instance. ...
* @class gui.ThemePicker 
* @hierarchy child node of Flamingo 
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
* @attr persistentlayerids A coma seperated list of layer ids that is not influenced by the selection of a theme. 
* These are for instance topographical baselayers that should always be visible.   
* @attr listlength The length of the combobox list.
*/


import mx.controls.ComboBox;

import gui.Theme;
import core.AbstractContainer;

import mx.utils.Delegate;
import mx.controls.ComboBase;

class gui.ThemeSelector extends AbstractContainer {
	private var componentID:String = "ThemePicker";
	private var depth:Number = 0;
	private var map:Object = null;
	private var themes:Array; 
	private var numThemes:Number = 0;
	private var textFormat:TextFormat; 
	private var themeComboBox:ComboBox; 
	private var persistentLayers:Array;
	private var listlength:Number = 5;
	//currentTheme can be set by flamingo setArgument
    private var currentTheme:Theme = null;
    
 	function init():Void {
        this.map =_global.flamingo.getComponent(listento[0]);
        var componentIDs:Array = getComponents();
        var component:MovieClip = null;
        themes= new Array();
        for (var comp:String in componentIDs) {
            component = _global.flamingo.getComponent(componentIDs[comp]);
            if (component.getComponentName() != "Theme") {
                continue;
            }
			themes.push(component); 
			numThemes++;   
        }
        if (themes.length == 0) {
            _global.flamingo.tracer("Exception in gui.ThemePicker.<<init>>()\nNo themes configured.");
            return;
        }
     	var currentThemeName:String = _global.flamingo.getArgument(this, "currentTheme");
		if(currentThemeName==null){
			currentThemeName="default";
		}
		for(var i:Number=0;i<themes.length;i++){
 			if(themes[i].name==currentThemeName){
 				currentTheme=themes[i];		
 			}	
		}	
        addThemeSelector();
		_global.flamingo.addListener(this,"flamingo",this);	
 	}
 	
 	public function onConfigComplete():Void {
		if(currentTheme!=null){
	    	for(var i:Number=0;i<themeComboBox.dataProvider.length;i++){
	    		if(themeComboBox.dataProvider[i].data == currentTheme){
	    			themeComboBox.setSelectedIndex(i);
	    			setCurrentTheme(currentTheme);
	    			return;
	    		}
	    	}	
		}
	}
 	    	    
   function setAttribute(name:String, value:String):Void { 
        if(name=="persistentlayerids"){
        	persistentLayers = new Array();
        	var mapStr:String = listento[0]; 
        	var a:Array =value.split(",");
			for (var j:Number = 0; j<a.length; j++) {
				var layername:String = null;
				var sublayer:String = null;
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
				persistentLayers[layername + "." + sublayer] = item;
        	}  
        }   
        if(name=="listlength"){
        	this.listlength = Number(value);
        } 	
    }
    
    function getMap():Object{
    	return map;
    }

	function themeReady():Void{
		numThemes--;
		if(numThemes==0){
			resetDataProvider();		
		}	
	}
	
	private function resetDataProvider(){
		var item:Object=null;
	    var items:Array = new Array();
		var themeselLabel:String = _global.flamingo.getString(this, "label");
		if(themeselLabel!=null){
			item = new Object();
			item["label"] = _global.flamingo.getString(this, "label");
			item["data"] = null;
			items.push(item);
		}	
        for (var i:Number = 0; i < themes.length; i++) {
            item = new Object();     
            item["label"] = Theme(themes[i]).getLabel();
            item["data"] = Theme(themes[i]);
            items.push(item);
        }
        themeComboBox.dataProvider = items;   
	}
	
    private function addThemeSelector():Void {
        var comboBoxContainer:MovieClip = createEmptyMovieClip("mThemeComboBoxContainer", 0);
        comboBoxContainer._lockroot = true; // Without this line comboboxes wouldn't open.
        themeComboBox = this["mThemeComboBoxContainer"].createClassObject(mx.controls.ComboBox, "cmbThemeChoser", 0);
        // to get rid of sticky focusrects use these lines
		themeComboBox.__rowCount = listlength;
		themeComboBox.getDropdown().drawFocus = "";
		themeComboBox.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		themeComboBox.setSize(this.__width,22);
		themeComboBox.addEventListener("close", Delegate.create(this, onChangeThemeComboBox));
	}
	
	private function onChangeThemeComboBox(eventObject:Object) : Void {
		if(eventObject.target.selectedItem.data!=null){	
			setCurrentTheme(eventObject.target.selectedItem.data);
		}	
	}
	
	private function setCurrentTheme(selectedTheme:Theme) : Void{
		var scope:String = "";
		if(selectedTheme.name == "all"){
			scope="all";
		} 
		if(selectedTheme.name == "none"){
			scope="none";
		} 
		//loop through all layers and sublayers
		var mapLayers:Array = map.getLayers();
		for(var i:Number=0;i<mapLayers.length;i++){ 
			var mapLayer:MovieClip = _global.flamingo.getComponent( mapLayers[i].toString());
			var layers:Array = mapLayer.getLayers();
			var themeLayers:Array = selectedTheme.getThemelayers();
			for (var sublayer in layers) {
				if(persistentLayers[mapLayers[i]+ "."+ sublayer] != null){
					//do nothing
				} else {
					switch (scope){
						case "all":
							showLayer(mapLayer,sublayer);
						break;
						case "none":
							hideLayer(mapLayer,sublayer);
						break;
						case "":
							if (themeLayers[mapLayers[i]+ "."+ sublayer] != null) {
								showLayer(mapLayer,sublayer);
							} else {
								hideLayer(mapLayer,sublayer);
							}
						break;	
					}	
				}	
			}
			mapLayer.update();	
		}
	}
	
	private function showLayer(layer:Object,sublayer:String):Void {
		if(sublayer==""){
			layer.show();
		} else {
			layer.setLayerProperty(sublayer, "visible", true);
		}	
	}
	
	private function hideLayer(layer:Object,sublayer:String):Void {
		if(sublayer==""){
			layer.hide();
		} else {
			layer.setLayerProperty(sublayer, "visible", false);
		}	
	}
}
	
