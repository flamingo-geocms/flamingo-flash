/*-----------------------------------------------------------------------------
Copyright (C) 2007  Provincie Overijssel

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
-----------------------------------------------------------------------------*/
import mx.controls.UIScrollBar;
import groenloket.SubsidieInfoConfig;
import groenloket.GebisPakket;

import groenloket.AbstractComponent;

class groenloket.SubsidieInfoPB extends AbstractComponent {
    
    private var txtInfo:TextField = null;
    private var txtHeader:TextField = null;
    private var textinfo:String = "";
    private var mSBV:UIScrollBar = null;
    private var mSBH:UIScrollBar = null;
    private var denystrangers:Boolean = true;
    private var subsidieInfoConfig:SubsidieInfoConfig = null;
    
    function init():Void {
			this._visible = false;
			var window = _global.flamingo.getParent(this);
			window._visible = false;
			//
			txtHeader = this.createTextField("txtHeader", getNextHighestDepth(), 0, 0, 100, 100);
			txtHeader.wordWrap = true;
			//false;
			txtHeader.html = true;
			txtHeader.selectable = false;
			var ss = _global.flamingo.getStyleSheet(this);
			//flamingo.tracer("ss-names = " + ss.getStyleNames().join(newline));
	    	txtHeader.styleSheet = ss;
			//
			txtInfo = this.createTextField("txtInfo", getNextHighestDepth(), 0, 0, 100, 100);
			txtInfo.wordWrap = false;
			txtInfo.html = true;
			txtInfo.multiline = true;
	    txtInfo.styleSheet = ss;
			//


      var initObject:Object = new Object();
      mSBV = UIScrollBar(attachMovie("UIScrollBar", "mUIScrollBarV", getNextHighestDepth(), initObject));

			mSBV.setScrollTarget(txtInfo);
			//
      mSBH = UIScrollBar(attachMovie("UIScrollBar", "mUIScrollBarH", getNextHighestDepth(), initObject));

			mSBH.horizontal = true;
			mSBH.setScrollTarget(txtInfo);
			this._visible = false;
			
			//traceProperties();

      _global.flamingo.addListener(this, listento[0], this);
			_global.flamingo.addListener(this, _global.flamingo.getParent(this), this);

      subsidieInfoConfig = new SubsidieInfoConfig();
      
      _global.flamingo.raiseEvent(this, "onInit", this);
    }   

    function onIdentify(map:MovieClip, extent:Object):Void {
      //flamingo.tracer("onIdentify: map = " + map + ", extent = " + extent);
			this.show();
			var s = _global.flamingo.getString(this, "startidentify", "Bezig met ophalen subsidieinformatie...");
			txtHeader.htmlText = "<span class='status'>"+s+"</span>";
			txtInfo.htmlText = "";
			textinfo = "";
    }
    
    function onIdentifyComplete(map:MovieClip):Void {
      //flamingo.tracer("onIdentifyComplete: map = " + map);
			txtHeader.htmlText = "";
    	if ( txtInfo.htmlText == "" ) {
			  txtInfo.htmlText = "Perceel maakt geen deel uit van het Natuur- en/of Landschapsgebiedsplan";
    	}
    }
    
    function onIdentifyData(map:MovieClip, layer:MovieClip, data:Object, identifyextent:Object, nridentified:Number, total:Number):Void {
    	//flamingo.raiseEvent(map, "onCorrectIdentifyIcon", map, extent);
    	var layerid = _global.flamingo.getId(layer);
    	var mapid = _global.flamingo.getId(map);
    	var id = layerid.substring(mapid.length+1, layerid.length);
    	//store info 
    	//if (info[id] == undefined) {
    	//info[id] = new Object();
    	//}
    	for (var layerid in data) {
    		//store info 
    		//info[id][layerid] = data[layerid];
    		//
    		// get string from language object
    		var stringid = id+"."+layerid;
    		var infostring = _global.flamingo.getString(this, stringid);
    		if (infostring != undefined) {
    			//this layer is defined so convert infostring
    			var stripdatabase = _global.flamingo.getString(this, stringid, "", "stripdatabase");
    			for (var record in data[layerid]) {
    				textinfo += convertInfo(infostring, data[layerid][record], layerid);
    				textinfo += "";
    			}
    		} else {
    			//for this layer no infostring is defined
    			if (!denystrangers) {
    				textinfo += newline+"<b>"+id+"."+layerid+"</b>";
    				for (var record in data[layerid]) {
    					for (var field in data[layerid][record]) {
    						var a = field.split(".");
    						var fieldname = "["+a[a.length-1]+"]";
    						textinfo += newline+fieldname+"="+data[layerid][record][field];
    					}
    					//txtInfo.htmlText += newline;
    				}
    			}
    		}
    	}
    	txtInfo.htmlText = textinfo;
    	//trace(txtInfo.htmlText)
	}
		
	function convertInfo(infostring:String, record:Object, layerid:String):String {
		var t:String;
		t = infostring;
		//flamingo.tracer("infostring = " + infostring + ", layerid = " + layerid);
		//remove all returns
		t = infostring.split("\r").join("");
		//convert \\t to \t 
		t = t.split("\\t").join("\t");
		for (var field in record) {
			var value = record[field];
			//flamingo.tracer("field = " + field + ", value = '" + value + "'");
			
			var fieldname = field;
			var a = field.split(".");
			fieldname = "["+a[a.length-1]+"]";
			if ( fieldname == "[SAN_TOEG_P]" || fieldname == "[SN_TOEG_P]" ) {
      			var newvalue:String = "";
      			if (value != "niet opengesteld" && value != "") {
        			var pakketIDs = value.split(",");
        			var prefix:String = null;
    				if (layerid.indexOf("gebis_l") > -1) {
      					prefix = "LGP ";
    				} else if (fieldname == "[SAN_TOEG_P]") {
      					prefix = "SAN ";
    				} else if (fieldname == "[SN_TOEG_P]") {
      					prefix = "SN ";
    				}
			        //flamingo.tracer("fieldname = " + fieldname + " pakketIDs.length = " + pakketIDs.length + " value = " + value);
			        for (var j:Number = 0; j < pakketIDs.length; j++) {
			            var pakket:GebisPakket = subsidieInfoConfig.getPakket(prefix + pakketIDs[j])
			            newvalue = newvalue + "<a href='" + pakket.getURL() + "' target='_blank'><u>" + pakket.getDescription() + "</u></a>";
			            if (j < ( pakketIDs.length - 1 )) {
			              newvalue = newvalue + "\r\t\t";
			            }
    				}
		      		t = t.split(fieldname).join(newvalue);
     			} else {
			    	var notext:String = "";
			    	if ( fieldname == "[SAN_TOEG_P]" ) {
			      		notext = subsidieInfoConfig.getText("geen_ogb");
			    	} else {
			      		notext = subsidieInfoConfig.getText("no");
			    	}
        		t = t.split(fieldname).join(notext);
			  	}
			} else if ( fieldname == "[OGB]" ) {
			  	if (value.toUpperCase() == "JA" ) {
			    	var ogbtext:String = subsidieInfoConfig.getText("ogb");
        			t = t.split(fieldname).join(ogbtext);
			  	} else {
			    	var geen_ogbtext:String = subsidieInfoConfig.getText("geen_ogb");
			    	t = t.split(fieldname).join(geen_ogbtext);
			  	}
			} else if ( fieldname == "[GBD_SRT]" ) {
			  	if (value.toUpperCase() == "BRJ" ) {
			    	var brjtext:String = subsidieInfoConfig.getText("brj");
        			t = t.split(fieldname).join(brjtext);
				} else {
			  		t = t.split(fieldname).join("");
				}
			} else {
			  t = t.split(fieldname).join(value);
			}
		}
		return t;
	}

    function onIdentifyProgress(map:MovieClip, layersindentified:Number, layerstotal:Number, sublayersidentified:Number, sublayerstotal:Number):Void {
      //flamingo.tracer("onIdentifyProgress: map = " + map + ",layersindentified = " + layersindentified + ", layerstotal = " + layerstotal + ", sublayersidentified = " + sublayersidentified + ", sublayerstotal = " + sublayerstotal);
    }

	function show() {
	  	resize();
		//make sure that this component is visible
		_visible = true;
		var parent = this;
		while (!_global.flamingo.isVisible(this) || parent != undefined) {
			parent = _global.flamingo.getParent(parent);
			parent.show();
			parent._visible = true;
		}
    }

    function onResize(mc:MovieClip) {
      resize();
    }

	function resize() {
		txtHeader.htmlText = "  ";
		var r = _global.flamingo.getPosition(this);
		var x = r.x;
		var y = r.y;
		var w = r.width;
		var h = r.height;
		var sb = 16;
		//
		txtHeader._x = x;
		txtHeader._y = y;
		txtHeader._width = w;
		var th = txtHeader.textHeight+5;
		txtHeader._height = th;
		//
		txtInfo._x = x;
		txtInfo._y = y+th;
		txtInfo._height = h-th;
		txtInfo._width = w-sb;
		//
		mSBV.setSize(sb, h-th-sb);
		mSBV.move(x+w-sb, y+th);
		//
		mSBH.setSize(w-sb, sb);
		mSBH.move(x, y+h-sb);
		//
		var mc = createEmptyMovieClip("mLine", 10);
		with (mc) {
			lineStyle(0, 0x999999, 60);
			moveTo(x, y+th);
			lineTo(x+w, y+th);
		}
	}


}
