import core.AbstractComponent;

import gui.legend.LegendItem;
import gui.legend.AbstractLegendItem;
import gui.legend.LegendContainer;
import gui.legend.AbstractGroupLegendItem;
import gui.legend.AbstractLabelLegendItem;
import gui.legend.Parser;
import gui.legend.Renderer;
import gui.legend.LegendLayout;
import gui.legend.GroupLegendItem;

import tools.Arrays;
import tools.XMLTools;

import mx.utils.Delegate;
import mx.containers.ScrollPane;

/**
 * @author Herman
 */
class gui.LegendTNG extends AbstractComponent {
	
	private var _skin: String = "";
	private var _parser: Parser;
	private var _legendContainer: LegendContainer;
	private var _renderer: Renderer;
	private var _layout: LegendLayout;
	private var _scrollPane: ScrollPane;
	 
    public var configObjId: String;
    public var legenditems: Array = [ ];
    
    public function get legendContainer (): LegendContainer {
    	return _legendContainer;
    }
    
	public function LegendTNG() {
		super();
	}
	
	public function init (): Void {
        // Create a scroll pane that will contain the legend:
        _scrollPane = this['createClassObject'] (mx.containers.ScrollPane, 'mScrollPane', 1);
        _scrollPane.contentPath = _skin + "_legend";
        _scrollPane.vLineScrollSize = 50;
        _scrollPane.setStyle("borderStyle", "none");
        _scrollPane.setStyle("borderColor", "none");
        _scrollPane.drawFocus = function (): Void { };
        
		// If there is a config object, the initialization of the legend is postponed until the configuration
		// XML is provided through the parseCustomAttr method (typically by print templates):
		if (!configObjId) {
			doInit ();
		}
	}
	
	private function doInit (): Void {
		
        		
        // Create a layout manager:
        _layout = new LegendLayout (_legendContainer);
        _layout.width = this.__width;
        
        // Trigger a resize:
        resize ();
        
        // Create a renderer:
        _renderer = new Renderer (_scrollPane.content, _legendContainer, _skin, _global.flamingo.getStyleSheet (this));
		
		// Register listeners:
		_legendContainer.addEventListener ('onPressLegendItem', Delegate.create (this, onPressLegendItem));
		_layout.addEventListener ('onLayoutComplete', Delegate.create (this, resize));
		
		_global.flamingo.addListener ({
			onResize: Delegate.create (this, resize)
		}, _global.flamingo.getParent (this), this);
		
		// Debug: List all groups.
		/*
		_legendContainer.getAllItemsFiltered (
                function (item: AbstractLegendItem): Boolean {
                	return (item instanceof GroupLegendItem) || (item instanceof LegendItem);
                },
                true,
                function (items: Array): Void {
                	_global.flamingo.tracer ("Listing all groups and legend items:");
                	for (var i: Number = 0; i < items.length; ++ i) {
                		_global.flamingo.tracer (" - " + items[i].label + " (" + items[i].id + ")");
                	}
                },
                function (item: AbstractGroupLegendItem): Boolean {
                	return (item instanceof GroupLegendItem) || (item instanceof LegendContainer);
                }
            );
		*/
	}
	
	public function setAttribute (name: String, value: String): Void {
		switch (name.toLowerCase ()) {
		case 'configobject':
            configObjId = value;
            break;
		case 'skin':
            _skin = value;
            break;
		}
	}
	
    private function addComposites (): Void {
		if (!configObjId) {
    	   processAppConfigs (_global.flamingo.getXMLs (this));
		}
    }
    
    private function processAppConfigs (appConfigs: Array): Void {
        if (appConfigs.length == 0) {
        	return;
        }
        
        var configuration: XMLNode = appConfigs[0],
            i: Number,
            j: Number,
            start: Number;
            
		if (_legendContainer) {
			configuration = _legendContainer.configuration;
			start = 0;
		} else {
			configuration = appConfigs[0];
			start = 1;
		}
		
        for (i = start; i < appConfigs.length; ++ i) {
        	var otherConfig: XMLNode = appConfigs[i];
        	for (j = 0; j < otherConfig.childNodes.length; ++ j) {
        		configuration.appendChild (otherConfig.childNodes[j]);
        	}
        }

		if (configuration.childNodes.length == 0) {
			return;
		}
		
        processConfig (configuration);
    }
    
    public function processConfig (configuration: XMLNode): Void {
    	
    	if (!_legendContainer) {
    		
    		// Initialize the legend if this is the first configuration:
	        _parser = new Parser (_global.flamingo.getId (this));
	        _parser.map = listento[0];
	        _legendContainer = _parser.legendContainer (configuration, _global.flamingo.getId (this));
	        _legendContainer.map = listento[0];
	        
	        // Initialize after setting the configuration if this legend has a config object:
	        if (configObjId) {
	        	doInit ();
	        }
    	} else {
    		
    		// Update the legend:
    		_legendContainer.updateConfiguration ();
    	}
    }
    
    public function getConfig (): XMLNode {
    	if (!_legendContainer) {
    		return null;
    	}
    	
    	return _legendContainer.configuration;
    }
    
    /**
     * Adds a node object described by xml to the legend. The object can be a single legend item
     * or a tree of legend items.
     * @param xml Object XML description of the node.
     * @param idNextSib id of next sibling
     * @param idParent id of parent
     * @return Boolean True or false. Indicates succes or failure. 
     */                  
    /*public function addNodeObject (xml: Object, idNextSib: String, idParent: String): Boolean {
    }*/
    
    /**
     * Removes a node object and it's tree. The object is designated by it's id.
     * @param id String id of the node object.
     * @return Boolean True or false. Indicates succes or failure.
     */
    /*public function removeNodeObject(id: String): Boolean {
    	// TODO: Implement.
    }*/
    
    /**
     * Removes all node objects of the legend
     * @return Boolean True or false. Indicates succes or failure.
     */                  
    /*public function removeAllNodeObjects(): Boolean {
    	// TODO: Implement.
    }*/
    
    /**
     * Find node object of the legend by id
     * @return Boolean True or false. Indicates found or not found.
     */
    /*public function legendItemExists(id2m: String): Boolean {
    	if (!_legendContainer) {
    		return false;
    	}
    	
    	return !!_legendContainer.getItemById (id2m);
    }*/
    
    private function onPressLegendItem (e: Object): Void {
    	var item: AbstractLegendItem = e.item;
    	
    	if (item instanceof GroupLegendItem) {
    		var group: GroupLegendItem = GroupLegendItem (item);

            if (group.collapsed) {
            	// Open the item after its children have been loaded:
                group.getItems (Delegate.create (group, function (): Void {
                	this.collapsed = false;
                	this.invalidate ();
                }));
                
            } else {
            	group.collapsed = true;
            	group.invalidate ();
            }
    	}
    }
    
    public function resize (): Void {
        var r: Object = _global.flamingo.getPosition(this);
        this._x = r.x;
        this._y = r.y;
        __width = r.width;
        __height = r.height;
        _scrollPane.setSize(__width, __height);
        
        _layout.width = this.__width;
        
        var sb: Number;
        if (_scrollPane.vScroller == undefined) {
            sb = 0;
        } else {
            sb = 20;//mScrollPane.vScroller._width;
        }

        var w: Number;        
        _scrollPane.content.clear();
        if (sb>0) {
            w = _scrollPane.content._width-25;
        } else {
            w = _scrollPane.content._width-1;
        }
        
        fill (_scrollPane.content, 0xCCCCCC, 0, w);
    }
    
    private function fill (mc: MovieClip, color: Number, alpha: Number, w: Number, h: Number): Void {
        mc.clear();
        mc.beginFill(color, alpha);
        mc.moveTo(0, 0);
        if (w == undefined) {
            w = mc._width;
        }
        if (h == undefined) {
            h = mc._height;
        }
        mc.lineTo(w, 0);
        mc.lineTo(w, h);
        mc.lineTo(0, h);
        mc.lineTo(0, 0);
        mc.endFill();
    }
    
    // =========================================================================
    // Group state methods:
    // =========================================================================
    /**
     * Set the collapsed property of a group 
     * @param id:groupid, collapsed (true or false)
     */ 
    public function setGroupCollapsed(groupid:String,items:Array,collapsed:Boolean): Void {
    	var group: GroupLegendItem = GroupLegendItem (_legendContainer.getItemById(groupid));
    	
    	_global.flamingo.tracer ("setGroupCollapsed: " + groupid + ", " + collapsed);
    	
    	// If the group is loaded, update its collapsed flag:
    	if (group) {
    		_global.flamingo.tracer ("Opening loaded group: " + groupid);
    		group.collapsed = collapsed;
    		group.invalidate ();
    		return;
    	}
    	
    	// Locate the group node and alter it:
    	var configuration: XMLNode = _legendContainer.configuration,
            fringe: Array = [ configuration ],
            node: XMLNode;
            
        while (fringe.length > 0) {
        	node = XMLNode (fringe.shift ());
        	
        	if (node.localName.toLowerCase () == 'group' && node.attributes['id'] == groupid) {
        		node.attributes['collapsed'] = collapsed ? 'true' : 'false';
        		node.attributes['open'] = collapsed ? 'false' : 'true';
        		_global.flamingo.tracer ("Opening unloaded group: " + groupid);
        		return;
        	}
        	
        	Arrays.each (node.childNodes, function (child: XMLNode): Void {
        		fringe.push (child);
        	});
        }
    }
    
    public function setGroupsCollapsed (groupIDs: Array, collapsed: Boolean): Void {
    	var unparsedGroups: Object = { },
    		unparsedGroupCount: Number = 0,
    		self: LegendTNG = this;

		Arrays.each (groupIDs, function (id: String): Void {
			var group: GroupLegendItem = GroupLegendItem (self._legendContainer.getItemById (id));
			
			if (group) {
				group.collapsed = collapsed;
				group.invalidate ();
			} else {
				unparsedGroups[id] = true;
				unparsedGroupCount = unparsedGroupCount + 1;
			}
		});
		
		if (unparsedGroupCount == 0) {
			return;
		}
		
    	// Locate the group node and alter it:
    	var configuration: XMLNode = _legendContainer.configuration,
            fringe: Array = [ configuration ],
            node: XMLNode;
            
        while (fringe.length > 0 && unparsedGroupCount > 0) {
        	node = XMLNode (fringe.shift ());
        	
        	if (node.localName.toLowerCase () == 'group' && unparsedGroups[node.attributes['id']]) {
        		node.attributes['collapsed'] = collapsed ? 'true' : 'false';
        		node.attributes['open'] = collapsed ? 'false' : 'true';
        		-- unparsedGroupCount;
        	}
        	
        	Arrays.each (node.childNodes, function (child: XMLNode): Void {
        		fringe.push (child);
        	});
        }    
	}
    
    public function setAllCollapsed(list:Array, collapsed:Boolean): Void {
    	for (var i: Number = 0; i < list.length; ++ i) {
    		if (list[i] instanceof GroupLegendItem) {
    			list[i].collapsed = collapsed;
    			list[i].invalidate ();
    		}
    	}
    }
    
    /**
     * Return the ID's of all groups that have an id and whose collapsed state matches the corresponding argument.
     * Only groups that have been loaded by the legend are returned by this method.
     * 
     * @return An array of (string) ids of groups.
     */
    public function getGroups (collapsed: Boolean): Array {
    	
    	return Arrays.map (
                _legendContainer.getAllItemsFiltered(function (item: AbstractLegendItem): Boolean {
                    return (item instanceof GroupLegendItem) && GroupLegendItem (item).id && GroupLegendItem (item).collapsed == collapsed;
                }),
                function (item: GroupLegendItem): String {
                    return item.id;
                }
            );
    }
    
    /**
     * This method is invoked whenever the current state of the viewer must be persisted in an XML document. The
     * legend stores a list of open groups in the viewer state.
     */
    public function persistState (document: XML, node: XMLNode): Void {
    	var openGroups: XMLNode = document.createElement ('GroupsOpen');
    	
		Arrays.each (getGroups (false), function (groupId: String): Void {
			var child: XMLNode = document.createElement ('G'),
				content: XMLNode = document.createTextNode (groupId);
				
			child.appendChild (content);
			openGroups.appendChild (child);
		});
		
		node.appendChild (openGroups);    	
    }
    
    /**
     * This method is invoked by the URL component whenever the viewer state needs to be restored based on a 
     * previously stored XML document.
     */
    public function restoreState (node: XMLNode): Void {
    	var i: Number,
    		self: LegendTNG = this;
    	
    	var groupsOpenNode: XMLNode = XMLTools.getChild ('GroupsOpen', node);
    	if (groupsOpenNode) {
    		var groupIDs: Array = [ ];
    		Arrays.each (groupsOpenNode.childNodes, function (groupNode: XMLNode): Void {
    			var content: String = LegendTNG.getStringContent (groupNode);
    			if (content != "") {
    				groupIDs.push (content);
    			}
    		});
    		setGroupsCollapsed (groupIDs, false);
    	}
    }
    
    static function getStringContent (_xmlNode: XMLNode): String {
    	if (_xmlNode.firstChild && (_xmlNode.firstChild.nodeType == 3 || _xmlNode.firstChild.nodeType == 4)) {
    		return _xmlNode.firstChild.nodeValue;
		} else {
			return "";
		}
    }}
