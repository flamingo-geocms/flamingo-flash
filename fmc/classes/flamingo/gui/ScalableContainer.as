/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import flamingo.gui.*;

import flash.geom.Rectangle;
import mx.controls.UIScrollBar;
import mx.utils.Delegate;

import flamingo.core.AbstractContainer;

class flamingo.gui.ScalableContainer extends AbstractContainer {
    
    private var componentID:String = "ScalableContainer 1.0";
    
    private var scale:Number = 100;
    private var semiscaled:Boolean = false;
    private var horiScrollBar:UIScrollBar = null;
    private var vertiScrollBar:UIScrollBar = null;
    
    function setScale(scale:Number):Void {
    	
        if (this.scale == scale) {
            return;
        }
        
        this.scale = scale;
        setScales();
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
            initObject["_y"] = Math.floor(__height * scale / 100) - 15;
            initObject["horizontal"] = true;
            horiScrollBar = UIScrollBar(border.attachMovie("UIScrollBar", "mHoriScrollBar", 0, initObject));
            horiScrollBar.setSize(Math.floor(__width * scale / 100) - 15, 15);
            horiScrollBar.setScrollProperties(50, 0, __width - Math.floor(__width * scale / 100) - 1 + 15);
            horiScrollBar.addEventListener("scroll", Delegate.create(this, onScrollBar));
            
            initObject = new Object();
            initObject["_x"] = Math.floor(__width * scale / 100) - 15;
            vertiScrollBar = UIScrollBar(border.attachMovie("UIScrollBar", "mVertiScrollBar", 1, initObject));
            vertiScrollBar.setSize(15, Math.floor(__height * scale / 100) - 15);
            vertiScrollBar.setScrollProperties(50, 0, __height - Math.floor(__height * scale / 100) - 1 + 15);
            vertiScrollBar.addEventListener("scroll", Delegate.create(this, onScrollBar));
            
            contentPane.scrollRect = new Rectangle(0, 0, Math.floor(__width * scale / 100), Math.floor(__height * scale / 100));
        } else {
            horiScrollBar.removeMovieClip();
            horiScrollBar = null;
            vertiScrollBar.removeMovieClip();
            vertiScrollBar = null;
            
            contentPane.scrollRect = null;
        }
    }
    
    function onScrollBar(eventObject:Object):Void {
        contentPane.scrollRect = new Rectangle(horiScrollBar.scrollPosition, vertiScrollBar.scrollPosition, Math.floor(__width * scale / 100), Math.floor(__height * scale / 100));
    }
    
}
