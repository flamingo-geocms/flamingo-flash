/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component LayerProxy
* The LayerProxy is a proxy for a Layer component (LayerOGCWMS or LayerArcIMS) which is located in a map in a different instance of the flamingo viewer.
* All (common) public methods of the LayerOGCWMS or LayerArcIMS component are implemented 
* @file LayerProxy.as  (sourcefile)
* @file LayerProxy.fla (sourcefile)
* @file LayerProxy.swf (compiled Map, needed for publication on internet)
*/

/** @tag <fmc:LayerProxy>  
* This tag defines a layerProxy.
* @attr id The id should be the same as the id of the layer component for which this component serves as a proxy. 
* @attr instanceid should be the same as the name of the flamingo instance(FlashObject in html) of the layer component for which this component serves as a proxy.
*/



import proxys.*;

import flash.external.ExternalInterface;

import core.AbstractComponent;

class proxys.LayerProxy extends AbstractComponent {
	var version:String = "1.0";
	
	private var instanceID:String;
	private var legendId:String;
	
	function setAttribute(name:String, value:String):Void {
		if (name == "instanceid") {
			instanceID = value;
		}
	}
	
	function init() {
		legendId = _global.flamingo.getId(this);
	}
	

	public function setConfig(xml:Object):Void {
		var a:Array = [xml];
		ExternalInterface.call("callMethodJS", instanceID, legendId, "setConfig", a);
	}

	function setAlpha(alpha:Number):Void{
		var a:Array = [alpha]
		ExternalInterface.call("callMethodJS", instanceID, legendId, "setAlpha", a);
	}
		
	public function hide():Void {
		ExternalInterface.call("callMethodJS", instanceID, legendId, "hide");
	}
	
	public function show():Void {
		ExternalInterface.call("callMethodJS", instanceID, legendId, "show");
	}
									
	public function update():Void {
		ExternalInterface.call("callMethodJS", instanceID, legendId, "update");
	}
	
	public function cancelIdentify():Void {
		ExternalInterface.call("callMethodJS", instanceID, legendId, "cancelIdentify");
	}
		
	public function identify(extent:Object):Void {
		var a:Array = [extent];
		ExternalInterface.call("callMethodJS", instanceID, legendId, "identify",a);
	}
			
	public function setLayerProperty(ids:String, field:String, value:Object):Void {
		var a:Array = [ids,field,value];
		ExternalInterface.call("callMethodJS", instanceID, legendId, "setLayerProperty",a);
	}
	
	public function getLayerProperty(id:String, field:String):Object {
		var a:Array = [id,field];
		return Object(ExternalInterface.call("callMethodJS", instanceID, legendId, "getLayerProperty",a));
	}
		
	public function getLayers():Object {
		return Object(ExternalInterface.call("callMethodJS", instanceID, legendId, "getLayers"));
	}
	
	public function getLayerIds():Object {
		return Object(ExternalInterface.call("callMethodJS", instanceID, legendId, "getLayerIds"));
	}
	
	public function moveToLayer(ids:String, coord:Object, updatedelay:Number, movetime:Number):Void {
		var a:Array = [ids,coord,updatedelay,movetime];
		ExternalInterface.call("callMethodJS", instanceID, legendId, "moveToLayer",a);
	}
		
	public function getLegend():String {
		return String(ExternalInterface.call("callMethodJS", instanceID, legendId, "getLegend"));
	}
	
	public function setVisible(vis:Boolean, id:String) {
		var a:Array = [vis,id];
		ExternalInterface.call("callMethodJS", instanceID, legendId, "setVisible",a);
	}
	
	public function getVisible(id:String):Number {
		var a:Array = [id];
		return Number(ExternalInterface.call("callMethodJS", instanceID, legendId, "getVisible",a));
	}
		
	public function updateCaches():Void {
		ExternalInterface.call("callMethodJS", instanceID, legendId, "updateCaches");
	}
		
	public function getScale():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceID, legendId, "getVisible"));
	}
}