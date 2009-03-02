/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.coregui.*;

import flamingo.event.ActionEventListener;

class flamingo.coregui.ButtonConfig {
    
    private var graphicURL:String = null;
    private var toolTipText:String = null;
    private var actionEventListener:ActionEventListener = null;
    private var url:String = null;
    private var windowName:String = null;
    
    function ButtonConfig(graphicURL:String, toolTipText:String, actionEventListener:ActionEventListener, url:String, windowName:String) {
        this.graphicURL = graphicURL;
        this.toolTipText = toolTipText;
        this.actionEventListener = actionEventListener;
        this.url = url;
        this.windowName = windowName;
    }
    
    function getGraphicURL():String {
        return graphicURL;
    }
    
    function getToolTipText():String {
        return toolTipText;
    }
    
    function getActionEventListener():ActionEventListener {
        return actionEventListener;
    }
    
    function getURL():String {
        return url;
    }
    
    function getWindowName():String {
        return windowName;
    }
    
    function toString():String {
        return "ButtonConfig(" + graphicURL + ")";
    }
}
