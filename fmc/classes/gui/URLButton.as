/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author:  Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component URLButton
* The URLButton Component is a google like button that opens a link.
* @file flamingo/tpc/classes/flamingo/gui/URLButton.as  (sourcefile)
* @file flamingo/fmc/URLButton.fla (sourcefile)
* @file flamingo/fmc/URLButton.swf (compiled component, needed for publication on internet)
* @configstring label Button label.
* @configstring tooltip Tooltip text for the button.
*/

/** @tag <fmc:URLButton> 
* This tag defines an urlButton instance. 
* @class gui.URLButton extends GradientButton
* @hierarchy childnode of Flamingo or a container component.
* @example
    <fmc:URLButton url="experturl" left="right -240" width = "140" height = "20" top= "10" listento="map,experturl">
        <string id="label" nl="Open uitgebreide viewer"/>
        <string id="tooltip" nl="Open uitgebreide viewer in nieuw browser venster"/>
    </fmc:URLButton>
	..
	<fmc:URL id="experturl" url="http://tapserver.test.local/loket/html/atlas.html?type=standard&atlas=roo" target="_self"/>    
     ..
* @attr listento, The URLButton component should listen to a map and to an URL component (the order in listento string is important)  	
 */
 
import coregui.GradientFill;
import coregui.GradientButton;

import mx.controls.Label;

import gui.URL;

class gui.URLButton extends GradientButton {

	private var urlId:String = null;
	private var url:URL = null;
	
	
	function setAttribute(name:String, value:String):Void {
	   if (name.toLowerCase() == "url") {
            urlId = value;    
	   }	 		
	   
	}

	


    function onPress():Void {
    	if(url==null){
    		url =_global.flamingo.getComponent(urlId);
			url.setMap(_global.flamingo.getComponent(listento[0]));
    	}	
		var my_xml:XML = new XML();
		my_xml.contentType = "text/xml";
		my_xml.send(url.getUrl(), url.getTarget());	    			
    }
}
