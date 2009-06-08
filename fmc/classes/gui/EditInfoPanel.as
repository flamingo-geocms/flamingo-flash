// This file is part of Flamingo MapComponents.
// Author: Maurits Kelder.

import gui.*;
import core.AbstractComponent;

import event.*;
import gismodel.GIS;
import gismodel.Feature;
import gismodel.Layer;
import geometrymodel.*;


class gui.EditInfoPanel extends AbstractComponent implements StateEventListener {
    
    private var gis:GIS = null;
	private var geometry:Geometry = null; // Set by init object.
	private var thisObj:Object;
	private var nrDigits:Number = 0;		//specifies the number of digits to be used in the gui
	private var nrDigitsBase:Number = 1;	//base = 10 to the power nrDigits
    
    function init():Void {
        thisObj = this;
		gis = _global.flamingo.getComponent(listento[0]).getGIS();
        this._visible = false;
		
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "geometryUpdate");
		gis.addEventListener(this, "GIS", StateEvent.CHANGE, "geometryDragUpdate");
		var layers:Array = gis.getLayers();
        var layer:Layer = null;
        for (var i:Number = 0; i < layers.length; i++) {
            layer = Layer(layers[i]);
            layer.addEventListener(this, "Layer", StateEvent.CHANGE, "visible");
        }
    }
	
	function setAttribute(name:String, value:String):Void { 
		if (name=="nrdigits"){
			nrDigits=Math.round(Number(value));
			if (nrDigits < 0) {
				nrDigits = 0;
			}
			else if (nrDigits > 6) {
				nrDigits = 6;
			}
			nrDigitsBase = Math.pow(10,nrDigits);
		}
	}
    
	function remove():Void { // This method is an alternative to the default MovieClip.removeMovieClip. Also unsubscribes as event listener. The event method MovieClip.onUnload cannot be used, because it works buggy.
        gis.removeEventListener(this, "GIS", StateEvent.CHANGE, "activeFeature");
		gis.removeEventListener(this, "GIS", StateEvent.CHANGE, "geometryUpdate");
        this.removeMovieClip(); // Keyword "this" is necessary here, because of the global function removeMovieClip.
    }
    
	
	function onStateEvent(stateEvent:StateEvent):Void {
        var sourceClassName:String = stateEvent.getSourceClassName();
        var actionType:Number = stateEvent.getActionType();
        var propertyName:String = stateEvent.getPropertyName();
		
		if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_geometryUpdate"
			|| sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_geometryDragUpdate") {
            if (geometry instanceof Polygon) {
				var area:Number = Polygon(geometry).getArea(false);
				if (area == null) {
					thisObj.mEditInfoPanel_Polygon.tf1.text = "0 (m²) \nPolygon is complex";
				}
				else {
					area = Math.abs(Math.round(area)); 
				
					thisObj.mEditInfoPanel_Polygon.tf1.text = digitGrouping(String(area))+" (m²)";
					if (area > 1000000) {
						thisObj.mEditInfoPanel_Polygon.tf1.text += "\n"+digitGrouping(String( Math.round(area/1000000) ))+" (km²)";
					}
				}
			}
			else if (geometry instanceof LineString) {
				var lengthString:Number = Math.abs(Math.round(LineString(geometry).getLength()));
				thisObj.mEditInfoPanel_Linestring.tf1.text = digitGrouping(String(lengthString))+" (m)";
				if (lengthString > 1000) {
					thisObj.mEditInfoPanel_Linestring.tf1.text += "\n"+digitGrouping(String(Math.round(lengthString/1000) ))+" (km)";
				
				}
				if (gis.getCreatePointAtDistance()) {
					var endPoint:geometrymodel.Point = LineString(geometry).getEndPoint();
					thisObj.mEditInfoPanel_Linestring.ti_X.text = decimalFormatting(endPoint.getX());
					thisObj.mEditInfoPanel_Linestring.ti_Y.text = decimalFormatting(endPoint.getY());	
				}
				

			}
			else if (geometry instanceof Point) {
				thisObj.mEditInfoPanel_Point.ti_X.text = decimalFormatting(Point(geometry).getX());
				thisObj.mEditInfoPanel_Point.ti_Y.text = decimalFormatting(Point(geometry).getY());
			}
		} 
		
		else if (sourceClassName + "_" + actionType + "_" + propertyName == "GIS_" + StateEvent.CHANGE + "_activeFeature") {
            var feature:Feature = gis.getActiveFeature();
			if (feature == null) {
				this._visible=false;
			}
			else {
				this._visible=true;
				
				geometry = feature.getGeometry();
				if (geometry instanceof Polygon) {
					//remove mEditInfoPanel_Linestring sub panel if existing
					if (thisObj.mEditInfoPanel_Linestring instanceof MovieClip) {
						thisObj.mEditInfoPanel_Linestring.removeMovieClip();
					}
					//remove mEditInfoPanel_Point sub panel if existing
					if (thisObj.mEditInfoPanel_Point instanceof MovieClip) {
						thisObj.mEditInfoPanel_Point.removeMovieClip();
					}
				
					//create EditInfoPanel_Polygon sub panel if not existing
					if (!(thisObj.EditInfoPanel_Polygon instanceof MovieClip)) {
						thisObj.attachMovie("EditInfoPanel_Polygon", "mEditInfoPanel_Polygon",10);
						thisObj.mEditInfoPanel_Polygon._x = 5;
						thisObj.mEditInfoPanel_Polygon._y = 5;
						with (thisObj.mEditInfoPanel_Polygon.tf1) {
							setStyle("fontSize",11);
							background = true;
						}
					}
					var area:Number = Math.abs(Math.round(Polygon(geometry).getArea(false)));
					thisObj.mEditInfoPanel_Polygon.tf1.text = digitGrouping(String(area))+" (m²)";
					if (area > 1000000) {
						thisObj.mEditInfoPanel_Polygon.tf1.text += "\n"+digitGrouping(String( Math.round(area/1000000) ))+" (km²)";
					}
				}
				else if (geometry instanceof LineString) {
					//remove mEditInfoPanel_Polygon sub panel if existing
					if (thisObj.mEditInfoPanel_Polygon instanceof MovieClip) {
						thisObj.mEditInfoPanel_Polygon.removeMovieClip();
					}
					//remove mEditInfoPanel_Point sub panel if existing
					if (thisObj.mEditInfoPanel_Point instanceof MovieClip) {
						thisObj.mEditInfoPanel_Point.removeMovieClip();
					}
					
					if (!gis.getCreatePointAtDistance()) {
						if (!(thisObj.EditInfoPanel_Polygon instanceof MovieClip)) {
							thisObj.attachMovie("EditInfoPanel_Linestring", "mEditInfoPanel_Linestring",10);
							thisObj.mEditInfoPanel_Linestring._x = 5;
							thisObj.mEditInfoPanel_Linestring._y = 5;
							with (thisObj.mEditInfoPanel_Linestring.tf1) {
								setStyle("fontSize",11);
								background = true;
							}
						}
					}
					else {
						if (!(thisObj.EditInfoPanel_Polygon instanceof MovieClip)) {
							thisObj.attachMovie("EditInfoPanel_PointAtDist", "mEditInfoPanel_Linestring",10);
							thisObj.mEditInfoPanel_Linestring._x = 5;
							thisObj.mEditInfoPanel_Linestring._y = 5;
							with (thisObj.mEditInfoPanel_Linestring.tf1) {
								setStyle("fontSize",11);
								background = true;
							}
						}
						var endPoint:geometrymodel.Point = LineString(geometry).getEndPoint();
						thisObj.mEditInfoPanel_Linestring.ti_X.text = decimalFormatting(endPoint.getX());
						thisObj.mEditInfoPanel_Linestring.ti_Y.text = decimalFormatting(endPoint.getY());	
					}
					
					var lengthString:Number = Math.abs(Math.round(LineString(geometry).getLength()));
							
					thisObj.mEditInfoPanel_Linestring.tf1.text = digitGrouping(String(lengthString))+" (m)";
					if (lengthString > 1000) {
						thisObj.mEditInfoPanel_Linestring.tf1.text += "\n"+digitGrouping(String(Math.round(lengthString/1000) ))+" (km)";
					
					}

				}
				
				else if (geometry instanceof Point) {
					thisObj.tfGeomInfo.text = "";
					
					//create mEditInfoPanel_Point sub panel if not existing
					if (!(thisObj.mEditInfoPanel_Point instanceof MovieClip)) {
						thisObj.attachMovie("EditInfoPanel_Point", "mEditInfoPanel_Point",10);
					}
					thisObj.mEditInfoPanel_Point._x = 5;
					thisObj.mEditInfoPanel_Point._y = 5;
						
					with (thisObj.mEditInfoPanel_Point.ti_X) {
						setStyle("fontSize",11);
						background = true;
					}
					with (thisObj.mEditInfoPanel_Point.ti_Y) {
						setStyle("fontSize",11);
						background = true;
					}
					thisObj.mEditInfoPanel_Point.ti_X.text = decimalFormatting(Point(geometry).getX());
					thisObj.mEditInfoPanel_Point.ti_Y.text = decimalFormatting(Point(geometry).getY());	

					//try to set the tabindex and the defaultPushButton of the sub panel
					//Unfortunately it does not work and there seems to be a sneaky bug in as2 cs3 with the mixing of 
					//the components: textinput and button. The order by which you add them to the lib influences the correct
					//execution of the tab sequencing.
					thisObj.tabChildren=true; 
					thisObj.tabEnabled=false;
					thisObj.mEditInfoPanel_Point.tabChildren = true;
					thisObj.mEditInfoPanel_Point.tabEnabled=true;
					thisObj.mEditInfoPanel_Point.ti_X.tabIndex = 1;
					thisObj.mEditInfoPanel_Point.ti_Y.tabIndex = 2;
					thisObj.mEditInfoPanel_Point.bt_Apply.tabEnabled = true;
					thisObj.mEditInfoPanel_Point.bt_Apply.tabIndex = 3;
					
					thisObj.defaultPushButton = thisObj.mEditInfoPanel_Point.bt_Apply.defaultPushButton;
					thisObj.mEditInfoPanel_Point.ti_X.setFocus();
					
					var theActivePoint:Object = Point(geometry);
					var thisObj2:Object = this;
					
					if (gis.getEditMapEditable()) {
						thisObj.mEditInfoPanel_Point.bt_Apply.visible = true;
						thisObj.mEditInfoPanel_Point.bt_Apply.onPress = function(evt_obj:Object):Void {
							var p:Point = thisObj2.cleanCoordinateInput(_parent.ti_X.text, _parent.ti_Y.text);
							if (p != null) {
								theActivePoint.setXY(p.getX(), p.getY());
								//redraw corresponding editMapPoint
								theActivePoint.changeGeometry(this);
							}
							else {
								//trace("EditInfoPanel.as: user input for point coordinates did not pass test (out of range or no numbers)");
							}
						}
					}
					else {
						thisObj.mEditInfoPanel_Point.bt_Apply.visible = false;
					}						
					
					
				}
			}
        }
		else if (sourceClassName + "_" + actionType + "_" + propertyName == "Layer_" + StateEvent.CHANGE + "_visible") {
            var layer:Layer = Layer(stateEvent.getSource());
            if (layer.isVisible()) {
				if (gis.getActiveFeature() != null) {
					this._visible = true;
				}
			}
			else {
				this._visible = false;
			}
		}
    }
	
	
	private function cleanCoordinateInput(xText:String, yText:String):Point {
		var p:Point;
		var x:Number = Number(xText);
		var y:Number = Number(yText);
	
		var fullExtent:Object = _global.flamingo.getComponent(listento[0]).getMap().getCFullExtent();
		var currentExtent:Object = _global.flamingo.getComponent(listento[0]).getMap().getCurrentExtent();
				
		//check if input values are within the FullExtent
		if (x!=undefined && x > fullExtent.minx && x < fullExtent.maxx && y!=undefined && y > fullExtent.miny && y < fullExtent.maxy) {
			p = new Point(x, y);

			//check if point p is within the current extent, if not resize extent so that it is shown to the user
			if (x < currentExtent.minx || x > currentExtent.maxx || y < currentExtent.miny || y > currentExtent.maxy) {
				//calc extended extent
				var margin:Number = 0.2;
				var extendedExtent:Object = _global.flamingo.getComponent(listento[0]).getMap().getCurrentExtent();
				if (x < currentExtent.minx) {
					extendedExtent.minx -= (currentExtent.minx - x) + margin * (currentExtent.maxx - x);
					if (extendedExtent.minx < fullExtent.minx) {
						extendedExtent.minx = fullExtent.minx;
					}
				}
				if (x > currentExtent.maxx) {
					extendedExtent.maxx -= (currentExtent.maxx - x) + margin * (currentExtent.minx - x);
					if (extendedExtent.maxx > fullExtent.maxx) {
						extendedExtent.maxx = fullExtent.maxx;
					}
				}
				if (y < currentExtent.miny) {
					extendedExtent.miny -= (currentExtent.miny - y) + margin * (currentExtent.maxy - y);
					if (extendedExtent.miny < fullExtent.miny) {
						extendedExtent.miny = fullExtent.miny;
					}
				}
				if (y > currentExtent.maxy) {
					extendedExtent.maxy -= (currentExtent.maxy - y) + margin * (currentExtent.miny - y);
					if (extendedExtent.maxy > fullExtent.maxy) {
						extendedExtent.maxy = fullExtent.maxy;
					}
				}
				
				//dispatch resize extent event
				_global.flamingo.getComponent(listento[0]).getMap().moveToExtent(extendedExtent);
				_global.flamingo.getComponent(listento[0]).getMap().update();
				
			}

			
			return p;
		
		}
		else {
		
			return null;
		}
		
		
		
	}
	
	private function decimalFormatting(n:Number):String {
		//ensures that the number of decimals after the . sign are fixed
		var str:String;
		if (n == NaN) {
			return "0.00";
		}
		else {
			str = String(Math.round(nrDigitsBase*n)/nrDigitsBase);
		}
		
		var digitAfterPointCount:Number = -1;
		var startCounting:Boolean = false;
		for (var i = 0; i < str.length; i++) {
			if (str.charAt(i) == "." ) {
				startCounting = true;
			}
			if (startCounting) {
				digitAfterPointCount++;
			}
		}
		if (digitAfterPointCount == -1) {
			if (nrDigits > 0) {
				str += ".";
			}
			digitAfterPointCount =0;
		}
		for (var i = digitAfterPointCount; i<nrDigits; i++) { 
			str += "0";
		}
		
		return str;
	}
	
	private function digitGrouping(strIn:String):String {
		var strRevOut:String = "";
		var strOut:String = "";
		for (var i = strIn.length - 1; i>=0; i--) {
			strRevOut += strIn.charAt(i);
			if (i>0 && (strIn.length - i) % 3 == 0) {
				strRevOut += " ";
			}
		}
		//reverse strRevOut to fill strOut
		for (var i = strRevOut.length - 1; i>=0; i--) {
			strOut += strRevOut.charAt(i);
		}
		return strOut;
	}

    
}
