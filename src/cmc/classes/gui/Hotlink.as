/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Roy Braam
* B3partners bv
 -----------------------------------------------------------------------------*/
 /** @component cmc:Hotlink
* A component that opens a web page when a getFeatureInfo is done.
* @file flamingo/cmc/classes/gui/Hotlink.as (sourcefile)
*/

/** @tag <cmc:Hotlink>
* @class gui.Hotlink extends AbstractComponent
* @hierarchy childnode of HotlinkResults2
* @example
	<FLAMINGO>
		...
		<cmc:HotlinkResults2 ...
			<hotlink name="link" listento="layer1.gemeenten_2006" href="http://localhost/[id]" maxresulst="1"/>			
			....
		</cmc:HotlinkResults2>	
		...
	</FLAMINGO>
* @attr listento the listento object on which a getFeatureInfo is done (identify). Can be <flamingoLayerId>.<layerId> or <flamingoLayerId>
* @attr href the link that is opened. With [attributeName] you can add some dynamic data. If a [attributeName] not is found in the found feature
* then it is removed.
* @attr maxresults (optional) default: 1. Is the max results that are opened in this hotlink when a getFeature is done
* The browser decides how url's are opend, even if you set a target in the HotlinkResults. Default most browser will open all opend links in the same window.
*/
import gui.*;
import core.AbstractComposite;

class gui.Hotlink extends AbstractComposite {
    
    private var name:String = null;
    private var listento:Array = null;
    private var href:String = null;    
	private var maxResults:Number=1;
	private var counter:Number=0;
    function Hotlink(xmlNode:XMLNode) {
        parseConfig(xmlNode);
		if (href==null){
			_global.flamingo.tracer("<construct>Hotlink: href is mandatory!");
		}
		if (listento==null){
			_global.flamingo.tracer("<construct>Hotlink: listento is mandatory!");
		}
    }
    
    function setAttribute(name:String, value:String):Void {		
        if (name == "name") {
            name = value;
        } else if (name == "listento") {
            listento = value.split(",");
        } else if (name == "href") {
            href = value;
        } else if (name == "maxresults"){
			maxResults=Number(value);
		}
    }   
	/**
	* resets the open hotlink counter
	*/
	function resetCounter(){
		counter=0;
	}
	/**
	*This function replaces all [attributename] in the this.href.
	*@param feature is a object containing the feature (feature[attributename]=value)
	*@param target the target where the url is opened.
	*@return true if opened false if not.
	*/
	function openLink(feature:Object ,target:String):Boolean {
		if (counter < maxResults){		
			var link:String=""+href;
			for (var attri in feature){
				link=link.split("["+attri+"]").join(feature[attri]);
			}
			//todo: remove all []
		while (link.indexOf("[") >= 0 && link.indexOf("]") >= 0) {
				var beginIndex=link.indexOf("[");
				var endIndex=link.indexOf("]");
				var replacePart:String = "["+link.substring(beginIndex+1,endIndex)+"]";
				link=link.split(replacePart).join("");
			}
			if (link!=undefined && link.length>0){
				counter++;
				getURL(link,target);
				return true;
			}
		}
		return false;
	}
	
	//getters and setters:
	public function getCounter(){
		return counter;
	}
	public function getName():String{
		return name;
	}
	public function setName(n:String){
		name=n;
	}
	public function setListento(l:Array){
		listento=l;
	}
    public function getListento():Array{
		return listento;
	}
	public function setHref(h:String){
		href=h;
	}
	public function getHref():String{
		return href;
	}
	public function setMaxResults(m:Number){
		maxResults=m;
	}
	public function getMaxResults():Number{
		return maxResults;
	}
}
