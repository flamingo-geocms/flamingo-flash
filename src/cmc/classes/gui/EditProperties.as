/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/


/** @component cmc:EditProperties
* Edit properties component. A component that shows the properties of the active feature in the feature model, and their values. 
* As a single line or multi line text inputs, or as drop down lists. The user can change the values for properties that are not immutable.
* Changing values in the edit properties component means changing them in the feature model at the same time. Please refer to the GIS component.
* @file flamingo/cmc/classes/gui/EditProperties.as  (sourcefile)
* @file flamingo/cmc/EditProperties.fla (sourcefile)
* @file flamingo/cmc/EditProperties.swf (compiled component, needed for publication on internet)
*/

/** @tag <cmc:EditProperties>
* This tag defines an edit properties component instance. The edit properties component must be registered as a listener to an edit map. 
* Actually, the edit properties component listens to the feature model underneath the edit map. 
* An edit properties component should be placed in a window so that the active feature event of the feature model can make it pop-up. 
* The visible parameter of EditProperties and the window should both be configured to false.
* @class gui.EditProperties extends AbstractComponent implements StateEventListener
* @hierarchy childnode of Flamingo or a container component.
* @example 
<[!CDATA[
  <cmc:Window id="editPropertiesWindow">
     <cmc:EditProperties id="editProperties" top="0" left="0" right="right" bottom="bottom" visible="false" listento="editMap" okbutton="true">
     	<string id="okbuttonlabel" en="OK" nl="OK"/> 
     </cmc:EditProperties>
  </fmc:Window>
]]>
 * * @attr okbutton (defaultvalue = "false") boolean for showing or hiding okbutton  
* @configstring okbuttonlabel (defaultvalue = "OK") labeltext of the okbutton
*/

import geometrymodel.*;
import gui.*;

import event.*;
import coremodel.service.ServiceLayer;
import gismodel.Feature;
import gismodel.GIS;
import gismodel.Layer;
import gismodel.Property;
import gismodel.GeometryProperty;

import flash.geom.Rectangle;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.TextArea;
import mx.controls.UIScrollBar;
import mx.utils.Delegate;
import mx.controls.Button;
import tools.Logger;

import core.AbstractComponent;

class gui.EditProperties extends AbstractComponent implements StateEventListener {
    
    private var gis:GIS = null;
    private var components:Array = null;
    private var mainLabel:Label = null;
    private var labelStyle:Object = null;
    private var componentsPanel:MovieClip = null;
    private var componentHeight:Number = 22;
    private var vertiSpacing:Number = 7;
    private var minTextAreaHeight:Number = 50;
    private var scrollBar:UIScrollBar = null;
    private var nullValueText:String = "";
    private var showOKButton:Boolean = true;
	private var showApplyButton:Boolean = false;
	private var lastFocusComponent:Object = null;
	private var actionEventListeners:Array = null;
    
    function init():Void {
        gis = _global.flamingo.getComponent(listento[0]).getGIS();   
        components = new Array();
        gis.addEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
        mainLabel = Label(attachMovie("Label", "mMainLabel", 0, {autoSize: "left"}));
        labelStyle = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
        mainLabel.setStyle("fontFamily", labelStyle["fontFamily"]);
        mainLabel.setStyle("fontSize", labelStyle["fontSize"]);
        mainLabel.setStyle("fontWeight", "bold");
        componentsPanel = createEmptyMovieClip("mPanel", 1);
        componentsPanel._y = componentHeight;
        componentsPanel._lockroot = true; // Without this line comboboxes wouldn't open.
		
		actionEventListeners = new Array();
    }

	function setAttribute(name:String, value:String):Void {		
    	if(name.toLowerCase()=="okbutton"){
			if (value.toLowerCase()=="true"){
				showOKButton = true;
			}else{
				showOKButton = false;
			}
        	
        }
		if(name.toLowerCase()=="applybutton"){
			if (value.toLowerCase()=="true"){
				showApplyButton = true;
			}else{
				showApplyButton = false;				
			}
		  	
        } 
		
	}
    
	function setActionEventListener(actionEventListener:ActionEventListener):Void {
		if (actionEventListener != null) {
			actionEventListeners.push(actionEventListener);
		}
    }
	
	function closeOtherComponentWindows(callerComponent:MovieClip):Void{
		for (var i:Number=0; i<actionEventListeners.length; i++) {
			if (actionEventListeners[i] != callerComponent && actionEventListeners[i] != null) {
				var actionEvent:ActionEvent = new ActionEvent(this, "PropWindow", ActionEvent.OPEN);
				actionEventListeners[i].onActionEvent(actionEvent);
			}
		}
	}
		
	
    private function layout():Void {
        var numLabels:Number = 0;
        var numTextAreas:Number = 0;
		var numGeometryAreas:Number= 0;
        for (var i:String in components) {
            if (components[i] instanceof Label) {
                numLabels++;
            } else if (components[i] instanceof TextArea) {
                numTextAreas++;
            } else{
				numGeometryAreas++;
			}
        }
        var panelWidth:Number = __width - 15 - 1;
        var panelHeight:Number = __height - componentHeight;
        var textAreaHeight:Number = (__height - ((components.length + 1 - numTextAreas) * componentHeight) - (numLabels * vertiSpacing)) / numTextAreas;
        if (textAreaHeight < minTextAreaHeight) {
            textAreaHeight = minTextAreaHeight;
        }
        var y:Number = 0;
		var x:Number = 0;
        
        var component:MovieClip = null;
        for (var i:Number = 0; i < components.length; i++) {
            component = MovieClip(components[i]);
            if (component instanceof Label) {
                y += vertiSpacing;
                component._y = y;
                y += componentHeight;
            } else if (component instanceof TextArea) {
                component._y = y;
                component.setSize(panelWidth, textAreaHeight);
                y += textAreaHeight;
            } else {
                component._y = y;
                component.setSize(panelWidth, componentHeight);
                y += componentHeight;
            }
        }
		if(showApplyButton==true){ 
			y += 30;
			
	       var button2:Button = Button(attachMovie("Button", "mApplyButton", 102));
	       button2._y = y;
		   button2._x = x;
	       button2.label = _global.flamingo.getString(this, "applybuttonlabel");
	       if(button2.label==null||button2.label==""){
	       	button2.label="Apply";
	       }
	       button2.addEventListener("click", Delegate.create(this, onClickApplyButton)); 
        } 
		
       if(showOKButton==true){ 
			y += 30;
			var button:Button = Button(attachMovie("Button", "mOKButton", 101));
			button._y = y;
			button._x = x;
			button.label = _global.flamingo.getString(this, "okbuttonlabel");
			if(button.label==null||button.label==""){
				button.label="OK";
			}	
			button.addEventListener("click", Delegate.create(this, onClickOKButton)); 
		} 
	   
        
        if (y > panelHeight) {
            if (scrollBar == null) {
                scrollBar = UIScrollBar(attachMovie("UIScrollBar", "mScrollBar", 2, {_y: componentHeight}));
                scrollBar.addEventListener("scroll", Delegate.create(this, onScrollBar));
            }
            scrollBar._x = panelWidth;
            scrollBar.setSize(15, panelHeight);
            scrollBar.setScrollProperties(panelHeight, 0, y - panelHeight);
            componentsPanel.scrollRect = new Rectangle(0, scrollBar.scrollPosition, panelWidth, y);
        } else {
            if (scrollBar != null) {
                scrollBar.removeMovieClip();
                scrollBar = null;
                componentsPanel.scrollRect = null;
            }
        }
    
	}
	
	private function onClickOKButton() : Void {
		setFeatureValues();
		raiseActiveFeatureEvent("onOk",gis.getActiveFeature().getLayer().getName());
		this.setVisible(false);
	}
	
	private function onClickApplyButton() : Void {
		setFeatureValues();
		var feature:Feature = gis.getActiveFeature();
		raiseActiveFeatureEvent("onApply",feature.getLayer().getName());
		//redraw the geometry		
		var geometry:Geometry = feature.getGeometry().getFirstAncestor();
		geometry.geometryEventDispatcher.changeGeometry(geometry);
	}
	
	private function raiseActiveFeatureEvent(ev,layerId){
		_global.flamingo.raiseEvent(this,ev,layerId,gis.getActiveFeature().toObject());
	}

	function onScrollBar(eventObject:Object):Void {
        var rectangle:Rectangle = Rectangle(componentsPanel.scrollRect);
        rectangle.y = scrollBar.scrollPosition;
        componentsPanel.scrollRect = rectangle;
    }
    
    function setVisible(visible:Boolean):Void {
        super.setVisible(visible);
        
        if (!this.visible) {
            gis.setActiveFeature(null);
        }
    }
    
    function onStateEvent(stateEvent:StateEvent):Void {		
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
        if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_activeFeature") {
            var previousActiveFeature:Feature = Feature(ChangeEvent(stateEvent).getPreviousState());
            var activeFeature:Feature = gis.getActiveFeature();
            if (previousActiveFeature != null) {
                previousActiveFeature.removeEventListener(this, "Feature", StateEvent.CHANGE, "values");
            }
            if (activeFeature != null) {
                activeFeature.addEventListener(this, "Feature", StateEvent.CHANGE, "values");
                
                setVisible(true);
                if (previousActiveFeature == null) {
                    removeComponents();
					addComponents();
					setFeatureValues();
                } else if (previousActiveFeature.getLayer() == activeFeature.getLayer()) {
					removeComponents();
					addComponents();
                } else { // From a different layer; not from null.
                    removeComponents();
                    addComponents();
                }
            } else {
                setVisible(false);
				setComponentValues();
                removeComponents();
            }
        } else if (sourceClassName + "_" + actionType + "_" + propertyName == "Feature_" + StateEvent.CHANGE + "_values") {			
			/*removeComponents();
            addComponents();*/
			
			//setComponentValues();			
        }
    }
    
    private function addComponents():Void {
		if (components.length > 0) {
            _global.flamingo.tracer("Exception in gui.EditProperties.addComponents()");
            return;
        }
        
        var feature:Feature = gis.getActiveFeature();
        var layer:Layer = feature.getLayer();
        var layerName:String = layer.getName();
        var serviceLayer:ServiceLayer = layer.getServiceLayer();
        var properties:Array = layer.getProperties();
        var property:Property = null;
        var propertyName:String = null;
        var propertyType:String = null;
		var propertyPropertyType:String = null;
        var initObject:Object = null;
        var dataProvider:Array = null;
		var thisObj:Object = null;
		var geometry:Geometry = feature.getGeometry().getFirstAncestor();
        
		//loop over properties with k
		var i:Number = 0;		//component loop index i
		for (var k:Number = 0; k < properties.length; k++) {
            property = Property(properties[k]);
            propertyName = property.getName();
            propertyType = property.getType();
			var isGeometryProperty:Boolean = (property instanceof GeometryProperty);
						
			//verify if we should use this GeometryProperty
			var useGeometryProperty = false;
			if (isGeometryProperty){
				useGeometryProperty=useGeomProperty(GeometryProperty(properties[k]),geometry);
			}
			initObject = new Object();
			initObject["autoSize"] = "left";
			initObject["text"] = property.getTitle();
			if (!isGeometryProperty || useGeometryProperty){
				components.push(componentsPanel.attachMovie("Label", "mLabel" + layerName + i, i * 2, initObject));
				Label(components[i * 2]).setStyle("fontFamily", labelStyle["fontFamily"]);
				Label(components[i * 2]).setStyle("fontSize", labelStyle["fontSize"]);
				if ((serviceLayer == null) || (serviceLayer.getServiceProperty(propertyName).isOptional())) {
					Label(components[i * 2]).setStyle("fontStyle", "italic");
				}
			}
			initObject = new Object();
			initObject["enabled"] = !property.isImmutable();
			initObject["tabIndex"] = i;
			initObject["tabEnabled"] = true;						
			initObject["gis"] = gis;
			initObject["propertyName"] = propertyName;
			//if not a geometryproperty
			if(!isGeometryProperty){
				if (propertyType == "SingleLine") {
					components.push(componentsPanel.attachMovie("TextInput", "mComponent" + layerName + i, i * 2 + 1, initObject));
					//MovieClip(components[i * 2 + 1]).addEventListener("change", Delegate.create(this, onComponentChange));
				} else if (propertyType == "MultiLine") {
					components.push(componentsPanel.attachMovie("TextArea", "mComponent" + layerName + i, i * 2 + 1, initObject));
					//MovieClip(components[i * 2 + 1]).addEventListener("change", Delegate.create(this, onComponentChange));
				} else { // DropDown
					dataProvider = propertyType.split(":")[1].split(",");
					dataProvider.splice(0, 0, nullValueText);
					initObject["dataProvider"] = dataProvider;
					initObject["rowCount"] = dataProvider.length;
					initObject["editable"] = false;
					components.push(componentsPanel.attachMovie("ComboBox", "mComponent" + layerName + i, i * 2 + 1, initObject));
					ComboBox(components[i * 2 + 1]).getDropdown().drawFocus = ""; // Without this line the green focus would remain after selecting from the combobox.
				}
				MovieClip(components[i * 2 + 1]).addEventListener("change", Delegate.create(this, onComponentChange));
				//increase component loop index i				
				i++;
			//if geometry property and useGeometryProperty	
			}else if (useGeometryProperty){				
				initObject["propertyPropertyType"] = GeometryProperty(property).getPropertyType();

				if (propertyType == "ColorPalettePicker") {
					initObject["minvalue"] = GeometryProperty(properties[k]).getMinvalue();
					initObject["maxvalue"] = GeometryProperty(properties[k]).getMaxvalue();
					initObject["nrTilesHor"] = GeometryProperty(properties[k]).getNrTilesHor();
					initObject["nrTilesVer"] = GeometryProperty(properties[k]).getNrTilesVer();
					components.push(componentsPanel.attachMovie("ColorPalettePicker", "mComponent" + layerName + i, i * 2 + 1, initObject));
				} else if (propertyType == "OpacityInput") {
					initObject["minvalue"] = GeometryProperty(properties[k]).getMinvalue();
					initObject["maxvalue"] = GeometryProperty(properties[k]).getMaxvalue();
					components.push(componentsPanel.attachMovie("OpacityInput", "mComponent" + layerName + i, i * 2 + 1, initObject));
				} else if (propertyType == "OpacityPicker") {
					initObject["minvalue"] = GeometryProperty(properties[k]).getMinvalue();
					initObject["maxvalue"] = GeometryProperty(properties[k]).getMaxvalue();
					initObject["nrTilesHor"] = GeometryProperty(properties[k]).getNrTilesHor();
					initObject["nrTilesVer"] = GeometryProperty(properties[k]).getNrTilesVer();
					components.push(componentsPanel.attachMovie("OpacityPicker", "mComponent" + layerName + i, i * 2 + 1, initObject));
				} else if (propertyType == "LineTypePicker") {
					components.push(componentsPanel.attachMovie("LineTypePicker", "mComponent" + layerName + i, i * 2 + 1, initObject));
				}  else if (propertyType == "DashStylePicker") {
					initObject["minvalue"] = GeometryProperty(properties[k]).getMinvalue();
					initObject["maxvalue"] = GeometryProperty(properties[k]).getMaxvalue();
					initObject["nrTilesHor"] = GeometryProperty(properties[k]).getNrTilesHor();
					initObject["nrTilesVer"] = GeometryProperty(properties[k]).getNrTilesVer();
					components.push(componentsPanel.attachMovie("DashStylePicker", "mComponent" + layerName + i, i * 2 + 1, initObject));
				} else if (propertyType == "PatternPicker") {
					initObject["minvalue"] = GeometryProperty(properties[k]).getMinvalue();
					initObject["maxvalue"] = GeometryProperty(properties[k]).getMaxvalue();
					initObject["nrTilesHor"] = GeometryProperty(properties[k]).getNrTilesHor();
					initObject["nrTilesVer"] = GeometryProperty(properties[k]).getNrTilesVer();
					components.push(componentsPanel.attachMovie("PatternPicker", "mComponent" + layerName + i, i * 2 + 1, initObject));
				} else if (propertyType == "IconPicker") {
					initObject["minvalue"] = GeometryProperty(properties[k]).getMinvalue();
					initObject["maxvalue"] = GeometryProperty(properties[k]).getMaxvalue();
					initObject["nrTilesHor"] = GeometryProperty(properties[k]).getNrTilesHor();
					initObject["nrTilesVer"] = GeometryProperty(properties[k]).getNrTilesVer();
					components.push(componentsPanel.attachMovie("IconPicker", "mComponent" + layerName + i, i * 2 + 1, initObject));			
				} else if (propertyType == "PointTextEditor") {
					components.push(componentsPanel.attachMovie("PointTextEditor", "mComponent" + layerName + i, i * 2 + 1, initObject));
				} else{
					_global.flamingo.tracer("Exception in gui.EditProperties.addComponents()\nThe geometry PropertyType: "+propertyType+" is unknown");
					//error so component is not added: decrease the components (because later a increase will be done)					
					i++;
				}
				//increase component loop index i				
				i++;
			}
        }
        layout();
        setComponentValues();
    }
    
    function onComponentChange(eventObject:Object):Void {
        setFeatureValues();
    }
	
	function onComponentSetFocus(newfocus:Object):Void {
		//put the componentsPanel on top at a depth of 200.
		componentsPanel.swapDepths(200);
		//Depth of ok, apply, future cancel buttons is resp. 101, 102, 103.
		//all components are childs of the componentsPanel
		var newDepth:Number = componentsPanel.getNextHighestDepth();
		if (newDepth>1000) {	//allows around 1000 clicks before redraw.
			removeComponents();
            addComponents();
		}
		newfocus.swapDepths(componentsPanel.getNextHighestDepth());
    }
    
    private function removeComponents():Void {
        for (var i:String in components) {
            MovieClip(components[i]).removeMovieClip();
        }
        components = new Array();
    }
    
    private function setComponentValues():Void {
        var feature:Feature = gis.getActiveFeature();
        var properties:Array = feature.getLayer().getProperties();
        var values:Array = feature.getValues();
        var value:String = null;
        var component:MovieClip = null;

		var geometry:Geometry = feature.getGeometry().getFirstAncestor();	
        var property:Property = null;
		var propertyType:String = null;
		var propertyName:String = null;
		
		//loop over properties with k
		var i:Number = 0;		//component loop index i
		for (var k:Number = 0; k < properties.length; k++) {
			property = Property(properties[k]);
            propertyName = property.getName();
            propertyType = property.getType();
			var isGeometryProperty:Boolean = (property instanceof GeometryProperty);
			
			//verify if we should use this GeometryProperty
			var useGeometryProperty = false;
			if (isGeometryProperty){
				useGeometryProperty=useGeomProperty(GeometryProperty(properties[k]),geometry);
			}
			value = values[i];
			if(!isGeometryProperty) {				
				if (value == null) {
					value = nullValueText;
				}
				component = MovieClip(components[i * 2 + 1]);
				if (component instanceof ComboBox) {
					setComboBoxValue(ComboBox(component), value);
				}
				else {
					component.text = value;
				}
				i++;
			}else if(useGeometryProperty) {
				component = MovieClip(components[i * 2 + 1]);								
				if (component instanceof ColorPalettePicker) {
					//set available colors
					component.setAvailableColors(GeometryProperty(property).getAvailableColors());
				} else if (component instanceof DashStylePicker) {
					//set available dashStyles
					component.setAvailableDashStyles(GeometryProperty(property).getAvailableDashStyles());
				} else if (component instanceof IconPicker) {
					//set available icons
					component.setAvailableIcons(GeometryProperty(property).getAvailableIcons());
				} 
				//set default value
				if (Property(property).getDefaultValue() != null) {
					component.setDefaultvalue(Property(property).getDefaultValue());
				}
				component.init();				
				//increase component loop index i
				i++;
			}
        }
        mainLabel.text = feature.getLayer().getTitle() + ": " + feature.getID();
    }
    
    private function setComboBoxValue(comboBox:ComboBox, value:String):Void {
        var dataProvider:Array = comboBox.dataProvider;
        for (var i:Number = 0; i < dataProvider.length; i++) {
            if (dataProvider[i] == value) {
                comboBox.selectedIndex = i;
                return;
            }
        }
        _global.flamingo.tracer("Exception in gui.EditProperties.setComboBoxValue()\nThe value \"" + value + "\" does not exist in \"" + dataProvider.toString() + "\".");
    }
    
    private function setFeatureValues():Void {
        var feature:Feature = gis.getActiveFeature();
        var properties:Array = feature.getLayer().getProperties();
        var values:Array = new Array();
        var value:String = null;
        var component:MovieClip = null;
		
		closeOtherComponentWindows(null);
		
        for (var j:Number = 1; j < components.length; j+=2) {
            
			component = MovieClip(components[j]);
            if (component instanceof ComboBox) {
                value = String(ComboBox(component).selectedItem);
				if (value == nullValueText) {
					value = null;
				}
			} else if (component instanceof IconPicker || component instanceof OpacityInput || component instanceof OpacityPicker 
			      || component instanceof ColorPalettePicker || component instanceof PointTextEditor || component instanceof LineTypePicker
				  || component instanceof DashStylePicker || component instanceof PatternPicker) {
				value = component.getValue();
			} else {
                value = component.text;
				if (value == nullValueText) {
					value = null;
				}
            }
            var propertyName:String = String(component["propertyName"]);
            feature.setValue(propertyName, value);
        }        
    }
	//verify if we should use this GeometryProperty for this geometry
	public function useGeomProperty(geometryProperty:GeometryProperty,geometry:Geometry):Boolean{
		if (geometryProperty==undefined || geometry==undefined){
			_global.flamingo.tracer("Exception in gui.EditProperties.useGeomProperty(). Not all parameters are set");
		}
		var propertyType = geometryProperty.getType();
		var useGeometryProperty = false;
		var inGeometryTypes:Array = geometryProperty.getInGeometryTypes();
		for (var j:Number = 0; j < inGeometryTypes.length; j++) { 
			var geometryType:String = String(inGeometryTypes[j]);
			if (geometryType == "Point") {
				if (geometry instanceof Point){
					useGeometryProperty = true;
				}
			} else if (geometryType == "LineString") {
				if (geometry instanceof LineString){
					useGeometryProperty = true;
				}
			} else if (geometryType == "Polygon") {
				if (geometry instanceof Polygon){
					useGeometryProperty = true;
				}
			} else if (geometryType == "Circle") {
				if (geometry instanceof Circle){
					useGeometryProperty = true;
				}
			}
			//overwrite for the iconpicker. In order to exclude other geometryTypes than Point.
			if ( (propertyType == "IconPicker" || propertyType == "PointTextEditor") &&  ( not(geometry instanceof Point) || geometryType != "Point") ) {
				useGeometryProperty = false;
			}
		}
		return useGeometryProperty;
	}
	
    /**
	* Dispatched when in the editproperties a apply is clicked
	* @param editProperties: a reference to the editProperties movieclip.
	* @param featureAsObject:Object representation of the feature that is active.
	*/
	public function onApply(editProperties:MovieClip, featureAsObject:Object):Void {}
	/**
	* Dispatched when in the editproperties a ok is clicked
	* @param layerId: The id of the layer where this feature is stored in.
	* @param featureAsObject:Object representation of the feature that is active.
	*/
	public function onOk(layerId:String, featureAsObject:Object):Void {}
}
