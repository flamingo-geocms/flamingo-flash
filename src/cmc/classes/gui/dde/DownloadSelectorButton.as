import core.AbstractComponent;
import tools.Logger;
/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component cmc:DownloadSelectorButton
* A button to open the DownloadSelector component
* @file DownloadSelectorButton.as  (sourcefile)
* @file DownloadSelectorButton.fla (sourcefile)
* @file DownloadSelectorButton.swf (compiled component, needed for publication on internet)
* @file DownloadSelectorButton.xml (configurationfile, needed for publication on internet)
* @configstring tooltip tooltiptext of the button
*/

/** @tag <cmc:DownloadSelectorButton>  
* This tag defines a button for opening the DownloadSelector component. the button listens to the window of the
* DownloadSelector ("downloadSelectorWindow")
* @hierarchy childnode of <flamingo>
* @example  <cmc:DownloadSelectorButton right="500" top="6" listento="downloadSelectorWindow">
*/

class gui.dde.DownloadSelectorButton extends AbstractComponent {
	 private var downloadSelector:Object;   
	 var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<DownloadSelectorButton>" + 
							"<string id='tooltip' en='open DDE download window' nl='open DDE download scherm'/>" +
							"</DownloadSelectorButton>";
		
	function DownloadSelectorButton() {
		super();		
		//because not a mkid is used in the fla find the id like this:
		if (id == undefined) {			
			//try to get some sort of id.... Not so nice :(
			var tokens:Array = this._target.split("/");		
			if (tokens[tokens.length - 1] == "mDownloadSelectorButton") {
				id = tokens[tokens.length - 2];
			}else {			
				//cant set the id, set the id later by getting it from Flamingo
			}
		}
		_global.flamingo.correctTarget(_parent, this);
    }
							
	function onLoad():Void {		
		super.onLoad();		
		this.useHandCursor = false;	
		
	}
		
	function onPress():Void{
		this.gotoAndStop(3);
		downloadSelector = _global.flamingo.getComponent(listento[0]);
		downloadSelector.setVisible(!downloadSelector._visible);
	}
	
	function onReleaseOutside():Void{
		this.gotoAndStop(1);
	}
	
	function onRelease():Void{
		this.gotoAndStop(2);
	}
	
	
	function onRollOver():Void{
		this.gotoAndStop(2);
		_global.flamingo.showTooltip(_global.flamingo.getString(this,"tooltip"),this);
	}

	function onRollOut():Void{
		this.gotoAndStop(1);
	}
	
	function resize() {
		_global.flamingo.position(this);
	}
	
}