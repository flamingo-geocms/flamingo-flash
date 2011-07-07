/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.filters.DropShadowFilter;
import flash.filters.BlurFilter;

import gui.legend.AbstractGroupLegendItem;
import gui.legend.AbstractLegendItem;
import gui.legend.LegendContainer;
import gui.legend.GroupLegendItem;
import gui.legend.LegendItem;
import gui.legend.RulerLegendItem;
import gui.legend.TextLegendItem;
import gui.legend.SymbolLegendItem;
import gui.legend.LegendVisitor;

import mx.utils.Delegate;

import FlamingoCheckButton;

class gui.legend.Renderer implements LegendVisitor {
	private var _canvas: MovieClip;
	private var _legendContainer: LegendContainer;
	private var _skin: String;
	private var _styleSheet: Object;
	
	private var _invalidLayout: Array;
	
	public function get canvas (): MovieClip {
		return _canvas;
	}
	
	public function get legendContainer (): LegendContainer {
		return _legendContainer;
	}
	
	public function get skin (): String {
		return _skin;
	}
	
	public function get styleSheet (): Object {
		return _styleSheet;
	}
	
	public function Renderer (canvas: MovieClip, legendContainer: LegendContainer, skin: String, styleSheet: Object) {
		_canvas = canvas;
		_legendContainer = legendContainer;
		_skin = skin;
		_styleSheet = styleSheet;
		_invalidLayout = [ ];
		
		// Render the legend container:
		render (legendContainer, canvas, 0);
		
		// Render all items that currently exist in the legend:
		
        // Register a listener that renders newly added items:
        legendContainer.addEventListener ('onItemsAdded', Delegate.create (this, onItemsAdded));
        legendContainer.addEventListener ('onLegendItemVisibilityChanged', Delegate.create (this, onLegendItemVisibilityChanged));
	}
	
	private function onItemsAdded (e: Object): Void {
		var group: AbstractGroupLegendItem = e.group,
            items: Array = e.items;

        for (var i: Number = 0; i < items.length; ++ i) {
        	render (items[i], group.movieClip.mItems, 0);
        }
	}
	
	public function render (item: AbstractLegendItem, parent: MovieClip, indent: Number): MovieClip {
		var nr: Number = parent.getNextHighestDepth(),
            container: MovieClip = parent.createEmptyMovieClip('i' + nr, nr);
		
		container.item = item;
		item._setMovieClip (container);
		
		var context: Object = {
			parent: parent,
			indent: indent,
			container: container,
			invalidateItem: true
		};
		
		item.visit (this, context);
		
		if (context.invalidateItem) {
            item.invalidate ();
		}
        
        container._visible = false;
        
		return container;
	}
	
    // =========================================================================
    // Legend container:
    // =========================================================================
    public function visitContainer (item: LegendContainer, context: Object): Void {
    	var parent: MovieClip = context.parent,
            indent: Number = context.indent,
            container: MovieClip = context.container;
            
        // Create an empty movieclip that will contain the legend items:
        container.createEmptyMovieClip("mItems", 1);
    }
    
	// =========================================================================
	// Groups:
    // =========================================================================
    private var _groupDelegates: Object = null;
    
    public function get groupDelegates (): Object {
    	if (_groupDelegates === null) {
    		var self: Renderer = this;
    		_groupDelegates = {
    			onPress: function (): Void {
    				self.legendContainer._onPressLegendItem (this._parent.item);
    			},
    			onRollOver: function (): Void {
                    self.drawGroupLabel (this._parent, this._parent.item, true);
                    self.drawGroupIcon (this._parent, this._parent.item, true);
    			},
    			onRollOut: function (): Void {
                    self.drawGroupLabel (this._parent, this._parent.item, false);
                    self.drawGroupIcon (this._parent, this._parent.item, false);
    			}
    		};
    	}
    	
    	return _groupDelegates;
    }
    
	public function visitGroup (item: GroupLegendItem, context: Object): Void {
        var parent: MovieClip = context.parent,
            indent: Number = context.indent,
            container: MovieClip = context.container;
            
        //this movie will act as a group
        container.createEmptyMovieClip("mHeader", 1);
        container.mHeader.useHandCursor = false;
        container.mHeader.attachMovie(skin+"_group_open", "skin", 1);
        
        container.mHeader.onPress = groupDelegates.onPress;
        container.mHeader.onRollOver = groupDelegates.onRollOver;
        container.mHeader.onRollOut = groupDelegates.onRollOut;
        
        if (item.label) {
            container.mHeader.createTextField("mLabel", 2, container.mHeader.skin._x + container.mHeader.skin._width, 0, 100, 15);
            
            container.mHeader.mLabel.styleSheet = styleSheet;
            container.mHeader.mLabel.multiline = true;
            container.mHeader.mLabel.wordWrap = true;
            container.mHeader.mLabel.html = true;
            container.mHeader.mLabel.selectable = false;
        }
        container.createEmptyMovieClip("mItems", 2);
        
        drawGroupLabel (container, item, false);
        drawGroupIcon (container, item, false);
	}
	
    private function drawGroupLabel (container: MovieClip, item: GroupLegendItem, mouseover: Boolean): Void {
        var label: String = item.label;
        var styleid: String;
        
        if (mouseover) {
            styleid = item.mouseOverStyleId;
            if (!styleid) {
                styleid = item.styleId;
                if (!styleid) {
                    styleid = "group_mouseover";
                }
            }
        } else {
            styleid = item.styleId;
            if (!styleid) {
                styleid = "group";
            }
        }
        
        container.mHeader.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
    }
    
    private function drawGroupIcon (container: MovieClip, item: GroupLegendItem, mouseover: Boolean): Void {
    	var over: String = mouseover ? '_over' : '';
        if (item.collapsed) {
            container.mHeader.attachMovie (this.skin+"_group_close" + over, "skin", 1);
        } else {
            container.mHeader.attachMovie (this.skin+"_group_open" + over, "skin", 1);
        }
    }
    
    // =========================================================================
    // Items:
    // =========================================================================
    private var _itemDelegates: Object = null;
    
    public function get itemDelegates (): Object {
    	if (!_itemDelegates) {
            var self: Renderer = this;
            _itemDelegates = {
                onPress: function (checked: Boolean): Void {
                	this.item._onPress (checked);
                }
            };
    	}
    	
    	return _itemDelegates;
    }
    
	public function visitItem (item: LegendItem, context: Object): Void {
        var parent: MovieClip = context.parent,
            indent: Number = context.indent,
            container: MovieClip = context.container;
            
		if (item.canHide && item.listenTo) {
            container.chkButton = new FlamingoCheckButton(container.createEmptyMovieClip("mCheck", 1), skin+"_checked", skin+"_checkeddown", skin+"_checkedover", skin+"_unchecked", skin+"_uncheckeddown", skin+"_uncheckedover", skin+"_checked", container, false);
            container.chkButton.onPress = itemDelegates.onPress;
        }
        if (item.label) {
            container.createTextField("mLabel", 2, 0, 0, 1000, 1000);
            //mc.mLabel.border = true;
            container.mLabel.styleSheet = styleSheet;
            container.mLabel.multiline = true;
            container.mLabel.wordWrap = false;
            container.mLabel.html = true;
            container.mLabel.selectable = false;
            
            drawItemLabel (container, item);
        }
        
        container.createEmptyMovieClip("mItems", 3);
        container.createTextField("mScale", 4, 0, 0, 1, 1);
        container.mScale.styleSheet = styleSheet;
        container.mScale.multiline = true;
        container.mScale.wordWrap = false;
        container.mScale.html = true;
        container.mScale.selectable = false;
	}
	
    private function onLegendItemVisibilityChanged (e: Object): Void {
        var item: LegendItem = e.item,
            movieClip: MovieClip = item.movieClip;
        
        // Set the out of scale text if the item has gone out of scale:
        if (item.outOfScale) {
            movieClip._zoomToLayer = function() {
                for (var maplayer: String in item.listenTo) {
                    var comp: MovieClip = _global.flamingo.getComponent (maplayer);
                    var layers: Array = item.listenTo[maplayer];
                    comp.moveToLayer(layers.join(','), undefined, 0);
                }
            };
            
            movieClip.mScale.htmlText = "<span class='outofscale'><a href='asfunction:_zoomToLayer'>" + legendContainer.outOfScaleMessage + "</a></span>";
            movieClip.mScale._width = movieClip.mScale.textWidth+5;
            movieClip.mScale._height = movieClip.mScale.textHeight+5;
            
            if (movieClip.chkButton) {
            	movieClip.chkButton.setEnabled (false);
            }
        } else if (movieClip._zoomToLayer){
        	delete movieClip._zoomToLayer;
        	movieClip.mScale.htmlText = '';
        	
        	if (movieClip.chkButton) {
        		movieClip.chkButton.setEnabled (true);
        	}
        }
        
        // Update the checkbox state:
        if (movieClip.chkButton) {
        	movieClip.chkButton.setChecked (item.visible);
        }
        
        // Update the label if stickylabel is enabled for this item:
        var self: Renderer = this;
        if (item.stickyLabel) {
        	item.getItems (function (items: Array): Void {
        		for (var i: Number = 0; i < items.length; ++ i) {
        			if (!(items[i] instanceof SymbolLegendItem)) {
        				continue;
        			}
        			
        			self.drawItemLabel (movieClip, item, item.visible ? "" : items[i].label);
        			item.invalidate ();
        			
        			break;
        		}
        	});
        }
        
        item.invalidate ();
        
        // Gray out symbols if the layer is invisible:
        if (item.isGroupOpen) {
        	item.getItems (function (items: Array): Void {
        		for (var i: Number = 0; i < items.length; ++ i) {
        			if (!(items[i] instanceof SymbolLegendItem)) {
        				continue;
        			}
        			
        			if (!item.visible) {
        				self.grayOut (items[i].movieClip.mSymbol);
        			} else {
        				self.clearSymbol (items[i].movieClip.mSymbol);
        				if (self.legendContainer.shadowSymbols) {
        					self.dropShadow (items[i].movieClip.mSymbol);
        				}
        			}
        		}
        	});
        }
    }
    
	private function drawItemLabel (container: MovieClip, item: LegendItem, label: String): Void {
		
		if (label == undefined) {
			label = item.label;
		}
		
		var styleid: String;
        if (item.infoURL) {
            styleid = item.linkStyleId;
            if (!styleid) {
                styleid = "item_link";
            }
            container.mLabel.htmlText = "<span class='"+styleid+"'><a href=\""+ item.infoURL +"\">" + label + "</a></span>";
        } else {
            styleid = item.styleId;
            if (!styleid) {
                styleid = "item";
            }
            container.mLabel.htmlText = "<span class='"+styleid+"'>" + label + "</span>";
        }
	}
	
    // =========================================================================
    // Ruler:
    // =========================================================================
	public function visitRuler (item: RulerLegendItem, context: Object): Void {
        var parent: MovieClip = context.parent,
            indent: Number = context.indent,
            container: MovieClip = context.container;
            
        container.attachMovie("_hr", "mHr", 0);
	}
	
    // =========================================================================
    // Text:
    // =========================================================================
	public function visitText (item: TextLegendItem, context: Object): Void {
        var parent: MovieClip = context.parent,
            indent: Number = context.indent,
            container: MovieClip = context.container;
            
        container.createTextField("mLabel", 1, 0, 0, 1, 1);
        //mc.mLabel.border = true;
        container.mLabel.styleSheet = styleSheet;
        container.mLabel.wordWrap = true;
        container.mLabel.multiline = true;
        container.mLabel.html = true;
        container.mLabel.selectable = false;
        var styleid: String = item.styleId;
        if (styleid == undefined) {
            styleid = "text";
        }
        
        drawTextLabel (container, item);
	}
	
	private function drawTextLabel (container: MovieClip, item: TextLegendItem): Void {
        var txt: String = item.label;
        /*
        var left: Number = container.getBounds(thisObj)["xMin"];
        var w = this.__width-left-20;
         */
        var styleid: String = item.styleId
        if (!styleid) {
            styleid = "text";
        }
        
        container.mLabel.htmlText = "<span class='"+styleid+"'>"+txt+"</span>";
        container.mLabel._width = container.mLabel.textWidth + 5;
        container.mLabel._height = 100000;
        container.mLabel._height = container.mLabel.textHeight+5;
        container.mLabel._x = 0;
        container.mLabel._y = 0;
	}
	
    // =========================================================================
    // Symbol:
    // =========================================================================
    private var _loadSymbolListener: Object = null;
    
	public function visitSymbol (item: SymbolLegendItem, context: Object): Void {
		
        var parent: MovieClip = context.parent,
            indent: Number = context.indent,
            container: MovieClip = context.container;
            
        if (item.label) {
            container.createTextField("mLabel", 1, 0, 0, 1, 1);
            //mc.mLabel.border = true;
            container.mLabel.styleSheet = styleSheet;
            container.mLabel.wordWrap = false;
            container.mLabel.html = true;
            container.mLabel.multiline = true;
            container.mLabel.selectable = false;
        }
        
        loadSymbol (item, container);
        drawSymbolLabel (item, container);
        
        // The item layout cannot be determined until after the symbol has loaded:
        context.invalidateItem = false;
	}
	
	private function drawSymbolLabel (item: SymbolLegendItem, container: MovieClip): Void {
		var url: String = item.infoURL;
        var label: String = item.label;
        var styleid: String;		
        if (url && url.length>0) {
            styleid = item.symbolLinkStyleId;
            if (styleid == undefined) {
                styleid = "symbol_link";
            }
            container.mLabel.htmlText = "<span class='"+styleid+"'><a href=\""+url+"\">"+label+"</a></span>";
        } else {
            styleid = item.styleId;
            if (styleid == undefined) {
                styleid = "symbol";
            }
            container.mLabel.htmlText = "<span class='"+styleid+"'>"+label+"</span>";
        }
        
        container.mLabel._width = container.mLabel.textWidth+5;
        container.mLabel._height = container.mLabel.textHeight+5;
        container.mLabel._x = 0;
	}
	
	private function loadSymbol (item: SymbolLegendItem, container: MovieClip): Void {
        container.createEmptyMovieClip("mSymbol", 2);
        
        // Create a listener for the symbol loader. The listener is only created once:
        if (!_loadSymbolListener) {
        	
        	var self: Renderer = this;
        	_loadSymbolListener = {
        		onLoadError: function(mc:MovieClip, error:String, httpStatus:Number) {
                },
                onLoadProgress: function(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
                },
                onLoadInit: function(mcsymbol:MovieClip) {
                    var item: SymbolLegendItem = mcsymbol._parent.item;
                    
                    // Copy item attributes to the symbol movieclip:
                    mcsymbol.linkage = item.libLinkage;
                    mcsymbol.id = item.id;
                    mcsymbol.symbol_styleid = item.symbolStyleId;
                    mcsymbol.symbol_link_styleid = item.symbolLinkStyleId;
                    mcsymbol.label = item.label;
                    for (var name: String in item.extraAttributes) {
                    	mcsymbol[name] = item.extraAttributes[name];
                    }
                    
                    if(mcsymbol['linkage'] != null){
                        mcsymbol.attachSymbol (mcsymbol["linkage"],1);
                    }
                    
                    mcsymbol.init();
                    
                    // Invalidate the item, the symbol height is now known:
                    item.invalidate ();
                    
                    // If loading completes after the item became visible for the first time the shadow filter
                    // will be removed and must be added again:
                    if (self.legendContainer.shadowSymbols) {
                    	self.dropShadow (mcsymbol);
                    }
                }
            };
        }
        
        var mcl:MovieClipLoader = new MovieClipLoader();
        mcl.addListener(_loadSymbolListener);
        mcl.loadClip(_global.flamingo.correctUrl(legendContainer.symbolPath + '/' + item.symbolURL), container.mSymbol);
	}
	
	private function grayOut (movieClip: MovieClip): Void {
        var colort: ColorTransform = new ColorTransform();
        colort.rgb = 0xffffff;
        var trans: Transform = new Transform(movieClip);
        trans.colorTransform = colort;
        movieClip._alpha = 20;		
	}
	
	private function clearSymbol (movieClip: MovieClip): Void {
        var colort:ColorTransform = new ColorTransform();
        var trans:Transform = new Transform(movieClip);
        trans.colorTransform = colort;
        movieClip.filters = [];
        movieClip._alpha = 100;
	}
	
	private function dropShadow (movieClip: MovieClip): Void {
        var distance:Number = 2;
        var angleInDegrees:Number = 45;
        var color:Number = 0x333333;
        var alpha:Number = .8;
        var blurX:Number = 3;
        var blurY:Number = 3;
        var strength:Number = 0.8;
        var quality:Number = 3;
        var inner:Boolean = false;
        var knockout:Boolean = false;
        var hideObject:Boolean = false;
        var filter:DropShadowFilter = new DropShadowFilter(distance, angleInDegrees, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
        
        movieClip.filters = [filter];
	}
}
