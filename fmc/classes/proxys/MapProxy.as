/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component MapProxy
* The MapProxy is a proxy for a Map component which is located in a different instance of the flamingo viewer.
* All public methods of the Map component are implemented 
* @file MapProxy.as  (sourcefile)
* @file MapProxy.fla (sourcefile)
* @file MapProxy.swf (compiled Map, needed for publication on internet)
*/

/** @tag <fmc:MapProxy>  
* This tag defines a mapProxy.
* @attr id The id should be the same as the id of the map component for which this component serves as a proxy. 
* @attr instanceId should be the same as the name of the flamingo instance(FlashObject in html) of the map component for which this component serves as a proxy.
* @attr cursorsid should point at a Cursors component in the flamingo instance with the map
*/


import flash.external.ExternalInterface;

import core.AbstractComponent;

class proxys.MapProxy extends AbstractComponent {
	var version:String = "1.0";
	private var instanceId:String;
	private var mapId:String;
	private var cursorsId:String;
	
	//Defines the instance where the map component is placed.
	function setAttribute(name:String, value:String):Void { 
		if(name=="instanceid") {
			instanceId = value;
		}
		if (name=="cursorsid") {
			cursorsId = value;
		}
	}

	function init() {
		mapId = _global.flamingo.getId(this);
	}
	
	public function setConfig(xml:Object) {
		var a:Array = [xml];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setConfig", a);
	}
		
	public function resize():Void {
		ExternalInterface.call("callMethodJS", instanceId, mapId, "resize");
	}
	
	public function addLayers(xml:Object):Void {
		var a:Array = [xml];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "addLayers", a);
	}
	
	public function addLayer(xml:Object):String {
		var a:Array = [xml];
		return String(ExternalInterface.call("callMethodJS", instanceId, mapId, "addLayer", a));
	}
	
	public function clear() {
		ExternalInterface.call("callMethodJS", instanceId, mapId, "clear");
	}
	
	public function getLayers():Array {
		return Array(ExternalInterface.call("callMethodJS", instanceId, mapId, "getLayers"));
	}
	
	public function removeLayer(id:String):Void {
		var a:Array = [id];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "removeLayer", a);
	}
	
	public function swapLayer(id:String, index:Number):Void {
		var a:Array = [id,index];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "swapLayer", a);
	}
	
	public function hideLayer(id:String):Void {
		var a:Array = [id];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "hideLayer", a);
	}
	
	public function showLayer(id:String):Void {
		var a:Array = [id];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "showLayer", a);
	}
	
	public function hide():Void {
		ExternalInterface.call("callMethodJS", instanceId, mapId, "hide");
	}
	
	public function show():Void {
		ExternalInterface.call("callMethodJS", instanceId, mapId, "show");
	}
	
	public function cancelIdentify():Void {
		ExternalInterface.call("callMethodJS", instanceId, mapId, "cancelIdentify");
	}
	
	public function identify(identifyextent:Object):Void {
		var a:Array = [identifyextent];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "identify", a);
	}
	
	public function getFullScale():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getFullScale"));
	}
	
	public function getCurrentScale():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getCurrentScale"));
	}
	
	public function getMapScale():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMapScale"));
	}
	
	public function getScale(extent:Object):Number {
		var a:Array = [extent];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getScale", a));
	}
	
	public function getScale2(extent:Object):Number {
		var a:Array = [extent];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getScale2", a));
	}
	
	public function getScaleHint2(extent:Object):Number {
		var a:Array = [extent];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getScaleHint2", a));
	}
	
	public function getScaleHint(extent:Object):Number {
		var a:Array = [extent];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getScaleHint", a));
	}
	
	public function getHeight(extent:Object):Number {
		var a:Array = [extent];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getHeight", a));
	}
	
	public function getWidth(extent:Object):Number {
		var a:Array = [extent];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getWidth", a));
	}
	
	public function getMovieClipHeight():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMovieClipHeight"));
	}
	
	public function getMovieClipWidth():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMovieClipWidth"));
	}
	
	public function getCenter(extent:Object):Object {
		var a:Array = [extent];
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getCenter", a);
	}
	
	public function getMapExtent():Object {
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getMapExtent");
	}
	
	public function getCFullExtent():Object {
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getCFullExtent");
	}
	
	public function getFullExtent():Object {
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getFullExtent");
	}
	
	public function getCurrentExtent():Object {
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getCurrentExtent");
	}
	
	public function getExtent():Object {
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getExtent");
	}
	
	public function setFullExtent(extent:Object):Void {
		var a:Array = [extent];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setFullExtent", a);
	}
	
	public function meters2Degrees(meter:Number):Number {
		var a:Array = [meter];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "meters2Degrees", a));
	}
	
	public function degrees2Meters(angle:Number):Number {
		var a:Array = [angle];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "degrees2Meters", a));
	}
	
	public function moveToScale(scale:Number, coord:Object, updatedelay:Number, movetime:Number):Void {
		var a:Array = [scale,coord,updatedelay,movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToScale", a);
	}
	
	public function moveToScaleHint(scalehint:Number, coord:Object, updatedelay:Number, movetime:Number):Void {
		var a:Array = [scalehint,coord,updatedelay,movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToScaleHint", a);
	}
	
	public function moveToPercentage(percentage:Number, coord:Object, updatedelay:Number, movetime:Number):Void {
		var a:Array = [percentage,coord,updatedelay,movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToPercentage", a);
	}
	
	public function moveToCoordinate(coord:Object, updatedelay:Number, movetime:Number):Void {
		var a:Array = [coord,updatedelay,movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToCoordinate", a);
	}
	
	public function getNextExtents():Object {
		return Object(ExternalInterface.call("callMethodJS", instanceId, mapId, "getNextExtents"));
	}
	
	public function moveToNextExtent(movetime:Number):Void {
		var a:Array = [movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToNextExtent", a);
	}
	
	public function getPrevExtents(): Object {
		return Object(ExternalInterface.call("callMethodJS", instanceId, mapId, "getPrevExtents"));
	}
	
	public function moveToPrevExtent(movetime:Number):Void {
		var a:Array = [movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToPrevExtent", a);
	}

	public function moveToExtent(extent:Object, updatedelay:Number, movetime:Number):Void {
		var a:Array = [extent,updatedelay,movetime];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "moveToExtent", a);
	}
	
	public function update(delay:Number, forceupdate:Boolean):Void {
		var a:Array = [delay,forceupdate];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "update", a);
	}
		
	public function cancelUpdate():Void {
		ExternalInterface.call("callMethodJS", instanceId, mapId, "cancelUpdate");
	}
	
	public function getDistance(coord1:Object, coord2:Object):Number {
		var a:Array = [coord1,coord2];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getDistance", a));
	}
	
	public function getDistanceLinear(coord1:Object, coord2:Object):Number {
		var a:Array = [coord1,coord2];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getDistanceLinear", a));
	}
	
	public function getDistanceDegree(coord1:Object, coord2:Object):Number {
		var a:Array = [coord1,coord2];
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getDistanceDegree", a));
	}
	
	public function extent2Rect(extent:Object, extent2:Object):Object {
		var a:Array = [extent,extent2];
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "extent2Rect", a)
	}
	
	public function rect2Extent(rect:Object, extent:Object):Object {
		var a:Array = [rect,extent];
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "rect2Extent", a);
	}
	
	public function point2Coordinate(point:Object, extent:Object):Object {
		var a:Array = [point,extent];
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "point2Coordinate", a);
	}
	
	public function coordinate2Point(coordinate:Object, extent:Object):Object {
		var a:Array = [coordinate,extent];
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "coordinate2Point", a);
	}
	
	public function isUpdating():Boolean {
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "isUpdating"));
	}
	
	public function isIdentifying():Boolean {
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "isIdentifying"));
	}
	
	public function extent2String(extent:Object):String {
		var a:Array = [extent];
		return String(ExternalInterface.call("callMethodJS", instanceId, mapId, "extent2String", a));
	}
	
	public function string2Extent(str:String):Object {
		var a:Array = [str];
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "string2Extent", a);
	}
	
	public function isEqualExtent(extent:Object, extent2:Object):Boolean {
		var a:Array = [extent,extent2];
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "isEqualExtent", a));
	}
			
	public function isValidExtent(extent:Object):Boolean {		
		var a:Array = [extent];
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "isValidExtent", a));	
	}
	
	public function isHit(extent:Object, extent2:Object):Boolean {
		var a:Array = [extent,extent2];
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "isHit", a));		
	}
	
	public function setCursor(cursor:Object):Void {
		var compId:String = mapId;
		var a:Array = [compId,cursor];
		ExternalInterface.call("callMethodJS", instanceId, cursorsId , "setCursor", a);		
	}
	
	public function getCursor():Object {
		return ExternalInterface.call("callMethodJS", instanceId, mapId, "getCursor");		
	}
	
	public function setMoveTime(value:Number):Void {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setMoveTime", a);		
	}
	
	public function getMoveTime():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMoveTime"));		
	}
	
	public function setMoveSteps(value:Number) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setMoveSteps", a);		
	}

	public function getMoveSteps():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMoveSteps"));	
	}

	public function setFadeSteps(value:Number) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setFadeSteps", a);	
	}

	public function getFadeSteps():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getFadeSteps"));	
	}

	public function setMinScale(value:Number) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setMinScale", a);	
	}

	public function getMinScale():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMinScale"));	
	}

	public function setMaxScale(value:Number) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setMaxScale", a);	
	}

	public function getMaxScale():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getMaxScale"));	
	}

	public function setHoldOnIdentify(value:Boolean) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setHoldOnIdentify", a);	
	}

	public function getHoldOnIdentify():Boolean {
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "getHoldOnIdentify"));	
	}

	public function setHoldOnUpdate(value:Boolean) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setHoldOnUpdate", a);	
	}

	public function getHoldOnUpdate():Boolean {
		return Boolean(ExternalInterface.call("callMethodJS", instanceId, mapId, "getHoldOnUpdate"));	
	}

	public function setExtentHistory(value:Number) {
		var a:Array = [value];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "setExtentHistory", a);	
	}

	public function getExtentHistory():Number {
		return Number(ExternalInterface.call("callMethodJS", instanceId, mapId, "getExtentHistory"));	
	}
	
	public function drawRect(id:String, rect:Object, fillSymbol:Object, lineSymbol:Object):Void {
		var a:Array = [id,rect,fillSymbol,lineSymbol];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "drawRect", a);
	}
	
	public function drawCircle(id:String, circle:Object, fillSymbol:Object, lineSymbol:Object) {
		var a:Array = [id,circle,fillSymbol,lineSymbol];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "drawCircle", a);
		
	}

	public function draw(id:String, points:Array, fillSymbol:Object, lineSymbol:Object) {
		var a:Array = [id,points,fillSymbol,lineSymbol];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "draw", a);
	}

	public function clearDrawings(id:String) {
		var a:Array = [id];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "clearDrawings", a);
	}
	
	public function showTooltip(tiptext:String, delay:Number):Void{
		var a:Array = [tiptext,delay];
		ExternalInterface.call("callMethodJS", instanceId, mapId, "showTooltip", a);	
	}
	
	public function hideTooltip():Void{
		ExternalInterface.call("callMethodJS", instanceId, mapId, "hideTooltip");	
	}
	

}