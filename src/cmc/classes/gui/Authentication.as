/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component Authentication 
* A component that tells other Flamingo components which authorization roles the current authenticated user has. 
* One component that uses the authentication component is the feature model. It does so to decide which layers 
* should be kept away for the current user. Please refer to the GIS component.
* @file flamingo/cmc/classes/gui/Authentication.as  (sourcefile)
* @file flamingo/cmc/Authentication.fla (sourcefile)
* @file flamingo/cmc/Authentication.swf (compiled component, needed for publication on internet)
*/

/** @tag <cmc:Authentication>  
* This tag defines an authentication component instance. 
* Authentication has one Resource child node, and zero or more Role child nodes. 
* These configuration tags are not used by the authentication component itself. 
* In fact, the Authentication child nodes are read by a JavaScript method before Flamingo is started. 
* This JavaScript method prepares the webbrowser for an authenticated session with the server. 
* The authentication component does have a user interface, but generally it is only used for testing purposes. 
* In production environments the visible parameter should be set to false.
* @class gui.Authentication extends AbstractComponent
* @hierarchy childnode of Flamingo or a container component.
* @example
<Flamingo>
	<cmc:Authentication id="authentication" left="right -210" right="right" top="0" bottom="40" visible="false"/>
</Flamingo>
*/

/** @tag <cmc:Resource> 
* This tag defines a protected resource. A protected resource is a service on a server, 
* which requires http authentication before it can be accessed.
* @hierarchy childnode of Authentication.
* @example
	<cmc:Authentication>
		<fmc:Resource name="deegree" url="http://berkel:8080/deegree"/>
		...
	</cmc:Authentication>
* @attr name Name that identifies the protected resource on the server. The resource name is not used within the Flamingo framework.
* @attr url	URL to the protected resource. Navigating to this location with a web browser should result in a login screen.
*/


/** @tag <cmc:Role>
* This tag defines an authorization role. An authorization role is a role a user may be given by the server. 
* Configuring a Role does not guarantee the role to the current user. The server decides about that.
* @hierarchy childnode of Authentication.
* @example
	<cmc:Authentication>
		...
        <cmc:Role name="XDF56YZ" flux="admins"/>
	</fmc:Authentication>
* @attr name Name that identifies the role within the Flamingo framework. 
* It is advisable to obfuscate the role name, as it will appear in the web browser's navigation bar and could easily be substituted there.
* @attr flux Name that identifies the role on the server. The form of this name depends on the authentication backend of the server. 
* With an ldap backend this name would usually have the form of a distinguished name.
*/

import gui.*;
import core.AbstractComponent;

class gui.Authentication extends AbstractComponent {
    
    private var authroles:Array = null;
    
    function init():Void {
        var rolesString:String = _global.flamingo.mFlamingo.roles;
        if (rolesString == null) {
            authroles = new Array();
        } else {
            authroles = rolesString.split(",");
        } 
        addTextField();
    }
    
    function hasRole(role:String):Boolean {
        for (var i:String in authroles) {
            if (authroles[i] == role) {
                return true;
            }
        }
        return false;
    }
    
    private function addTextField():Void {
        var textFormat:TextFormat = new TextFormat();
        var style:Object = _global.flamingo.getStyleSheet("flamingo").getStyle(".general");
		if(style!=null){
			textFormat.font = style["fontFamily"];
			textFormat.size = style["fontSize"] - 1;
		} else {	
			textFormat.font = "arial";
			textFormat.size = 12;
		}
		
	
        var textField:TextField = createTextField("textField_mc", 0, 0, 0, __width, __height);
        textField.multiline = true;
        textField.setNewTextFormat(textFormat);
        
        if (authroles.length == 0) {
            textField.text = "User has no roles.";
        } else {
            textField.text = "User has roles:\n";
            for (var i:Number = 0; i < authroles.length; i++) {
                textField.text += authroles[i] + "\n";
            }
        }
    }
    
}
