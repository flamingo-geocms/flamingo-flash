import coregui.GradientButton;


class gui.LayerSwitch extends GradientButton {    
    private var layers1:Array = null;
    private var layers2:Array = null;
    private var layerNames1:String = null;
    private var layerNames2:String = null;
    private var label1Text:String = null;
    private var label2Text:String = null;

   	private var next : Number = 1;

	var intervalID : Number;

	function init(){
		super.init();
        _global.flamingo.addListener(this, "flamingo", this);
		 for (var i:Number = 0; i < listento.length; i++) {
			 var comp:Object  = _global.flamingo.getComponent(listento[i]);
	         _global.flamingo.addListener(this, comp, this);
        }
		label1Text = _global.flamingo.getString(this,"label1");
        label2Text = _global.flamingo.getString(this,"label2");
        buttonLabel.text = label1Text;
		changeVisibility();
		next = 2;
	}
    
    
    function setAttribute(name:String, value:String):Void {
        if (name == "layers1") {
        	layerNames1 = value;
        }
        if (name == "layers2") {
        	layerNames2 = value;
        }
    }
    
 
    function onPress():Void{
    	changeVisibility();	
    	if(next == 1){
			next = 2;
		} else {
			next = 1;
		}	
    }
        
    private function draw(){
    	if (disabled) {
    		buttonLabel.setStyle("color","0xbbbbbb");
    		gradientDisabled.draw(this);
    	} else {
    		gradient1.draw(this);
    		buttonLabel.setStyle("color","0x666666");
    		if(next==1){
    			buttonLabel.text = label2Text;
    		} else {
    			buttonLabel.text = label1Text;
    		}
    	} 
    	
    }
    
    function swizch():Void {
		if (isAllOutOfScale(layers1) || isAllOutOfScale(layers2)){
			disabled = true;
		} else {
			disabled = false;	
		}
		draw();
    }
    
    function changeVisibility(){
        disabled = true;
        if (layers1 == null) {
        	layers1 = createLayers(layerNames1);
		}
        if (layers2 == null) {
        	layers2 = createLayers(layerNames2);
        }
		if(next == 1){
        	for (var i:Number=0;i<layers1.length;i++) {
        		setLayerVisibility(layers1[i],true, isAllOutOfScale(layers2));	
        	}
        	for (var i:Number=0;i<layers2.length;i++)  {
        		setLayerVisibility(layers2[i], false, isAllOutOfScale(layers1));
        	}
		} else {
			for (var i:Number=0;i<layers1.length;i++) {
        		setLayerVisibility(layers1[i],false, isAllOutOfScale(layers2));			
        	}
        	for (var i:Number=0;i<layers2.length;i++) {
        		setLayerVisibility(layers2[i], true, isAllOutOfScale(layers1));
        	}
    	}	
    	draw();	
    		
    }
    
    private function createLayers(layerNames:String):Array {
    	var lyrs:Array = layerNames.split(",");
    	var layers:Array = new Array();
    	for (var i:Number = 0; i < lyrs.length; i++) {
    		var lyr:Object = new Object();
    		if(lyrs[i].indexOf(".")>0){
    			var lyrstr:String = lyrs[i].substr(0,lyrs[i].indexOf("."));
    			var sublyr:String = lyrs[i].substr(lyrs[i].indexOf(".")+1);
    			if(layerNotYetIn(layers,lyrstr)){
    				var sublyrs:Array = new Array();
    				sublyrs.push(sublyr);
    				lyr.id = lyrstr;
    				lyr.sublyrs = sublyrs;
    				layers.push(lyr);
    			} else {
    				findLayer(layers,lyrstr).sublyrs.push(sublyr);
    			}	
    		} else {
    			//no sublayers
    			lyr.id = lyrs[i];
    			layers[lyrs[i]] = lyr;
    		}
    	}	
    	return layers;
    }
    
    private function layerNotYetIn(layers : Array, lyrStr : String) : Boolean {
		var notYetIn:Boolean = true;
		for (var j:Number = 0; j < layers.length; j++) {
			if(layers[j].id == lyrStr){
			 	notYetIn = false;
			}
		}
		return notYetIn;
	}
	
	private function findLayer(layers:Array, lyrStr : String):Object{
		for (var j:Number = 0; j < layers.length; j++) {
		 	if(layers[j].id == lyrStr){
			 	return layers[j];
		 	}
		} 
		return null;
	}
    
    private function setLayerVisibility(layer:Object,visible:Boolean,othersOutOfScale:Boolean):Void {
        var setVis:Boolean;
        if (visible || othersOutOfScale) {
        	setVis = true;
        } else if (!visible && !othersOutOfScale) {
          	setVis = false;
        }             
    	var comp:Object = _global.flamingo.getComponent(layer.id); 
    	//_global.flamingo.tracer("setLayerVisibility " + visible + " layer.id= " + layer.id + " comp = " + comp + " sublyrs " + layer.sublyrs.length);
    	if(layer.sublyrs != null){   		
			for (var sublyr:String in layer.sublyrs) {
				comp.setVisible(setVis,layer.sublyrs[sublyr]); 	
			}
    	} else {
    		comp.setVisible(setVis);
   		}
   		_global.setTimeout(updateLayers(), 1000);
    }
    
    function updateLayers(){
		for (var j:Number = 0; j < layers1.length; j++) { 
			_global.flamingo.getComponent(layers1[j].id).update();
		}	
		for (var j:Number = 0; j < layers2.length; j++) {
			_global.flamingo.getComponent(layers2[j].id).update();
		}
    }
    
    private function isAllOutOfScale(layers:Array):Boolean {
		if(layers.length == 0){
			return false;
		}
		var allOutOfScale:Boolean = true;
    	for (var j:Number = 0; j < layers.length; j++) {
    		var comp:Object = _global.flamingo.getComponent(layers[j].id ); 
			if(layers[j].sublyrs != null){
				for (var sublyr:String in layers[j].sublyrs) {
					if (Math.abs(comp.getVisible(layers[j].sublyrs[sublyr])) != 2) {
    					allOutOfScale = false;
					}	
				}
				
			} else if (Math.abs(comp.getVisible()) != 2) {
    			allOutOfScale = false;
    		}
    	}
    	return allOutOfScale;
    }

    
	function onUpdateComplete(layer:MovieClip, updateTime:Number):Void {
        //_global.flamingo.tracer("LayerSwitch on UpdateComplete " + layer);
        swizch();
    }
}
