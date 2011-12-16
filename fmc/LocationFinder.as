/*-----------------------------------------------------------------------------
Copyright (C) 2006  Menko Kroeske

This file is part of Flamingo MapComponents.

Flamingo MapComponents is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-----------------------------------------------------------------------------
Modified by : Abeer.Mahdi@realworld-systems.com
		     Realworld systems BV
			 
Change: Extented locationfinder to work with Arcgis server connections.
------------------------------------------------------------------------------
Modified by: roybraam@b3partners.nl
Change: Added WFS search.

*/
/** @component LocationFinder
* Component for searching for and zooming to places, areas etc.
* Supported arguments: find (comma seperated list of locationid and location)  eg. flamingo.swf?config=mymap.xml&amp;locationfinder.find=places,hometown
* @file LocationFinder.fla (sourcefile)
* @file LocationFinder.swf (compiled component, needed for publication on internet)
* @file LocationFinder.xml (configurationfile, needed for publication on internet)
* @configstring label  en="search..." nl="zoek..."/>
* @configstring busy  en="searching..." nl="zoeken..."/>
* @configstring nohit  en="nothing found..." nl="niets gevonden..."/>
* @configstring prev  en="previous   " nl="vorige   "/>
* @configstring next  en="next" nl="volgende"/>
* @configstyle .nohit font-family="verdana" font-size="10px" color="#cccccc" display="block" font-weight="normal"/>
* @configstyle .busy font-family="verdana" font-size="10px" color="#cccccc" display="block" font-weight="normal" font-style="italic"/>
* @configstyle .feature font-family="verdana" font-size="12px" color="#0066cc" display="block" font-weight="normal"/>
* @configstyle .prev font-family="verdana" font-size="10px" color="#0066cc" display="block" font-weight="bold" text-align="center"/>
* @configstyle .next font-family="verdana" font-size="10px" color="#0066cc" display="block" font-weight="bold" text-align="center"/>
* @configstyle .error font-family="verdana" font-size="12px" color="#ff0000" display="block" font-weight="normal"/>
* @configstyle .hint font-family="verdana" font-size="10px" color="#cccccc" display="block" font-weight="normal" font-style="italic"/>
*/
var version:String = "2.0";
//-------------------------------
var defaultXML:String = "<?xml version='1.0' encoding='UTF-8'?>" +
						"<LocationFinder>" +
						"<string id='label'  en='search...' nl='zoek...'/>" +
						"<string id='busy'  en='searching...' nl='zoeken...'/>" +
						"<string id='nohit'  en='nothing found...' nl='niets gevonden...'/>" +
						"<string id='prev'  en='previous   ' nl='vorige   '/>" +
						"<string id='next'  en='next' nl='volgende'/>" +
						"<style id='.nohit' font-family='verdana' font-size='10px' color='#cccccc' display='block' font-weight='normal'/>" +
						"<style id='.busy' font-family='verdana' font-size='10px' color='#cccccc' display='block' font-weight='normal' font-style='italic'/>" +
						"<style id='.hint' font-family='verdana' font-size='10px' color='#cccccc' display='block' font-weight='normal' font-style='italic'/>" +
						"<style id='.feature' font-family='verdana' font-size='12px' color='#0066cc' display='block' font-weight='normal'/>" +
						"<style id='.prev' font-family='verdana' font-size='10px' color='#0066cc' display='block' font-weight='bold' text-align='center'/>" +
						"<style id='.next' font-family='verdana' font-size='10px' color='#0066cc' display='block' font-weight='bold' text-align='center'/>" +
						"<style id='.error' font-family='verdana' font-size='12px' color='#ff0000' display='block' font-weight='normal'/>" +
						"</LocationFinder>";
var thisObj = this;
var locationdata:Array = new Array();
var foundlocations:Array;
var currentlocation:Object;
var filesstr:String;
var files:Array;
var beginrecord = 1;
var nrlines:Number;
var controls:Boolean = true;
var namespaces:Object;
var entersDone:Number=0;
var currentExtentSelector:Object;
var resultViewerId:String;
var resultViewer:Object;
var showSearchButton:Boolean = false;

var tFeaturesDelta:Number = 0;
var locationPin:MovieClip = null;
var map:Object = null;
var coord:Object = null;
var contextObject:Object = null;

//---------------------------------------
import mx.controls.ComboBox;
import mx.controls.TextInput;
import event.ActionEventListener;
import event.ActionEvent;
import coremodel.service.*;
import geometrymodel.Envelope;
import geometrymodel.Geometry;
import gui.LocationPin;


var lParent:Object = new Object();
lParent.onResize = function(mc:MovieClip) {
	resize();
};
lParent.onSetVisible = function(mc:MovieClip,visible:Boolean) {
	for (var i in thisObj.locationdata ) {
		thisObj.locationdata[i].extentSelector.setVisible(false,"locationFinder");
	}
	thisObj.tFeaturesDelta = 0;
	if(thisObj.currentExtentSelector!=null && visible){
		thisObj.currentExtentSelector.setVisible(true,"locationFinder");
		thisObj.tFeaturesDelta = 10 + thisObj.currentExtentSelector.getExtents().length * 20;
	}	
};
flamingo.addListener(lParent, flamingo.getParent(this), this);
//---------------------------------------
var lFlamingo:Object = new Object();
lFlamingo.onSetLanguage = function(lang:String) {
	var locationindex = mHolder.cbChoice.selectedItem.data;
	refresh();
	if (locationindex == -1) {
		return;
	}
	var hint = getString(locationdata[locationindex], "hint");
	if (locationdata[locationindex].features == undefined) {
		if (locationdata[locationindex].searchstring.length == 0) {
			if (hint.length>0) {
				mHolder.tFeatures.wordWrap = true;
				mHolder.tFeatures.htmlText = "<span class='hint'>"+hint+"</span>";
			}
		} else {
			_findLocation(locationdata[locationindex], locationdata[locationindex].searchstring, nrlines, true);
		}
	} else {
		mHolder.cbFeature.removeAll();
		if (hint.length>0) {
			mHolder.cbFeature.addItem({data:-1, label:hint});
		}
		for (var attr in locationdata[locationindex].features) {
			mHolder.cbFeature.addItem({data:locationdata[locationindex].features[attr], label:attr});
		}
	}
	mHolder.cbChoice.selectedIndex = locationindex+1;
	//locationdata[index].searchstring = mHolder.tSearch.text;
	//_findLocation(locationdata[index], mHolder.tSearch.text, nrlines, true);
};
flamingo.addListener(lFlamingo, "flamingo", this);




//---------------------------------------
init();
/** @tag <fmc:LocationFinder>  
* This tag defines a locationfinder. This component listens to 1 or more maps.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>
* @example
<fmc:LocationFinder include="config/lf-data.xml"
 id="locationfinder"  width="200" right="50%" top="5" bottom="bottom"  listento="map" >
<LOCATIONS  id="gemeente" >
<string id="label"  nl="Zoek een gemeente" en="Search a gemeente" />
<string id="hint"   nl="Kies een gemeente..." en="Choose a gemeente..." /> 
<LOCATION label="Achtkarspelen" extent="197249,573382,211591,587353" />
<LOCATION label="Ameland" extent="170080,603747,193989,609332" />
<LOCATION label="Het bildt" extent="165091,582112,179135,594259" />
<LOCATION label="Bolsward" extent="161979,562086,166404,566091" />
</LOCATIONS>
</fmc:LocationFinder>
* @attr resultviewer id of a resultviewer in which the results will be shown
* @attr showsearchbutton deafult:false When set to true a simple search button will be shown when the
* inputtext field is is visible. The search can be triggered either by doing an enter in the textfield 
* or by pressing the search button
* @attr include External files in which locations can be stored (comma seperated).
*/
function init():Void {
	mHolder._visible = false;
	if (flamingo == undefined) {
		var t:TextField = this.createTextField("readme", 0, 0, 0, 550, 400);
		t.html = true;
		t.htmlText = "<P ALIGN='CENTER'><FONT FACE='Helvetica, Arial' SIZE='12' COLOR='#000000' LETTERSPACING='0' KERNING='0'><B>LocationFinder "+this.version+"</B> - www.flamingo-mc.org</FONT></P>";
		return;
	}
	this._visible = false;
	//defaults
	//var xml:XML = new XML(defaultXML);
	this.setConfig(defaultXML);
	delete xml;
	//custom
	//custom
	var xmls:Array = flamingo.getXMLs(this);
	for (var i = 0; i<xmls.length; i++) {
		this.setConfig(xmls[i]);
	}
	delete xmls;
	//remove xml from repository
	flamingo.deleteXML(this);
	this._visible = visible;
	flamingo.raiseEvent(this, "onInit", this);
}
/**
* Configurates a component by setting a xml.
* @attr xml:Object Xml or string representation of a xml.
*/
function setConfig(xml:Object) {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	//load default attributes, strings, styles and cursors                    
	flamingo.parseXML(this, xml);
	//parse custom attributes
	for (var attr in xml.attributes) {
		var val:String = xml.attributes[attr];
		switch (attr.toLowerCase()) {
		case "include" :
			filesstr = val;
			break;
		case "controls" :
			if (val.toLowerCase() == "true") {
				controls = true;
			} else {
				controls = false;
			}
			break;
		case "resultviewer" :
			resultViewerId = val;
			break;	
		case "showsearchbutton" :
			if (val.toLowerCase() == "true") {
				showSearchButton = true;
			} else {
				showSearchButton = false;
			}	
			break;
		}
	}
	initControls();
	addLocation(xml);
	if (filesstr == undefined) {
		refresh();
		flamingo.raiseEvent(thisObj, "onData", thisObj);
		var arg = flamingo.getArgument(thisObj, "find");
		var a:Array = flamingo.asArray(arg);
		if (a.length == 2) {
			this.moveToLocation(a[0], a[1]);
		}
	} else {
		files = filesstr.split(",");
		for(var a:Number = 0; a < files.length; a++){ 
			loadXML(files[a]);
		}
	}
}
function loadXML(file:String) {
	if (file == undefined) {
		return;
	}
	file = flamingo.correctUrl(file);
	var xml:XML = new XML();
	xml.ignoreWhite = true;
	xml.onLoad = function(success:Boolean) {
		if (success) {
			if (this.firstChild.nodeName.toLowerCase() == "flamingo") {
				addLocation(this.firstChild);
				refresh();
				flamingo.raiseEvent(thisObj, "onData", thisObj);
				var arg = flamingo.getArgument(thisObj, "find");
				var a:Array = flamingo.asArray(arg);
				if (a.length == 2) {
					thisObj.moveToLocation(a[0], a[1]);
				}
			}
		}
	};
	xml.load(file);
}
/** @tag <locations>  
* This tag defines a source for locations. Locations can point to a server or you can define your own list with 'location' tags.
* @hierarchy childnode of <fmc:LocationFinder>  or <flamingo> in case of an external file
* @example
<flamingo>
<LOCATIONS  id="plaats"  server="www.myserver.com" service="mymapservice" layerid="searchlayer" searchfield="searchfield"  
 outputfields="NAME" extentlabel="[NAME]" extentSelector="extentSelector"
 pinlocation="true"/>
<string id="output" nl="Zoom naar [NAME]..." en="Zoom to [NAME]..."  />
<string id="label" nl="Zoek een plaats" en="Search a place"/>
<string id="hint" nl="Type een plaatsnaam of een paar letters daarvan in het tekstvak hierboven..." en="Type a placename or a few letters in the textbox..."/>
<string id="closepin" nl="verwijder lokatie indicator" en="remove loaction indicator" de="remove loaction indicator" fr="remove loaction indicator" />

</LOCATIONS>
<LOCATIONS id="ro_onlineplan0"
    server="http://afnemers.ruimtelijkeplannen.nl/afnemers/services" 
    type="WFS" serverVersion="1.1.0" srs="EPSG:28992"  
    layerid="app:Bestemmingsplangebied"  searchfield="app:naamOverheid"  
    extentselector ="extentSelector"
    outputfields="app:naamOverheid,app:identificatie,app:naam"
    highlightlayer="highlightlayer" highlightwmsurl="http://afnemers.ruimtelijkeplannen.nl/afnemers/services?service=WMS" highlightsldservleturl="http://support.idgis.eu/sldtest"  
    highlightfeaturetypename="app:Bestemmingsplangebied" highlightpropertyname="app:identificatie"
    highlightmaxscale="10" matchcase="false">
    <string id="output" nl="[app:naamOverheid]: [app:naam]" />
    <string id="label" nl="Zoek op RO-online naam overheid" />
    <string id="hint" nl="Type een (deel van de) naam overheid  in het tekstvak hierboven..." />
</LOCATIONS>
</flamingo>
* @attr id Unique identifier for each location source.
* @attr visible (defaultvalue = true) True or False.
* @attr type (defaultvalue = arcims) value shoule be arcims, arcserver or wfs.
* @attr label Label that appears in the combobox of the locationfinder. Use string tag (id="label") to support multi-languages.
* @attr hint A hint which is shown in loactionfinder. Use string tag (id="hint") to support multi-languages. 
* @attr inputprefix A prefix which is shown in the input field. Can be used if the input always starts with the same string
* @attr servlet Servletalias of ArcIMS server.
* @attr server Servername of ArcIMS server or ArcGIS Server.
* @attr service Name of mapservice.
* @attr layerid The layerid in the mapservice in which the locations can be queried.
* @attr searchfield Query field (just one).
* @attr fieldtype "n" for numeric fields. If omitted the locationfinder makes a query for string fields.
* @attr extentlabel Field for labeling the extent.
* @attr outputfields Comma seperated list of fields, the query returns, must be filled for queries on OGWFS layers
* @attr output String that will be shown in locationfinder.  [fieldname] will be replaced by actually values. Use string tag (id="output") to support multi-languages. 
* @attr srs The srs you want the gml in.
* @attr serverversion The WFS server version
* @attr enlargeextent If the min coordinates and max coordinates of the GML bbox (service type = WFS) are te same the BBOX is enlarged with this attribute
* @attr namespaces the namespaces that are needed to do a wfs request
* @attr extentSelector id of an extentSelector component
* @attr pinlocation default:false If true a found location will be pinned on the map 
* @attr matchcase default:false Only for deegree WFS. When false the searchstring is caseinsensitive.
* @attr highlightlayer id of an highlightlayer component. When a hightlightlayer is configured a found feature
* will get highlighted when an user moves the mouse over the the feature in the resultviewer. 
* @attr highlightwmsurl
* @attr highlightsldservleturl
* @attr highlightfeaturetypename
* @attr highlightpropertyname
* @attr highlightmaxscale Scale to prevent highlighting of features when the mapscale is too large. 
* If the currentmapscale is larger than the highlightmaxscale the Locationfinder will not send a GetMap request 
* to the highlightwms but the BBox of found feature will be shown instead.
*/
//
/** @tag <location>  
* This tag is used for making your own xml list of locations. See example above.
* @hierarchy childnode of <locations> 
* @attr label Label of location. (No multi language support by using string tag)
* @attr extent Extent of location as comma seperated string. minx,miny,maxx,maxy 
*/
//      
function addLocation(xml:Object) {
	if (typeof (xml) == "string") {
		xml = new XML(String(xml)).firstChild;
	}
	var xnode:Array = xml.childNodes;
	if (xnode.length>0) {
		for (var i:Number = 0; i<xnode.length; i++) {
			if (xnode[i].nodeName.toLowerCase() == "locations") {
				var location = new Object();
				//set default values
				location.visible = true;
				location.type = "arcims";
				location.dataframe ="Layers";

				location.language = new Object();
				flamingo.parseString(xnode[i], location.language);
				locationdata.push(location);
				for (var attr in xnode[i].attributes) {
					var val:String = xnode[i].attributes[attr];
					switch (attr.toLowerCase()) {
					case "id" :
						location.id = val;
						break;
					case "visible" :
						if (val.toLowerCase() == "false") {
							location.visible = false;
						}
						break;
					case "type" :
						location.type = val;
						break;
					case "label" :
						location.label = val;
						break;
					case "hint" :
						location.hint = val;
						break;
					case "servlet" :
						location.servlet = val;
						break;
					case "server" :
						location.server = val;
						break;
					case "service" :
						location.service = val;
						break;
					case "dataframe" :
						location.dataframe = val;
						break;
					case "layerid" :
						location.layerid = val;
						break;
					case "searchfield" :
						location.searchfield = val;
						break;
					case "fieldtype" :
						location.fieldtype = val;
						break;
					case "extentlabel" :
						location.extentlabel = val;
						break;
					case "outputfields" :
						if (val.indexOf(",", 0)>=0) {
							var a:Array = flamingo.asArray(val);
							val = a.join(" ");
						}
						location.outputfields = val;
						break;
					case "output" :
						location.output = val;
						break;
					case "srs" :						
						location.srs = val;						
						break;
					case "serverversion" :
						location.serverVersion = val;
						break;
					case "enlargeextent":
						location.enlargeExtent=Number(val);
						break;
					case "namespaces":
						var ns:Array = val.split(",");
						namespaces=new Object();
						for (var b:Number=0; b < ns.length; b++){
							namespaces[ns[b].split("=")[0]]=ns[b].split("=")[1];
						}
						break;
					case "highlightlayer":
           				location.hllayerid = String(val);	
						break;
    				case "highlightwmsurl":
    					location.wmsUrl = String(val);
    					break;
    				case "highlightsldservleturl":
    					location.sldServletUrl = String(val);
    					break;
    				case "highlightfeaturetypename":
    					location.featureTypeName = String(val);
    					break;
    				case "highlightpropertyname":
    					location.propertyName = String(val);
    					break;
    				case "highlightmaxscale":
    					location.highlightmaxscale = Number(val);
    					break;		
    				case "pinlocation":
						if(val=="true"){
							location.pinLocation = true;
						} else {
							location.pinLocation = false;
						}						
						break;	
					case "closepin":
						location.closePin = val;					
						break;		
					case "extentselector":
						location.extentSelector=_global.flamingo.getComponent(val);
						flamingo.addListener(this, location.extentSelector, this);
						break;	
					case "matchcase":
						if(val=="true"){
							location.matchCase = true;
						} else {
							location.matchCase = false;
						}
						break;		
				    default: 
						flamingo.tracer("unknown attribute in confige file for LocationFinder: "+attr);
					}
				}
				
				for (var j:Number = xnode[i].childNodes.length-1; j>=0; j--) {
					switch (xnode[i].childNodes[j].nodeName.toLowerCase()) {
					case "location" :
						var label;
						var ext = new Object();
						for (var attr in xnode[i].childNodes[j].attributes) {
							var val:String = xnode[i].childNodes[j].attributes[attr];
							switch (attr.toLowerCase()) {
							case "label" :
								label = val;
								break;
							case "extent" :
								var as = val.split(",");
								ext.minx = as[0];
								ext.miny = as[1];
								ext.maxx = as[2];
								ext.maxy = as[3];
								break;
							}
						}
						if (ext != undefined and label != undefined) {
							if (location.features == undefined) {
								location.features = new Object();
							}
							ext.name = label;
							location.features[label] = ext;
						}
						break;
					}
				}
			}
		}
	}
}
function refresh() {
	if (not controls) {
		return;
	}
	var nr:Number = 1
	mHolder.cbChoice.removeAll();
	mHolder.cbChoice.addItem({data:-1, label:flamingo.getString(thisObj, "label")});
	for (var i = 0; i<locationdata.length; i++) {
		if (locationdata[i].visible) {
			nr++
			var label = getString(locationdata[i], "label");
			mHolder.cbChoice.addItem({data:i, label:label});
		}
	}
  mHolder.cbChoice.setRowCount(nr);
	
}


function onChangeSearchExtent(){
	_findLocation(locationdata[locationindex], locationdata[locationindex].searchstring, nrlines, true);
}

/**
* Search 1 location and moves to it's extent
* @param locationfinderid:String Id of locations source.
* @param search:String Searchstring.
*/
function moveToLocation(locationfinderid:String, search:String) {
	mHolder.tFeatures._visible = true;
	findLocation(locationfinderid, search, 1, true);
}
/**
* Search a location
* @param locationfinderid:String Id of locations source.
* @param search:String Searchstring.
* @param nr:Number Number of search results.
* @param zoom:Boolean [optional] True: Zooms map to extent.
*/
function findLocation(locationfinderid:String, search:String, nr:Number, zoom:Boolean) {
	if (zoom == undefined) {
		zoom = false;
	}
	if (nr == undefined) {
		nr = 1;
	}
	flamingo.deleteArgument(this, "location");
	foundlocations = new Array();
	for (var i = 0; i<locationdata.length; i++) {
		var lf = locationdata[i];
		if (lf.id.toLowerCase() == locationfinderid.toLowerCase()) {
			if (lf.features != undefined) {
				// find a feature in the features collection
				for (var attr in lf.features) {
					if (attr.toLowerCase().indexOf(search.toLowerCase(), 0)>=0) {
						foundlocations.push({label:attr, extent:lf.features[attr]});
					}
					if (foundlocations.length == nr) {
						break;
					}
				}
				flamingo.raiseEvent(thisObj, "onFindLocation", thisObj, foundlocations, false);
				if (zoom) {
					_zoom(0);
				}
			} else {
				//find a feature on a server
				_findLocation(lf, search, nr, false, zoom);
			}
		}
	}
}

//function is called when pressing the searchbutton or onEnter the tSearch field
function find():Void {
	if (mHolder.tSearch.text.length>0) {
		beginrecord = 1;
		var index = mHolder.cbChoice.selectedItem.data;
		locationdata[index].searchstring = mHolder.tSearch.text;
		entersDone++;				
		setTimeout(function(){_findLocation(locationdata[index], mHolder.tSearch.text, nrlines, true);}, 100 );
	}
}


function _findLocation(locationdata:Object, search:String, nr:Number, updatefeatures:Boolean, zoom:Boolean) {	
	entersDone--;
	//when a location is entered via the url the entersDone will be smaller than zero
	if (entersDone<=0){
		if (locationdata.type.toUpperCase()=='WFS'){
			_findLocationWFS(locationdata,search,nr,updatefeatures,zoom);
		}else{
			_findLocationARC(locationdata,search,nr,updatefeatures,zoom);
		}
	}else{
		return;
	}
}

function _findLocationWFS(locationdata:Object, search:String, nr:Number, updatefeatures:Boolean, zoom:Boolean) {	
	//No need to parse the geometry
	contextObject = new Object();
	contextObject.parseGeometry = false;
	contextObject.parseEnvelope = true;
	var lConn = new ActionEventListener();
	lConn.onActionEvent= function(actionEvent:ActionEvent){
		var sourceClassName:String = actionEvent.getSourceClassName();
		var actionType:Number = actionEvent.getActionType();
		if (sourceClassName + "_" + actionType == "ServiceConnector_" + ActionEvent.LOAD) {
            var exceptionMessage:String = actionEvent["exceptionMessage"];
            var serviceLayer:ServiceLayer = ServiceLayer(actionEvent["serviceLayer"]);
			var serviceFeatures:Array = actionEvent["features"];
            var transactionResponse:TransactionResponse = TransactionResponse(actionEvent["transactionResponse"]);
            if (exceptionMessage != null) {
                _global.flamingo.showError("Fout bij het laden", exceptionMessage, 0);
            } else if (serviceLayer != null) {
				var whereClauses:Array = new Array();
				whereClauses.push(whereClause);
				var env:Envelope = null;
				var reqprops:Array = locationdata.outputfields.split(" ");
				if (extent instanceof Geometry) {
					conn.performGetFeature(serviceLayer, Geometry(extent), whereClauses, null, false, this, reqprops, thisObj.contextObject);
				} else if (!isNaN(extent.minx) && !isNaN(extent.maxx) && !isNaN(extent.miny) && !isNaN(extent.maxy)){
					env = new Envelope(extent.minx, extent.miny, extent.maxx, extent.maxy) ;
                	conn.performGetFeature(serviceLayer, env, whereClauses, null, false, this, reqprops, contextObject);
				} else {
					conn.performGetFeature(serviceLayer, null, whereClauses, null, false, this, reqprops, contextObject);
				}
			} else if (serviceFeatures != null) {
				foundlocations = new Array();
            	var label = getString(locationdata, "output");	
            	for(var i:Number = 0;i < serviceFeatures.length;i++ ){
					var loc:Object = new Object();
					var env:Envelope = serviceFeatures[i].getEnvelope();
					var ext:Object = new Object();
					ext.minx = env.getMinX();
					ext.miny = env.getMinY();
					ext.maxx = env.getMaxX();
					ext.maxy = env.getMaxY();
					//if its a extent of a point, enlarge it:
					if (ext.minx==ext.maxx && ext.miny==ext.maxy&&locationdata.enlargeExtent!=undefined){													
						ext.minx=Number(ext.minx)-locationdata.enlargeExtent;
						ext.miny=Number(ext.miny)-locationdata.enlargeExtent;
						ext.maxx=Number(ext.maxx)+locationdata.enlargeExtent;
						ext.maxy=Number(ext.maxy)+locationdata.enlargeExtent;					
					}

					loc.locationdata = locationdata;			
					loc.extent = ext;
					loc.label = "";
					if (label.length>0) {
						var lbl:String = label;
						var props:Array = serviceFeatures[i].getServiceLayer().getServiceProperties();
	            		for(var l:Number = 0;l < props.length;l++ ){
							//LV ?? "|"in output string??
							//var fieldIndex:Number= label.indexOf("|"+field);
							//if (fieldIndex < 0){
							//fieldIndex= label.indexOf(field+"|");
							//}
							if(locationdata.propertyName!=null){
								if(props[l].getName()==locationdata.propertyName){
									loc.propertyvalue =  serviceFeatures[i].getValue(props[l].getName());
								}
							}
	            			var n:Number =lbl.indexOf("["+props[l].getName()+"]", 0);
	            			if (n >= 0) {
								lbl = lbl.substring(0,n) + serviceFeatures[i].getValue(props[l].getName()) +
										lbl.substr(n + (props[l].getName()).length + 2);
	            			}
	            			if(serviceFeatures[i].getValue(props[l].getName())!=undefined){
	            				//Do not add the geometry value (causes prolems while raising the event width serializing in js)  
	            				if(serviceFeatures[i].getServiceLayer().getDefaultGeometryProperty()==props[l].getName() == false){
	            					loc[props[l].getName()] = serviceFeatures[i].getValue(props[l].getName());
	            				}	 
	            			}          			
	            			
	            		}
					}
				
				// add extent label ????
				/*var extentlabel = getString(locationdata, "extentlabel");
				if (extentlabel.length>0) {
					for (var field in r) {
						if (extentlabel.indexOf(field, 0)>=0) {
							extentlabel = extentlabel.split("["+field+"]").join(r[field]);
						}
					}
					r.extent.name = extentlabel;
				}	*/
				loc.label = lbl;
				foundlocations.push(loc);
				}
								 
				
				flamingo.raiseEvent(thisObj, "onFindLocation", thisObj, foundlocations, updatefeatures);
				if (updatefeatures) {
					_updateFeatures(hasmore);
				}		
				if (zoom) {
					_zoom(0);
				}
            } 
		}

	};
	
	var server = locationdata.server;
	var layerid = locationdata.layerid;
	var searchfield = locationdata.searchfield;
	
	var url:String = locationdata.type.toLowerCase() + "::" + server;
	var  conn:ServiceConnector = ServiceConnector.getInstance(url);
	conn.setSrsName(locationdata.srs);
	if(locationdata.serverVersion!=undefined){
		conn.setServiceVersion(locationdata.serverVersion);
	}
	map = flamingo.getComponent(this.listento[0]);
	//Get extent
	var extent:Object = null;
	if (currentExtentSelector!=null){
		extent = currentExtentSelector.getCurrentExtent().getExtent();
	} else {
		extent = map.getFullExtent();
	}


	conn.performDescribeFeatureType(layerid, lConn, contextObject);
	var whereClause:WhereClause = new WhereClause(searchfield,locationdata.fieldtype.toLowerCase() == "n" ? search : '*'+search+'*',
										WhereClause.LIKE,locationdata.matchCase != undefined ? locationdata.matchCase : false );
	if (updatefeatures) {
		var str:String = "<span class='busy'>"+flamingo.getString(thisObj, "busy")+"</span>";
		if(resultViewerId!=null){
			showTextInResultViewer(str);
		} else {	
			mHolder.tFeatures.htmlText = str;
		}
	}
}
function _findLocationARC(locationdata:Object, search:String, nr:Number, updatefeatures:Boolean, zoom:Boolean) {
	//Get extent
	map = flamingo.getComponent(this.listento[0]);
	var extent:Object = null;
	if (currentExtentSelector!=null){
		extent = currentExtentSelector.getCurrentExtent().getExtent();
	} else {
		extent = map.getFullExtent();
	}
 	if (extent instanceof Geometry){
 		ext = new Object();
 		ext.minx = extent.getEnvelope().getMinX();
		ext.miny = extent.getEnvelope().getMinY();
		ext.maxx = extent.getEnvelope().getMaxX();
		ext.maxy = extent.getEnvelope().getMaxY(); 
 		extent = ext;
 	}
	//Make query
	var astr = search.toUpperCase().split(" ");
	if (astr.length == 0) {
		return;
	}
	var query = "";
	var layerid:String ="";
	var layerids:Array = map.getLayers();

	for(var j = 0; j< layerids.length; j++)
	{	
		var layer = flamingo.getComponent(layerids[j]);
		if( layer.mapservice == locationdata.service )
		{
			layerid = layerids[j];
		}		
	}
	if(layerid != "")
	{
		var layerObj = flamingo.getComponent(layerid);
		query = layerObj.getLayerProperty(locationdata.layerid, "query").toString();
	}
	if (locationdata.fieldtype.toLowerCase() == "n") {
		for (var i = 0; i<astr.length; i++) {
			if (astr[i].length>0) {
				if (query.length == 0) {
					query = locationdata.searchfield+"="+astr[i];
				} else {
					query = query+" or "+locationdata.searchfield+"="+astr[i];
				}
			}
		}
	} else {
		for (var i = 0; i<astr.length; i++) {
			if (astr[i].length>0) {
				if (query.length == 0) {
					query = "UPPER("+locationdata.searchfield+") like '%"+astr[i]+"%'";
				} else {
					if(query == undefined)
					{
						query = "UPPER("+locationdata.searchfield+") like '%"+astr[i]+"%'";
					}
					else
					{
						query = query+" "+"AND"+" UPPER("+locationdata.searchfield+") like '%"+astr[i]+"%'";
					}
					
				}
			}
		}
	}
	//Events of ArcServerConnector
	var lConnArcServer = new Object();
	lConnArcServer.onResponse = function(connector:ArcServerConnector) {
		mHolder.tFeatures.htmlText = "";
		//flamingo.raiseEvent(thisObj, "onServerResponse", thisObj, responseobject);
	};
	lConnArcServer.onRequest = function(connector:ArcServerConnector) {
		//flamingo.raiseEvent(thisObj, "onServerRequest", thisObj, requestobject);
	};
	lConnArcServer.onError = function(error:String, objecttag:Object, requestid:String) {
		flamingo.raiseEvent(thisObj, "onError", thisObj, error);
		if (updatefeatures) {
			mHolder.tFeatures.htmlText = "<span class='error'>"+error+"</span>";
		}
	};
	lConnArcServer.onGetFeatures = function(layerid:String, data:Array, count:Number, hasmore:Boolean, objecttag:Object) {
		foundlocations = new Array();		
		var len:Number =nrlines;
		var num:Number = Number(thisObj.beginrecord) + nrlines -1;
		
		if(data.length > num)
		{
			len = num;			
		}
		else
		{
			len = data.length;
			hasmore =false;
		}
		for (var i = thisObj.beginrecord-1; i<len; i++) {
			var r = new Object();
			r.locationdata = locationdata;
			delete data[i]["#SHAPE#"];
			for (var field in data[i]) {				
				if (field == "SHAPE.ENVELOPE") {
					r.extent = data[i][field];
				} else {
					var a = field.split(".");
					r[a[a.length-1]] = data[i][field];
				}
			}
			//outputstring
			var label = getString(locationdata, "output");
			if (label.length>0) {
				for (var field in r) {
					if (label.indexOf(field, 0)>=0) {
						label = label.split("["+field+"]").join(r[field]);
					}
				}
				r.label = label;
			} else {
				r.label = r[0];
			}
			// add extent label
			var extentlabel = thisObj.getString(locationdata, "extentlabel");
			
			if (extentlabel.length>0) {
				for (var field in r) {
					if (extentlabel.indexOf(field, 0)>=0) {
						extentlabel = extentlabel.split("["+field+"]").join(r[field]);
					}
				}
				r.extent.name = extentlabel;
			}
			//done                             
			foundlocations.push(r);
		}

		delete data;
		flamingo.raiseEvent(thisObj, "onFindLocation", thisObj, foundlocations, updatefeatures);
		if (updatefeatures) {
			_updateFeatures(hasmore);
		}
		if (zoom) {
			_zoom(0);
		}
	};
	
	//Events of ArcImsConnector
	var lConnArcIMS = new Object();
	lConnArcIMS.onResponse = function(connector:ArcIMSConnector) {
		mHolder.tFeatures.htmlText = "";
		//flamingo.raiseEvent(thisObj, "onServerResponse", thisObj, responseobject);
	};
	lConnArcIMS.onRequest = function(connector:ArcIMSConnector) {
		//flamingo.raiseEvent(thisObj, "onServerRequest", thisObj, requestobject);
	};
	lConnArcIMS.onError = function(error:String, objecttag:Object, requestid:String) {
		flamingo.raiseEvent(thisObj, "onError", thisObj, error);
		if (updatefeatures) {
			mHolder.tFeatures.htmlText = "<span class='error'>"+error+"</span>";
		}
	};
	lConnArcIMS.onGetFeatures = function(layerid:String, data:Array, count:Number, hasmore:Boolean, objecttag:Object) {
		foundlocations = new Array();
		for (var i = 0; i<data.length; i++) {
			var r = new Object();
			r.locationdata = locationdata;
			delete data[i]["#SHAPE#"];
			for (var field in data[i]) {
				if (field == "SHAPE.ENVELOPE") {
					r.extent = data[i][field];
				} else {
					var a = field.split(".");
					r[a[a.length-1]] = data[i][field];
				}
			}
			//outputstring
			var label = getString(locationdata, "output");
			if (label.length>0) {
				for (var field in r) {
					if (label.indexOf(field, 0)>=0) {
						label = label.split("["+field+"]").join(r[field]);
					}
				}
				r.label = label;
			} else {
				r.label = r[0];
			}
			// add extent label
			var extentlabel = getString(locationdata, "extentlabel");
			if (extentlabel.length>0) {
				for (var field in r) {
					if (extentlabel.indexOf(field, 0)>=0) {
						extentlabel = extentlabel.split("["+field+"]").join(r[field]);
					}
				}
				r.extent.name = extentlabel;
			}
			//done                             
			foundlocations.push(r);
		}
		delete data;
		flamingo.raiseEvent(thisObj, "onFindLocation", thisObj, foundlocations, updatefeatures);
		if (updatefeatures) {
			_updateFeatures(hasmore);
		}
		if (zoom) {
			_zoom(0);
		}
	};
	var server = locationdata.server;
	var service = locationdata.service;
	var servlet = locationdata.servlet;
	var layerid = locationdata.layerid;
	var outputfields = locationdata.outputfields+" #ID#";
	var searchfield = locationdata.searchfield;

	if(locationdata.type.toLowerCase() == "arcims")
	{
		var connArcIMS:ArcIMSConnector = new ArcIMSConnector(server, service);
		if (servlet.length>0) {
			connArcIMS.servlet = servlet;
		}	
		connArcIMS.addListener(lConnArcIMS);
		connArcIMS.featurelimit = nr;
		connArcIMS.envelope = true;
		if (updatefeatures) {
			connArcIMS.beginrecord = this.beginrecord;
		} else {
			connArcIMS.beginrecord = 1;
		}
		connArcIMS.getFeatures(service, layerid, extent, outputfields, query, objecttag);
		if (updatefeatures) {
			var str:String  = "<span class='busy'>"+flamingo.getString(thisObj, "busy")+"</span>";
				if(resultViewerId!=null){
					showTextInResultViewer(str);
				} else {
					mHolder.tFeatures.htmlText = str;
				}
		}
	}
	else if(locationdata.type.toLowerCase() == "arcserver")
	{
		var connArcServer:ArcServerConnector = new ArcServerConnector(server);

		connArcServer.addListener(lConnArcServer);
		connArcServer.featurelimit = nr;
		connArcServer.envelope = true;
		if (updatefeatures) {
			connArcServer.beginrecord = this.beginrecord;
		} else {
			connArcServer.beginrecord = 1;
		}
		map = flamingo.getComponent(this.listento[0]);			
		connArcServer.dataframe = locationdata.dataframe;

		connArcServer.getFeatures(service, layerid, extent, outputfields, query);
		if (updatefeatures) {
			var str:String ="<span class='busy'>"+flamingo.getString(thisObj, "busy")+"</span>";
			if(resultViewerId!=null){
				showTextInResultViewer(str);
			} else {
				mHolder.tFeatures.htmlText = str; 
			}
		}
	}	
}

function _updateFeatures(hasmore:Boolean) {
	var str = "";
	if (foundlocations.length>0) {
		foundlocations.sortOn("label");
		for (var i = 0; i<foundlocations.length; i++) {
			var value:String = foundlocations[i].label;
			//replace < with &lt; < causes problems in a htmlTextField
			var valArray:Array = value.split("<");
			if(valArray.length>1){
				value=valArray[0];
				for(var j:Number=1;j<valArray.length;j++){
					value+="&lt;" + valArray[j];
				}
			}	
			
			if (str.length == 0) {
				str = "<span class='feature'><a href='asfunction:_parent._zoom,"+i+"'>"+value+"</a></span>";
			} else {
				str = str+"<br><span class='feature'><a href='asfunction:_parent._zoom,"+i+"'>"+value+"</a></span>";
			}
			foundlocations[i].str = "<span class='feature'><a href='asfunction:_parent._zoom,"+i+"'>"+value+"</a></span>";
		}
		if (hasmore) {
			if (this.beginrecord == 1) {
				str = str+"<br><br>"+"<span class='next'><a href='asfunction:_parent._next'>"+flamingo.getString(thisObj, "next")+"</a></span>";
			} else {
				str = str+"<br><br>"+"<span class='prev'><a href='asfunction:_parent._prev'>"+flamingo.getString(thisObj, "prev")+"</a></span><span class='next'><a href='asfunction:_parent._next'>"+flamingo.getString(thisObj, "next")+"</a></span>";
			}
		} else {
			if (this.beginrecord == 1) {
			} else {
				str = str+"<br><br>"+"<span class='prev'><a href='asfunction:_parent._prev'>"+flamingo.getString(thisObj, "prev")+"</a></span>";
			}
		}
	} else {
		str = "<span class='nohit'>"+flamingo.getString(thisObj, "nohit")+"</span>";
	}
	if(resultViewerId==null){
		mHolder.tFeatures.wordWrap = false;
		mHolder.tFeatures.htmlText = str;
	} else {
		mHolder.tFeatures.htmlText = "";	
		if(foundlocations.length>0 && foundlocations[0].locationdata.hllayerid != null){
			resultViewer.setLocations(foundlocations);
		} else {
			resultViewer.setText(str);
		}
	}
}
function _zoom(index:Number) {
	var ext = foundlocations[index].extent;
	var sext = extent2String(ext);
	if (ext != undefined) {
		for (var i = 0; i<this.listento.length; i++) {
			map = flamingo.getComponent(listento[i]);
			
			if (map != undefined) {
				var location:Object = locationdata[mHolder.cbChoice.selectedIndex -1]
				if(location.pinLocation){
					coord = new Object();
					coord.x = Number(ext.minx) + (Number(ext.maxx) - Number(ext.minx))/2;
					coord.y = Number(ext.maxy) - (Number(ext.maxy) - Number(ext.miny))/2;
					if(locationPin == null){
						map.createEmptyMovieClip("mPin", map.getNextHighestDepth());
						var thisObj:Object = this;
						mc.createEmptyMovieClip("mSymbol", 2);
						var listener:Object = new Object();
						listener.onLoadInit = function(mc:MovieClip) {
							thisObj.locationPin = mc.kid;
							thisObj.locationPin.setMap(thisObj.map);
							thisObj.locationPin.setCoord(thisObj.coord);
							
							thisObj.locationPin.setTooltipText(_global.flamingo.getString(thisObj, "closepin"));
							thisObj.locationPin.placePin();	
							
						};
						var mcl:MovieClipLoader = new MovieClipLoader();
						mcl.addListener(listener);
						mcl.loadClip(_global.flamingo.correctUrl("fmc/LocationPin.swf"), map.mPin);	
					} else {
						locationPin.setCoord(coord);
					}
				}
				map.moveToExtent(ext, 0);	
			} else {
				flamingo.setArgument(listento[i], "extent", sext);
			}
		}
	}

}





function extent2String(extent:Object):String {
	return (extent.minx+","+extent.miny+","+extent.maxx+","+extent.maxy);
}
function _next() {
	var index = mHolder.cbChoice.selectedItem.data;
	this.beginrecord = this.beginrecord+nrlines;
	_findLocation(locationdata[index], locationdata[index].searchstring, nrlines, true);
}
function _prev() {
	var index = mHolder.cbChoice.selectedItem.data;
	this.beginrecord = this.beginrecord-nrlines;
	if (this.beginrecord<1) {
		this.beginrecord = 1;
	}
	_findLocation(locationdata[index], locationdata[index].searchstring, nrlines, true);
}
function initControls() {
	if (not controls) {
		mHolder._visible = false;
		return;
	}
	mHolder._visible = true;
	//this.createEmptyMovieClip("mHolder", 0);
	mHolder._lockroot = true;
	//mHolder.createClassObject(mx.controls.ComboBox, "cbChoice", 1);
	//
	mHolder.cbChoice.drawFocus = "";
	mHolder.cbChoice.getDropdown().drawFocus = "";
	
	//mHolder.cbChoice.onKillFocus = function(newFocus:Object) {
		//super.onKillFocus(newFocus);
	//};
	//mHolder.cbChoice.borderStyle = "none";
	//mHolder.cbChoice.backgroundColor = 0x000000
	mHolder.cbChoice.themeColor = 0x999999;
	mHolder.cbChoice.rollOverColor = 0xE6E6E6;
	mHolder.cbChoice.selectionColor = 0xCCCCCC;
	//mHolder.cbChoice.color = 0x000000
	//mHolder.cbChoice.textRollOverColor = 0x000000
	mHolder.cbChoice.textSelectedColor = 0x000000;
	//mHolder.cbChoice.fontFamily = "Verdana";
	//mHolder.cbChoice.fontSize = 9;
	// to prevent the list to close after scrolling
	mHolder.cbChoice.onKillFocus = function(newFocus:Object) {
			super.onKillFocus(newFocus);
	};
	var cbListener:Object = new Object();
	// Create event handler function.
	cbListener.change = function(evt_obj:Object) {
		this.beginrecord = 1;
		mHolder.tFeatures.htmlText = "";
		locationindex = evt_obj.target.selectedItem.data;
		mHolder.tFeatures._visible = false;
		mHolder.tSearch._visible = false;
		mHolder.tFind._visible = false;
		mHolder.cbFeature._visible = false;
		if (locationindex == -1) {
			return;
		}
		var hint = getString(locationdata[locationindex], "hint");
		var label = getString(locationdata[locationindex], "label");
		var inputPrefix = getString(locationdata[locationindex], "inputprefix");

		for (var i in locationdata ) {
			if(locationdata[i].extentSelector!=null){
				locationdata[i].extentSelector.setVisible(false,"locationFinder");
			}
			tFeaturesDelta = 0;
		}
		currentExtentSelector = locationdata[locationindex].extentSelector;
		
		if(currentExtentSelector!=null){
			currentExtentSelector.setVisible(true,"locationFinder");
			tFeaturesDelta = 10 + currentExtentSelector.getExtents().length * 20;
		}
		if (locationdata[locationindex].features == undefined) {
			locationdata[locationindex].searchstring = "";
			mHolder.tFeatures._visible = true;
			mHolder.cbFeature._visible = false;
			mHolder.cbFeature.removeAll();
			mHolder.tSearch._visible = true;
			if(showSearchButton){
				mHolder.tFind._visible = true;
			}
			if (inputPrefix.length>0) {
				mHolder.tSearch.text = inputPrefix;
			} else {
				mHolder.tSearch.text = "";
			}
			_global['setTimeout'](mHolder.tSearch, 'setFocus', 10);
			//
			//if (locationdata[locationindex].searchstring.length > 0){
			//tSearch.text = locationdata[locationindex].searchstring
			//} else {
			//}
			if (hint.length>0) {
				mHolder.tFeatures.wordWrap = true;
				mHolder.tFeatures.htmlText = "<span class='hint'>"+hint+"</span>";
			}
			//Selection.setSelection(0, 5);                                
		} else {
			mHolder.cbFeature.removeAll();
			if (hint.length>0) {
				mHolder.cbFeature.addItem({data:-1, label:hint});
			}
			for (var attr in locationdata[locationindex].features) {
				mHolder.cbFeature.addItem({data:locationdata[locationindex].features[attr], label:attr});
			}
			mHolder.cbFeature._visible = true;
			_global['setTimeout'](mHolder.cbFeature, 'setFocus', 10);
			//mHolder.cbFeature.open();
		}
		resize();
	};
	mHolder.cbChoice.addEventListener("change", cbListener);
	//
	//mHolder.createClassObject(mx.controls.ComboBox, "cbFeature", 2);
	//mHolder.cbFeature.borderStyle = "none";
	//mHolder.cbFeature.backgroundColor = 0x000000
	mHolder.cbFeature.themeColor = 0x999999;
	mHolder.cbFeature.rollOverColor = 0xE6E6E6;
	mHolder.cbFeature.selectionColor = 0xCCCCCC;
	//mHolder.cbFeature.color = 0x000000
	//mHolder.cbFeature.textRollOverColor = 0x000000
	mHolder.cbFeature.textSelectedColor = 0x000000;
	//mHolder.cbFeature.fontFamily = "Verdana";
	//mHolder.cbFeature.fontSize = 9;
	mHolder.cbFeature.drawFocus = "";
	mHolder.cbFeature.getDropdown().drawFocus = "";
	// to prevent the list to close after scrolling
	mHolder.cbFeature.onKillFocus = function(newFocus:Object) {
			super.onKillFocus(newFocus);
	};
	var cbListener2:Object = new Object();
	// Create event handler function.
	cbListener2.change = function(evt_obj:Object) {
		mHolder.cbFeature.__dropdown.drawFocus = "";
		var label = evt_obj.target.selectedItem.label;
		var ext = evt_obj.target.selectedItem.data;
		foundlocations = new Array();
		foundlocations.push({label:label, extent:ext});
		_zoom(0);
		flamingo.raiseEvent(thisObj, "onFindLocation", thisObj, foundlocations, true);	
	};
	mHolder.cbFeature.addEventListener("change", cbListener2);
	//
	//mHolder.createClassObject(mx.controls.TextInput, "tSearch", 3);
	mHolder.tSearch.drawFocus = "";
	var tListener:Object = new Object();
	tListener.handleEvent = function(evt_obj:Object) {
		switch (evt_obj.type) {
		case "enter" :
			thisObj.find();
			break;
		case "change" :
			var index = mHolder.cbChoice.selectedItem.data;
			if (tSearch.text.charCodeAt(tSearch.text.length-1) == 27) {
				if (locationdata[index].searchstring.length>0) {
					mHolder.tSearch.text = locationdata[index].searchstring;
				} else {
					mHolder.tSearch.text = "";
				}
			}
			locationdata[index].searchstring = mHolder.tSearch.text;
			break;
		}
	};
	// Add listener.
	mHolder.tSearch.addEventListener("enter", tListener);
	mHolder.tSearch.addEventListener("change", tListener);
	//
	mHolder.createTextField("tFeatures", 4, 0, 0, 1, 1);
	//mc.mLabel.border = true;
	mHolder.tFeatures.styleSheet = flamingo.getStyleSheet(this);
	mHolder.tFeatures.wordWrap = true;
	mHolder.tFeatures.multiline = true;
	mHolder.tFeatures.html = true;
	//mHolder.tFeatures.border = true;
	mHolder.tFeatures.selectable = false;
	//
	mHolder.tFeatures._visible = false;
	mHolder.tSearch._visible = false;
	mHolder.tFind._visible = false;
	mHolder.cbFeature._visible = false;
	mHolder.btnSearch._visible = false;
	resize();
}
function resize() {
	if (not controls) {
		return;
	}
	beginrecord = 1;
	var r = flamingo.getPosition(thisObj);
	var x = r.x;
	var y = r.y;
	var w = r.width;
	var h = r.height;

	mHolder._y = y;
	mHolder.setSize(w,10);
	
	//
	mHolder.cbChoice._x = x;
	mHolder.cbChoice.setSize(w, 22);
	//
	mHolder.cbFeature._x = x;
	mHolder.cbFeature._y = 24;
	mHolder.cbFeature.setSize(w, 22);
	//
	mHolder.tSearch._x = x;
	mHolder.tSearch._y = 24;
	mHolder.tSearch.setSize(w , 22);
	if(showSearchButton){
		mHolder.tSearch.setSize(w - 22 , 22);
		mHolder.tFind._x = w - 13;
		mHolder.tFind._y = 24;
		mHolder.tFind.setSize(22, 22);
		mHolder.tFind.editable = false;
		mHolder.tFind.background = true;
		mHolder.tFind.backgroundColor = 0xcccccc;
		mHolder.tFind.html = true;
		mHolder.tFind.text="<a href='asfunction:_parent._parent.find'><b>>></b></a>";
	}
	
	mHolder.tFeatures._x = x;
	mHolder.tFeatures._y = tFeaturesDelta+48;
	mHolder.tFeatures._width = w;
	mHolder.tFeatures._height = h-tFeaturesDelta-48;
	//-mHolder.tFeatures._y;
	// calculate number of lines
	mHolder.tFeatures.htmlText = "<span class='feature'>XXXYYYgggg</span>";
	var th:Number = mHolder.tFeatures.textHeight;
	if(resultViewerId==null){
		nrlines = Math.floor((mHolder.tFeatures._height-(th*2))/th)-2;
	} else {
		var resultViewer:Object = _global.flamingo.getComponent(resultViewerId);
		nrlines = Math.floor((0.8*resultViewer.__height)/th)-2;
	}
	var nritems = Math.floor((h-48)/22);
	mHolder.tFeatures.htmlText = "";
	mHolder.cbFeature.setRowCount(Math.max(2, nritems));
}
function getString(item:Object, stringid:String):String {
	var lang = flamingo.getLanguage();
	var s = item.language[stringid][lang];
	if (s != undefined) {
		return s;
	}
	s = item[stringid];
	if (s != undefined) {
		return s;
	}
	for (var attr in item.language[stringid]) {
		return item.language[stringid][attr];
	}
	return "";
}

function showTextInResultViewer(text:String):Void{
	resultViewer = _global.flamingo.getComponent(resultViewerId);
	resultViewer.setLocationFinder(this);
	resultViewer.setVisible(true);
	resultViewer.setText(text);
}
/**
* Dispatched when 'findLocation' or 'moveToLocation' is called or when a location is set by using the controls.
* @param locationfinder:MovieClip a reference or id of the locationfinder.
* @param foundLocations:Array Array with location objects. A location object has a label and a extent property
* @param internal:Boolean True: event dispatched by using the controls, false: event dispatched by calling methods.
*/
//public function onFindLocation(locationfinder:MovieClip,  foundLocations:Array, internal:Boolean):Void {
//
/**
* Dispatched when an error occurs.
* @param locationfinder:MovieClip a reference or id of the locationfinder.
* @param error:String error message.
*/
//public function onError(locationfinder:MovieClip,  error:String):Void {
//
/**
* Dispatched when the component is loaded.
* @param locationfinder:MovieClip a reference or id of the locationfinder.
*/
//public function onInit(locationfinder:MovieClip):Void {
//
/**
* Dispatched when the component is up and running and the locations are loaded.
* @param locationfinder:MovieClip a reference or id of the locationfinder.
*/
//public function onData(locationfinder:MovieClip):Void {
//

