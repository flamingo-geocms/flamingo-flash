import core.AbstractComponent;
import roo.XMLTools;

class roo.FilterLayer extends AbstractComponent {
    
    private var sldURL:String = "";
    private var defaultFilterName = "filter";
    private var filterconditions:Object = null; // Associative array;
    private var filtertemplates:Object = null;
    
    function onLoad():Void {
        super.onLoad();
        
        this.filterconditions = new Object();
        this.filtertemplates = new Object();
    }
    
    function setAttribute(name:String, value:String):Void {
        switch (name) {
            case "sldurl":
                sldURL = value;
        }
    }
    
    function getSLDURL():String {
        return sldURL;
    }
    
    function getFilterTemplate(filtername:String):String {
    		if (this.filtertemplates[filtername] == undefined) {
            this.filtertemplates[filtername] = new Object();
            var template:String = _global.flamingo.getString(this, filtername, null, "nl");
            this.filtertemplates[filtername] = XMLTools.xmlDecode(template);
    		}
        //_global.flamingo.tracer("getFilterTemplate, template = " + this.filtertemplates[filtername]);
        return this.filtertemplates[filtername];
    }
    
    function addFilter(name:String, filtercondition:String, update:Boolean):Void {

        this.filterconditions[name] = new Object();
        this.filterconditions[name] = filtercondition;
        //_global.flamingo.tracer("addFilter, name = " + name + " filtercondition = " + filtercondition + " this.filterconditions = " + this.filterconditions + " this.filterconditions[name] = " + this.filterconditions[name]);
        
        _global.flamingo.raiseEvent(this, "onAddRemoveFilter", this, update);
    }
    
    function removeFilter(name:String, update:Boolean):Void {
        
        delete this.filterconditions[name];
        
        _global.flamingo.raiseEvent(this, "onAddRemoveFilter", this, update);
    }
    
    function getFiltercondition(name:String):String {
        return this.filterconditions[name];
    }

    function getFilterconditions():Object {
        return this.filterconditions;
    }    

    function getFiltersFingerprint():String {
        var filtersFingerprint:String = "";
        for (var filtername:String in filterconditions) {
            var filtercondition:String = getFiltercondition(filtername);
            filtersFingerprint += filtername + filtercondition;
		    }
        return filtersFingerprint;
    }    

}
