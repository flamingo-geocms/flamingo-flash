import coremodel.service.dde.DDEConnectorListener;
import coremodel.service.dde.DDEConnector;

import mx.controls.ComboBox;
import mx.utils.Delegate;

/**
 * @author velsll
 */
 

class gui.dde.DownloadAreas  extends ComboBox  implements DDEConnectorListener{


	private var ddeConnector : DDEConnector;
	private var areas : Array;

    function DownloadAreas () {
        super();
        this.addEventListener("close", Delegate.create(this, onChangeInArea));
        this.drawFocus = function() {
			};
		this.getDropdown().drawFocus = "";
		// to prevent the list to close after scrolling
		this.onKillFocus = function(newFocus:Object) {
			super.onKillFocus();
		};
		this.enabled = true;
    }

	function setDDEConnector(ddeConnector:DDEConnector){
		this.ddeConnector = ddeConnector;
		ddeConnector.addListener(this);	
		ddeConnector.sendRequest("getDownloadAreas");
	}
	
	function onDDELoad(result:XML):Void{	
		var resultType:String = result.firstChild.nodeName;
		if (resultType=="DownloadAreas"){
			areas = new Array();
		 	var list:Array = result.firstChild.childNodes;
			for (var i = 0; i<list.length; i++) {
				
				if(list[i].nodeName == "DownloadArea"){
					var label:String;
					if(list[i].attributes["label"]==null){
						label= XMLNode(list[i]).firstChild.firstChild.nodeValue;
					} else {
						label = list[i].attributes["label"];
					} 	
					areas.push({label:label,data:"fromServer"+list[i].attributes["id"],sortOrder:list[i].attributes["sortOrder"]+label.toUpperCase()});
				}
			}	
			areas.sortOn("sortOrder");
			this.dataProvider = this.dataProvider.concat(areas);
			this.open();
			this.close();
				
		}
		

		
	}
	
	private function onChangeInArea(evtObj:Object):Void{
		ddeConnector.setInArea(evtObj.target.selectedItem.label);
		ddeConnector.setClippingCoords(evtObj.target.selectedItem.data);
	}
	

}
