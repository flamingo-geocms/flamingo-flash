/*-----------------------------------------------------------------------------
Copyright (C) Linda Vels

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
import tools.Logger;
/**
 * WMSc Connector
 * @author Linda Vels
 */
class coremodel.service.tiling.connector.WMScConnector {
    private var events:Object;
    var error:String;
	var requestid:String;
	var busy:Boolean;
    private var log:Logger = null;
    /**
     * addListener
     * @param	listener
     */
    function addListener(listener:Object) {
        events.addListener(listener);
    }
	/**
	 * removeListener
	 * @param	listener
	 */
    function removeListener(listener:Object) {
        events.removeListener(listener);
    }
    /**
     * constructor
     */
    function WMScConnector() {
        events = new Object();
        AsBroadcaster.initialize(events);
        this.log = new Logger("coremodel.service.tiling.connector.WMScConnector",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());
    }
    /**
     * getFeatureInfo
     * @param	url
     * @param	args
     * @param	obj
     */
    function getFeatureInfo(url:String, args:Object, obj:Object) {
        args.REQUEST = "GetFeatureInfo";
        var xrequest:XML = new XML();
        xrequest.ignoreWhite = true;
        var thisObj:WMScConnector = this;
        var req_url = url;
        for (var arg in args) {
            req_url = this._changeArgs(req_url, arg, args[arg]);
        }
        xrequest.onLoad = function(success:Boolean) {
            if (success) {
                if (this.firstChild.nodeName.toLowerCase() == "serviceexceptionreport") {
                    thisObj.error = this.firstChild.toString();
                    thisObj.events.broadcastMessage("onResponse", thisObj);
                    thisObj.events.broadcastMessage("onError", thisObj.error, obj);
                } else {
                    thisObj.events.broadcastMessage("onResponse", thisObj);
                    thisObj._processFeatureInfo(this, obj, thisObj.requestid);
                }
            } else {
                thisObj.error = url + " connection failed...";
                thisObj.events.broadcastMessage("onResponse", thisObj);
                thisObj.events.broadcastMessage("onError", thisObj.error, obj);
            }
            thisObj.busy = false;
        };
        xrequest.load(req_url);
    }
    
    private function _processFeatureInfo(xml:XML, obj, reqid) {
        //switch (xml.firstChild.nodeName.toLowerCase()) {      
        switch (xml.firstChild.localName.toLowerCase()) {
        case "featurecollection" :
            _process_featureCollection(xml, obj, reqid);
            break;
        default :
            this.events.broadcastMessage("onError", "cannot parse unknown output format...", obj, reqid);
        }
    }
    
    private function _process_featureCollection(xml:XML, obj, reqid) {
        var features:Object = new Object();
        var layer:String;
        var val:String;
        var xfeatures:Array = xml.firstChild.childNodes;
        for (var i:Number = 0; i<xfeatures.length; i++) {
            switch (xfeatures[i].nodeName.toLowerCase()) {
            case "gml:boundedby" :
                break;
            case "gml:featuremember" :
                var feature:Object = new Object();
                layer = "";
                var xfeature:Array = xfeatures[i].childNodes;
                var xfirstnode = xfeature[0];
                if (xfirstnode.nodeName.toLowerCase() == "layer") {
                    layer = xfirstnode.firstChild.nodeValue;
                    for (var j:Number = 1; j<xfeature.length; j++) {
                        val = xfeature[j].firstChild.nodeValue;
                        if (val == undefined) {
                            val = "";
                        }
                        feature[xfeature[j].nodeName] = val;
                    }
                } else {
                    //DEEGREE/GEOSERVER
                    layer = xfirstnode.localName;
                    feature = parseFeature(xfirstnode);
                }
                if (features[layer] == undefined) {
                    features[layer] = new Array();
                }
                features[layer].push(feature);
                break;
            }
        }
        this.events.broadcastMessage("onGetFeatureInfo", features, obj, reqid);
    }
    
    
    private function parseFeature(xmlNode:XMLNode):Object {
        if ((xmlNode.nodeName == "gml:boundedBy") || (xmlNode.nodeName == "gml:MultiSurface")
                              || (xmlNode.nodeName == "gml:MultiLineString")
                              || (xmlNode.nodeName == "gml:MultiPoint")
                              || (xmlNode.nodeName == "gml:Surface")
                              || (xmlNode.nodeName == "gml:LineString")
                              || (xmlNode.nodeName == "gml:Point")) {
            return null;
        }
        
        var object:Object = new Object();
        if (xmlNode.firstChild.attributes["gml:id"] != null) {
            object["featureCollection"] = "true";
        }
        
        var childNode:XMLNode = null;
        var value:Object = null;
        for (var i:Number = 0; i < xmlNode.childNodes.length; i++) {
            childNode = xmlNode.childNodes[i];
            if (childNode.firstChild.nodeType == 1) {
                value = parseFeature(childNode);
            } else {
                value = childNode.firstChild.nodeValue;
            }
            if (value == null) {
                value = "";
            }
            //Due to a bug in the ActionScript-JavaScript bridge the escape character (=backslash) must to be escaped
            if (String(value).indexOf("\\") > -1) {
              value = value.split("\\").join("\\\\");
            }
            object[childNode.localName] = value;
        }
        return object;
    }
    
    private function _changeArgs(url:String, arg:String, val:String):String {
        var amp = "&";
        if (url.indexOf("?") == -1) {
            return url+"?"+arg+"="+val;
        }
        var p1:Number = url.toLowerCase().indexOf("&"+arg.toLowerCase()+"=", 0);
        if (p1 == -1) {
            p1 = url.toLowerCase().indexOf("?"+arg.toLowerCase()+"=", 0);
            if (p1 == -1) {
                return (url+amp+arg+"="+val);
            }
            var p2:Number = url.indexOf("&", p1);
            var s1:String = url.substring(0, p1);
            if (p2 == -1) {
                return (s1+"?"+arg+"="+val);
            }
            var s2:String = url.substring(p2, url.length);
            return (s1+"?"+arg+"="+val+s2);
        }
        var p2:Number = url.indexOf("&", p1);
        var s1:String = url.substring(0, p1);
        if (p2 == -1) {
            return (s1+amp+arg+"="+val);
        }
        var s2:String = url.substring(p2, url.length);
        return (s1+amp+arg+"="+val+s2);
    }
    
}
