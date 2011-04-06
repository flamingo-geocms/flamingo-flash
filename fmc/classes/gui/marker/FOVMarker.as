// This file is part of Flamingo MapComponents.
// Author: Roy Braam (B3Partners BV).
import gui.marker.AbstractMarker;
/**
A Field of View marker. Indicates the direction and horizontal view angle for (by example) street view foto's.
*/
class gui.marker.FOVMarker extends AbstractMarker {			
	private var size:Number=20;	
	
	private var directionAngle:Number=null;
	private var viewAngle:Number=null;
	/**
	* Create a fov marker.	*/
	
	public function createMarker(){
		super.createMarker();
		//the direction line for the curve
		var radDirection=directionAngle/180*Math.PI;
		var directionLineX=Math.sin(radDirection)*(size+10);
		var directionLineY=Math.cos(radDirection)*-(size+10);		
		
		//end point line 1(left fov)
		var angleLine1=this.directionAngle-(this.viewAngle/2);
		angleLine1=angleLine1/180*Math.PI;
		var leftLineX=Math.sin(angleLine1)*this.size;
		var leftLineY=Math.cos(angleLine1)*-this.size;
		
		//end point line 2 (right of fov)
		var angleLine2=this.directionAngle+(this.viewAngle/2);
		angleLine2=angleLine2/180*Math.PI;
		var rightLineX=Math.sin(angleLine2)*this.size;
		var rightLineY=Math.cos(angleLine2)*-this.size;
		
		//draw line
		this.mcMarker.lineStyle(1,0xFF0000,100);
		this.mcMarker.beginFill(0xFF0000,70);
		this.mcMarker.moveTo(0,0);
		this.mcMarker.lineTo(leftLineX,leftLineY);
		this.mcMarker.curveTo(directionLineX,directionLineY,rightLineX,rightLineY);				
		this.mcMarker.lineTo(0,0);
	}
	
	/*Getters and setters*/
	
	public function setDirectionAngle(directionAngle:Number){
		this.directionAngle=directionAngle;
	}
	public function getDirectionAngle():Number{
		return this.directionAngle;
	}
	
	public function setViewAngle(viewAngle:Number){
		this.viewAngle=viewAngle;
	}
	public function getViewAngle():Number{
		return this.viewAngle;
	}
	public function setSize(size:Number){
		this.size=size;
	}
	public function getSize():Number{
		return this.size;
	}
}