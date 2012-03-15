import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
/**
 * display.spriteloader.BitmapUtils
 */
class display.spriteloader.BitmapUtils
{
	/**
	 * BitmapUtils can be used by calling it's static functions, no need for a new instance
	 */
	public function BitmapUtils() 
	{
		trace('BitmapUtils can be used by calling it\'s static functions, no need for a new instance')
	}	
		
	/**
	 * bitmapDataToMovieClip
	 * @param	bmpData
	 * @param	attachTarget
	 * @param	newMcName
	 * @param	newDepth
	 * @return
	 */	
	public static function bitmapDataToMovieClip(bmpData:BitmapData, attachTarget:MovieClip, newMcName:String, newDepth:Number):MovieClip
	{
		var depth:Number =(newDepth==undefined) ? attachTarget.getNextHighestDepth() : newDepth;
		if(bmpData==undefined){
			trace("BitmapUtils::bitmapDataToMovieClip():BitmapData undefined ("+newMcName+") ")
			return null;
		}
		var newMC:MovieClip=attachTarget.createEmptyMovieClip(newMcName,depth)
		attachTarget[newMcName].attachBitmap(bmpData, attachTarget[newMcName].getNextHighestDepth());
		return newMC;
	}
    /**
     * movieClipToBitmapData
     * @param	srcMC
     * @return
     */
	public static function movieClipToBitmapData(srcMC:MovieClip):BitmapData
	{
		var converted_bd:BitmapData=new BitmapData(srcMC._width,srcMC._height,true, 0x00000000);
		converted_bd.draw(srcMC, new Matrix(), new ColorTransform(), null, null, false);
		return converted_bd;
	}
	


	
	
}