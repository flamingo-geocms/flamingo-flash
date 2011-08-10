
/**
 * @author velsll
 */
interface ris.BridgisConnectorListener {

	function onLoadResult(result:XML):Void;
	
	function onLoadFail(result : XML) : Void;
}
