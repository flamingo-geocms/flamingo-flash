/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import coregui.*;

import mx.controls.CheckBox;
import mx.utils.Delegate;

class coregui.ContainerInspector extends MovieClip {
    
    private var container:MovieClip = null; // Set by init object.
    
    private var depth:Number = 0;
    
    function onLoad():Void {
        addCheckBoxes(container, 0);
    }
    
    private function addCheckBoxes(container:MovieClip, level:Number):Void {
        var componentIDs:Array = container.getComponents();
        var component:MovieClip = null;
        var name:String = null;
        var initObject:Object = new Object();
        var checkBox:CheckBox = null;
        
        for (var i:Number = 0; i < componentIDs.length; i++) {
            component = _global.flamingo.getComponent(componentIDs[i]);
            name = component.name;
            
            initObject["_x"] = level * 20;
            initObject["_y"] = depth * 25;
            initObject["_width"] = 170;
            if ((name != null) && (name != "")) {
                initObject["label"] = name;
            } else {
                initObject["label"] = componentIDs[i];
            }
            initObject["selected"] = component._visible;
            initObject["component"] = component;
            checkBox = CheckBox(attachMovie("CheckBox", "mCheckBox" + depth, depth, initObject));
            checkBox.addEventListener("click", Delegate.create(this, onClickCheckBox));
            
            depth++;
            if (component.getComponents != undefined) { // Instance of container.
                addCheckBoxes(component, level + 1);
            }
        }
    }
    
    function onClickCheckBox(eventObject:Object):Void {
        var component:MovieClip = eventObject.target["component"];
        if (component.setVisible == undefined) {
            component._visible = !component._visible;
        } else {
            component.setVisible(!component._visible);
        }
    }
    
}
