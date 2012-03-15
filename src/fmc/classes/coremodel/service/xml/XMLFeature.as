/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import coremodel.service.ServiceProperty;
import coremodel.service.ServiceFeature;
import coremodel.service.ServiceLayer;
import geometrymodel.Envelope;

/**
 * coremodel.service.xml.XMLFeature
 */
class coremodel.service.xml.XMLFeature extends ServiceFeature {
	/**
	 * constructor
	 * @param	serviceLayer
	 */
	public function XMLFeature (serviceLayer: ServiceLayer) {
		super ();
		
		this.serviceLayer = serviceLayer;
		this.values = [ ];
	}
	/**
	 * setEnvelope
	 * @param	envelope
	 */
	public function setEnvelope (envelope: Envelope): Void {
		this.envelope = envelope;
	}
}
