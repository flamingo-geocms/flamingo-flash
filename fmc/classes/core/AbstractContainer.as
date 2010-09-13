import core.AbstractComponent;

/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/
class core.AbstractContainer extends AbstractComponent {
    
    private var componentID:String = "AbstractContainer 1.0";
    
    // Container layout properties.
    var alpha:Number = 100;
    var backgroundcolor:Number = 0xFFFFFF;
    var backgroundalpha:Number = 100;
    var bordercolor:Number = 0xB8B8B8;
    var borderalpha:Number = 100;
    var borderwidth:Number = 1;
    var mask:Boolean = false;
    var defaultXML:String = "";
    
    private var background:MovieClip = null;
    private var contentPane:MovieClip = null;
    private var border:MovieClip = null;
    
    /** @component AbstractContainer
    * Abstract superclass for all containers.
    * @file AbstractContainer.as (sourcefile)
    */
    function AbstractContainer() {
        if (_global.flamingo == null) {
            var textField:TextField = createTextField("mTextField", 0, 0, 0, 550, 400);
            textField.html = true;
            textField.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>AbstractContainer</B> - www.flamingo-mc.org</FONT></P>";
            
            return;
        }
    }
    
    function onLoad():Void {
        if (_global.flamingo == null) {
            return;
        }
        background = createEmptyMovieClip("mBackground", 0);
        contentPane = createEmptyMovieClip("mContentPane", 1);
        border = createEmptyMovieClip("mBorder", 2);
        setConfig();
        contentPane.guides = guides;
        
    }
    
    function setConfig(){
    	setBaseConfig();
        setCompoConfig();
        setCustomConfig();
        wait();
    }
    
    function getContentPane():MovieClip {
        return contentPane;
    }
    
    function setCompoConfig():Void {
        // Retrieves the default configuration for the component, in order to set the "compo" properties.
        var defaultConfig:XMLNode = new XML(defaultXML);
        setCompoProperties(defaultConfig);
        
        // Retrieves the application configurations for the component, in order to set the "compo" properties.
        var appConfigs:Array = _global.flamingo.getXMLs(this);
        for (var i = 0; i < appConfigs.length; i++) {
            setCompoProperties(XMLNode(appConfigs[i]));
        }
        listento = listento.concat(getComponents()); // Makes the container wait for its child components to be ready.
    }
    
    // Parses the xml child nodes to components. A container has no other composites than components.
    function setCompoProperties(config:XMLNode):Void {
        for (var i:Number = 0; i < config.childNodes.length; i++) {
            var xmlNode:XMLNode = config.childNodes[i];
            var nodeName:String = xmlNode.nodeName;
            if (nodeName.indexOf(":") > -1) {
                nodeName = nodeName.substr(nodeName.indexOf(":") + 1);
            }
            addComponent(nodeName, xmlNode);
        }
    }
    
    // Parses the xml attributes to object attributes. They can be either attributes on the abstract container level or attributes on the "really custom" level.
    function setCustomProperties(config:XMLNode):Void {
        for (var attributeName:String in config.attributes) {
            var value:String = config.attributes[attributeName];
            setContainerAttribute(attributeName, value);
            setAttribute(attributeName, value);
        }
    }
    
    function setContainerAttribute(name:String, value:String):Void {
        if (name == "bordercolor") {
            if (value.charAt(0) == "#") {
                bordercolor = Number("0x" + value.substring(1, value.length));
            } else {
                bordercolor = Number(value);
            }
        } else if (name == "backgroundcolor") {
            if (value.charAt(0) == "#") {
                backgroundcolor = Number("0x" + value.substring(1, value.length));
            } else {
                backgroundcolor = Number(value);
            }
        } else if (name == "borderwidth") {
            borderwidth = Number(value);
        } else if (name == "borderalpha") {
            borderalpha = Number(value);
        } else if (name == "backgroundalpha") {
            backgroundalpha = Number(value);
        } else if (name == "alpha") {
            alpha = Number(value);
        } else if (name == "mask") {
            mask = value.toLowerCase() == "true"? true : false;
        }
    }

    function addComponent(name:String, config:XMLNode):Void {
        if (config.prefix.length > 0) {
            var id:String;
            for (var attr in config.attributes) {
                if (attr.toLowerCase() == "id") {
                    id = config.attributes[attr];
                    break;
                }
            }
            if (id == undefined) {
                id = _global.flamingo.getUniqueId();
                config.attributes.id = id;
            }
            if (_global.flamingo.exists(id)) {
                // id already in use let flamingo manage double id's
                _global.flamingo.addComponent(config, id);
            } else {
                var mc:MovieClip = contentPane.createEmptyMovieClip(id, contentPane.getNextHighestDepth());
                _global.flamingo.loadComponent(config, mc, id);
                _global.flamingo.raiseEvent(this, "onAddComponent", this, mc[id]);
            }
            //return id;
        }
    }
    
    function clear():Void {
        for (var id in contentPane) {
            if (typeof (contentPane[id]) == "movieclip") {
                removeComponent(id);
            }
        }
    }
    
    function removeComponent(id:String):Void {
        _global.flamingo.killComponent(id);
        _global.flamingo.raiseEvent(this, "onRemoveComponent", this, id);
    }
    
    /**
    * Returns the ids of all direct child components within the container. Does not return any grandchildren.
    * DEPRECATED  Use getChildComponents() instead.
    */
    function getComponents():Array {
        var comps:Array = new Array();
        for (var id in contentPane) {
            if (typeof (contentPane[id]) == "movieclip") {
                comps.push(id);
            }
        }
        return comps;
    }
    
    /**
    * Returns all direct child components within the container. Does not return any grandchildren.
    */
    function getChildComponents():Array {
        var comps:Array = new Array();
        for (var id in contentPane) {
            if (typeof (contentPane[id]) == "movieclip") {
                comps.push(contentPane[id]);
            }
        }
        return comps;
    }
    
    /**
    * Shows the container.
    * This will raise the onShow event.
    * DEPRECATED  Use setVisible(true) instead.
    */
    function show():Void {
        setVisible(true);
        _global.flamingo.raiseEvent(this, "onShow", this);
    }
    
    /**
    * Hides the container.
    * This will raise the onHide event.
    * DEPRECATED  Use setVisible(false) instead.
    */
    function hide():Void {
        setVisible(false);
        _global.flamingo.raiseEvent(this, "onHide", this);
    }
    
    /**
    * Sets the position and the size of the container.
    * This will raise the onResize event.
    * @param x:Number The x position.
    * @param y:Number The y position.
    * @param width:Number The width.
    * @param height:Number The height.
    */
    function setBounds(x:Number, y:Number, width:Number, height:Number):Void {
        contentPane.__width = width;
        contentPane.__height = height;
        super.setBounds(x, y, width, height);
    }
    
    function layout():Void {
        _alpha = alpha;
        
        background.clear();
        if (backgroundalpha > 0) {
            background.beginFill(backgroundcolor, backgroundalpha);
            background.moveTo(0, 0);
            background.lineTo(__width - 1, 0);
            background.lineTo(__width - 1, __height - 1);
            background.lineTo(0, __height - 1);
            background.lineTo(0, 0);
            background.endFill();
        }
        
        border.clear();
        if ((borderalpha > 0) && (borderwidth > 0)) {
            border.lineStyle(borderwidth, bordercolor, borderalpha);
            border.moveTo(0, 0);
            border.lineTo(__width - 1, 0);
            border.lineTo(__width - 1, __height - 1);
            border.lineTo(0, __height - 1);
            border.lineTo(0, 0);
        }
        
        if (mask) {
            contentPane.scrollRect = new flash.geom.Rectangle(0, 0, (__width), (__height));
        }
    }
    
}
