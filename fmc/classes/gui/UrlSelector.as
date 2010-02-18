/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component URLSelector
* A combobox component that gives you the possibility to select an url theme (defined by an URL component). 
* An URL defines a url that can be opened from within flamingo. When for the URL components the group attribute
* is filled a second comboBox will be drawn above the URLSelector combobox. By selecting a group the choices 
* in de URLSelector combobox will be limited. 
* @file flamingo/fmc/classes/flamingo/gui/URLSelector.as  (sourcefile)
* @file flamingo/fmc/URLSelector.fla (sourcefile)
* @file flamingo/fmc/URLSelector.swf (compiled component, needed for publication on internet)
* @configstring urlsellabel Label text for the "first choice" in the URLSelectorcombobox.
* @configstring groupsellabel Label text for the "first choice" in the group combobox.
*/

/** @tag <fmc:URLSelector> 
* This tag defines an urlSelector instance. ...
* @class gui.URLSelector extends AbstractContainer
* @hierarchy child node of Flamingo 
* @example
* <fmc:UrlSelector left="10" top="20" right="right -10" height="50"  borderalpha="0">
     <string id="groupsellabel" nl="Selecteer een thema..."/>
     <string id="urlsellabel" nl="Kies een atlas..."/>
     <fmc:URL   url="http://..." group="algemeen" listento="map" target="_blank">
      	<string id="grouplabel" nl="Algemeen"/>	
      	<string id="label" nl="Kaart en luchtfoto"/>	
     </fmc:URL>
     <fmc:URL   url="http://...." group="economie_werk" listento="map" target="_blank">
      	<string id="grouplabel" nl="Economie en werk"/>	
      	<string id="label" nl="Bedrijventerreinen"/>	
     </fmc:URL>
     .....
   </fmc:URLSelector> 
* @attr listlength The length of the combobox lists.
*/





import mx.controls.ComboBox;

import gui.URL;
import core.AbstractContainer;

import mx.utils.Delegate;
import mx.controls.ComboBase;
class gui.UrlSelector extends AbstractContainer {
	private var componentID:String = "URLSelector";
	private var urls:Array; 
	private var textFormat:TextFormat; 
	private var urlComboBox:ComboBox; 
	private var groupComboBox:ComboBox; 
	private var listlength:Number = 5;
	private var y = 0;
	private var map:Map = null;

    
 	function init():Void {
 		if(listento[0] != null) {
    		map=_global.flamingo.getComponent(listento[0]);
    	}
        var componentIDs:Array = getComponents();
        var component:MovieClip = null;
        urls = new Array();
        for (var comp:String in componentIDs) {
            component = _global.flamingo.getComponent(componentIDs[comp]);
            if (component.getComponentName() != "URL") {
                continue;
            }
            component.setMap(map);
			urls.push(component); 
        }
        if (urls.length == 0) {
            _global.flamingo.tracer("Exception in gui.URLSelector.<<init>>()\nNo urls configured.");
            return;
        }
        addURLGroupSelector();  
		_global.flamingo.addListener(this,"flamingo",this);	
 	}
 		    
   	function setAttribute(name:String, value:String):Void {  
        if(name=="listlength"){
        	this.listlength = Number(value);
        } 	
   
    }
    
    
    function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
    	urlComboBox.setSize(width,22);
    	groupComboBox.setSize(width,22);
    	urlComboBox._y = y + this.y;
    	super.setBounds(x,y,width,height);
    }    	

 	private function addURLGroupSelector():Void {
 		var groups:Array = getURLGroups();
 		if(groups.length > 1){
	 		var comboBoxGroupContainer:MovieClip = createEmptyMovieClip("mGroupComboBoxContainer", 20);
	        comboBoxGroupContainer._lockroot = true; // Without this line comboboxes wouldn't open.
	        groupComboBox = this["mGroupComboBoxContainer"].createClassObject(mx.controls.ComboBox, "cmbGroupChoser", 0);
	        // to get rid of sticky focusrects use these lines
			groupComboBox.__rowCount = listlength;
			groupComboBox.getDropdown().drawFocus = "";
			groupComboBox.onKillFocus = function(newFocus:Object) {
				super.onKillFocus();
			};
			groupComboBox.setSize(this.__width,22);
			groupComboBox.addEventListener("close", Delegate.create(this, onChangeURLGroupComboBox));
			groupComboBox.setDataProvider(groups);
			y += 10;
 		}
 		addURLSelector();
 	}
    
    private function addURLSelector():Void {
        var comboBoxContainer:MovieClip = createEmptyMovieClip("mURLComboBoxContainer", 10);
        comboBoxContainer._lockroot = true; // Without this line comboboxes wouldn't open.
        urlComboBox = this["mURLComboBoxContainer"].createClassObject(mx.controls.ComboBox, "cmbURLChoser", 0);
        // to get rid of sticky focusrects use these lines
		urlComboBox.__rowCount = listlength;
		urlComboBox.getDropdown().drawFocus = "";
		urlComboBox.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		urlComboBox.setSize(this.__width,22);
		urlComboBox.addEventListener("close", Delegate.create(this, onChangeURLComboBox));
		if(groupComboBox!=null){
			urlComboBox._visible = false;
		} else {
			urlComboBox.dataProvider = getURLs(null);
		}
		urlComboBox._y = y;
	}

	private function getURLGroups(){
		var group:Object=null;
	    var groups:Array = new Array();
		var groupselLabel:String = _global.flamingo.getString(this, "groupsellabel");
		if(groupselLabel!=null){
			group = new Object();
			group["label"] = groupselLabel;
			group["data"] = null;
			groups.push(group) ;
		}
		for (var i:Number = 0; i < urls.length; i++) {
			var groupStr:String = URL(urls[i]).getGroup();
            if (groupStr!=null && groupNotYetIn(groups,groupStr)){
            	group = new Object(); 
	            group["label"] = URL(urls[i]).getGroupLabel();
    	        group["data"] = URL(urls[i]).getGroup();
        	    groups.push(group);
            }    
        }
		return groups;		
	}
	
	private function groupNotYetIn(groups : Array, groupStr : String) : Boolean {
		var notYetIn:Boolean = true;
		for (var j:Number = 0; j < groups.length; j++) {
			if(groups[j]["data"] == groupStr){
			 	notYetIn = false;
			}
		}
		return notYetIn;
	}
				

	
	private function getURLs(group:String):Array{
		var gUrl:Object=null;
	    var gUrls:Array = new Array();
		var urlselLabel:String = _global.flamingo.getString(this, "urlsellabel");
		if(urlselLabel!=null){
			gUrl = new Object();
			gUrl["label"] = urlselLabel;
			gUrl["data"] = null;
			gUrls.push(gUrl);
		}	
        for (var i:Number = 0; i < urls.length; i++) {
            if(URL(urls[i]).getGroup() == group || group == null){
            	gUrl = new Object();     
            	gUrl["label"] = URL(urls[i]).getLabel();
            	gUrl["data"] = URL(urls[i]);
            	gUrls.push(gUrl);
            }	
        }
        return gUrls;   
	}
	
	private function onChangeURLComboBox(eventObject:Object) : Void {
		var url:URL = eventObject.target.selectedItem.data;
		if(url.getUrl()!=null){	
			var my_xml:XML = new XML();
			my_xml.contentType = "text/xml";
			my_xml.send(url.getUrl(), url.getTarget());
		}	
	}
	
	private function onChangeURLGroupComboBox(eventObject:Object) : Void {
		var group:String = eventObject.target.selectedItem.data;
		if(group!=null){
			urlComboBox._visible = true;
			urlComboBox.setDataProvider(getURLs(group));
		} else {
			urlComboBox._visible = false;
		}
	}

}
	
