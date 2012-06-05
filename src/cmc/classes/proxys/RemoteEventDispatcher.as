/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda vels.
* IDgis bv
 -----------------------------------------------------------------------------*/


/** @component RemoteEventDispatcher
* The RemoteEventDispatcher component receives events via ExternalInterface and sends thes events to the flamingo raiseEvent method. instance of the flamingo viewer.
* This component is used to enable the communicatiion between flamingo components in different Flash instances.
* @file RemoteEventDispatcher.as  (sourcefile)
* @file RemoteEventDispatcher.fla (sourcefile)
* @file RemoteEventDispatcher.swf (compiled Map, needed for publication on internet)
*/

/** @tag <cmc:RemoteEventDispatcher>  
* This tag defines a remoteEventDispatche.
* @attr id unique identifier for the component
*/

import flash.external.ExternalInterface;

import core.AbstractComponent;

class proxys.RemoteEventDispatcher extends AbstractComponent {
	var version:String = "1.0";

	private var methodName:String;
	private var instance:Object;
	private var method:Function;
	private var compId:String;
	private var comp:Object;


	function init() {
		methodName = "dispatchFlamingoEvent";
		instance = this;
		method = dispatchFlamingoEvent;
		ExternalInterface.addCallback(methodName, instance, method);
	}
	
	function dispatchFlamingoEvent(s:String, a:Array) {
		compId = String(a.shift());
		comp = _global.flamingo.getComponent(compId);		
		_global.flamingo.raiseEvent(comp, s, comp, a[0], a[1], a[2],a[3]);	
	}
}