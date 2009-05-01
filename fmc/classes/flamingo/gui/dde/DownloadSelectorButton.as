import flamingo.core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Linda Vels.
* IDgis bv
 -----------------------------------------------------------------------------*/
 
/** @component DownloadSelectorButton
* A button to open the DownloadSelector component
* @file DownloadSelectorButton.as  (sourcefile)
* @file DownloadSelectorButton.fla (sourcefile)
* @file DownloadSelectorButton.swf (compiled component, needed for publication on internet)
* @file DownloadSelectorButton.xml (configurationfile, needed for publication on internet)
* @configstring tooltip tooltiptext of the button
*/

/** @tag <fmc:DownloadSelectorButton>  
* This tag defines a button for opening the DownloadSelector component. the button listens to the window of the
* DownloadSelector ("downloadSelectorWindow")
* @hierarchy childnode of <flamingo>
* @example  <fmc:DownloadSelectorButton right="500" top="6" listento="downloadSelectorWindow">
*/

class flamingo.gui.dde.DownloadSelectorButton extends AbstractComponent {
	 private var downloadSelector:Object;   
	 var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
							"<DownloadSelectorButton>" + 
							"<string id='tooltip' en='open DDE download window' nl='open DDE download scherm'/>" +
							"</DownloadSelectorButton>";
		
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