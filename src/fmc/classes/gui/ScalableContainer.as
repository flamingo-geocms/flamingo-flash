/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import gui.*;

import flash.geom.Rectangle;
import mx.controls.UIScrollBar;
import mx.utils.Delegate;

import core.AbstractContainer;

class gui.ScalableContainer extends AbstractContainer {
    
    private var componentID:String = "ScalableContainer 1.0";
    
    private var scale:Number = 100;
    private var semiscaled:Boolean = false;
    private var horiScrollBar:UIScrollBar = null;
    private var vertiScrollBar:UIScrollBar = null;
    private var scrollWidth:Number = 0;
    private var scrollHeight:Number = 0;
    
    function setScale(scale:Number):Void {
    	
        if (this.scale == scale) {
            return;
        }
        
        this.scale = scale;
        setScales();
    }
    
    function setScrollWidth(width:Number):Void {
        scrollWidth = width;
    }
    
    function setScrollHeight(height:Number):Void {
        scrollHeight = height;
    }
    
    function getScale():Number {
        return scale;
    }
    
    function setSemiscaled(semiscaled:Boolean):Void {
        if (this.semiscaled == semiscaled) {
            return;
        }
        
        this.semiscaled = semiscaled;
        setScales();
    }
    
    function isSemiscaled():Boolean {
        return semiscaled;
    }
    
    private function setScales():Void {
        if (semiscaled) {
            background._xscale = 100;
            background._yscale = 100;
            contentPane._xscale = 100;
            contentPane._yscale = 100;
            border._xscale = 100;
            border._yscale = 100;
        } else {
            background._xscale = scale;
            background._yscale = scale;
            contentPane._xscale = scale;
            contentPane._yscale = scale;
            border._xscale = scale;
            border._yscale = scale;
        }
        
        if ((scale < 100) && (semiscaled)) {
            var initObject:Object = new Object();
            initObject["_y"] = scrollHeight - 15;
            initObject["horizontal"] = true;
            horiScrollBar = UIScrollBar(border.attachMovie("UIScrollBar", "mHoriScrollBar", 0, initObject));
            horiScrollBar.setSize(scrollWidth - 15, 15);
            horiScrollBar.setScrollProperties(scrollWidth - 15, 0, __width);
            horiScrollBar.addEventListener("scroll", Delegate.create(this, onScrollBar));
            
            initObject = new Object();
            initObject["_x"] = scrollWidth - 15;
            vertiScrollBar = UIScrollBar(border.attachMovie("UIScrollBar", "mVertiScrollBar", 1, initObject));
            vertiScrollBar.setSize(15, scrollHeight - 15);
            vertiScrollBar.setScrollProperties(scrollHeight - 15, 0, __height);
            vertiScrollBar.addEventListener("scroll", Delegate.create(this, onScrollBar));
            
            contentPane.scrollRect = new Rectangle(0, 0, scrollWidth - 15, scrollHeight - 15);
        } else {
            horiScrollBar.removeMovieClip();
            horiScrollBar = null;
            vertiScrollBar.removeMovieClip();
            vertiScrollBar = null;
            
            contentPane.scrollRect = null;
        }
    }
    
    function onScrollBar(eventObject:Object):Void {
        contentPane.scrollRect = new Rectangle(horiScrollBar.scrollPosition, vertiScrollBar.scrollPosition, scrollWidth - 15, scrollHeight - 15);
    }
    
}
