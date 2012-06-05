/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/



/** @component fmc:EditBar
* A container that holds the commit button. 
* Flamingo has two buttons used for editing: the remove feature button, which removes the active feature from the feature model, 
* and the commit button, which commits the changes made within the feature model to the server. Please refer to the GIS component.
* The CommitButton is an instance of BaseButton
* The RemoveFeatureButton is an instance of ComponentVisibleButton. Configure it outside the EditBar tags
* @file flamingo/fmc/classes/gui/EditBar.as  (sourcefile)
* @file flamingo/fmc/EditBar.fla (sourcefile)
* @file flamingo/fmc/EditBar.swf (compiled component, needed for publication on internet)
*/

/** @tag <fmc:EditBar>
* This tag defines an edit bar instance. The edit bar must be registered as a listener to an edit map. 
* Actually, the edit bar listens to the feature model of the edit map.
* @class gui.EditBar extends AbstractContainer implements ActionEventListener 
* @hierarchy childnode of Flamingo or a container component.
* @example
	<Flamingo>
		<fmc:EditBar id="editBar" left="523" top="4" listento="editMap" backgroundalpha="0" borderalpha="0">
			...
			<fmc:SelectFeatureButton left="25" top="2" listento="editMap">
				<string id="tooltip" en="select object" nl="object selecteren"/>
			</fmc:SelectFeatureButton>
			...
		</fmc:EditBar>
		
		<fmc:RemoveFeatureButton left="0" top="0" listento="confirmation">
			<string id="tooltip" en="remove object" nl="Tekenobject verwijderen"/>
		</fmc:RemoveFeatureButton>
	</Flamingo>	
*/

import gui.*;

import event.ActionEvent;
import event.ActionEventListener;
import gismodel.GIS;
import core.AbstractContainer;

/**
 * EditBar
 */
class gui.EditBar extends AbstractContainer implements ActionEventListener {
    
    private var gis:GIS = null;
    /**
     * init the edit bar
     */
    function init():Void {
		
        gis = _global.flamingo.getComponent(listento[0]).getGIS();
        
        var ids:Array = getComponents();
        for (var i:String in ids) {
            _global.flamingo.getComponent(ids[i]).setActionEventListener(this);
        }
    }
    /**
     * action event handler
     * @param	actionEvent
     */
    function onActionEvent(actionEvent:ActionEvent):Void {
		var sourceClassName:String = actionEvent.getSourceClassName();
        var actionType:Number = actionEvent.getActionType();
        if (sourceClassName + "_" + actionType == "Button_" + ActionEvent.CLICK) {
            var buttonName:String = actionEvent.getSource()._name;
			if (buttonName.indexOf("RemoveFeature") > -1) {
				var feature:gismodel.Feature = gis.getActiveFeature();
                if (feature != null) {
                    feature.getLayer().removeFeature(feature, true);
                }
			}
			else if (buttonName.indexOf("SelectFeature") > -1) {
				gis.setSelectedEditTool("selectFeature");
			}
			else if (buttonName.indexOf("CommitButton") > -1) {
				gis.commit();
			}
        } else if (sourceClassName + "_" + actionType == "Confirmation_" + ActionEvent.CLICK) {
            var feature:gismodel.Feature = gis.getActiveFeature();
            if (feature != null) {
                feature.getLayer().removeFeature(feature, true);
            }
        }
    }
    
}

