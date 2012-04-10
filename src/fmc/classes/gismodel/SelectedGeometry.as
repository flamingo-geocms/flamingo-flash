// This file is part of Flamingo MapComponents.
// Author: Michiel J. van Heek.
// Changes by author: Maurits Kelder, B3partners bv

import geometrymodel.Geometry;
/**
 * gismodel.SelectedGeometry
 */
class gismodel.SelectedGeometry {  
    
	static var PLUS:Number = 0;
    static var MINUS:Number = 1;
	
    private var id:String = null;
    private var geometry:Geometry = null;
    private var name:String = null; 
	private var status:Number= null;
	private var extraText:String=null;
    /**
     * constructor
     * @param	id
     * @param	name
     * @param	extraText
     * @param	geometry
     */
    function SelectedGeometry(id:String, name:String, extraText:String,geometry:Geometry) {
		setId(id);
		setName(name);
		setGeometry(geometry);
		setExtraText(extraText);
		setStatus(PLUS);
    }	
	/**
	 * setId
	 * @param	id
	 */
    function setId(id:String){
		if (id == null) {
            _global.flamingo.tracer("Exception in gismodel.SelectedGeometry.<<init>>(" + id + ")\nNo layer given.");
            return;
        }
		this.id=id;
	}
	/**
	 * getId
	 * @return
	 */
	function getId():String{
		return id;
	}
	/**
	 * setName
	 * @param	name
	 */
	function setName(name:String){
		if (name == null) {
            _global.flamingo.tracer("Exception in gismodel.SelectedGeometry.<<init>>()\nNo name given.");
            return;
        }
		this.name=name;
	}
	/**
	 * getName
	 * @return
	 */
	function getName():String{
		return name;
	}
	/**
	 * setExtraText
	 * @param	extraText
	 */
	function setExtraText(extraText:String){
		if (extraText==undefined){
			this.extraText=null;
		}
		this.extraText=extraText;
	}
	/**
	 * getExtraText
	 * @return
	 */
	function getExtraText():String{
		return extraText;
	}
	/**
	 * setGeometry
	 * @param	geometry
	 */
    function setGeometry(geometry:Geometry){
		if (geometry == null) {
            _global.flamingo.tracer("Exception in gismodel.SelectedGeometry.<<init>>(" + id + ")\\No geometry given.");
            return;
        }
		this.geometry=geometry;		
	}  
	/**
	 * getGeometry
	 * @return
	 */
	function getGeometry():Geometry{
		return geometry;
	}
	/**
	 * setStatus
	 * @param	status
	 */
	function setStatus(status:Number){
		this.status=status;
	}
	/**
	 * getStatus
	 * @return
	 */
	function getStatus():Number{
		return this.status;
	}
}
