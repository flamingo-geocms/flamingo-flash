/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractLegendItem;
import gui.legend.LegendContainer;
import gui.legend.LegendItem;
import gui.legend.SymbolLegendItem;
import gui.legend.TextLegendItem;
import gui.legend.RulerLegendItem;
import gui.legend.AbstractGroupLegendItem;
import gui.legend.AbstractLabelLegendItem;
import gui.legend.GroupLegendItem;
import tools.Arrays;
import mx.utils.Delegate;

class gui.legend.Parser {
	
	private var _blockSize: Number = 20;
	private var _delay: Number = 10;
    private var _map: String = 'map';
    private var _allGroupsOpen: Boolean = false;
    private var _allGroupsClosed: Boolean = false;
    private var _groupsState: Object;
    
    public function get map (): String {
    	return _map;
    }
    
    public function set map (map: String): Void {
    	_map = map;
    }
    
	public function Parser (componentId: String, blockSize: Number, delay: Number) {
		if (blockSize) {
            _blockSize = Math.min (blockSize, 1);
		}
		if (delay) {
            _delay = Math.min (delay, 1);
		}
		
		// Determine initial groups state based on startup parameters:
		_groupsState = { };
        var groupsopen:Array = _global.flamingo.getArgument(componentId, "groupsopen").split(",");
        var groupsclosed:Array = _global.flamingo.getArgument(componentId, "groupsclosed").split(",");
        var i: Number;
        if (groupsopen[0].toLowerCase () == 'all') {
			_allGroupsOpen = true;
		}
		if (groupsclosed[0].toLowerCase () == 'all') {
			_allGroupsClosed = true;
		}
        for (i = 0; i < groupsopen.length; ++ i) {
        	_groupsState[groupsopen[i]] = true;		
        }
        for (i = 0; i < groupsclosed.length; ++ i) {
        	_groupsState[groupsclosed[i]] = false;
        }
	}
	
    public function items (parent: AbstractGroupLegendItem, configuration: XMLNode, callback: Function): Array {
        var children: Array = [ ];
        var worker: Function = Delegate.create (this, function (child: XMLNode): Void {
        	var localName: String = child.localName.toLowerCase ();
        	if (localName == 'string' || localName == 'style') {
        		return;
        	}
            children.push (this.item (parent, child));
        });
        
        if (callback) {
            var continuation: Function = function (): Void {
            	callback (children);
            };
            
            Arrays.eachAsync (configuration.childNodes, worker, _blockSize, _delay, continuation);
            
            return null;
        } else {
        	Arrays.each (configuration.childNodes, worker);
        
            return children;
        }
    }
    
	public function item (parent: AbstractGroupLegendItem, configuration: XMLNode): AbstractLegendItem {
        switch (configuration.localName.toLowerCase ()) {
        case 'group':
            return groupLegendItem (parent, configuration);
        case 'item':
            return legendItem (parent, configuration);
        case 'symbol':
            return symbolLegendItem (parent, configuration);
        case 'ruler':
        case 'hr':
            return rulerLegendItem (parent, configuration);
        case 'text':
            return textLegendItem (parent, configuration);
        default:
            _global.flamingo.tracer ("Unknown legend item type: `" + configuration.localName + "`");
            break;
        }
	}
    
    public function legendContainer (configuration: XMLNode, componentId: String): LegendContainer {
        var item: LegendContainer = new LegendContainer (configuration, this, componentId);
        
        acceptLegendContainer (item, configuration);
        
        return item; 
    }
    
    public function legendItem (parent: AbstractGroupLegendItem, configuration: XMLNode): LegendItem {
    	var item: LegendItem = new LegendItem (parent, configuration);
    
        acceptLegendItem (item, configuration);
        
        return item;	
    }
    
    public function symbolLegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode): SymbolLegendItem {
    	var item: SymbolLegendItem = new SymbolLegendItem (parent);
    	
    	acceptSymbolLegendItem (item, configuration);
    	
    	return item;
    }
    
    public function textLegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode): TextLegendItem {
    	var item: TextLegendItem = new TextLegendItem (parent);
    	
    	acceptTextLegendItem (item, configuration);
    	
    	return item;
    }
    
    public function rulerLegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode): RulerLegendItem {
    	var item: RulerLegendItem = new RulerLegendItem (parent);
    	
    	acceptRulerLegendItem (item, configuration);
    	
    	return item;
    }
    
    public function groupLegendItem (parent: AbstractGroupLegendItem, configuration: XMLNode): GroupLegendItem {
    	var item: GroupLegendItem = new GroupLegendItem (parent, configuration);
    	
    	acceptGroupLegendItem (item, configuration);
    	
    	return item;
    }
    
    private function acceptLegendContainer (item: LegendContainer, configuration: XMLNode): Void {
    	acceptAbstractGroupLegendItem (item, configuration);
    	
    	item.shadowSymbols = Boolean (acceptAttribute (configuration, 'shadowsymbols', asBoolean, false));
    	item.updateDelay = Number (acceptAttribute (configuration, 'updatedelay', asNumber, 1000));
    	item.symbolPath = String (acceptAttribute (configuration, 'symbolpath', asString, ''));
    	
    	item.defaultDelta['group'] = [
    	   Number (acceptAttribute (configuration, 'groupdx', asNumber, 0)),
           Number (acceptAttribute (configuration, 'groupdy', asNumber, 0))
    	];
        item.defaultDelta['hr'] = [
           Number (acceptAttribute (configuration, 'hrdx', asNumber, 0)),
           Number (acceptAttribute (configuration, 'hrdy', asNumber, 0))
        ];
        item.defaultDelta['text'] = [
           Number (acceptAttribute (configuration, 'textdx', asNumber, 0)),
           Number (acceptAttribute (configuration, 'textdy', asNumber, 0))
        ];
        item.defaultDelta['item'] = [
           Number (acceptAttribute (configuration, 'itemdx', asNumber, 0)),
           Number (acceptAttribute (configuration, 'itemdy', asNumber, 0))
        ];
        item.defaultDelta['symbol'] = [
           Number (acceptAttribute (configuration, 'symboldx', asNumber, 0)),
           Number (acceptAttribute (configuration, 'symboldy', asNumber, 0))
        ];
    }
    
    private function acceptGroupLegendItem (item: GroupLegendItem, configuration: XMLNode): Void {
    	acceptAbstractGroupLegendItem (item, configuration);
    	
    	if (configuration.attributes['open'] !== undefined) {
    		item.collapsed = !Boolean (acceptAttribute (configuration, 'open', asBoolean, true));
    	} else {
    	   item.collapsed = Boolean (acceptAttribute (configuration, 'collapsed', asBoolean, false));
    	}
    	item.hideAllButOne = Boolean (acceptAttribute (configuration, 'hideallbutone', asBoolean, false));
    	item.mouseOverStyleId = [acceptAttribute (configuration, 'mouseoverstyleid', asString, null)][0];

        if (_allGroupsOpen) {
        	item.collapsed = false;
        } else if (_allGroupsClosed) {
        	item.collapsed = true;
        } else if (item.id && _groupsState[item.id] !== undefined) {
			item.collapsed = !_groupsState[item.id];
        }
    }
    
    private function acceptLegendItem (item: LegendItem, configuration: XMLNode): Void {
        acceptAbstractGroupLegendItem (item, configuration);
        
        item.symbolPosition = [acceptAttribute (configuration, 'symbolposition', asString, null)][0];
        item.canHide = Boolean (acceptAttribute (configuration, 'canhide', asBoolean, false));
        item.stickyLabel = Boolean (acceptAttribute (configuration, 'stickylabel', asBoolean, false));
        item.infoURL = [acceptAttribute (configuration, 'infourl', asString, null)][0];
        item.linkStyleId = [acceptAttribute (configuration, 'linkstyleid', asString, null)][0];
        
        var listenTo: Array = [acceptAttribute (configuration, 'listento', asArray, null)][0];
        if (listenTo) {
        	item.listenTo = parseListento (listenTo);
        }
    }
    
    private function acceptSymbolLegendItem (item: SymbolLegendItem, configuration: XMLNode): Void {
        acceptAbstractLabelLegendItem (item, configuration);
        
        var url: String = [acceptAttribute (configuration, 'url', asString, null)][0];
        if (!url) {
        	url =  [acceptAttribute (configuration, 'symbolurl', asString, null)][0];
        }
        item.symbolURL = url;
        item.libLinkage = [acceptAttribute (configuration, 'liblinkage', asString, '')][0];
        item.symbolStyleId = [acceptAttribute (configuration, 'symbolstyleid', asString, null)][0];
        item.symbolLinkStyleId = [acceptAttribute (configuration, 'symbollinkstyleid', asString, null)][0];
        item.infoURL = [acceptAttribute (configuration, 'infourl', asString, null)][0];

        var skipAttributes: Object = { };
        Arrays.each (['url', 'liblinkage', 'symbolstyleid', 'symbollinkstyleid', 'label', 'text', 'styleid', 'id', 'dx', 'dy', 'minscale', 'maxscale'], function (i: String): Void {
        	skipAttributes[i] = true;        
        });
        
        for (var attributeName: String in configuration.attributes) {
        	if (skipAttributes[attributeName]) {
        		continue;
        	}
        	
        	item.extraAttributes[attributeName] = configuration.attributes[attributeName];
        }
    }
    
    private function acceptTextLegendItem (item: TextLegendItem, configuration: XMLNode): Void {
        acceptAbstractLabelLegendItem (item, configuration);
    }
    
    private function acceptRulerLegendItem (item: RulerLegendItem, configuration: XMLNode): Void {
    	acceptAbstractLegendItem (item, configuration);
    }
    
    private function acceptAbstractGroupLegendItem (item: AbstractGroupLegendItem, configuration: XMLNode): Void {
    	acceptAbstractLabelLegendItem (item, configuration);
    }
    
    private function acceptAbstractLabelLegendItem (item: AbstractLabelLegendItem, configuration: XMLNode): Void {
    	acceptAbstractLegendItem (item, configuration);
    	
    	item.label = [acceptAttribute (configuration, 'label', asString, null)][0];
    	if (!item.label) {
    		item.label = [acceptAttribute (configuration, 'text', asString, null)][0];
    	}
    	item.styleId = [acceptAttribute (configuration, 'styleid', asString, null)][0];
    	
    	// Parse strings into the language object:
    	var language: Object = { };
    	if (_global.flamingo.parseString (configuration, language)) {
    		if (language['text']) {
    			language['label'] = language['text'];
    		}
            item.language = language;
    	}
    }
    
    private function acceptAbstractLegendItem (item: AbstractLegendItem, configuration: XMLNode): Void {
    	item.id = [acceptAttribute (configuration, 'id', asString, null)][0];
    	item.dx = Number (acceptAttribute (configuration, 'dx', asNumber, 0));
    	item.dy = Number (acceptAttribute (configuration, 'dy', asNumber, 0));
    	item.minScale = Number (acceptAttribute (configuration, 'minscale', asNumber, 0));
    	item.maxScale = Number (acceptAttribute (configuration, 'maxscale', asNumber, 0));
    }
    
    private function acceptAttribute (configuration: XMLNode, name: String, conversion: Function, defaultValue: Object): Object {
    	var value: String = configuration.attributes[name],
            result: Object = defaultValue;
            
        if (value) {
        	result = conversion (value);
        }
    	
    	return result;
    }
    
    private function parseListento (listento: Array): Object {

        var result: Object = { };
            	
    	for (var i: Number = 0; i < listento.length; ++ i) {
            var l: String = listento[i];
            var layer: String;
            var sublayer: String;
            
            if (l.indexOf (".", 0) == -1) {
                layer = map + "_" + l;
                sublayer = "";
            } else {
                layer = map + "_" + l.split(".")[0];
                sublayer = l.substring(l.split(".")[0].length+1);                             
            }
    	
            if (!result[layer]) {
            	result[layer] = [ ];	
            }
            
            if (sublayer != '') {
                result[layer].push (sublayer);
            }
    	}
    	
    	return result;
    }
    
    private static function asBoolean (value: String): Boolean {
    	return value.toLowerCase () == 'true';
    }
    
    private static function asString (value: String): String {
    	return value;
    }
    
    private static function asArray (value: String): Array {
    	return _global.flamingo.asArray (value);
    }
    
    private static function asNumber (value: String): Number {
    	return Number (value);
    }
    
}
