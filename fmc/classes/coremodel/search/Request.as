/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
import mx.utils.Delegate;
import mx.events.EventDispatcher;

import coremodel.search.FeatureType;
import coremodel.search.ServiceDescription;

import coremodel.service.ServiceConnector;
import coremodel.service.ServiceLayer;
import geometrymodel.Geometry;
import event.ActionEventListener;
import event.ActionEvent;

/**
 * Events:
 * - describeFeaturesComplete
 * - getFeaturesComplete
 * - getFeatureCountComplete
 * - error
 */
class coremodel.search.Request {
	
	private var _featureType: FeatureType;
	private var _connector: ServiceConnector;
	
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var dispatchEvent: Function;
	
	public function get serviceDescription (): ServiceDescription {
		return featureType.serviceDescription;
	}
	
	public function get featureType (): FeatureType {
		return _featureType;
	}
	
	public function get connector (): ServiceConnector {
		return _connector;
	}
	
	public function Request (featureType: FeatureType, url: String) {
		
		// Turn this object into an event dispatcher:
		EventDispatcher.initialize (this);
		
		if (!url) {
			url = featureType.server;
		}
		
		_featureType = featureType;
		
		// Initialize a connection to the remote service:
		_connector = ServiceConnector.getInstance (featureType.type.toLowerCase () + "::" + url);
		_connector.setSrsName (serviceDescription.srs);
		_connector.setServiceVersion (featureType.serverVersion);
		
		// TODO: Introduce an interface that provides addFeatureType to connectors.
		if (_connector['addFeatureType']) {
			//_global.flamingo.tracer ("Adding properties to feature type");
			Object (_connector).addFeatureType (featureType.layerId, featureType.properties);
		}
	}
	
	/**
	 * Performs a DescribeFeatures request on this request's feature type. After completing
	 * the request the 'describeFeaturesComplete' event is dispatched, the resulting event
	 * object has 'serviceLayer' attribute which contains the DescribeFeatures result.
	 * 
	 * When an error occurs, the 'error' event is dispatched.
	 */
	public function describeFeatures (): Void {
		
		//_global.flamingo.tracer ("Request::describeFeatures");
		
		// Create a listener:
		var listener: ActionEventListener = new ActionEventListener ();
		listener.onActionEvent = Delegate.create (this, describeFeaturesComplete);
		
		//_global.flamingo.tracer ("Perform describeFeatures");
		connector.performDescribeFeatureType(featureType.layerId, listener);
	}
	
	private function describeFeaturesComplete (e: ActionEvent): Void {
		
		//_global.flamingo.tracer ("Perform describeFeatures done");
		
		if (e['exceptionMessage']) {
			dispatchEvent ({ type: 'error', message: e['exceptionMessage'] });
			return;
		}
		
		var serviceLayer: ServiceLayer = e['serviceLayer'];
		dispatchEvent ({ type: 'describeFeaturesComplete', serviceLayer: serviceLayer });
	}
	
	/**
	 * Performs a GetFeatures request for this object's feature type. A GetFeatures request requires
	 * a service layer, which can be obtained by first performing a describeFeatures request. If no
	 * service layer object is given this method initiates a new DescribeFeatures request on the server.
	 * 
	 * A 'getFeaturesComplete' event is dispatched, the resulting event object contains a property 'features',
	 * which is an array of Feature instances. On error the 'error' event is dispatched and no features
	 * are returned.
	 */
	public function getFeatures (extent: Geometry, whereClauses: Array, serviceLayer: ServiceLayer, outputFields: Array): Void {
		var contextObject = new Object();
		contextObject.parseGeometry = false;
		contextObject.parseEnvelope = true;
		//_global.flamingo.tracer ("Request::getFeatures");
		
		if (!outputFields) {
			outputFields = serviceDescription.outputFields;
		}
		
		var doGetFeatures: Function = Delegate.create (this, function (serviceLayer: ServiceLayer) {
			// Create a listener:
			var listener: ActionEventListener = new ActionEventListener ();
			listener.onActionEvent = Delegate.create (this, this.getFeaturesComplete);
			
			this.connector.performGetFeature(serviceLayer, extent, whereClauses, null, false, listener, outputFields,contextObject);
		});
		
		// If a serviceLayer object is not present, a describeFeatures request must first be performed:
		if (!serviceLayer) {
			
			// Register a handler that responds to describeFeaturesComplete and error:
			var handler: Function = Delegate.create (this, function (e: Object) {
				this.removeEventListener ('error', handler);
				this.removeEventListener ('describeFeaturesComplete', handler);
				
				if (e.type == 'describeFeaturesComplete') {
					doGetFeatures (e.serviceLayer);	
				}
			});
			
			addEventListener ('error', handler);
			addEventListener ('describeFeaturesComplete', handler);
			
			describeFeatures ();
		} else {
			doGetFeatures (serviceLayer);
		}
	}
	
	private function getFeaturesComplete (e: ActionEvent): Void {
		
		//_global.flamingo.tracer ("Perform getFeatures done");
		//
		if (e['exceptionMessage']) {
			dispatchEvent ({ type: 'error', message: e['exceptionMessage'] });
			return;
		}
		
		var features: Array = e['features'];
		dispatchEvent ({ type: 'getFeaturesComplete', features: features });
	}

	/*	
	public function getFeatureCount (): Void {
		
	}
	
	private function getFeatureCountComplete (e: ActionEvent): Void {
		
	}
	*/
}
