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
import gui.layers.AbstractLayer;
import gui.Map;
import tools.Logger;
/** @component fmc:LayerImage
* A image layer. With this component a image can be shown in the map
* @file flamingo/fmc/classes/gui/layers/ImageLayer.as (sourcefile)
* @file flamingo/fmc/classes/gui/layers/AbstractLayer.as (sourcefile)
* @file flamingo/fmc/classes/core/AbstractConfigurable.as
* @file flamingo/fmc/classes/core/AbstractPositionable.as
* @file LayerImage.xml (configurationfile for layer, needed for publication on internet)
*/
 /** @tag <fmc:LayerImage>  
* This tag defines a image layer.
* @hierarchy childnode of <fmc:Map> 
* @attr extent  Extent of layer. Comma seperated list of minx,miny,maxx,maxy.
* @attr url The url of the png, swf or jpg containing the mapimage. The url can be absolute or relative to flamingo.swf.
* @attr minscale  If mapscale is less then or equal minscale, the layer will not be shown.
* @attr maxscale  If mapscale is greater then maxscale, the layer will not be shown.
* @attr alpha (defaultvalue = "100") Transparency of the layer.
*/
 /**
 * A image layer. With this component a image can be shown in the map
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.layers.ImageLayer extends AbstractLayer{
	
	var _extent:Object;
	var maxscale:Number;
	var minscale:Number;
	var visible:Boolean;
	var initialized:Boolean = false;
	var mHolder:MovieClip;
	
	var starttime:Date;
	/**
	 * Constructor for creating this layer
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @param 	map reference to the map where this layer is placed
	 * @see 	gui.layers.AbstractLayer
	 */
	public function ImageLayer(id:String, container:MovieClip, map:Map) {
		super(id, container, map);
		init();
	}
	/**
	* Configurates a component by setting a xml.
	* @attr xml:Object Xml or string representation of a xml.
	*/
	/**
	 * Configurates a component by setting a xml.
	 * @param	xml:Object Xml or string representation of a xml.
	 */
	function setConfig(xml:Object) {
		if (xml == undefined) {
			return;
		}
		if (typeof (xml) == "string") {
			xml = new XML(String(xml))
			xml = xml.firstChild;			
		}
		if (this.type!=undefined && this.type.toLowerCase() != xml.localName.toLowerCase()) {
			return;
		}
		super.setConfig(XMLNode(xml));
		
		if(map.visible){
			setImage(this.serviceUrl, extent);
		}	
		/* Make backwards compatible
		 * pass the listento to the container so all the clickable overviews will still work....
		 */
		if (this.listento != undefined) {
			this.container.listento = this.listento;
		}
	}
	/**
	 * Passes a configured attribute for this component.
	 * @param name name of the attribute
	 * @param val value of the attribute
	 */
	function setAttribute(name:String, val:String):Void {
		switch (name.toLowerCase()) {
		case "url" :
		case "imageurl" :
			serviceUrl = val;
			break;
		case "alpha" :
			this.container._alpha = Number(val);
			break;
		case "extent" :
			extent = map.string2Extent(val);
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
	 * Set the image as a layer
	 * @param	url the url to the layer
	 * @param	extent the extent for this image
	 */
	public function setImage(url:String, extent:Object) {
		if (url != undefined and map.isValidExtent(extent)) {
			this.serviceUrl = flamingo.getNocacheName(flamingo.correctUrl(url), "hour");
			extent = extent;
			var listener:Object = new Object();
			//
			var thisObj:ImageLayer = this;
			listener.onLoadError = function(mc:MovieClip, error:String, httpStatus:Number) {
				thisObj.flamingo.raiseEvent(thisObj, "onError", thisObj, "update", error);
			};
			//
			listener.onLoadProgress = function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
				thisObj.flamingo.raiseEvent(thisObj, "onUpdateProgress", thisObj, bytesLoaded, bytesTotal);
			};
			//
			listener.onLoadInit = function(mc:MovieClip) {
				thisObj.initialized = true
				var newDate:Date = new Date();
				var loadtime = (newDate.getTime()-thisObj.starttime.getTime())/1000;
				thisObj.update();
				
				//mHolder.cacheAsBitmap = true;
				thisObj.flamingo.raiseEvent(thisObj, "onUpdateComplete", thisObj, 0, loadtime, mc.getBytesTotal());
				if (thisObj.map.fadesteps>0) {
					var step = (100/thisObj.map.fadesteps)+1;
					thisObj.container.onEnterFrame = function() {
						thisObj.mHolder._alpha = thisObj.mHolder._alpha+step;
						if (thisObj.mHolder._alpha>=100) {							
							delete thisObj.container.onEnterFrame;
						}
					};
				} else {
					thisObj.mHolder._alpha = 100;
				}
			};
			//
			mHolder = this.container.createEmptyMovieClip("mHolder", 1);
			var mcl:MovieClipLoader = new MovieClipLoader();
			mcl.addListener(listener);
			mHolder._alpha = 0;

			mcl.loadClip(this.serviceUrl, mHolder);
			this.starttime = new Date();
			flamingo.raiseEvent(thisObj, "onUpdate", thisObj);
			
		}
	}

	/**
	* Updates a layer.
	*/
	function update() {
		if (!this.initialized) {
			return;
		}
		if (visible) {
			if (!map.hasextent) {
				mHolder._visible = false;
				return;
			}
			if (!map.isHit(extent)) {
				mHolder._visible = false;
				return;
			}
			var ms:Number = map.getScale();
			if (minscale != undefined) {
				if (ms<=minscale) {
					mHolder._visible = false;
					return;
				}
			}
			if (maxscale != undefined) {
				if (ms>maxscale) {
					mHolder._visible = false;
					return;
				}
			}
			var r:Object = map.extent2Rect(extent);
			mHolder._x = r.x;
			mHolder._y = r.y;
			mHolder._width = r.width;
			mHolder._height = r.height;
			
			
			if (mHolder._xscale>20000) {
				mHolder._visible = false;
			} else {
				mHolder._visible = true;
			}
		} else {
			mHolder._visible = false;
		}
	}
	
	/**
	* Shows a layer.
	*/
	function show():Void {
		visible = true;
		_visible = true;
		update();
		flamingo.raiseEvent(this, "onShow", this);
	}
	/**
	* Hides a layer.
	*/
	function hide():Void {
		visible = false;
		_visible = false;
		update();
		flamingo.raiseEvent(this, "onHide", this);
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
	 * Map listener
	 */ 	
	public function onChangeExtent(map:MovieClip):Void  {
		this.update();
	}
	/**
	 * Map listener
	 */ 	
	public function onHide(map:MovieClip):Void  {
		this.update();
	}
	/**
	 * Map listener
	 */ 	
	public function onShow(map:MovieClip):Void  {
		if (!this.initialized) {
			setImage(serviceUrl, extent);
		} else {	
			update();
		}	
	}	
	/*********************** Getters and Setters ***********************/
	/**
	 * get extent
	 */
	public function get extent():Object {
		return _extent;
	}
	/**
	 * set extent
	 */
	public function set extent(value:Object):Void {
		/* Make backwards compatible:
		 * pass the extent to the container so all the clickable overviews will still work....	
		 */
		this.container.extent = value;
		_extent = value;
	}

}