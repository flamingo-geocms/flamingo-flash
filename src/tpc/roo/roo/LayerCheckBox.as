import mx.controls.CheckBox;
import mx.utils.Delegate;

import core.AbstractComponent;

class roo.LayerCheckBox extends AbstractComponent {
    
    private var checkBox:CheckBox = null;
    private var layer:MovieClip = null;
    
    function onLoad():Void {
        super.onLoad();
        layer = listento[0];
        _global.flamingo.addListener(this, layer, this);
        _global.flamingo.addListener(this, "flamingo", this);
    }
    
    function setAttribute(name:String, value:String):Void {
        if (name == "title") {
            addCheckBox(value);
        }
    }
    
    function addCheckBox(title:String):Void {
        var initObject:Object = new Object();
        initObject["selected"] = false;
        initObject["label"] = title;
        initObject["labelPlacement"] = "right";
        checkBox = CheckBox(attachMovie("CheckBox", "mCheckBox0", 0, initObject));
        //_global.flamingo.tracer("checkBox = " + checkBox);
        checkBox.addEventListener("click", Delegate.create(this, onClickCheckBox));
        checkBox.setStyle("fontSize", 11);
        checkBox.setSize(200, 22);
    }
    
    function onClickCheckBox(eventObject:Object):Void {
        //_global.flamingo.tracer("checkBox.selected = " + checkBox.selected);
        _global.flamingo.getComponent(layer).setVisible(checkBox.selected);
    }
    
    function onResize(o:Object) {
        _global.flamingo.position(this);
    }
    
    function onUpdateComplete(layer:MovieClip, updateTime:Number):Void {

        //_global.flamingo.tracer("layer.getVisible() = " + layer.getVisible());
        if (layer.getVisible() > 0) {
            checkBox.selected = true;
        } else {
            checkBox.selected = false;
        }

        if (Math.abs(layer.getVisible()) == 2) {
            checkBox.enabled = false;
        } else {
            checkBox.enabled = true;
        }
    }
        
}
