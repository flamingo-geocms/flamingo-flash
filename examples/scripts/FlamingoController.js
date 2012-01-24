/*Copyright 2010 B3Partners B.V (http://www.b3partners.nl)
 *@authors:Roy Braam (roy@b3p.nl)
 *         Jytte Schaeffer (jytte@b3p.nl)
 *         Meine Toonen (meine@b3p.nl)
 *
 *This file is distributed under the GNU General Public License,see http://www.gnu.org/licenses/gpl.html.
 *
 *A flamingoController. It only controlles the layers that are added with this script.
 *flamingoElement: (Mandatory) The html embeded flash object referencing to flamingo
 *thisVarName: (Mandatory) the var name of the reference where this object is stored.
 *
 *Example: var fc=FlamingoController(flamingo,'fc');
 **/
function FlamingoController(flamingoElement, thisVarName){
    if (flamingoElement==undefined || thisVarName==undefined){
        alert ("Error: FlamingoController is not created because both constructor param's need to be submitted.");
        return null;
    }
    this.flamingo=flamingoElement;
    this.thisName=thisVarName;
    this.maps= new Array();
    this.legends= new Array();
    this.identifyResultsHTML=null;
    this.editMaps= new Array();
    this.namespacePrefix="fmc";
    this.methodController = new MethodController(this.flamingo,this.thisName);

    /*Help functions*/
    /*Initialize a (in flamingo)existing Map component */
    this.initMap = function(mapid) {
        this.maps.push(new Map(mapid, this));
        return this.getMap(mapid);
    }
    /*@deprecated use: initMap(mapid)*/
    this.createMap = function(mapid) {
        return this.initMap(mapid);
    }
    /*Initialize a (in flamingo)existing EditMap component */
    this.initEditMap = function(editMapId) {
        this.editMaps.push(new EditMap(editMapId, this));
        return this.getEditMap(editMapId);
    }
    /*@deprecated use: initEditMap(editMapId)*/
    this.createEditMap = function(editMapId) {
        return this.initEditMap(editMapId);
    }
    /*Initialize a (in flamingo)existing Legend component */
    this.initLegend = function(legendid) {
        this.legends.push(new Legend(legendid, this));
        return this.getLegend(legendid);
    }
    /*@deprecated use: initLegend(legendid)*/
    this.createLegend = function(legendid) {
        return this.initLegend(legendid);
    }
    /*Initialize a (in flamingo)existing IdentifyResultsHTML component */
    this.initIdentifyResultsHTML = function (identifyid){
        this.identifyResultsHTML = new IdentifyResultsHTML(identifyid, this);
    }
    /*@deprecated use: initIdentifyResultsHTML(identifyid)*/
    this.createIdentifyResultsHTML = function(identifyid) {
        this.initIdentifyResultsHTML(identifyid);
    }
    /*Set a object visibility
     * id: the id of the object
     * visible: visibility of a object
     **/
    this.setVisible= function(id,visible){
        this.getFlamingo().callMethod(id,'setVisible',visible);
    }
    //setters and getters
    this.setFlamingo = function(flamingoElement){
        this.flamingo=flamingoElement;
    }
    this.getFlamingo = function(){
        return this.flamingo;
    }
    this.setMap=function(map){
        this.maps.push(map);
    }
    this.setLegend=function(legend){
        this.legends.push(legend);
    }
    /* Returns the map with the given id or the first map when no id is given
     * and the array of maps only contains 1 map.
     * Returns an error when the array is emty or no id is given and the array
     * contains more then 1 map or when the given id does not excist.
     */
    this.getMap=function (id){
        if(this.maps.length <= 0){
            alert("There are no existing maps. Make sure you configure at least 1 map.");
            return null;
        }
        if(id == null){
            if(this.maps.length == 1){
                return this.maps[0];
            }else{
                alert("There is more then 1 existing map. Make sure you select the map you want to use.");
                return null;
            }
        }
        for (var i=0; i < this.maps.length; i++){
            if (this.maps[i].getId()==id){
                return this.maps[i];
            }
        }
        alert(id +" is not an existing map.");
        return null;
    }
    this.getLegend=function (id){
        if(this.legends.length <= 0){
            alert("There are no existing legends. Make sure you configure at least 1 legend.");
            return null;
        }
        if(id == null){
            if(this.legends.length == 1){
                return this.legends[0];
            }else{
                alert("There is more then 1 existing legend. Make sure you select the legend you want to use.");
                return null;
            }
        }
        for (var i=0; i < this.legends.length; i++){
            if (this.legends[i].getId()==id){
                return this.legends[i];
            }
        }
        alert(id +" is not an existing legend.");
        return null;
    }
    this.getEditMap = function(id) {
        if (this.editMaps.length <= 0) {
            alert("There are no existing editmaps. Make sure you configure at least 1 editMap.");
            return null;
        }
        if (id == null) {
            if (this.editMaps.length == 1) {
                return this.editMaps[0];
            } else {
                alert("There is more then 1 existing EditMap. Make sure you select the EditMap you want to use.");
                return null;
            }
        }
        for (var i = 0; i < this.editMaps.length; i++) {
            if (this.editMaps[i].getId() == id) {
                return this.editMaps[i];
            }
        }
        alert(id + " is not an existing EditMap.");
        return null;
    }
    this.setIdentifyResultsHTML=function(identifyResultsHTML){
        this.identifyResultsHTML=identifyResultsHTML;
    }
    this.getIdentifyResultsHTML=function (){
        return this.identifyResultsHTML;
    }
    this.setNamespacePrefix= function(namespacePrefix){
        this.namespacePrefix=namespacePrefix;
    }
    this.getNamespacePrefix= function(){
        return this.namespacePrefix;
    }
    this.getThisName = function(){
        return this.thisName;
    }
    this.getMethodController= function(){
        return this.methodController;
    }
}
function Map(id,flamingoController){
    this.id=id;
    this.flamingoController=flamingoController;
    //array of layers (0 is added first then the rest is added on top of 0)
    this.layers= new Array();
    this.requestListener=null;

    /**
     *Add a layer to flamingo
     *layer: a FlamingoWMSLayer object
     *refresh: if true the function will do a refresh after adding the layer
     *replaceifIdExists: Replaces the layer when it has a layer with the same id
     *      set true if you want to let the previous layer be visible until the new layer is loaded.
     *merge: set true if you want the layers of the added layer to be merged with a excisting layer with the same service url.
     *      can't be combined with replaceIfIdExists.
     */
    this.addLayer= function(layer,refresh,replaceIfIdExists,merge){
        //this.removeLayer(layer);
        if (layer.getUrl()==null || layer.getUrl().length<=0){
            alert("Url of flamingo layer is empty! Layer not added");
            return;
        }
        var flamingoLayers= this.getFlamingoController().getFlamingo().callMethod(this.getId(),'getLayers');
        if (layer.id.length==0){
            layer.id="layer";
        }
        if (!replaceIfIdExists){
            var newId=this.createUniqueLayerId(flamingoLayers,layer.id);
            if (newId==null){
                return;
            }
            layer.setId(newId);
        }
        if (merge){
            for (var i=0; i < this.layers.length && layer!=null; i++){
                if (this.layers[i].getUrl()==layer.getUrl()){
                    var ls= layer.getLayers().split(",");
                    for(var l=0; l < ls.length; l++){
                        this.layers[i].addLayer(ls[l]);
                    }
                    if (refresh){
                        this.layers[i].reload();
                    }
                    layer=null;
                }
            }
        }else{
            for (var i=0; i < this.layers.length; i++){
                if (this.layers[i].getId()==layer.getId()){
                    this.layers.splice(i,1);
                }
            }
        }
        if (layer!=null){
            layer.setMap(this);
            this.layers.push(layer);
            this.getFlamingoController().getFlamingo().callMethod(this.getId(),'addLayer',layer.toXml(this.getFlamingoController().getNamespacePrefix()));
            if (this.getRequestListener()!=null){
                this.createLayerListener(layer.getId(),'onRequest',this.getRequestListener());
            }
        }
        if (refresh){
            this.update();
        }
    }
    /**
     *Get layer with flaming id
     **/
    this.getLayerWithFlamingoId=function (flamingoId){
        var lid=flamingoId.substring(this.getId().length+1);
        return this.getLayer(lid);
    }
    /**
    *Get layer by id.
    */
    this.getLayer= function(lid){
        for (var i=0; i < this.layers.length; i++){
            if (this.layers[i].getId()==lid){
                return this.layers[i];
            }
        }
        return null;
    }
    /**
    *Returns the index of the layer
    */
    this.getLayerIndex = function(layer){
        for (var i=0; i < this.getLayers().length; i++){
            if (this.getLayers()[i]==layer){
                return i;
            }
        }
        return -1;
    }
    /**
     *Remove a specified layer
     **/
    this.removeLayer=function(layer,refresh){
        var layerId=layer.getId();
        this.removeLayerById(layerId,refresh);
    }
    /**
     *Remove a layer by id
     */
    this.removeLayerById=function(layerId,refresh){
        this.getFlamingoController().getFlamingo().call(this.getId(),'removeLayer',this.getId()+"_"+layerId);
        for (var i=0; i < this.layers.length; i++){
            if (this.layers[i].getId()==layerId){
                if (this.getRequestListener()!=null){
                    this.removeLayerListener(layerId,'onRequest');
                }
                this.layers.splice(i,1);
                if(refresh)
                    this.update();
                return;
            }
        }
    }
    /*Remove all layers
     **/
    this.removeAllLayers=function(refresh){
        var layerIds= new Array();
        for (var i=0; i < this.layers.length; i++){
            layerIds.push(this.layers[i].id);
        }
        for (var i=0; i < layerIds.length; i++){
            this.removeLayerById(layerIds[i]);
        }
        if (refresh)
            this.update();
    }
    /**
     *Sets the layer to the given index. (order of layers) (0 is bottom lenght-1 is top)
     *Returns the old index of the layer
     */
    this.setLayerPosition= function(layerId,newIndex){
        var layer=this.getLayer(layerId);
        if (layer==undefined || layer==null){
            alert("Layer can not be found.");
        }
        if (newIndex < 0 || newIndex >= this.getLayers().length){
            alert("Index out of bound: "+newIndex+" arrayLength: "+this.getLayers().length);
        }

        var indexOfLayer = this.getLayerIndex(layer);
        if (indexOfLayer==newIndex){
            return indexOfLayer;
        }
        var newLayerArray= new Array();
        var oldLayerArray = this.getLayers();
        var size = oldLayerArray.length;
        // Delete layer from the old array
        oldLayerArray.splice(indexOfLayer   ,1);
        var count = 0;

        // Make temporary array, with correct order
        for(var i = 0 ; i < size; i++){
            if(newIndex == i ){
                newLayerArray.push(layer);
            }else{
                newLayerArray.push(oldLayerArray[count]);
                count++;
            }
        }
        this.setLayers(newLayerArray);
        return indexOfLayer;
    }

    /**
     * refreshes the layer order of flamingo. It sets the js layerOrder in flamingo
     */
    this.refreshLayerOrder=function(){
        for (var i=0; i < this.getLayers().length; i++){
            var layerId=this.getLayers()[i].getId();
            flamingoController.getFlamingo().callMethod(this.getId(),"swapLayer",this.getId()+"_"+layerId);
        }
        //this.update();
    }
    /*Listener functions*/
    /**
     *Creates a listener for the layer.
     *layerId: The id of the layer
     *listenTo: the event that needs to be heard
     *TODO: Het stukje =function (.....) is listener specifiek.
     */
    this.createLayerListener=function(layerId,listento,method){
        var listener=""+this.getFlamingoController().getFlamingo().id+"_"+this.getId()+"_"+layerId+"_"+listento+"=function (layer,type,requestObject){"+method+"(layer,type,requestObject);};";
        eval(listener);
    }
    this.removeLayerListener=function(layerId,listento){
        eval(""+this.getFlamingoController().getFlamingo().id+this.getId()+layerId+"_"+listento+"=undefined;");
    }
    /*Listeners*/
    /**
     *Enables the request handler in this object. The default layerRequestHandler is used.
     */
    this.enableLayerRequestListener= function(){
        this.setRequestListener(this.getFlamingoController().getThisName()+".getMap(\""+this.getId()+"\").layerRequestHandler");
    }
    /**
     *Default layer request listener.
     */
    this.layerRequestHandler = function (layerId,type,requestObject){
        //type can be: init, update
        var layer=this.getLayerWithFlamingoId(layerId);
        if (layer==null){
            return;
        }
        if (type=='update'){
            layer.setLastGetMapRequest(requestObject.url);
        }
    }
    /*Helper functions*/
    /**
     *Check if the id is unique, not: Create a new layer id that is unique.
     *With a max of 1000 tries.
     *flamingoLayerlist the list with flamingoLayer ids
     *id: The id to check.
     **/
    this.createUniqueLayerId = function(flamingoLayerlist,lid){
        var newId=lid;
        for (var i=0; i < 1000; i++){
            if (!this.contains(flamingoLayerlist,this.id+"_"+newId)){
                return newId;
            }else{
                newId=""+lid+i;
            }
        }
        return null;
    }
    /**
     *check if the array contains the id.
     **/
    this.contains = function(list,id){
        if(list){
            for (var i=0; i < list.length; i++){
                if (list[i]==id){
                    return true;
                }
            }
        }
        return false;
    }
    //flamingo call methods:
    //move to a extent
    this.moveToExtent = function(ext,delay){
        if(delay==undefined){
            delay=0;
        }
        this.getFlamingoController().getFlamingo().callMethod(this.getId(), "moveToExtent", ext, delay);
    }
    this.moveToFullExtent = function(){
        this.moveToExtent(this.getFlamingoController().getFlamingo().callMethod(this.getId(), "getFullExtent"));
    }
    //set and get the maximum extent of this map
    this.setFullExtent=function(ext){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(), "setFullExtent", ext);
    }
    this.getFullExtent=function(){
        return this.getFlamingoController().getFlamingo().callMethod(this.getId(), "getFullExtent");
    }
    this.doIdentify=function(ext){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(), "identify", ext);        
    }
    //Get the current extent
    this.getExtent= function(){
        return this.getFlamingoController().getFlamingo().callMethod(this.getId(),'getExtent');
    }
    /**
     *Moves to previous extent.
     *@param movetime the time of move animation. if undefined then the default map movetime is used.
     */
    this.moveToPreviousExtent=function(movetime){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'moveToPrevExtent',movetime);
    }
    /**
     *Moves the map to next extent.
     *@param movetime the time of move animation. if undefined then the default map movetime is used.
     */
    this.moveToNextExtent=function(movetime){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'moveToNextExtent',movetime);
    }
    /**
     *Update the flamingo map
     */
    this.update=function(){        
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'update', 100, true);
    }
    /*
     *Reload all the layers     *
     **/
    this.reload=function(){
        for (var i=0; i < this.layers.length; i++){
            this.layers[i].reload();
        }
    }
    this.setMarker= function(markerName,x,y,type){
        if (type==undefined){
            type="default";
        }
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),"setMarker",markerName,"default",Number(x),Number(y));
    }
    /*Setters en getters*/
    this.getId= function(){
        return id;
    }
    this.setId=function (id){
        this.id=id;
    }
    this.getFlamingoController = function(){
        return flamingoController;
    }
    this.setFlamingoController = function (flamingoController){
        this.flamingoController=flamingoController;
    }
    this.getLayers = function(){
        return this.layers;
    }
    this.setLayers = function(layers){
        this.layers=layers;
    }
    /*Sets the request listener. The given function name is called when a
     *layer does a request and the server responsed
     *requestListener: the function name dat is called
     **/
    this.setRequestListener= function(requestListener){
        this.requestListener=requestListener;
    }
    this.getRequestListener= function(){
        return this.requestListener;
    }
}
function FlamingoWMSLayer(id){
    if (id==undefined){
        alert("Error: Id must be defined");
        return;
    }
    this.id=null;
    this.url=null;
    this.getfeatureinfourl=null;
    this.getcapabilitiesurl=null;
    this.map=null;
    this.layers=null;
    this.querylayers=null;
    this.maptiplayers=null;
    this.srs=null;
    this.showerrors=null;
    this.nocache=false;
    this.transparent=true;
    this.lastGetMapRequest=null;
    this.version=null;
    this.timeOut=null;
    this.retryOnError=null;
    this.format=null;
    this.exceptions=null;
    this.visible=null;
    this.alpha=null;
    this.layerProperties= new Array();
    this.sld=null;
    this.maptipFeatureCount=null;
    this.featureCount=null;
    this.visible_layers=null;
    this.styles=null;
    this.updateWhenEmpty=null;
    this.minScale=null;
    this.maxScale=null;

    //methods
    this.toXml = function(namespaceprefix){
        var xml="<";
        if (namespaceprefix!=null)
            xml+=namespaceprefix+":";
        xml+="LayerOGWMS";
        if (namespaceprefix!=null)
            xml+=" xmlns:fmc=\"fmc\"";
        xml+=" id=\""+this.getId()+"\"";
        xml+=" url=\""+this.getUrl();
        //sld parameter of flamingo isn't working. Append it to the url parameter
        if (this.getSld()!=null){
            xml+=this.getUrl().indexOf("?")>=0 ? "&" : "?";
            xml+="SLD="+this.getSld()+"&";
        }
        xml+="\"";        
        if (this.getGetcapabilitiesUrl()!=null)
            xml+=" getcapabilitiesurl=\""+this.getGetcapabilitiesUrl()+"\"";
        if (this.getGetfeatureinfoUrl()!=null)
            xml+=" getfeatureinfourl=\""+this.getGetfeatureinfoUrl()+"\"";
        if (this.getLayers()!=null)
            xml+=" layers=\""+this.getLayers()+"\"";
        if (this.getQuerylayers()!=null)
            xml+=" query_layers=\""+this.getQuerylayers()+"\"";
        if (this.getMaptiplayers()!=null)
            xml+=" maptip_layers=\""+this.getMaptiplayers()+"\"";
        if (this.getSrs()!=null)
            xml+=" srs=\""+this.getSrs()+"\"";
        if (this.getShowerrors()!=null)
            xml+=" showerrors=\""+this.getShowerrors()+"\"";
        if (this.getNocache())
            xml+=" nocache=\"true\"";
        if(!this.getTransparent())
            xml+=" transparent=\"false\"";
        if (!this.getUpdateWhenEmpty()!=null)
            xml+=" updateWhenEmpty=\""+this.getUpdateWhenEmpty()+"\"";
        if(this.getVersion()!=null)
            xml+=" version=\""+this.getVersion()+"\"";
        if(this.getTimeOut()!=null)
            xml+=" timeout=\""+this.getTimeOut()+"\"";
        if(this.getRetryOnError()!=null)
            xml+=" retryonerror=\""+this.getRetryOnError()+"\"";
        if (this.getFormat()!=null)
            xml+=" format=\""+this.getFormat()+"\"";
        if (this.getExceptions()!=null)
            xml+=" exceptions=\""+this.getExceptions()+"\"";
        if (this.getVisible()!=null)
            xml+=" visible=\""+this.getVisible()+"\"";
        if (this.alpha !=null)
            xml+=" alpha=\""+this.alpha+"\"";
        if (this.getFeatureCount()!=null)
            xml+=" feature_count=\""+this.getFeatureCount()+"\"";
        if (this.getMaptipFeatureCount()!=null)
            xml+=" maptip_feature_count=\""+this.getMaptipFeatureCount()+"\"";
        /*sld parameter isn't working. The sld is added to the url
        if (this.sld !=null)
            xml+=" sld=\""+this.sld+"\"";*/
        if (this.visible_layers !=null)
            xml+=" visible_layers=\""+this.visible_layers+"\"";
        if (this.styles !=null)
            xml+=" styles=\""+this.styles+"\"";
        if (this.maxScale!=null)
            xml+=" maxscale=\""+ this.maxScale +"\"";
        if (this.minScale!=null)
            xml+=" minscale=\""+ this.minScale +"\"";
        xml+=">";
        for (var i=0; i < this.getLayerProperties().length; i++){
            var layerProperty=this.getLayerProperties()[i];
            xml+=layerProperty.toXml();
        }
        xml+="</";
        if (namespaceprefix!=null)
            xml+=namespaceprefix+":";
        xml+="LayerOGWMS>";
        return xml;
    }
    this.removeLayer=function(layerName){
        if (this.getLayers()!=null){
            var array = this.getLayers().split(",");
            var newLayers="";
            for (var i=0; i < array.length; i++){
                if (array[i]!=layerName){
                    if (newLayers.length>0){
                        newLayers+=",";
                    }
                    newLayers+=array[i];
                }
            }
            this.setLayers(newLayers);
        }
    }
    this.addLayer=function(layerName){
        if (this.hasLayer(layerName)){
            return;
        }
        var newLayers="";
        if (this.getLayers()!=null){
            newLayers=this.getLayers();
        }
        if (this.getLayers().toLowerCase()=="#all#"){
            alert("AddLayer in FlamingoWMSLayer can't be called if layers is set to #ALL#");
        }
        if (newLayers.length>0)
            newLayers+=",";
        newLayers+=layerName;
        this.setLayers(newLayers);
    }
    this.hasLayer=function(layerName){
        if (this.getLayers()!=null){
            if (this.getLayers().toLowerCase()=="#all#"){
                return true;
            }
            var array= this.getLayers().split(",");
            for (var i=0; i < array.length; i++){
                if (array[i]==layerName){
                    return true;
                }
            }
        }
    }
    this.reload = function(){
        if (this.getMap()!=null){
            this.getMap().getFlamingoController().getFlamingo().callMethod(this.getMap().getId()+"_"+this.getId(),"setConfig",this.toXml(this.getMap().getFlamingoController().getNamespacePrefix()));
        }
    }
    //getters and setters
    this.setId = function(id){
        this.id=id.split(' ').join('');
    }
    this.getId = function(){
        return this.id;
    }
    this.setUrl = function(url){
        this.url=url;
    }
    this.getUrl = function(){
        return this.url;
    }
    this.setGetfeatureinfoUrl=function(getfeatureinfourl){
        this.getfeatureinfourl=getfeatureinfourl;
    }
    this.getGetfeatureinfoUrl=function(){
        return this.getfeatureinfourl;
    }
    this.setGetcapabilitiesUrl=function(getcapabilitiesurl){
        this.getcapabilitiesurl=getcapabilitiesurl;
    }
    this.getGetcapabilitiesUrl = function(){
        return this.getcapabilitiesurl;
    }
    this.setMap = function(map){
        this.map=map;
    }
    this.getMap = function(){
        return this.map;
    }
    this.getSrs = function(){
        return this.srs;
    }
    this.setSrs = function(srs){
        this.srs=srs;
    }
    this.getLayers = function(){
        return this.layers;
    }
    this.setLayers = function(layers){
        this.layers=layers;        
    }
    this.getQuerylayers = function(){
        return this.querylayers;
    }
    this.setQuerylayers = function(querylayers){
        this.querylayers=querylayers;
    }
    this.getMaptiplayers= function(){
        return this.maptiplayers;
    }
    this.setMaptiplayers= function(maptiplayers){
        this.maptiplayers=maptiplayers;
    }
    this.getShowerrors = function(){
        return this.showerrors;
    }
    this.setShowerros = function(showerrors){
        this.showerrors=showerrors;
    }
    this.getNocache = function (){
        return this.nocache;
    }
    this.setNocache = function (nocache){
        this.nocache=nocache;
    }
    this.setTransparent= function(transparent){
        this.transparent=transparent;
    }
    this.getTransparent= function(){
        return this.transparent;
    }
    this.setUpdateWhenEmpty = function (updateWhenEmpty){
        this.updateWhenEmpty=updateWhenEmpty;
    }
    this.getUpdateWhenEmpty = function(){
        return this.updateWhenEmpty;
    }
    this.setLastGetMapRequest = function(lastGetMapRequest){
        this.lastGetMapRequest=lastGetMapRequest;
    }
    this.getLastGetMapRequest= function (){
        return this.lastGetMapRequest;
    }
    this.setVersion = function(version){
        this.version=version;
    }
    this.getVersion= function(){
        return this.version;
    }
    this.getTimeOut= function(){
        return this.timeOut;
    }
    this.setTimeOut= function(timeOut){
        this.timeOut=timeOut;
    }
    this.setRetryOnError = function(retryOnError){
        this.retryOnError=retryOnError;
    }
    this.getRetryOnError= function(){
        return this.retryOnError;
    }
    this.setFormat= function (format){
        this.format=format;
    }
    this.getFormat= function(){
        return this.format;
    }
    this.setExceptions= function(exceptions){
        this.exceptions=exceptions;
    }
    this.getExceptions= function(){
        return this.exceptions;
    }
    this.setVisible=function (visible){
        this.visible=visible;
    }
    this.getVisible=function (){
        return this.visible;
    }
    this.setStyles=function (styles){
        this.styles=styles;
    }
    this.getStyles=function (){
        return this.styles;
    }
    this.setAlpha= function(alpha){
        this.alpha=alpha;        
    }
    this.getAlpha= function(){
        return this.alpha;
    }
    this.setMaxScale = function(maxScale){
    	this.maxScale=maxScale;
    }
    this.getMaxScale = function(){
    	return this.maxScale;
    }
    this.setMinScale = function(minScale){
        this.minScale=minScale;
    }
    this.getMinScale = function(){
        return this.minScale;
    }
    this.setFeatureCount= function(featureCount){
        this.featureCount= featureCount;
    }
    this.getFeatureCount= function(){
        return this.featureCount;
    }
    this.setMaptipFeatureCount= function(maptipFeatureCount){
        this.maptipFeatureCount=maptipFeatureCount;
    }
    this.getMaptipFeatureCount= function(){
        return this.maptipFeatureCount;
    }    
    this.setSld= function (sld){
        this.sld=sld;        
    }
    this.getSld= function(){
        return this.sld;
    }
    this.setLayerProperties= function (layerProperties){
        this.layerProperties=layerProperties;
    }
    this.getLayerProperties= function(){
        return this.layerProperties;
    }
    this.addLayerProperty= function (layerProperty){
        this.layerProperties.push(layerProperty);
    }
    this.setVisible_layers= function (visible_layers){
        this.visible_layers=visible_layers;
    }
    this.getVisible_layers= function(){
        return this.visible_layers;
    }
    this.toString= function(){
        var s="";
        s+=this.getId()+": ";
        s+=this.getUrl()+" (";
        s+=this.getLayers()+")";
        return s;
    }

    /*Init*/

    this.setId(id);
}
/**
 *A child of a flamingo layer object (<layer> tag) With this the maptip string can be defined
 *id: the layer id/name
 *maptipField: the string that is used for showing the maptip (optional)
 *aka: if the returned getFeatureInfo has another name then the layer. (optional)
 **/
function LayerProperty(id,maptipField,aka){
    this.id=null;
    this.maptipField=null;
    this.aka=null;
    if (id==undefined){
        alert("Error: Id must be defined");
        return;
    }
    this.setId= function(id){
        this.id=id;
    }
    this.getId= function(){
        return this.id;
    }
    this.setMaptipField= function(maptipField){
        this.maptipField=maptipField;
    }
    this.getMaptipField= function(){
        return this.maptipField;
    }
    this.setAka=function(aka){
        this.aka=aka;
    }
    this.getAka=function(){
        return this.aka;
    }
    this.toXml=function(){
        var xml="<layer";
        xml+=" id=\""+this.getId()+"\"";
        if (this.getMaptipField()!=null)
            xml+=" maptip=\""+this.getMaptipField()+"\"";
        if (this.getAka()!=null){
            xml+=" aka=\""+this.getAka()+"\"";
        }
        xml+="/>"
        return xml;
    }
    //init
    this.setId(id);
    if (maptipField){
        this.setMaptipField(maptipField);
    }
    if (aka){
        this.setAka(aka);
    }
}
function EditMap(id,flamingoController){
    this.id=id;
    this.flamingoController=flamingoController;
    this.layers= new Array();
    
    this.removeAllFeatures=function (){
        flamingoController.getFlamingo().callMethod(this.id,'removeAllFeatures');
    }

    this.removeActiveFeature=function(){
        flamingoController.getFlamingo().callMethod(this.id,'removeActiveFeature');
    }

    this.getActiveFeature = function(){
        return flamingoController.getFlamingo().callMethod(this.id,'getActiveFeature');
    }

    this.getAllFeatures = function(){
        return flamingoController.getFlamingo().callMethod(this.id,"getAllFeaturesAsObject");
    }

    this.initLayer = function(layerId) {
        this.layers.push(new EditMapLayer(layerId, this, this.flamingoController));
        return this.getLayer(layerId);
    }
    this.getLayer= function (layerId){
        if (this.layers.length<=0){
            alert("No layers available");
        }
        if(layerId == null){
            if(this.layers.length == 1){
                return this.layers[0];
            }else{
                alert("There is more then 1 existing layer. Make sure you select the map you want to use.");
                return null;
            }
        }
        for (var i=0; i < this.layers.length; i++){
            if (this.layers[i].getId()==layerId){
                return this.layers[i];
            }
        }
        alert("layer not found with id: "+layerId);
        return null;
    }
    /*Getters and setters*/
    this.getId = function() {
        return this.id;
    }
    this.getLayers = function() {
        return this.layers;
    }
}
/*A layer in a editMap*/
function EditMapLayer(id,editMap,flamingoController){
    this.id=id;
    this.flamingoController=flamingoController;
    this.editMap=editMap;

    this.addFeature = function(wktGeom) {
        flamingoController.getFlamingo().callMethod(this.getEditMap().getId(), "addFeature", this.id, wktGeom);
    }
    /*Getters and setters*/
    this.getId=function (){
        return this.id;
    }
        
    this.getEditMap = function() {
        return this.editMap;
    }
}

/*Old javascript code that checks if a component is loaded and after that starts the method
 *that is called. Perhaps it can be removed. Not tested in new flamingoController
 **/
function MethodController(fmcObject,name){
    this.queues = new Array();
    this.fmc=fmcObject;
    this.name=name;
    this.busy=false;

    /*Use this function to call a flamingo function with javascript.
     **/
    this.callCommand =function (fmcCall){
        if (typeof this.fmc.callMethod == 'function' && this.fmc.callMethod(this.fmc.id,'exists',fmcCall.id)==true){
            if (fmcCall.params==null){
                eval("setTimeout(\"flamingo.callMethod('"+fmcCall.id+"','"+fmcCall.method+"')\",10);");
            }else{
                var value=""
                for (var i=0; i < fmcCall.params.length; i++){
                    value+=",";
                    var valueType=typeof(fmcCall.params[i]);
                    if (valueType == 'boolean' || valueType == 'number' || valueType == 'array'){
                        value+=fmcCall.params[i];
                    }else{
                        value+="'"+fmcCall.params[i]+"'";
                    }
                }
                eval("setTimeout(\"flamingo.callMethod('"+fmcCall.id+"','"+fmcCall.method+"'"+value+")\",10);");
            }
        }else{
            this.addToQueue(fmcCall);
        }
    }
    /*This function adds a call to the queue. It is used when a component not (yet) is loaded
     **/
    this.addToQueue = function(fmcCall){
        if (this.queues[fmcCall.id]==undefined || this.queues[fmcCall.id]==null){
            this.queues[fmcCall.id]= new Array();
            eval(""+this.fmc.id+"_"+fmcCall.id+"_onInit = function(){"+this.name+".getMethodController.executeQueue('"+fmcCall.id+"');};");
        }
        this.queues[fmcCall.id].push(fmcCall);
    }
    /*Executes the queue of a given component id.
     **/
    this.executeQueue = function(id){
        if (this.queues[id]==undefined || this.queues[id]==null || this.queues[id].length==0){
            return;
        }
        while (this.queues[id].length!=0){
            var flamingoCall=this.queues[id].shift();
            this.callCommand(flamingoCall);
        }
    }
}
/*Class FlamingoCall
 *Used to store the method call
 **/
function FlamingoCall(id,method,params){
    this.id = id;
    this.method = method;
    if (params==undefined || params==null){
        this.params=new Array();
    }else if (typeOf(params) == 'array'){
        this.params=params;
    }else {
        this.params=new Array();
        this.params.push(params);
    }
}
/*Returns the type of a object.
 **/
function typeOf(value) {
    var s = typeof value;
    if (s === 'object') {
        if (value) {
            if (value instanceof Array) {
                s = 'array';
            }
        } else {
            s = 'null';
        }
    }
    return s;
}
/*
* Legend
* A flamingo viewer can have more then one legend just like it can have more then one map.
*/
function Legend(id,flamingoController){
    this.id=id;
    this.flamingoController=flamingoController;
    /* 
	* Add a LegendNode and his posible childeren to the legend.
	* Node wil be inserted before nextNode. If nextNode is null the node will be inserted at the end.
	* Node will be inserted in parentNode. If parentNode is null the node will be inserted in te root 
	* of the legend or before nextNode if it is given.
	*/
    this.addNodeObject=function(legendNode, nextNode, parrentNode){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'addNodeObject',legendNode.toXml(),nextNode,parrentNode);
    }
    this.removeNodeObject=function(nodeId){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'removeNodeObject',nodeId);
    }
    this.removeAllNodeObjects=function(){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'removeAllNodeObjects');
    }
    this.legendItemExists=function(id){
        return this.getFlamingoController().getFlamingo().callMethod(this.getId(),'legendItemExists', id);
    }
    this.itemById=function(id){
        return this.getFlamingoController().getFlamingo().callMethod(this.getId(),'itemById', id);
    }

    /*Setters en getters*/
    this.getId= function(){
        return id;
    }
    this.setId=function (id){
        this.id=id;
    }
    this.getFlamingoController = function(){
        return flamingoController;
    }
    this.setFlamingoController = function (flamingoController){
        this.flamingoController=flamingoController;
    }
}
/*
* LegendNode
* This is an object in te legend. It can either be a group, item or symbol. 
*/
function LegendNode(id){
    if (id==undefined){
        alert("Error: Id must be defined");
        return;
    }
    this.id=null;
    this.type=null;
    this.childNodes= new Array();

    this.label=null;
    this.dx=null;
    this.dy=null;
    this.minscale=null;
    this.maxscale=null;

    /* for group */
    this.open=null;
    this.hideallbutone=null;
    /* for item */
    this.listento=null;
    this.canhide=null;
    this.infourl=null;
    this.infostring=null;
    this.stickylabel=null;
    /* for symbol*/
    this.url=null;

    this.toXml = function(){
        var xml;
        if(this.getType() == "group"){
            xml = this.groupToXml();
        }else if(this.getType() == "item"){
            xml = this.itemToXml();
        }else if(this.getType() == "symbol"){
            xml = this.symbolToXml();
        }else{
            alert("LegendNode does not have valid type");
        }
        return xml;
    }
    this.groupToXml = function(){
        var xml = "<group";
        if (this.getId()!=null)
            xml+=" id=\""+this.getId()+"\"";
        if (this.getLabel()!=null)
            xml+=" label=\""+this.getLabel()+"\"";
        if (this.getOpen()!=null)
            xml+=" open=\""+this.getOpen()+"\"";
        if (this.getDx()!=null)
            xml+=" dx=\""+this.getDx()+"\"";
        if (this.getDy()!=null)
            xml+=" dy=\""+this.getDy()+"\"";
        if (this.getHideallbutone()!=null)
            xml+=" hideallbutone=\""+this.getHideallbutone()+"\"";
        xml+=">";
        if(this.childNodes != null && this.childNodes.length > 0){
            for(var i = 0; i < this.childNodes.length; i++){
                xml+=this.childNodes[i].toXml();
            }
        }
        xml+="</group>";
        return xml;
    }
    this.itemToXml = function(){
        var xml = "<item";
        if (this.getId()!=null)
            xml+=" id=\""+this.getId()+"\"";
        if (this.getLabel()!=null)
            xml+=" label=\""+this.getLabel()+"\"";
        if (this.getListento()!=null)
            xml+=" listento=\""+this.getListento()+"\"";
        if (this.getDx()!=null)
            xml+=" dx=\""+this.getDx()+"\"";
        if (this.getDy()!=null)
            xml+=" dy=\""+this.getDy()+"\"";
        if (this.getCanhide()!=null)
            xml+=" canhide=\""+this.getCanhide()+"\"";
        if (this.getInfourl()!=null && this.getInfourl()!="")
            xml+=" infourl=\""+this.getInfourl()+"\"";
        if (this.getMinscale()!=null)
            xml+=" minscale=\""+this.getMinscale()+"\"";
        if (this.getMaxscale()!=null)
            xml+=" maxscale=\""+this.getMaxscale()+"\"";
        if (this.getStickylabel()!=null)
            xml+=" stickylabel=\""+this.getStickylabel()+"\"";
        xml+=">";
        if (this.getInfostring()!=null && this.getInfostring()!=""){
            xml+=this.getInfostring();
        }
        if(this.childNodes != null && this.childNodes.length > 0){
            for(var i = 0; i < this.childNodes.length; i++){
                xml+=this.childNodes[i].toXml();
            }
        }
        xml+="</item>";
        return xml;
    }
    this.symbolToXml = function(){
        var xml = "<symbol";
        if (this.getId()!=null)
            xml+=" id=\""+this.getId()+"\"";
        if (this.getLabel()!=null)
            xml+=" label=\""+this.getLabel()+"\"";
        if (this.getUrl()!=null)
            xml+=" url=\""+this.getUrl()+"\"";
        if (this.getDx()!=null)
            xml+=" dx=\""+this.getDx()+"\"";
        if (this.getDy()!=null)
            xml+=" dy=\""+this.getDy()+"\"";
        if (this.getMinscale()!=null)
            xml+=" minscale=\""+this.getMinscale()+"\"";
        if (this.getMaxscale()!=null)
            xml+=" maxscale=\""+this.getMaxscale()+"\"";
        xml+="/>";
        return xml;
    }
    /*Setters en getters*/
    this.setId = function(id){
        this.id=id.split(' ').join('');
    }
    this.getId = function(){
        return this.id;
    }
    this.setType = function(type){
        this.type=type;
    }
    this.getType = function(){
        return this.type;
    }
    this.setLabel = function(label){
        this.label=label;
    }
    this.getLabel = function(){
        return this.label;
    }
    this.setOpen = function(open){
        this.open=open;
    }
    this.getOpen = function(){
        return this.open;
    }
    this.setDx = function(dx){
        this.dx=dx;
    }
    this.getDx = function(){
        return this.dx;
    }
    this.setDy = function(dy){
        this.dy=dy;
    }
    this.getDy = function(){
        return this.dy;
    }
    this.setHideallbutone = function(hideallbutone){
        this.hideallbutone=hideallbutone;
    }
    this.getHideallbutone = function(){
        return this.hideallbutone;
    }
    this.setListento = function(listento){
        this.listento=listento;
    }
    this.getListento = function(){
        return this.listento;
    }
    this.setCanhide = function(canhide){
        this.canhide=canhide;
    }
    this.getCanhide = function(){
        return this.canhide;
    }
    this.setInfourl = function(infourl){
        this.infourl=infourl;
    }
    this.getInfourl = function(){
        return this.infourl;
    }
    this.setInfostring = function(infostring){
        this.infostring=infostring;
    }
    this.getInfostring = function(){
        return this.infostring;
    }
    this.setMinscale = function(minscale){
        this.minscale=minscale;
    }
    this.getMinscale = function(){
        return this.minscale;
    }
    this.setMaxscale = function(maxscale){
        this.maxscale=maxscale;
    }
    this.getMaxscale = function(){
        return this.maxscale;
    }
    this.setStickylabel = function(stickylabel){
        this.stickylabel=stickylabel;
    }
    this.getStickylabel = function(){
        return this.stickylabel;
    }
    this.setUrl = function(url){
        this.url=url;
    }
    this.getUrl = function(){
        return this.url;
    }
    /*
	* A Legendnode can have childeren which should be LegendNodes them self.
	* Read the flamingo documentation for rules on what a node can be the child of.
	* If you try to add a node that is not correct. For example an item in a symbol.
	* You get an error.
	*/
    this.setChildNodes= function (childNodes){
        this.childNodes=childNodes;
    }
    this.getChildNodes= function(){
        return this.childNodes;
    }
    this.addChildNode= function (childNode){
        if(this.getType() == "symbol"){
            alert("Symbol can not have a childNode.");
        }else if(childNode.getType() == "symbol" && this.getType() != "item"){
            alert("Symbol can not be a childNode of something else then a item.");
        }else if(childNode.getType() == "item" && this.getType() != "group"){
            alert("Item can not be a childNode of something else then a group.");
        }else{
            this.childNodes.push(childNode);
        }
    }
	
    /*Init*/
    this.setId(id);
}

function IdentifyResultsHTML(id,flamingoController){
    this.id=id;
    this.flamingoController=flamingoController;

    this.addStringObject=function(stringObject){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'addStringObject',stringObject.toXml());
    }
    this.removeStringObject=function(stringObjectId){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'removeStringObject',stringObjectId);
    }
    this.removeAllStringObjects=function(){
        this.getFlamingoController().getFlamingo().callMethod(this.getId(),'removeAllStringObjects');
    }

    /*Setters en getters*/
    this.getId= function(){
        return id;
    }
    this.setId=function (id){
        this.id=id;
    }
    this.getFlamingoController = function(){
        return flamingoController;
    }
    this.setFlamingoController = function (flamingoController){
        this.flamingoController=flamingoController;
    }
}

function StringObject(id){
    if (id==undefined){
        alert("Error: Id must be defined");
        return;
    }
    this.id=null;
    this.stripdatabase=null;
    this.xmlObject=null;

    this.toXml = function(){
        var xml = "<string ";
        xml += "id=\""+this.getId()+"\" ";
        xml += "stripdatabase=\""+this.getStripdatabase()+"\">";
        xml += this.getXmlObject();
        xml += "</string>"
        return xml;
    }

    /*Setters en getters*/
    this.setId = function(id){
        this.id=id.split(' ').join('');
    }
    this.getId = function(){
        return this.id;
    }
    this.setStripdatabase = function(stripdatabase){
        this.stripdatabase=stripdatabase;
    }
    this.getStripdatabase = function(){
        return this.stripdatabase;
    }
    this.setXmlObject = function(xmlObject){
        this.xmlObject=xmlObject;
    }
    this.getXmlObject = function(){
        return this.xmlObject;
    }

    /*Init*/
    this.setId(id);
}
