/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component ComponentVisibleButton
* A button intended to toggle the visibility of a certain component.
* @file flamingo/fmc/classes/flamingo/coregui/ComponentVisibleButton.as  (sourcefile)
* @file flamingo/fmc/PrintButton.fla  (sourcefile)
* @file flamingo/fmc/PrintButton.swf (compiled component, needed for publication on internet)
* @file flamingo/fmc/RemoveFeatureButton.fla  (sourcefile)
* @file flamingo/fmc/RemoveFeatureButton.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:PrintButton>
* This tag defines a component visible button instance for the Print Component. 
* A component visible button listens to the component of which it controls the visibility. 
* If that component extends AbstractComponent and it is placed in a window, then the component visible button controls the window's visibility, too. 
* Condition is that the window and its child component both have the visible parameter configured to the same value.
* @class flamingo.coregui.ComponentVisibleButton extends BaseButton
* @hierarchy childnode of Flamingo or a container component.
* @example
	<Flamingo>
		...
		<fmc:PrintButton left="570" top="5" listento="print">
        	<string id="tooltip" en="open/ close the print window" nl="printvenster openen/ sluiten"/>
    	</fmc:PrintButton>
		...
	</Flamingo>	
*/

/** @tag <fmc:RemoveFeatureButton>
* This tag defines a remove feature button instance (i.e. a component visible button instance for the Confirmation Component) 
* The remove feature button must be registered as a listener to a confirmation component. 
* As a component visible button, a click on it makes the confirmation component pop-up. 
* After the user has made his choice there the confirmation event will be sent to the edit bar, which removes the active feature from the feature model. 
* RemoveFeatureButton must not be a child node of EditBar.
* @class flamingo.coregui.ComponentVisibleButton extends BaseButton
* @hierarchy childnode of Flamingo or a container component.
* @example
	<Flamingo>
		...
		<fmc:RemoveFeatureButton left="493" top="4" listento="confirmation">
        	<string id="tooltip" en="remove object" nl="object verwijderen"/>
    	</fmc:RemoveFeatureButton>
		...
	</Flamingo>	
*/



import flamingo.coregui.*;

class flamingo.coregui.ComponentVisibleButton extends BaseButton {
    
    private var component:MovieClip = null;
    
    function init():Void {
		
        super.init();
        component = _global.flamingo.getComponent(listento[0]);
    }
    
    function onPress():Void {
        gotoAndStop(3);
        if (component.setVisible == undefined) {
            component._visible = !component._visible;
        } else {
            component.setVisible(!component._visible);
        }
    }
    
}
