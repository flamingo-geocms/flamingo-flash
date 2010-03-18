
/**
 * @author Linda Vels
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
