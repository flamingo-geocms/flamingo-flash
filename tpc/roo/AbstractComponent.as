class roo.AbstractComponent extends MovieClip {
    
    var name:String = null;
    var width:String = null;
    var height:String = null;
    var left:String = null;
    var right:String = null;
    var top:String = null;
    var bottom:String = null;
    var xcenter:String = null;
    var ycenter:String = null;
    var listento:Array = null;
    var visible:Boolean = null;
    var maxwidth:Number = null;
    var minwidth:Number = null;
    var maxheight:Number = null;
    var minheight:Number = null;
    
    var guides:Object = null; //associative array
    var styles:Object = null; //associative array
    var cursors:Object = null; //associative array
    var strings:Object = null; //associative array
    
    var __width:Number = null;
    var __height:Number = null;
    
    /** @component {Component}
    * Abstract superclass for all components.
    * @file AbstractComponent.as (sourcefile)
    */
    function onLoad():Void {
        if (_global.flamingo == undefined) {
            var textField:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
            textField.html = true;
            textField.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>AbstractComponent</B> - www.flamingo-mc.org</FONT></P>";
            
            return;
        }
        
        _visible = false;
        _global.flamingo.correctTarget(_parent, this);
        
        //defaults
        var xml:XML = _global.flamingo.getDefaultXML(this);
        this.setConfig(xml);
        delete xml;
        //custom
        var xmls:Array = _global.flamingo.getXMLs(this);
        for (var i = 0; i < xmls.length; i++) {
            this.setConfig(xmls[i]);
        }
        delete xmls;
        //remove xml from repository
        _global.flamingo.deleteXML(this);
        
        /*for (var i:String in listento) {
            _global.flamingo.addListener(this, _global.flamingo.getComponent(listento[0]), this);
        }*/
        setVisible(visible);
        var bounds:Object = _global.flamingo.getPosition(this);
        setBounds(bounds.x, bounds.y, bounds.width, bounds.height);
        
        _global.flamingo.raiseEvent(this, "onInit", this);
    }
    
    /**
    * Configures a component by setting a xml.
    * @attr xml:Object Xml or string representation of a xml.
    */
    function setConfig(xml:Object):Void {
        if (xml instanceof String) {
            xml = new XML(String(xml)).firstChild;
        }
        if (_global.flamingo.getType(this).toLowerCase() != xml.localName.toLowerCase()) {
            return;
        }
        //load default attributes, strings, styles and cursors  
        _global.flamingo.parseXML(this, xml);
        
        //parse custom attributes
        for (var attr:String in xml.attributes) {
            var value:String = xml.attributes[attr];
            setAttribute(attr, value);
        }
        
        //parse custom child nodes
        for (var i:Number = 0; i < xml.childNodes.length; i++) {
            var xmlNode:XMLNode = xml.childNodes[i];
            addComponent(xmlNode.nodeName, xmlNode);
        }
        
        //this.addComponents(xml);
    }
    
    function setAttribute(name:String, value:String):Void { }
    
    function addComponent(name:String, value:XMLNode):Void { }
    
    /**
    * Sets the position and the size of the component.
    * This will raise the onResize event.
    * @param x:Number The x position.
    * @param y:Number The y position.
    * @param width:Number The width.
    * @param height:Number The height.
    */
    function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
        this._x = x;
        this._y = y;
        __width = width;
        __height = height;
        
        _global.flamingo.raiseEvent(this, "onResize", this);
    }
    
    /**
    * Shows or hides the component.
    * This will raise the onSetVisible event.
    * @param visible:Boolean True or false.
    */
    function setVisible(visible:Boolean):Void {
        this._visible = visible;
        this.visible = visible;
        
        _global.flamingo.raiseEvent(this, "onSetVisible", this, visible);
    }
    
    /**
    * Displays the values of all the component's properties set by the Flamingo framework.
    * This can be useful for debugging.
    */
    function traceProperties():Void {
        _global.flamingo.tracer(this);
        
        _global.flamingo.tracer("NAME " + name);
        _global.flamingo.tracer("WIDTH " + width);
        _global.flamingo.tracer("HEIGHT " + height);
        _global.flamingo.tracer("LEFT " + left);
        _global.flamingo.tracer("RIGHT " + right);
        _global.flamingo.tracer("TOP " + top);
        _global.flamingo.tracer("BOTTOM " + bottom);
        _global.flamingo.tracer("XCENTER " + xcenter);
        _global.flamingo.tracer("YCENTER " + ycenter);
        _global.flamingo.tracer("LISTENTO " + listento.toString());
        _global.flamingo.tracer("VISIBLE " + visible);
        _global.flamingo.tracer("MAXWIDTH " + maxwidth);
        _global.flamingo.tracer("MINWIDTH " + minwidth);
        _global.flamingo.tracer("MAXHEIGHT " + maxheight);
        _global.flamingo.tracer("MINHEIGHT " + minheight);
        
        for (var i:String in guides) {
            _global.flamingo.tracer("GUIDE " + guides[i]);
        }
        for (var i:String in styles) {
            _global.flamingo.tracer("STYLE " + styles[i]);
        }
        for (var i:String in cursors) {
            _global.flamingo.tracer("CURSOR " + cursors[i]);
        }
        for (var i:String in strings) {
            for (var j:String in strings[i]) {
                _global.flamingo.tracer("STRING " + i + " " + j + " " + strings[i][j]);
            }
        }
        
        _global.flamingo.tracer("__WIDTH " + __width);
        _global.flamingo.tracer("__HEIGHT " + __height);
	}
	

}
