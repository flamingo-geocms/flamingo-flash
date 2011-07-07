/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import flash.filters.DropShadowFilter;

import mx.utils.Delegate;
import mx.events.EventDispatcher;

import gui.legend.AbstractLegendItem;
import gui.legend.GroupLegendItem;
import gui.legend.LegendContainer;
import gui.legend.LegendItem;
import gui.legend.RulerLegendItem;
import gui.legend.SymbolLegendItem;
import gui.legend.TextLegendItem;
import gui.legend.LegendVisitor;
import gui.legend.AbstractGroupLegendItem;

/**
 * Events:
 * - onLayoutComplete
 */
class gui.legend.LegendLayout implements LegendVisitor {
	
	private var _legendContainer: LegendContainer;
	private var _width: Number;
	
    public var addEventListener: Function;
    public var removeEventListener: Function;
    public var dispatchEvent: Function;
    
	public function get legendContainer (): LegendContainer {
		return _legendContainer;
	}
	
	public function get width (): Number {
		return _width;
	}
	
	public function set width (width: Number): Void {
		_width = width;
	}
	
	public function LegendLayout (legendContainer: LegendContainer) {
        // Make the legend layout an event dispatcher:
        EventDispatcher.initialize (this);
		
		_legendContainer = legendContainer;
		
        // Register a listener to update legend layout:
        legendContainer.addEventListener ('onInvalidateLegend', Delegate.create (this, onInvalidateLegend));
        
        // Force the root elements to be loaded so that the layout manager will position them (if they haven't already):
        legendContainer.fetchItems ();
	}
	
    private function onInvalidateLegend (e: Object): Void {
        _global.setTimeout (Delegate.create (this, updateLayout), 100);
    }
    
    private function updateLayout (continuation: Function): Void {
        if (legendContainer.invalid) {
            layoutItem (legendContainer, 0, 0);
            this.dispatchEvent ({ type: 'onLayoutComplete' });
        }
    }
    
    private function layoutItem (item: AbstractLegendItem, x: Number, y: Number): Void {

        // Make the item visible: 
        item.movieClip._visible = true;
        
        // Accumulate the total height of all (visible) children of this item:
        var childrenHeight: Number = 0;
             
        // Update and position the children if this is a group item and if the group is open:
        if (item instanceof AbstractGroupLegendItem && AbstractGroupLegendItem (item).isGroupOpen) {
        	var children: Array = AbstractGroupLegendItem (item).getItems () || [ ];
        	
            var childX: Number = 0,
                childY: Number = 0,
                labelMin: Number = 9999,
                labelMax: Number = 0,
                i: Number;
                
            for (i = 0; i < children.length; ++ i) {
                var child: AbstractLegendItem = children[i];
                
                if (child.invalid) {
                	layoutItem (child, childX, childY);
                }
                
                child.movieClip._y = childY;
                
                var height: Number = child.movieClip.mItems._visible ? child.movieClip.totalHeight : child.movieClip.itemHeight;
                childY += height;
                childrenHeight += height;
                
                if (child.movieClip.padding) {
                    child.movieClip._y += child.movieClip.padding;
                    childY += child.movieClip.padding; 
                }
                
                if (child.movieClip.mLabel) {
                	labelMin = Math.min (labelMin, child.movieClip.mLabel._x);
                	labelMax = Math.max (labelMax, child.movieClip.mLabel._x);
                }
            }
            
            // Align all labels in this group:
            if (labelMax > labelMin) {
            	for (i = 0; i < children.length; ++ i) {
            		var child: AbstractLegendItem = children[i];
            		if (child.movieClip.mLabel) {
            			child.movieClip.mLabel._x = labelMax;
            		}
            	}
            }
        }
        
        item.visit (this, {
            x: x,
            y: y
        });
        
        item.movieClip.totalHeight = item.movieClip.itemHeight + childrenHeight;
        
        item.validate ();
    }
    
    public function visitContainer (item: LegendContainer, context: Object): Void {
        var movieClip: MovieClip = item.movieClip;
        
        movieClip._x = context.x + item.dx;
        movieClip.padding = 0;
        movieClip.itemHeight = 0;
    }
    
    public function visitGroup (item: GroupLegendItem, context: Object): Void {
    	var movieClip: MovieClip = item.movieClip;
    	
        movieClip._x = context.x + item.dx + legendContainer.defaultDelta['group'][0];
        movieClip.padding = item.dy += legendContainer.defaultDelta['group'][1];
        
    	// Position the header:
    	movieClip.mHeader._x = 0;
    	movieClip.mHeader._y = 0;

        // Position the label:
        if (movieClip.mHeader.mLabel) {
            var left: Number = movieClip.mHeader.getBounds(legendContainer.movieClip)["xMin"];
            var w: Number = width - left - 20;
            
        	movieClip.mHeader.mLabel._height = 200; 
        	movieClip.mHeader.mLabel._width = w - movieClip.mHeader.skin._width;
        	// movieClip.mHeader.mLabel._width = movieClip.mHeader.mLabel.textWidth + 5;
        	movieClip.mHeader.mLabel._height = movieClip.mHeader.mLabel.textHeight + 5;
        }
            
    	// Position the clip containing the children:
    	if (item.collapsed) {
    		movieClip.mItems._visible = false;
    	} else {
    		movieClip.mItems._visible = true;
        	movieClip.mItems._x = movieClip.mHeader.skin._width;
        	movieClip.mItems._y = movieClip.mHeader._y + movieClip.mHeader._height;
    	}
    	
    	movieClip.itemHeight = movieClip.mHeader._y + movieClip.mHeader._height;
    }
    
    
    public function visitItem (item: LegendItem, context: Object): Void {
        var movieClip: MovieClip = item.movieClip;
        
        movieClip._x = context.x + item.dx + legendContainer.defaultDelta['item'][0];
        movieClip.padding = item.dy += legendContainer.defaultDelta['item'][1];

        var height: Number = 0,
            x: Number = 0;
            	
    	if (movieClip.mCheck) {
    		x = movieClip.mCheck._width;
    	}
    	
    	if (movieClip.mLabel) {
            movieClip.mLabel._x = movieClip.mCheck ? movieClip.mCheck._x + movieClip.mCheck._width : 0;
            movieClip.mLabel._y = 0;
            movieClip.mLabel._width = movieClip.mLabel.textWidth + 5;
            movieClip.mLabel._height = movieClip.mLabel.textHeight + 5;
            height = movieClip.mLabel._height;
    	}
    	
    	if (item.visible && !item.outOfScale) {
       		movieClip.mItems._x = x;
       		movieClip.mItems._y = height;
       		movieClip.mItems._visible = true;
    	} else {
    		movieClip.mItems._visible = false;
    	}
    	
    	if (item.outOfScale) {
    		movieClip.mScale._x = x;
    		movieClip.mScale._y = height;
    		movieClip.mScale._visible = true;
    		height += movieClip.mScale._height;
    	} else {
    		movieClip.mScale._visible = false;
    	}
    	
    	movieClip.itemHeight = height;
    }
    
    public function visitSymbol (item: SymbolLegendItem, context: Object): Void {
        var movieClip: MovieClip = item.movieClip;
        
        movieClip._x = context.x + item.dx + legendContainer.defaultDelta['symbol'][0];
        movieClip.padding = item.dy += legendContainer.defaultDelta['symbol'][1];
    	
    	movieClip.itemHeight = movieClip.mSymbol._height;//movieClip._height;
    	
    	movieClip.mLabel._x = movieClip.mSymbol._x + movieClip.mSymbol._width;
        movieClip.mSymbol._y = Math.max(0, ((movieClip.mLabel._height/2)-(movieClip.mSymbol._height/2)));
        movieClip.mLabel._y = Math.max(0, ((movieClip.mSymbol._y+movieClip.mSymbol._height/2)-(movieClip.mLabel._height/2)));
    }
    
    public function visitText (item: TextLegendItem, context: Object): Void {
        var movieClip: MovieClip = item.movieClip;
        
        movieClip._x = context.x + item.dx + legendContainer.defaultDelta['text'][0];
        movieClip.padding = item.dy += legendContainer.defaultDelta['text'][1];
    	
    	movieClip.itemHeight = movieClip._height;
    }
    
    public function visitRuler (item: RulerLegendItem, context: Object): Void {
        var movieClip: MovieClip = item.movieClip;
        
        movieClip._x = context.x + item.dx + legendContainer.defaultDelta['hr'][0];
        movieClip.padding = item.dy += legendContainer.defaultDelta['hr'][1];
        
        movieClip.itemHeight = movieClip._height;
    }
}
