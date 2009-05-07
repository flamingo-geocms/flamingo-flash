/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component Veil
* A component intended to cover off certain parts or the whole of the Flamingo user interface. 
* A veil, when made visible, prevents all mouse events from going to the underlying components.
* @file flamingo/fmc/classes/flamingo/coregui/Veil.as  (sourcefile)
* @file flamingo/fmc/Veil.fla (sourcefile)
* @file flamingo/fmc/Veil.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:Veil>
* This tag defines a veil component instance. Veil extends AbstactContainer and can be configured as such, for example with a fill color.
* @class coregui.Veil extends AbstractContainer
* @hierarchy childnode of Flamingo or a container component.
* @example
	<Flamingo>
		...
		<fmc:Veil id="veil" width="100%" height="100%" visible="false" borderwidth="0" fillcolor="#FFFFFF" alpha="50"/>
		...
	</Flamingo>	
*/


import coregui.*;
import core.AbstractContainer;

class coregui.Veil extends AbstractContainer {
    
    function init():Void {
        useHandCursor = false;
    }
    
    function onPress():Void {
        // Does nothing. Just to prevent all mouse events from going to the underlying movie clips.
    }
    
}
