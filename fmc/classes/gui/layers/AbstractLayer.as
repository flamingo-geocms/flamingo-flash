import core.AbstractComponent;
import tools.Logger;
import tools.Utils;

import flash.filters.ColorMatrixFilter;

class gui.layers.AbstractLayer extends core.AbstractComponent{  
    private var log:Logger = null;
    /*statics*/
    private static var SERVICEURL_ATTRNAME:String="serviceurl";
    private static var ID_ATTRNAME:String="id";
    private static var MINSCALE_ATTRNAME:String="minscale";
    private static var MAXSCALE_ATTRNAME:String="maxscale";
    private static var ALPHA_ATTRNAME:String="alpha";
    private static var GRAYSCALE_ATTRNAME:String="grayscale";
    private static var SHOWMAPTIPS_ATTRNAME:String="showmaptips";
    /*attributes*/
    private var map:Object = null;
    private var serviceUrl:String=null;
    private var minScale:Number=null;
    private var maxScale:Number=null;
    private var id:String = null;   
    private var grayscale:Boolean = false;
    
    /**
    Initialize the AbstractLayer.
    */
    function init():Void {                              
        map=getParent(null);
        if (map==undefined){
            log.critical("Can't find the parent Map component.");
        }
        if (serviceUrl==null){
            log.critical("Attribute "+SERVICEURL_ATTRNAME+" is mandatory");
        }
        setMap(map);
        map.mLayers.createEmptyMovieClip(id, map.getNextDepth());
        initLayer();
    }
    
    function setAttribute(name:String, value:String):Void {
        var lowerName=name.toLowerCase();
        if (lowerName==SERVICEURL_ATTRNAME){
            this.serviceUrl=value;
        }else if(lowerName==ID_ATTRNAME){
            this.id=value;
        }else if(lowerName==MINSCALE_ATTRNAME){
            this.setMinScale(Number(value));            
        }else if(lowerName==MAXSCALE_ATTRNAME){
            this.setMaxScale(Number(value));
        }else if(lowerName==ALPHA_ATTRNAME){
            this._alpha = Number(value); 
         }else if(lowerName==GRAYSCALE_ATTRNAME){
            if (value.toLowerCase() == "true") {
                this.grayscale = true;
            }
            else {
                this.grayscale = false;
            }
        }else{
            if(!setLayerAttribute(name,value)){
                log.warn("Attribute with name: "+name+" is not available for this component");
            }
        }
    }
        
    /*
    Getters and setters:
    */
    /**
    Set the map
    */
    function setMap(m:Object){
        map=m;      
        _global.flamingo.addListener(this, map, this);
    }
    /**
    Get the map that is defined by the listenTo
    */
    function getMap():Object{
        return map;
    }
    
    function setMaxScale(maxScale:Number){
        this.maxScale=maxScale;
        if (isNaN(this.maxScale)){
            this.maxScale=null;
        }
    }
    function getMaxScale():Number{
        return this.maxScale;
    }
    
    function setMinScale(minScale:Number){
        this.minScale=minScale;
        if (isNaN(this.minScale)){
            this.minScale=null;
        }
    }
    function getMinScale():Number{
        return this.minScale;
    }
    
    function setId(id:String){
        this.id=id;
    }
    function getId():Object{
        return this.id;
    }
    
    function setVisible(visible){
        //log.debug("visible = " + visible + " setVisible,caller = " + Utils.getFunctionName(arguments.caller));
        this.visible = visible;
        this._visible = visible;
        this.update(map);
    }

    function getVisible(){
        return this.visible;
    }
    
    function isWithinScaleRange():Boolean {
        var extent = map.getMapExtent();        
        var ms:Number = map.getScaleHint(extent);
        //_global.flamingo.tracer("ms = " + ms + " this.minScale = " + this.minScale + " this.maxScale = " + this.maxScale);    
        if ((this.minScale == undefined || this.minScale <= ms) && (this.maxScale == undefined || this.maxScale >= ms )) {
            return true;
        }
        else {
            return false;
        }
    }
    
    /**
    * Sets the transparency of a layer.
    * @param alpha:Number A number between 0 and 100, 0=transparent, 100=opaque
    */
    function setAlpha(alpha:Number) {
        this._alpha = alpha;
        _global.flamingo.raiseEvent(this, "onSetValue", "setAlpha", alpha); 
    }
    
    function getAlpha(): Number {
    	return this._alpha;
    }
    
    /**
    * Sets the grayscale property of a layer.
    * @param grayscale:Boolean when true the layer will be shown in gray
    */
    function setGrayscale(grayscale:Boolean) {
        this.grayscale = grayscale;
        this.update();
    }
    
    function getGrayscale(): Boolean {
    	return this.grayscale;
    }
    
    function applyGrayscale(mc:MovieClip):Void{
        var myElements_array:Array = [0.3, 0.59, 0.11, 0, 0,
                                0.3, 0.59, 0.11, 0, 0,
                                0.3, 0.59, 0.11, 0, 0,
                                0, 0, 0, 1, 0];
        var myColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(myElements_array);
        mc.filters = [myColorMatrix_filter];
    }
    
        
    /*
    Functions that will be called by the map (listento.
    */
    function onUpdate(map:MovieClip):Void{      
    
        update(map);
        
    }
    function onChangeExtent(map:MovieClip):Void{
        changeExtent(map);
    }
    function onIdentify(map:MovieClip, identifyextent:Object):Void  {
        identify(identifyextent);
    }
    function onIdentifyCancel(map:MovieClip):Void  {
        cancelIdentify();
    }
    function onMaptip(map:MovieClip, x:Number, y:Number, coord:Object):Void  {
        startMaptip(x, y);
    }
    function onMaptipCancel(map:MovieClip):Void  {
        stopMaptip();
    }
    function onHide(map:MovieClip):Void  {
        doHide();
    }
    function onShow(map:MovieClip):Void  {
        // doShow();
    }

    
    /**
    Must be overwritten in class that's extending this class.
    */
    /*initLayer is called the layer can be initialized.*/
    function initLayer():Void{}

    /*Called when a 'onUpdate' event occured in the map object
    * Update is called when the layer needs to be updated*/
    function update(map):Void{}
    
    /*Called on the 'onChangeExtent' event from the map.
    change extent is called when the map zooms animated to the wished extent. With every stap this function is called*/
    function changeExtent():Void{}
    /*identify is called when the onIdentify event occured on the map*/
    function identify(identifyextent:Object):Void{}
    function cancelIdentify():Void{}
    function stopMaptip() {}
    function startMaptip(x:Number, y:Number) {}
    function doHide():Void{}
    function doShow():Void{}
    function setLayerAttribute(name:String, value:String):Boolean{return false;}
}