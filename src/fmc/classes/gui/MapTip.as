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
import core.AbstractPositionable;
import tools.Logger;
/** @component fmc:Maptip
* This component shows the result of a maptip request as a tooltip. 
* The content of the maptips have to be configured at the layers. See documentation of LayerArcIMS, LayerOGWMS, etc.
* Beware: a map will only display maptips when its 'maptipdelay' attribute is set.
* @file flamingo/classes/gui/Maptip.as (sourcefile)
* @file flamingo/classes/core/AbstractPositionable.as
* @file Maptip.xml (configurationfile, needed for publication on internet)
*/
/** @tag <fmc:Maptip>  
* This tag shows maptips as tooltips on a map. This component listens to maps.
* The default size and positioning attributes will have no affect this component.
* @hierarchy childnode of <flamingo>
* @example 
* <fmc:Maptip listento="map"/> 
*/
/**
 * This component shows the result of a maptip request as a tooltip. 
 * @author ...
 * @author Meine Toonen
 * @author Roy Braam
 */
class gui.MapTip extends AbstractPositionable {
		
	public function MapTip(id:String, container:MovieClip)
	{
		super(id, container);
		init();
	}


	var lMap:Object = new Object();
	var lLayer:Object = new Object();
	/**
	 * Initialize this
	 */
	private function init():Void {
		if (flamingo == undefined) {
			var t:TextField = this.container.createTextField("readme", 0, 0, 0, 550, 400);
			t.html = true;
			t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>Maptip "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
			return;
		}
		this._visible = false;

		//defaults
		//custom
		var xmls:Array= flamingo.getXMLs(this);
		for (var i = 0; i < xmls.length; i++){
			this.setConfig(xmls[i]);
		}
		
		delete xmls;
		//remove xml from repository
		flamingo.deleteXML(this);
		this._visible = visible;
		
	
		flamingo.raiseEvent(this, "onInit", this);
	}
	/**
	* Configurates a component by setting a xml.
	* @param xml:Object Xml or string representation of a xml.
	*/
	function setConfig(xml:Object) {
		if (typeof (xml) == "string") {
			xml = new XML(String(xml));
			xml = xml.firstChild;
		}
		//load default attributes, strings, styles and cursors 
		flamingo.parseXML(this, xml);
		//
		var thisObj:MapTip = this;
		lMap.onAddLayer = function(map:MovieClip, layer:MovieClip) {
			thisObj.flamingo.addListener(thisObj.lLayer, layer, thisObj);
		}
		lMap.onMaptipCancel = function(map:MovieClip):Void  {
			thisObj.flamingo.hideTooltip();
		}
		
		lLayer.onMaptipMarkedUpData = function(layer:MovieClip, maptip:String){
			thisObj.flamingo.showTooltip(maptip, layer.map, 0, false);
		}
		if (listento!=undefined){
			//flamingo.addListener(lMap, listento, this);
			//if the layers already loaded add listeners.
			var mapa:Object = flamingo.getComponent(listento[0]);
			for (var layerid in mapa.mLayers){
				flamingo.addListener(lLayer, mapa.mLayers[layerid], this);
			}
		}
		flamingo.addListener(lMap, listento, this);
	}
	/*********************** Events ***********************/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
}