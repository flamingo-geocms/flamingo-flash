import core.AbstractComponent;

/**
 * @author velsll
 */
class pzh.createImage.CombineImageConnector extends AbstractComponent {
	private var serviceUrl:String = "http://localhost:8080/CombineImages/CombineImages";
	private var imageUrls:String = "";
	private var mapHeight:Number = 0;
	private var mapWidth:Number = 0;
	private var screenHeight:Number = 0;
	private var screenWidth:Number = 0;
	private var wktGeometry:String;
	private var bbox:String = "";
	private var mimeType:String = "image/png";
	private var htmloutput="imageurl=[IMAGESOURCE]";
	private var map:Object;
	private var editMap:Object;
	private var urls:Object;

	function init(){
		_global.flamingo.addListener(this,"map",this);
		urls = new Object();
		var lyrs:Array = map.getLayers();
       	for (var i = 0; i<lyrs.length; i++){
       		_global.flamingo.addListener(this,lyrs[i],this);
       	}
		
		
	}

//urls=http://geo-portaal2.zuid-holland.nl/arcgis/services/Ondergrond_standaard/MapServer/WMSServer?service=WMS&REQUEST=GetMap&TRANSPARANT=false&STYLES=&TRANSPARENT=TRUE&SRS=EPSG:28992&VERSION=1.1.1&EXCEPTIONS=application/vnd.ogc.se_xml&LAYERS=2,3,4,5,6,7,8,9,10,12,13,14,15,17,18,19,20,22,23,24,26,27,28,30,31,32,44,49,54,58,62,66&FORMAT=image/png&HEIGHT=593&WIDTH=1310&BBOX=90170.514043502,475113.402728126,96386.861422884,477927.367610549&alpha=1&screenX=1&screenY=1&screenWidth=6216.347379382001&screenHeight=2813.9648824229953;http://afnemers.ruimtelijkeplannen.nl/geowebcache/service/wms?LAYERS=bp_svbp_all&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image/png&INFO_FORMAT=application/vnd.ogc.gml&STYLES=&SRS=EPSG:28992&WIDTH=512&HEIGHT=512&BBOX=93068.4799999999,476762.56,96509.1199999999,480203.2&alpha=1&screenX=611&screenY=-480&screenWidth=725&screenHeight=725;http://afnemers.ruimtelijkeplannen.nl/geowebcache/service/wms?LAYERS=bp_svbp_all&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image/png&INFO_FORMAT=application/vnd.ogc.gml&STYLES=&SRS=EPSG:28992&WIDTH=512&HEIGHT=512&BBOX=93068.4799999999,473321.92,96509.1199999999,476762.56&alpha=1&screenX=611&screenY=245&screenWidth=725&screenHeight=726;http://afnemers.ruimtelijkeplannen.nl/geowebcache/service/wms?LAYERS=bp_svbp_all&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image/png&INFO_FORMAT=application/vnd.ogc.gml&STYLES=&SRS=EPSG:28992&WIDTH=512&HEIGHT=512&BBOX=89627.84,476762.56,93068.48,480203.2&alpha=1&screenX=-114&screenY=-480&screenWidth=725&screenHeight=725;http://afnemers.ruimtelijkeplannen.nl/geowebcache/service/wms?LAYERS=bp_svbp_all&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image/png&INFO_FORMAT=application/vnd.ogc.gml&STYLES=&SRS=EPSG:28992&WIDTH=512&HEIGHT=512&BBOX=89627.84,473321.92,93068.48,476762.56&alpha=1&screenX=-114&screenY=245&screenWidth=725&screenHeight=726&height=593&width=1310&wkts=&bbox=90170.514043502,475113.402728126,96386.861422884,477927.367610549&mimetype=image/jpeg&htmloutput=
//urls=http://geo-portaal2.zuid-holland.nl/arcgis/services/Ondergrond_standaard/MapServer/WMSServer?service=WMS&REQUEST=GetMap&TRANSPARANT=false&STYLES=&TRANSPARENT=TRUE&SRS=EPSG:28992&VERSION=1.1.1&EXCEPTIONS=application/vnd.ogc.se_xml&LAYERS=2,3,4,5,6,7,8,9,10,12,13,14,15,17,18,19,20,22,23,24,26,27,28,30,31,32,44,49,54,58,62,66&FORMAT=image/png&HEIGHT=592&WIDTH=1282&BBOX=-6032.77406976164,400027.816498207,188344.774069762,489787.183501793&alpha=NaN&screenX=1&screenY=1&screenWidth=1282&screenHeight=592
	public function export() {
		 var curExtent:Object = map.getCurrentExtent();
		 mapWidth = curExtent.maxx-curExtent.minx;  
		 mapHeight= curExtent.maxy-curExtent.miny;  
		 bbox = curExtent.minx + "," + curExtent.miny + "," + curExtent.maxx + "," + curExtent.maxy;    
		 var imageHeight:Number = map.getMovieClipHeight();
		 var imageWidth:Number = map.getMovieClipWidth();
		 var urlString="";
		 var tempUrls = new Array();
		 for (var i in urls){
			var lyri:Object = _global.flamingo.getComponent(i);
			var alpha = lyri.getAlpha();
			if (urls[i] && urls[i].length> 0){
				var u = ""; 
				//is het een tiling layer met meerdere urls?
				if(urls[i][0].url && urls[i][0].url.length > 0){
					for (var j = 0; j<urls[i].length; j++){
						var screenX = urls[i][j].screenX;
						var screenY = urls[i][j].screenY;
						screenWidth = urls[i][j].screenWidth;
						screenHeight = urls[i][j].screenHeight;
						var atrString = "alpha=" + alpha/100 + "&screenX=" + screenX + "&screenY=" + screenY + "&screenWidth=" + screenWidth+ "&screenHeight=" + screenHeight;
						if(urls[i][j].url.indexOf("?")>-1){
							tempUrls.push(urls[i][j].url + atrString);
						} else {
							tempUrls.push(urls[i][j].url + "?" + atrString);
						}
					}		
				} else {	
					if(urls[i].indexOf("?")>-1){
						tempUrls.push(urls[i] + "&alpha=" + alpha/100 + "&screenX=1&screenY=1&screenWidth=" + imageWidth+ "&screenHeight=" + imageHeight);
					} else {
					  tempUrls.push(urls[i] + "?alpha=" + alpha/100 + "&screenX=1&screenY=1&screenWidth=" + imageWidth+ "&screenHeight=" + imageHeight);
					}   
				}
			}
		}
		imageUrls = tempUrls.reverse().join(";");
		
		var features:Array = editMap.getAllFeaturesAsObject();
		var wktString:String = "";
		for (var i=0; i < features.length; i++){
			wktString+=features[i].wktgeom;
			wktString+="#00BBBB";
			if (features[i].label && features[i].label.length>0){
				wktString+="|"+features[i].label;
			}		
			wktString+=";";
		}
		var thisObj:Object = this;
		var response_lv:LoadVars = new LoadVars();
     	response_lv.onLoad = function(successful:Boolean):Void {
     		response_lv.decode(response_lv.toString());   	
     		thisObj.getURL(response_lv.imageurl,"_blank");
     	};
     	var send_lv:LoadVars = new LoadVars();
    	send_lv.urls = imageUrls;	
    	send_lv.wkts = wktString;
    	send_lv.height = imageHeight;
    	send_lv.width = imageWidth;
    	send_lv.bbox = bbox;
    	send_lv.mimetype = mimeType;
    	send_lv.htmloutput = htmloutput;
    	send_lv.sendAndLoad(serviceUrl, response_lv);
	}
	

	
	public function onResponse(eventObject:Object,eventType:String, connector:Object):Void{
		if(connector.requesttype=="GetMap"){
			urls[_global.flamingo.getId(eventObject)]=connector.url ;
		}	
		if(connector.requesttype=="getImage"){
		  if(connector.esriArcServerVersion!=null){
		  		urls[_global.flamingo.getId(eventObject)] = getParameter(connector.response,"","<ImageURL>","</ImageURL>");
	    	} else {    
	    		urls[_global.flamingo.getId(eventObject)]= getParameter(connector.response,"url","=\"","\"");    
			}
		}
	}
	
	
	public function onUpdateComplete(eventObject:Object):Void{
		var objId:String = _global.flamingo.getId(eventObject);
		if(objId=="map"){
       		var lyrs:Array = eventObject.getLayers();
	      	for (var i = 0; i<lyrs.length; i++){
	      		var lyr:Object = _global.flamingo.getComponent(lyrs[i]);
	      		if(lyr.getTilingType()!=undefined){
	      			if(lyr.getVisible()){
	      				urls[lyrs[i]] = lyr.getTilesArray();
	      			}
	      		} else {
	      		

	      	
	      	
	        //if(lyrs[i]=="map_bp_svbp_allLayer"||lyrs[i]=="map_bp_svbp_defLayer"||lyrs[i]=="map_bp_vv_gr_allLayer"||lyrs[i]=="map_bp_vv_gr_defLayer"||lyrs[i]=="map_vs_vv_grLayer"||lyrs[i]=="map_is_vv_grLayer"){
	          //if(TilingLayer(lyrs[i]).getVisible)){
	            //var tiles = flamingo.callMethod(lyrs[i],"getTilesArray");
       		    //urls[lyrs[i]] = tiles;
	         // }
	        //}
	      		}
	      	}  
  		}
	}
	public function onAddLayer(eventObject:Object,lyr:Object):Void{
      	var lyrId:String = _global.flamingo.getId(lyr);
      	_global.flamingo.addListener(this,lyr,this);
      	urls[lyrId] = "";
	}
	
	public function onRemoveLayer(eventObject:Object,lyr:Object):Void{
      	var lyrId:String = _global.flamingo.getId(lyr);
      	_global.flamingo.removeListener(this,lyr,this);
      	urls[lyrId] = "";
	}	      
	
	public function onHide(eventObject:Object):Void{
	 	var lyrId:String = _global.flamingo.getId(eventObject);
	 	if(urls[lyrId]){
	 		urls[lyrId]="";
	 	}  
	 }
	 
	function setAttribute(name:String, value:String):Void { 
        if(name=="mimeType"){
        	mimeType = value;
        }   
        if(name=="map"){
        	this.map=_global.flamingo.getComponent(value);
        } 
         if(name=="editmap"){
        	this.editMap=_global.flamingo.getComponent(value);
        } 	
    }
    
    private function getParameter(url,param,beginparam,endparam){
		var beginIndex:Number=0;
		var endIndex:Number=url.length;
		beginIndex=url.indexOf(param+beginparam)+param.length+beginparam.length;
		endIndex=url.indexOf(endparam,beginIndex);
		if(endIndex!=-1){
		    return url.substring(beginIndex,endIndex);	
		 } else {
		   return url.substring(beginIndex);
		  }
	}
	      
	}

