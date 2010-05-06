
/**
 * @author velsll
 */
interface ris.PopDataConnectorListener {
	function onAreaLoad(result:XML):Void;
	
	function onPopulationReportLoad(result:XML):Void;
	
	function onLoadFail(xmlResponse : XML) : Void;
}
