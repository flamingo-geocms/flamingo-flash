/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Roy Braam
* B3partners bv
 -----------------------------------------------------------------------------*/

/** @component HotlinkResults2
* A component that opens a web page when a getFeatureInfo is done.
* @file flamingo/cmc/classes/gui/HotlinkResults2.as (sourcefile)
* @file flamingo/cmc/classes/gui/Hotlink.as (sourcefile)
*/

/** @tag <cmc:HotlinkResults2>
* @class gui.HotlinkResults2 extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component.
* @example
	<FLAMINGO>
		...
		<cmc:HotlinkResults2 maxresults="3" id="hotlink" left="0" top="0" width="30%" height="100%" listento="map">
			<hotlink name="link" listento="layer1.gemeenten_2006" href="http://localhost/[id]" maxresulst="1"/>
			<hotlink name="link1" listento="layer1" href="http://localhost/[id]" maxresulst="1"/>
			<hotlink name="link2" listento="layer1.gemeenten_2006" href="http://localhost/[id]" maxresulst="1"/>
		</cmc:HotlinkResults2>	
		...
	</FLAMINGO>
* @attr listento the listento object on which a getFeatureInfo is done (identify). Usualy a fmc:Map
* @attr maxresults (optional) default: 1. Is the max results that can be opened by this hotlinkrestults when a getFeature is done* 
* @attr target (optional) default: _blank. the target that is used to open the url.
* The browser is deciding what is done with the target param. Default '_blank' wil open in a new window/tabblad. If you set maxresults > 1 all results
* will be opened in the same window/tab. So only 1 (the last one)result wil be opend even if there are more found.
*/
/** @tag <cmc:Hotlink>
* See Hotlink component.
*/
import gui.*;

import core.AbstractComponent;

class gui.HotlinkResults2 extends AbstractComponent{
	
	private var map:Object = null;
	private var hotlinks:Array=new Array();
	private var maxResults=1;
	private var target:String="_blank";
	private var counter:Number=0;
	
	function init():Void {						
        map=_global.flamingo.getComponent(listento[0]);		
		if (map==undefined){
			_global.flamingo.tracer("Object: " +listento[0] + "is not valid. Use another listento");
		}
		_global.flamingo.addListener(this, map, this);
	}
	function addComposite(name:String, xmlNode:XMLNode):Void {
        if (name == "Hotlink") {
            hotlinks.push(new Hotlink(xmlNode));
        } 		
    }
	
	function setAttribute(name:String, value:String):Void {
		if (name.toLowerCase()=="target"){
			target=value;
		}
		if (name.toLowerCase()=="maxresults"){
			maxResults=Number(value);
		}			
	}
	/**
	*Function is called when a getFeatureInfo is returned by the service
	*/
	function onIdentifyData (map:MovieClip, maplayer:MovieClip, data:Object, extent:Object) {
		var mapLayerId:String=_global.flamingo.getId(maplayer);
		var mapId:String=_global.flamingo.getId(map);
		mapLayerId=mapLayerId.split(mapId+"_").join("");
		//walk through the hotlinks
		for (var h=0; h < hotlinks.length && counter < maxResults; h++){
			var hotlink:Hotlink = Hotlink(hotlinks[h]);			
			if (hotlink.getListento()!=null){
				//walk through the listento's
				for (var l=0; l<hotlink.getListento().length && counter < maxResults; l++){					
					var listen=hotlink.getListento()[l];
					var listenParts:Array = listen.split(".");
					var flamingoLayerPart=listenParts[0];
					if (flamingoLayerPart==mapLayerId){
						var layerPart=listenParts[1];
						if (layerPart!=undefined && data[layerPart]!=undefined){
							//walk through the found data.
							for (var i=0; i < data[layerPart].length && counter < maxResults; i++){
								if(hotlink.openLink(data[layerPart][i],target)){
									counter++;
								}
							}
						}
					}															
				}
			}
		}
		
	}		
	/**
	*when a onIdentify is done on the map
	*/
	function onIdentify(map:MovieClip, extent:Object) {
		resetCounters();
	}
	/**
	*Resets all opened links counters
	*/
	function resetCounters(){
		for (var i =0; i < hotlinks.length; i++){
			var hotlink:Hotlink = Hotlink(hotlinks[i]);
			hotlink.resetCounter();
		}
		resetCounter();
	}
	/**
	*Resets the opened links counter
	*/
	function resetCounter(){
		counter=0;
	}
	//getters and setters
	public function setMaxResults(m:Number){
		maxResults=m;
	}
	public function getMaxResults():Number{
		return maxResults;
	}
	public function setTarget(t:String){
		target=t;
	}
	public function getTarget():String{
		return target;
	}
}