/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import gui.legend.AbstractLabelLegendItem;
import gui.legend.AbstractGroupLegendItem;
import gui.legend.LegendVisitor;

class gui.legend.SymbolLegendItem extends AbstractLabelLegendItem {
	
	private var _symbolURL: String;
	private var _libLinkage: String;
	private var _symbolStyleId: String;
	private var _symbolLinkStyleId: String;
	private var _extraAttributes: Object;
	private var _infoURL: String;
	
	public function get symbolURL (): String {
		return _symbolURL;
	}
	
	public function set symbolURL (symbolURL: String): Void {
		_symbolURL = symbolURL;
	}
	
	public function get libLinkage (): String {
		return _libLinkage;
	}
	
	public function set libLinkage (libLinkage: String): Void {
		_libLinkage = libLinkage;
	}
	
	public function get symbolStyleId (): String {
		return _symbolStyleId;
	}
	
	public function set symbolStyleId (symbolStyleId: String): Void {
		_symbolStyleId = symbolStyleId;
	}

    public function get symbolLinkStyleId (): String {
        return _symbolLinkStyleId;
    }
    
    public function set symbolLinkStyleId (symbolStyleId: String): Void {
        _symbolLinkStyleId = symbolLinkStyleId;
    }
    
    public function get extraAttributes (): Object {
    	return _extraAttributes;
    }
    
    public function get infoURL (): String {
        return _infoURL;
    }
    
    public function set infoURL (infoURL: String): Void {
        _infoURL = infoURL;
    }
    
	public function SymbolLegendItem (parent: AbstractGroupLegendItem) {
		super (parent);
		
		_extraAttributes = { };
	}
	
	public function visit (visitor: LegendVisitor, context: Object): Void {
		visitor.visitSymbol (this, context);
	}
}
