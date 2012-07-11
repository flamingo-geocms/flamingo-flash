/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
* Changes by author: Maurits Kelder, B3partners bv
 -----------------------------------------------------------------------------*/
import geometrymodel.*;

import tools.XMLTools;
import tools.Utils;
import tools.Logger;
/**
 * geometrymodel.GeometryTools
 */
class geometrymodel.GeometryTools {
    /**
     * getGeometryClass
     * @param	geometryType
     * @return
     */
    static function getGeometryClass(geometryType:String):Function {
        if (geometryType == "Point") {
            return Point;
        } else if (geometryType == "PointAtDistance") {
            return LineString;
        } else if (geometryType == "LineString") {
            return LineString;
        } else if (geometryType == "Polygon") {
            return Polygon;
        } else if (geometryType == "Circle") {
            return Circle;
        } else if (geometryType == "MultiPolygon") {
            return MultiPolygon;
        }        
        _global.flamingo.tracer("Exception in geometrymodel.GeometryTools.getGeometryClass(" + geometryType + ")");
        return null;
    }
    /**
     * getEnvelopeFromGeometryNode
     * @param	geometryNode
     * @return
     */
    static function getEnvelopeFromGeometryNode(geometryNode:XMLNode):Envelope {
		var minX:Number;
    	var maxX:Number;
    	var minY:Number;
    	var maxY:Number;
    	var coords:Array;
    	var preFix:String = geometryNode.getPrefixForNamespace("http://www.opengis.net/gml");
		var coordNodes:Array = XMLTools.getElementsByTagName(preFix +":posList", geometryNode);
		if (coordNodes != null && coordNodes.length > 0) {
			for(var i:Number = 0;i<coordNodes.length;i++){
				var coordsStr:String =  Utils.trim(XMLNode(coordNodes[i]).firstChild.nodeValue)
				coords = coordsStr.split(" ");
				if(i==0){
					minX = coords[0];
					minY = coords[1];
					maxX = minX;
					maxY = minY;
				} 
				for(var j:Number = 2;j<coords.length;j++){
					//even coords ==> X coordinates
					if(((j & 1) == 0)){
						if(coords[j] > maxX){
							maxX = 	coords[j];
						} 
						if(coords[j] < minX){
							minX = coords[j];
						}
					} else {
						if(coords[j] > maxY){
							maxY = 	coords[j];
						} 
						if(coords[j] < minY){
							minY = coords[j];
						}
					
					}
				}
			}
		}else {
			//if the nodes are coordinates.
			coordNodes = XMLTools.getElementsByTagName(preFix +":coordinates", geometryNode);			
			if (coordNodes != null && coordNodes.length > 0) {			
				for(var i:Number = 0;i<coordNodes.length;i++){
					var coordsStr:String =  Utils.trim(XMLNode(coordNodes[i]).firstChild.nodeValue);
					coords = coordsStr.split(" ");
					if (i == 0) {
						var firstCoord:Array = coords[0].split(",");
						minX = firstCoord[0];
						minY = firstCoord[1];
						maxX = minX;
						maxY = minY;
					} 
					for(var j:Number = 0;j<coords.length;j++){
						//even coords ==> X coordinates
						var coord:Array = coords[j].split(",");
						var x = Number(coord[0]);
						var y = Number(coord[1]);
						if(x > maxX){
							maxX = 	x;
						} 
						if(x < minX){
							minX = x;
						}
						if(y > maxY){
							maxY = 	y;
						} 
						if(y < minY){
							minY = y;
						}
					}
				}				
			}else {				
				coordNodes = XMLTools.getElementsByTagName(preFix +":pos", geometryNode);
				var coordsStr:String =  Utils.trim(XMLNode(coordNodes[0]).firstChild.nodeValue);
				coords = coordsStr.split(" ");
				minX = maxX = Number(coords[0]);
				minY = maxY = Number(coords[1]);
			}
		}		
    	return new Envelope(minX,minY,maxX,maxY);
    }
    
}
