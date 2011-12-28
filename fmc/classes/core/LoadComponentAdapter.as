import core.AbstractComponent;

class core.LoadComponentAdapter {

	private var listener:AbstractComponent = null;
    
    function LoadComponentAdapter(listener:AbstractComponent) {
        this.listener = listener;
    }
    
    function onLoadComponent(mc):Void {
		var tokens:Array = mc._name.split(".");
		var mcId = tokens[tokens.length - 1];
		if (listener.id==mcId) {					
			listener.removeLoadComponentAdapter(this);
		}
    }
    
}
