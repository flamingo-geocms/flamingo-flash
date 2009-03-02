/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

/** @component Veil
* A component intended to cover off certain parts or the whole of the Flamingo user interface. 
* A veil, when made visible, prevents all mouse events from going to the underlying components.
* @file flamingo/tpc/classes/flamingo/coregui/Veil.as  (sourcefile)
* @file flamingo/tpc/Veil.fla (sourcefile)
* @file flamingo/tpc/Veil.swf (compiled component, needed for publication on internet)
*/

/** @tag <tpc:Veil>
* This tag defines a veil component instance. Veil extends AbstactContainer and can be configured as such, for example with a fill color.
* @class flamingo.coregui.Veil extends AbstractContainer
* @hierarchy childnode of Flamingo or a container component.
* @example
	<Flamingo>
		...
		<tpc:Veil id="veil" width="100%" height="100%" visible="false" borderwidth="0" fillcolor="#FFFFFF" alpha="50"/>
		...
	</Flamingo>	
*/


import flamingo.coregui.*;
import flamingo.core.AbstractContainer;

class flamingo.coregui.Veil extends AbstractContainer {
    
    function init():Void {
        useHandCursor = false;
    }
    
    function onPress():Void {
        // Does nothing. Just to prevent all mouse events from going to the underlying movie clips.
    }
    
}
