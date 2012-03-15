/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coregui.*;

import event.ActionEventListener;

/**
 * coregui.ButtonConfig
 */
class coregui.ButtonConfig {
    
    private var graphicURL:String = null;
    private var toolTipText:String = null;
    private var actionEventListener:ActionEventListener = null;
    private var url:String = null;
    private var windowName:String = null;
    /**
     * constructor
     * @param	graphicURL
     * @param	toolTipText
     * @param	actionEventListener
     * @param	url
     * @param	windowName
     */
    function ButtonConfig(graphicURL:String, toolTipText:String, actionEventListener:ActionEventListener, url:String, windowName:String) {
        this.graphicURL = graphicURL;
        this.toolTipText = toolTipText;
        this.actionEventListener = actionEventListener;
        this.url = url;
        this.windowName = windowName;
    }
    /**
     * getGraphicURL
     * @return
     */
    function getGraphicURL():String {
        return graphicURL;
    }
    /**
     * getToolTipText
     * @return
     */
    function getToolTipText():String {
        return toolTipText;
    }
    /**
     * getActionEventListener
     * @return
     */
    function getActionEventListener():ActionEventListener {
        return actionEventListener;
    }
    /**
     * getURL
     * @return
     */
    function getURL():String {
        return url;
    }
    /**
     * getWindowName
     * @return
     */
    function getWindowName():String {
        return windowName;
    }
    /**
     * toString
     * @return string
     */
    function toString():String {
        return "ButtonConfig(" + graphicURL + ")";
    }
}
