import roo.Geometry;
import roo.Envelope;

class roo.Point extends Geometry {
    
    private var x:Number = -1;
    private var y:Number = -1;
    
    function Point(x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
    
    function move(dx:Number, dy:Number):Void {
        x += dx;
        y += dy;
        
        //dispatchEvent(new StateEvent(this, "Geometry", StateEvent.CHANGE, null));
    }
    
    function getEndPoint():Point {
        return this;
    }
    
    function getCenterPoint():Point {
        return new Point(x, y);
    }
    
    function getEnvelope():Envelope {
        return new Envelope(x, y, x, y);
    }
    
    function setXY(x:Number, y:Number):Void {
        this.x = x;
        this.y = y;
        
        //dispatchEvent(new StateEvent(this, "Geometry", StateEvent.CHANGE, null));
    }
    
    function getX():Number {
        return x;
    }
    
    function getY():Number {
        return y;
    }
    
    function toGMLString():String {
        var gmlString:String = "";
        gmlString += "<gml:Point srsName=\"90112\" xmlns:gml=\"http://www.opengis.net/gml\">\n";
        gmlString += "  <gml:coordinates cs=\",\" decimal=\".\" ts=\" \">";
        gmlString += (x + "," + y);
        gmlString += "</gml:coordinates>\n";
        gmlString += "</gml:Point>\n";
        
        return gmlString;
    }
    
    function toString():String {
        return("Point (" + x + ", " + y + ")");
    }
    
}
