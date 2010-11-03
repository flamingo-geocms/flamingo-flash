
/**
 * @author Velsll
 */
class coremodel.service.tiling.connector.WMScConnector {
	private var events:Object;
	var error:String;
	
	function addListener(listener:Object) {
		events.addListener(listener);
	}
	function removeListener(listener:Object) {
		events.removeListener(listener);
	}

	function WMScConnector() {
		events = new Object();
		AsBroadcaster.initialize(events);
	}
	
	function getFeatureInfo(url:String, args:Object, obj:Object) {
		args.REQUEST = "GetFeatureInfo";
		var xrequest:XML = new XML();
		xrequest.ignoreWhite = true;
		var thisObj:Object = this;
		var req_url = url;
		for (var arg in args) {
			req_url = this._changeArgs(req_url, arg, args[arg]);
		}
		xrequest.onLoad = function(success:Boolean) {
			if (success) {
				if (this.firstChild.nodeName.toLowerCase() == "serviceexceptionreport") {
					error = this.firstChild.toString();
					thisObj.events.broadcastMessage("onResponse", thisObj);
					thisObj.events.broadcastMessage("onError", error, obj);
				} else {
					thisObj.events.broadcastMessage("onResponse", thisObj);
					thisObj._processFeatureInfo(this, obj, thisObj.requestid);
				}
			} else {
				thisObj.error = thisObj.url + " connection failed...";
				thisObj.events.broadcastMessage("onResponse", thisObj);
				thisObj.events.broadcastMessage("onError", thisObj.error, obj);
			}
			thisObj.busy = false;
		};
		xrequest.load(req_url);
	}
	
	
	private function _changeArgs(url:String, arg:String, val:String):String {
		var amp = "&";
		if (url.indexOf("?") == -1) {
			return url+"?"+arg+"="+val;
		}
		var p1:Number = url.toLowerCase().indexOf("&"+arg.toLowerCase()+"=", 0);
		if (p1 == -1) {
			var p1:Number = url.toLowerCase().indexOf("?"+arg.toLowerCase()+"=", 0);
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
