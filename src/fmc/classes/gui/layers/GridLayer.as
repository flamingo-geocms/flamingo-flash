/*-----------------------------------------------------------------------------
Copyright (C) 2006  Menko Kroeske

This file is part of Flamingo MapComponents.

Flamingo MapComponents is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-----------------------------------------------------------------------------*/
/** @component fmc:LayerGrid
* A grid layer. With this component a grid can be shown on the map
* @file flamingo/fmc/classes/gui/layers/GridLayer.as (sourcefile)
* @file flamingo/fmc/classes/gui/layers/AbstractLayer.as (sourcefile)
* @file flamingo/fmc/classes/core/AbstractConfigurable.as
* @file flamingo/fmc/classes/core/AbstractPositionable.as
* @file LayerImage.xml (configurationfile for layer, needed for publication on internet)
*/
/** @tag <fmc:LayerGrid>  
* This tag defines a grid layer.
* @hierarchy childnode of <fmc:Map> 
* @example 
* <fmc:Map id="map" conform="true" mapunits="DECIMALDEGREES" left="10" top="10" right="right -10" bottom="50%" fullextent="-180,-90,180,90"  extent="-180,-90,180,90"  >
* <fmc:LayerGrid  gridwidth="10" gridheight="10" minscale="11000"/>
* <fmc:LayerGrid  gridwidth="5" gridheight="5" maxscale="11000" minscale="5000"/>
* <fmc:LayerGrid  gridwidth="2" gridheight="2" maxscale="5000" minscale="1000"/>
* <fmc:LayerGrid  gridwidth="1" gridheight="1" maxscale="1000" minscale = "500"/>
* <fmc:LayerGrid  gridwidth="0.5" gridheight="0.5" maxscale="500" minscale="100"/>
* <fmc:LayerGrid  gridwidth="0.1" gridheight="0.1" maxscale="100"/>
* </fmc:Map>
* @attr gridwidth  Width of the grid in mapunits.
* @attr gridheight Height of the grid in mapunits.
* @attr maxlines (defaultvalue "10000") Maximum number of gridlines. If number of gridlines exceeds this value, no grid will be visible.
* @attr gridlinecolor (defaultvalue "#777777") Color of the gridline.
* @attr gridlinewidth (defaultvalue "0") Width of gridline.
* @attr gridlinealpha (defaultvalue "20") Alpha blending of the gridline.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
*/
import gui.layers.AbstractLayer;
import gui.Map;
import tools.Logger;
/**
 * A grid layer. With this component a grid can be shown on the map
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.layers.GridLayer extends AbstractLayer{
	var gridheight:Number;
	var gridwidth:Number;
	var gridlinecolor:Number = 0x777777;
	var gridlinealpha:Number = 20;
	var gridlinewidth:Number = 0;
	var maxlines = 10000;
	var maxscale:Number;
	var minscale:Number;
	var mGrid:MovieClip;
	/**
	 * Constructor for creating this layer
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @param 	map reference to the map where this layer is placed
	 * @see 	gui.layers.AbstractLayer
	 */
	public function GridLayer(id:String, container:MovieClip, map:Map) {		
		super(id, container, map);
		init();
	}
		
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml = xml.firstChild;			
		}
		super.setConfig(XMLNode(xml));		
		update();
	}
	/**
	 * Passes a configured attribute for this component.
	 * @param name name of the attribute
	 * @param value value of the attribute
	 */
	function setAttribute(name:String, val:String):Void {
		super.setAttribute(name, val);
		switch (name.toLowerCase()) {
		case "maxlines" :
			maxlines = Number(val);
			break;
		case "gridlinewidth" :
			gridlinewidth = Number(val);
			break;
		case "gridlinecolor" :
			if (val.charAt(0) == "#") {
				gridlinecolor = Number("0x"+val.substring(1, val.length-1));
			} else {
				gridlinecolor = Number(val);
			}
			break;
		case "gridlinealpha" :
			gridlinealpha = Number(val);
			break;
		case "gridwidth" :
			gridwidth = Number(val);
			break;
		case "gridheight" :
			gridheight = Number(val);
			break;
		case "maxscale" :
			maxscale = Number(val);
			break;
		case "minscale" :
			minscale = Number(val);
			break;
		}
	}
	/**
	* Updates the layer.
	*/
	function update() {
		if (visible) {
			if (map == undefined) {
				var map = flamingo.getParent(this);
			}
			if (!map.hasextent) {
				return;
			}
			var ms:Number = map.getScale();
			if (minscale != undefined) {
				if (ms<=minscale) {
					_visible = false;
					return;
				}
			}
			if (maxscale != undefined) {
				if (ms>maxscale) {
					_visible = false;
					return;
				}
			}
			_visible = true;
			if (gridwidth != undefined || gridheight != undefined) {
				var currentextent:Object = map.getCurrentExtent();
				mGrid=this.container.createEmptyMovieClip("mGrid", 0);
				//calculate pixelsize of gridcell
				var e = map.getCurrentExtent();
				var msx = (e.maxx-e.minx)/map.__width;
				var msy = (e.maxy-e.miny)/map.__height;
				var pixelw = gridwidth/msx;
				var pixelh = gridheight/msy;
				//calculate how many gridlines are visible
				var xn = map.__width/pixelw;
				var yn = map.__height/pixelh;
				if ((xn*yn)>maxlines) {
					//more than 100 gridlines doesn't make sense, so quit updating
					return;
				}
				//calculate startpoint of grid rounded with gridsize in real coordinates                        
				var x = Math.floor(currentextent.minx/gridwidth)*gridwidth;
				var y = Math.floor(currentextent.maxy/gridheight)*gridheight;
				//calculate startpoint of grid in pixels
				var px = (x-currentextent.minx)/msx;
				var py = (currentextent.maxy-y)/msy;
				mGrid.lineStyle(gridlinewidth, gridlinecolor, gridlinealpha);
				//drawlines
				for (x = px; x<map.__width; x=x+pixelw) {
					mGrid.moveTo(x, 0);
					mGrid.lineTo(x, map.__height);
				}
				for (y = py; y<map.__height; y=y+pixelh) {
					mGrid.moveTo(0, y);
					mGrid.lineTo(map.__width, y);
				}
			}
		} else {
			_visible = false;
		}
	}

	/**
	* Hides a layer.
	*/
	function hide() {
		visible = false;
		update();
		flamingo.raiseEvent(this, "onHide", this);
	}

	/**
	* Shows a layer.
	*/
	function show() {
		visible = true;
		update();
		flamingo.raiseEvent(this, "onShow", this);
	}
	/** 
	* Gets the scale of the layer
	* @return Number Scale.
	*/
	function getScale():Number {
		return map.getScale();
	}
	/** 
	* Moves the map to a scale where the maplayer is visible.
	* @param coord:Object [optional] Coordinate, an object with x and y. If undefined the map will zoom in the center of the current mapextent.
	* @param updatedelay:Number [optional] Delay in milliseconds. If updatedelay is undefined or -1 there will be no onUpdate event.  
	* @param movetime:Number [optional] Total time of move-animation. If movetime is 0, there wil be no animation. The Extent is set immediately. If movetime is undefined, the default movetime of the map will be used.  
	*/
	function moveToLayer(coord:Object, updatedelay:Number, movetime:Number) {
		var zoomtoscale;
		if (maxscale != undefined) {
			zoomtoscale = maxscale*0.9;
		}
		if (minscale != undefined) {
			zoomtoscale = minscale*1.1;
		}
		if (zoomtoscale != undefined) {
			map.moveToScale(zoomtoscale, coord, updatedelay, movetime);
		}
	}
	/** 
	* Checks if a maplayer is visible.
	* @return Number -2, -1, 0, 1, or  2
	* -2 = maplayer is not visible and maplayer is out of scale
	* -1 = maplayer is not visible;
	*  1 = maplayer is visible;
	* -2 = maplayer is visible and maplayer is out of scale
	*/
	function getVisible():Number {
		//returns 0 : not visible or 1:  visible or 2: visible but not in scalerange
		var ms:Number = map.getScale();
		//var vis:Boolean = flamingo.getVisible(this)
		if (visible) {
			if (minscale != undefined) {
				if (ms<minscale) {
					return 2;
				}
			}
			if (maxscale != undefined) {
				if (ms>maxscale) {
					return 2;
				}
			}
			return 1;
		} else {
			if (minscale != undefined) {
				if (ms<minscale) {
					return -2;
				}
			}
			if (maxscale != undefined) {
				if (ms>maxscale) {
					return -2;
				}
			}
			return -1;
		}
	}
	/**
	 * map listener
	 */ 
	public function onChangeExtent(map:MovieClip) {
		update();
	}
	/**
	 * map listener
	 */ 
	public function onHide(map:MovieClip):Void  {
		update();
	}
	/**
	 * map listener
	 */ 
	public function onShow(map:MovieClip):Void  {
		update();
	}

}