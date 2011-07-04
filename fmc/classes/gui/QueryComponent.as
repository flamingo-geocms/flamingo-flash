/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Erik Orbons
* IDgis bv
 -----------------------------------------------------------------------------*/
/** @component QueryComponent
 * Component for searching in WFS and generic XML datasources, and formatting the search results. This
 * component is typically used in combination with the LocationResultViewer component, which displays the
 * results.
 * 
 * @file QueryComponent.fla (sourcefile)
 * @file QueryComponent.swf (compiled component, needed for publication on internet)
 * 
 * @configstring buttonLabel			Label for the search button.
 * @configstring clearButtonLabel		Label for the 'clear' button.
 * @configstring mandatoryFieldLabel	This label is displayed when the form has mandatory fields.
 * @configstring selectFieldLabel		Label to display in the combobox when the user has not selected a field yet.
 * @configstring selectValueLabel		Label to display in the combobox when the user has not selected a value yet.
 * 
 * 
 * 
 */
 
/** @tag <fmc:QueryComponent>
 * This tag defines a query component instance. 
 * @class gui.QueryComponent extends core.AbstractComponent
 * @attr startupindex (defaultvalue = "0") The index of the Accordion component that is open after startup (0 is the upper)
 * @example
 * <fmc:QueryComponent id="queryComponent" left="10" right="right -10" top="20" height="400" listento="map" startupindex="0">
 * <string id="buttonLabel" nl="Zoeken" />
 * <string id="clearButtonLabel" nl="Wissen" />
 * <string id="selectFieldLabel" nl="Selecteer een veld ..." />
 * <string id="selectValueLabel" nl="Selecteer een waarde ..." />
 * <string id="mandatoryFieldsLabel" nl="* verplicht in te vullen" />
 * <string id="selectServiceLabel" nl="Selecteer onderwerp" />
 * <string id="selectServiceBlank" nl="Selecteer zoekingang ..." />
 * <string id="selectServiceCaption" nl="Waarvoor geldt" />
 * </fmc:QueryComponent>
 */
/** 
 * @tag <ServiceDescription>
 * This tag describes a service description. A service description describes all attributes that
 * are required to search using a service. The service description contains a list of available
 * feature types, relations between feature types and the search fields that can be queried.
 * 
 * @class coremodel.search.ServiceDescription extends core.AbstractComposite
 * @hierarchy child node of <fmc:QueryComponent>
 * 
 * @attr srs	The spatial reference system to use.
 * @attr label	The label to display in the interface for this service.
 * @attr outputfields	A comma separated list of fields to include in the output of the search operation. The fields must be available in the result feature type.
 * @attr mandatoryfields	When available, this is is a comma separated list of fields that must be completed before searching.
 * @attr fixedfields		A comma separated list of fields that are always visible for each search query, the default is an empty list.
 * @attr minfields			The minimum number of fields that must be completed before the user can search. The default value is 0.
 * @attr maxfields			The maximum number of fields that can be completed, or 0 if there is no limit. The default value is 0.
 * @attr resultfeaturetype	The ID of the feature type that is queried by this service.
 * @attr enlargeextent		If the results contain point-geometry, this value is used to create a buffer around the points. The buffer is used as a boundingbox.
 * @attr outformat			The output format string. A reference can be created to the fields in the outputfields attribute by placing the field name within square brackets.
 * @attr tooltipformat		The format of the tooltip to show for search results, similar to outputformat.
 * @attr highlightlayer id of an highlightlayer component. When a hightlightlayer is configured a found feature
 * will get highlighted when an user moves the mouse over the the feature in the resultviewer. 
 * @attr highlightwmsurl
 * @attr highlightsldservleturl
 * @attr highlightfeaturetypename
 * @attr highlightpropertyname
 * @attr highlightmaxscale Scale to prevent highlighting of features when the mapscale is too large. 
 * If the currentmapscale is larger than the highlightmaxscale the Locationfinder will not send a GetMap request 
 * to the highlightwms but the BBox of found feature will be shown instead.
 * @attr sortfields			A comma separated list of fields to sort the results.
 * @attr useextent			When this value is set to "false", the extent is ignored from the search results
 * 
 * @example
 *     <ServiceDescription 
 *        id="sd_gemeente"
 *        label="Zoek gemeente" 
 *        tooltipFormat="[app:GEMNAAM]" 
 *        outputFormat="[app:GEMNAAM]" 
 *        fixedFields="sf_gemeentenaam"
 *        mandatoryFields="sf_gemeentenaam"
 *        sortFields="app:GEMNAAM asc"
 *        maxFields="1"
 *        resultFeatureType="gemeente2010" 
 *        srs="EPSG:28992" 
 *        outputFields="app:GEMNAAM">
 *        
 *        <FeatureType ... />
 *        <Relation ... />
 *        <SearchField ... />
 *     </ServiceDescription>
 */
/**
 * @tag <FeatureType>
 * Describes a feature type that can be queried on a server. Currently WFS services
 * and generic XML data sources can be queried. In the case of an XML datasource, each
 * property of the feature type must be listed using an XPath query that extracts
 * the values for that property from the source document.
 * 
 * @class coremodel.search.FeatureType extends core.AbstractComposite
 * @hierarchy child node of <ServiceDescription>
 * 
 * @attr id				The identifier of the feature type
 * @attr type			Service type: "wfs" or "xml"
 * @attr server			URL of the server to query
 * @attr serverversion	Service version to use (for WFS queries)
 * @attr layerid		ID of the layer to query (for WFS queries)
 * 
 * @example
 * <FeatureType 
 *   id="gemeente2010" 
 *   server="http://localhost:8080/zorro/services/esri.jsp?serviceURL=${wrolocalservice}/ArcGIS/services/ak_algemeen/MapServer/WFSServer&typeName=GEMEENTEGRENZEN_2010&shapeProperty=Shape&queryProperty=GEMNAAM&queryValue=[app:GEMNAAM]*&properties=OBJECTID,GEMNAAM,GEM2010NR"
 *   type="XML"
 *   serverVersion="1.0"
 *   layerid="app:GEMNAAM]">
 *
 *   <Property name="app:GEMNAAM" type="xsd:string" path="/Features/Feature/GEMNAAM" />
 *   <Property name="app:OBJECTID" type="xsd:string" path="/Features/Feature/OBJECTID" />
 *   <Property name="app:GEM2010NR" type="xsd:string" path="/Features/Feature/GEM2010NR" />
 *   <Property name="gml:boundedBy" type="boundingBox" path="/Features/Feature/BoundingBox" />
 * </FeatureType>
 * <FeatureType id="ft_provincies" server="http://afnemers.ro-online.net/ro-online-topdata/ogcwebservice" type="WFS" serverVersion="1.1.0" layerid="app:provincies" />
 */
/**
 * @tag <Property>
 * Describes a property in an XML feature type.
 * 
 * @class coremodel.search.Property extends core.AbstractComposite
 * @hierarchy child node of <FeatureType>
 * 
 * @attr name	The name of the property, this name can (for example) be included in the outputfields attribute of the service description.
 * @attr type	The type of the property, currently only xsd:string and boundingBox are accepted values. When the type is boundingBox, the
 * 				nodes are interpreted as a boundingbox and must have the following attributes: minx, maxx, miny, maxy.
 * @attr path	An XPath expression that extracts values for this property from the source document.
 * 
 * @example
 * <Property name="app:GEMNAAM" type="xsd:string" path="/Features/Feature/GEMNAAM" />
 * <Property name="app:OBJECTID" type="xsd:string" path="/Features/Feature/OBJECTID" />
 * <Property name="app:GEM2010NR" type="xsd:string" path="/Features/Feature/GEM2010NR" />
 * <Property name="gml:boundedBy" type="boundingBox" path="/Features/Feature/BoundingBox" />
 */
/**
 * @tag <Relation>
 * Describes a relation between two feature types.
 * Feature types that are related to other feature types are used as filters during a
 * search if they are used in a search field.
 * 
 * @class coremodel.search.Relation extends core.AbstractComposite
 * @hierarchy child node of <ServiceDescription>
 * 
 * @attr id				The identifier of the relation
 * @attr source			The identifier of the source feature type.
 * @attr dest			The identifier of the destination feature type.
 * @attr sourcefield	The name of the field in the source feature type.
 * @attr destfield		The name of the corresponding field in the source feature type.
 * 
 * @example
 * <Relation source="ft_provincies" dest="ft_woonplaatsen" sourceField="app:geographicidentifier" destField="app:parent" />
 * <Relation source="ft_woonplaatsen" dest="ft_straten" sourceField="app:geographicidentifier" destField="app:parent" />
 * <Relation source="ft_straten" dest="ft_adressen" sourceField="app:geographicidentifier" destField="app:parent" />
 */
/**
 * @tag <SearchField>
 * Describes a search field.
 * 
 * @class coremodel.search.SearchField extends core.AbstractComposite
 * @hierarchy child node of <ServiceDescription>
 * 
 * @attr id						Identifier of the search field, used to refer to the field from other entities.
 * @attr label					Label of the search field, this label is displayed in front of the input control.
 * @attr matchcase				When set to "true", the search is performed case sensitive (default value is "false").
 * @attr enumerate				When true, this search field displays a list of all possible values from which the user
 * 								can choose. Relations that exist between this search field's feature type and
 * 								other feature types that have a search field are used to filter this list.
 * @attr featuretype			The identifier of the feature type that is attached to this search field.
 * @attr searchfield			The name of the property (in this field's feature type) that is queried by this field.
 * @attr pattern				If set, this pattern is used in the search query instead of the raw value that was entered
 * 								by the user. Refer to the value that was entered by placing the "searchfield" within
 * 								square brackets (e.g. "*[searchfield]*" performs a wildcard search).
 * @attr mininput				The minimum number of characters that must be entered in this field (default 1).
 * @attr maxinput				The maximum number of characters that can be entered in this field, or 0 if no limit
 * 								is to be imposed (default 0).
 * @attr displayfield			If enumerate is set to "true", this names an optional property (in this field's feature type)
 * 								that is used for display purposes in the list of possible values.
 * @attr displayfields			If enumerate is set to "true", this value is interpreted as a comma separated list of fields
 * 								that are used for display purposes. See displayfield for details.
 * @attr displayfieldseparator	If enumerate is set to "true" and a value is entered for "displayfields", this pattern
 * 								is used to separate the display fields.
 * @attr autocomplete			If set to "true", the value entered by the user is autocompleted. Autocomplete works similar
 * 								to the "enumerate" functionality, other search fields can be used as filters.
 * @attr default				The default value, defaults to an empty string.
 * @attr defaultvalue			The default value, defaults to an empty string.
 * @attr operator				The operator to use for comparison. If no operator is given, the user can select an operator.
 * 
 * @example
 * <SearchField featureType="ft_provincies" id="sf_provincie" label="Provincie" searchField="app:geographicidentifier" enumerate="true" minInput="1" />
 * <SearchField featureType="ft_woonplaatsen" id="sf_woonplaats" label="Woonplaats" searchField="app:geographicidentifier" pattern="[app:geographicidentifier]*" enumerate="true" minInput="2" autocomplete="true" />
 * <SearchField featureType="ft_straten" id="sf_straat" label="Straat" searchField="app:geographicidentifier" displayField="app:straatnaam_nen" enumerate="true" minInput="2" autocomplete="true" />
 * <SearchField featureType="ft_adressen" id="sf_adres" label="Huisnummer" searchField="app:geographicidentifier" displayFields="app:huisnummer,app:toevoeging" displayFieldSeparator="-" enumerate="true" minInput="1" autocomplete="true" />
 */
/**
 * @tag <FieldValue>
 * Describes a possible value of a search field. If a search field has at least one FieldValue instance, the possible
 * values are not enumerated from the service. Instead the possible field values are listed as individual Fieldvalue
 * tags.
 * 
 * @class coremodel.search.FieldValue extends core.AbstractComposite
 * @hierarchy child node of <SearchField>
 * 
 * @attr label		The label to display for this field value.
 * @attr value		The field value.
 * 
 * @example
 * <SearchField id="sf_plantype" label="Plantype" featureType="ft_plantype" searchField="app:typePlan">
 *   <FieldValue label="bestemmingsplan artikel 10" value="gemeentelijk plan; bestemmingsplan artikel 10"/>
 *   <FieldValue label="uitwerkingsplan artikel 11" value="gemeentelijk plan; uitwerkingsplan artikel 11"/>
 *   <FieldValue label="wijzigingsplan artikel 11" value="gemeentelijk plan; wijzigingsplan artikel 11"/>
 *   <FieldValue label="bestemmingsplan" value="bestemmingsplan"/>
 * <SearchField>

 */
/**
 * @tag <XmlValueStore>
 * If a search field has an XML value store, the possible field values are enumerated from a generic XML
 * document instead of the field's feature type if the enumerate property is set to "true".
 * 
 * @class coremodel.search.XmlValueStore extends core.AbstractComposite
 * @hierarchy child node of <SearchField>
 * 
 * @attr url	The URL of the XML document.
 * @attr valuePath	The XPath expression that is used to extract field values from the document.
 * @attr labelPath	The XPath expression that is used to extract label values from the document.
 * 
 * @example
 * <XmlValueStore 
 *   url="http://url/to/document.xml" 
 *   valuePath="/Path/To/Value" 
 *   labelPath="/Path/To/Label" />
 */

import core.AbstractComponent;
import core.PersistableComponent

import gui.querybuilder.QueryBuilder;
import gui.querybuilder.Filter;
import gui.querybuilder.FilterContainer;

import coremodel.search.ServiceDescription;
import coremodel.search.FeatureType;
import coremodel.search.Relation;
import coremodel.search.SearchField;
import coremodel.search.Query;
import coremodel.search.QueryFilter;
import coremodel.search.Request;

import coremodel.service.ServiceFeature;

import geometrymodel.Geometry;
import geometrymodel.Envelope;

import tools.Arrays;
import tools.XMLTools;

import mx.containers.Accordion;
import mx.core.View;
import mx.controls.TextArea;
import mx.utils.Delegate;

class gui.QueryComponent extends AbstractComponent implements PersistableComponent {
	
	private var container: FilterContainer;
	
	/**
	 * A list of query builder UI components that have been created as children of this component.
	 */
	private var queryBuilders: Array = [ ];
	
	/**
	 * A list of queries that have been created for this component, each element in this array is
	 * an object containing the following attributes:
	 * - builder: The QueryBuilder instance that belongs to this query.
	 * - query: The Query object that represents the query that is being manipulated using the QueryBuilder.
	 * - serviceDescription: The ServiceDescription object that provides the configuration for this query.
	 */
	private var queries: Array = [ ];
	
	/**
	 * A list of service descriptions that have been read from the component configuration. Elements of this
	 * array are instances of the ServiceDescription class. This array
	 */
	private var _serviceDescriptions: Array = [ ];
	
	private var _layerListeners: Object = { };
	
	private var startupIndex = 0;
	
	private var activeFilters: Object;
	
	public function QueryComponent() {
		super();
		
		_layerListeners = { };
		queryBuilders = [ ];
		queries = [ ];
		_serviceDescriptions = [ ];
		activeFilters = { };
		
		// Set global styles:
		_global.style.setStyle ('themeColor', 0x999999);
		_global.style.setStyle ('rollOverColor', 0xE6E6E6);
		_global.style.setStyle ('selectionColor', 0xCCCCCC);
		_global.style.setStyle ('textSelectedColor', 0x000000);
	}
	
	function init (): Void {
		
		this.createUI ();
		this.bindUI ();
		this.syncUI ();
		
		// Add all query builders whose layers are currently available:
		for (var i: Number = 0; i < _serviceDescriptions.length; ++ i) {
			addQuery (_serviceDescriptions[i]);
		}

		// Select the initial query builder (if any):		
		var index:Number = startupIndex;
		if(startupIndex > queryBuilders.length - 1){
			index = queryBuilders.length - 1;
		}
		container.selectedIndex = index;
	}
	
	/**
	 * Creates a new query builder and adds it as a child of the accordion control with
	 * the given label.
	 * 
	 * @param label		The name of the query builder, which is used as the accordion label.
	 * @return			The new query builder instance which is added to the accordion.
	 */
	public function addQueryBuilder (label: String): QueryBuilder {
		var id:String = "querybuilder" + queryBuilders.length;
		var queryBuilder:QueryBuilder = QueryBuilder (container.createChild (gui.querybuilder.QueryBuilder, id, {label: label}));
		//var queryBuilder:QueryBuilder = QueryBuilder (attachMovie ('QueryBuilder', 'queryBuilder', getNextHighestDepth()));
		//queryBuilder.setSize (200, 200);
		queryBuilder.setSize (container.calcContentWidth(), container.calcContentHeight ());
		
		queryBuilder.searchLabel = _global.flamingo.getString (this, 'buttonLabel', 'Search ...');
		queryBuilder.clearLabel = _global.flamingo.getString (this, 'clearButtonLabel', 'Clear');
		
		queryBuilders.push (queryBuilder);
		return queryBuilder;
	}
	
	public function createQuery (o: Object): Void {
		var serviceDescription: ServiceDescription = o.serviceDescription;
		
		// If the query is 
		var builder: QueryBuilder;
		var query: Object;
		var o: Object;
		var i: Number;
		
		// Create a query object to represent the service description:
		query = new Query (serviceDescription);
		
		// Create a query builder to represent the service description:
		builder = addQueryBuilder (serviceDescription.label);
		
		o.builder = builder;
		o.query = query;
		
		// Add filters for all mandatory and fixed fields:
		var fixedFilterCount: Number = 0;
		var fixedFields: Array = serviceDescription.fixedFields;
		var mandatoryFields: Array = serviceDescription.mandatoryFields;
		var mandatory: Object = { };
		var created: Object = { };
		for (i = 0; i < mandatoryFields.length; ++ i) {
			mandatory[mandatoryFields[i].id] = true;
		}
		for (i = 0; i < fixedFields.length; ++ i) {
			addFixedFilter (o, fixedFields[i], !!mandatory[fixedFields[i].id]);
			created[fixedFields[i].id] = true;
			++ fixedFilterCount;
		}
		for (i = 0; i < mandatoryFields.length; ++ i) {
			if (created[mandatoryFields[i].id]) {
				continue;
			}
			addFixedFilter (o, mandatoryFields[i], true);
			++ fixedFilterCount;	
		}
		
		// Add an initial (empty) filter, only if non-mandatory filters remain
		// and if the maxFilters setting permits this:
		if (serviceDescription.maxFields == 0 || serviceDescription.maxFields > fixedFilterCount) {
			var fields: Array = serviceDescription.searchFields;
			var optionalFields: Array = [ ];
			for (i = 0; i < fields.length; ++ i) {
				if (!serviceDescription.isFieldMandatory(fields[i])) {
					optionalFields.push (fields[i]);
				}
			}
			if (optionalFields.length > 0) {
				addOptionalFilter (o, optionalFields, false);
			}
		}

		// Set a description label if any mandatory fields are in the form:
		if (mandatoryFields.length > 0) {
			builder.infoLabel = _global.flamingo.getString (this, 'mandatoryFieldsLabel', '* mandatory field');
		}
		
		// Add an event listener to the search button:
		builder.addEventListener ('search', Delegate.create (this, function (): Void {
			if (query.serviceDescription.type == ServiceDescription.TYPE_SEARCH) {
				onSearch (query, builder);
			} else if (query.serviceDescription.type == ServiceDescription.TYPE_FILTER) {
				onFilter (query, builder);
			}
		}));
		builder.addEventListener ('clear', Delegate.create (this, function (): Void {
			onClear (query, builder);
		}));
	}
	
	/**
	 * Adds a new query to this component based on a preconfigured service description. Each
	 * query consists of a query object, a query builder that manipulates it and a service
	 * description that provides configuration. The query component serves as a controller
	 * that alters and executes the query based on user interaction with the query builder.
	 * 
	 * The resulting object has three attributes:
	 * - builder: The querybuilder instance
	 * - query: The query object.
	 * - serviceDescription: The service description (the reference passed in the corresponding
	 *   argument to this method).
	 * 
	 * @return An object containing the query builder, query object and service description instance.
	 */
	public function addQuery (serviceDescription: ServiceDescription): Object {
		
		// Create a query object for the service description:
		var o: Object = {
			builder: null,
			query: null,
			serviceDescription: serviceDescription
		};
		
		queries.push (o);
		
		// If the service listens to a layer the query builder will not be created until the layer first becomes visible:
		if (serviceDescription.filterLayer) {
			var mapId: String = listento[0],
				parts: Array = serviceDescription.filterLayer.split ('.'),
				layerId: String = parts[0],
				subLayerId: String = parts[1];
				
			// Add the builder to the interface if the layer is visible, otherwise the builder will be first added as
			// soon as the layer becomes visible:
			onLayerAvailable (mapId, layerId, Delegate.create (this, function (layerComponent: MovieClip): Void {
				if (layerComponent.getVisible (subLayerId) > 0) {
					// The corresponding layer is visible, add the query builder to the interface:  
					createQuery (o);
				}
			}));
			
			o.layerId = mapId + '_' + layerId;
			o.subLayerId = subLayerId;
			
			addLayerListener (o.layerId, o);
		} else {
			createQuery (o);
		}
		
		return o;
	}
	
	private function onLayerAvailable (mapId: String, layerId: String, callback: Function): Void {
		var componentId: String = mapId + '_' + layerId,
			component: MovieClip = _global.flamingo.getComponent (componentId);
		
		if (component && (!(component instanceof AbstractComponent) || component.inited)) {
			callback (component);
		} else {
			_global.flamingo.addListener ({
				onInit: callback
			}, componentId, this);
		}
	}
	
	private function addLayerListener (layerId: String, query: Object): Void {
		if (!_layerListeners[layerId]) {
			_layerListeners[layerId] = [ ];
			_global.flamingo.addListener ({
				onUpdateComplete: Delegate.create (this, onLayerUpdated)
			}, layerId, this);
		}
		
		_layerListeners[layerId].push (query);
	}
	
	private function onLayerUpdated (layerComponent: MovieClip): Void {
		var layerId: String = _global.flamingo.getId (layerComponent);
		
		if (!_layerListeners[layerId]) {
			return;
		}
		
		var queries: Array = _layerListeners[layerId];
		
		for (var i: Number = 0; i < queries.length; ++ i) {
			var subLayerId: String = queries[i].subLayerId,
				visible: Boolean = layerComponent.getVisible (subLayerId) > 0;
				
			if (visible) {
				if (!queries[i].builder) {
					createQuery (queries[i]);
				} else {
					container.setChildEnabled (queries[i].builder, true);
				}
			} else {
				if (queries[i].builder) {
					container.setChildEnabled (queries[i].builder, false);
				}
			}
		}
	}
	
	private function onClear (query: Query, builder: QueryBuilder): Void {
		var filters: Array = builder.getFilters (),
			i: Number;
			
		for (i = 0; i < filters.length; ++ i) {
			var queryFilter: QueryFilter = query.filters[i],
				filter: Filter = filters[i],
				value: String = '';
				
			if (queryFilter.searchField && queryFilter.searchField.defaultValue) {
				value = queryFilter.searchField.defaultValue;
			}
			
			filter.value = value;
		}
		
		// Clear the filter on a layer:
		if (query.serviceDescription.type == ServiceDescription.TYPE_FILTER) {
			var mapId: String = listento[0],
				parts: Array = query.serviceDescription.filterLayer.split ('.'),
				layerId: String = mapId + '_' + parts[0],
				subLayerId: String = parts[1],
				layerComponent: MovieClip = _global.flamingo.getComponent (layerId);
				
			layerComponent.setLayerProperty (subLayerId, "query", "");
			layerComponent.setLayerProperty (subLayerId, "queryable", true);
			_global.flamingo.getComponent (listento[0]).refresh ();
		}
		
		if (query.serviceDescription.id && activeFilters[query.serviceDescription.id]) {
			delete activeFilters[query.serviceDescription.id];
		}
	}
	
	private function onFilter (query: Query, builder: QueryBuilder): Void {
		var filter: String = query.getFilterString (),
			mapId: String = listento[0],
			parts: Array = query.serviceDescription.filterLayer.split ('.'),
			layerId: String = mapId + '_' + parts[0],
			subLayerId: String = parts[1],
			layerComponent: MovieClip = _global.flamingo.getComponent (layerId);
			
		
		if (layerComponent) {
			layerComponent.setLayerProperty (subLayerId, "queryable", true);
			layerComponent.setLayerProperty (subLayerId, "query", filter);
			_global.flamingo.getComponent (listento[0]).refresh ();
			
			if (query.serviceDescription.id) {
				activeFilters[query.serviceDescription.id] = filter;
			}
		}
	}
	
	private function onSearch (query: Query, builder: QueryBuilder): Void {
		
		// Search for the map component that provides the search extent:
		var map: Object = _global.flamingo.getComponent (this.listento[0]);
		if (!map) {
			_global.flamingo.tracer ("The query component requires a map component named: " + this.listento[0]);
			return;
		}
		var e: Object = map.getFullExtent ();
		var extent: Geometry;
		if (!query.serviceDescription.useExtent) {
			extent = null;
		} else if (e instanceof Geometry) {
			extent = Geometry (e);
		} else {
			extent = new Envelope (e.minx, e.miny, e.maxx, e.maxy);
		}
		
		var resultFeatureType: FeatureType = query.resultFeatureType;
		if (!resultFeatureType) {
			return;
		}
		var request: Request = new Request (resultFeatureType, query.serviceUrl);
		var whereClauses: Array = query.getWhereClauses ();
		var i: Number;
		
		//for (i = 0; i < whereClauses.length; ++ i) {
			//_global.flamingo.tracer ("Where clause: " + whereClauses[i]);
		//}
		
		// Do getFeatures:
		request.addEventListener ('getFeaturesComplete', Delegate.create (this, function (e: Object): Void {
			var features: Array = e.features;
			var i: Number;
			for (i = 0; i < features.length; ++ i) {
				var name: String = "";
				var feature: Object = features[i];
				for (var n: Number = 0; n < query.serviceDescription.outputFields.length; ++ n) {
					name += String (feature.getValue (query.serviceDescription.outputFields[n])) + " ";
				}
				//_global.flamingo.tracer ("* " + name);
			}
			
			features = this.sortFeatures (query, features);
			this.dispatchFeatures (query, features);
			
			builder.showProgress = false;
		}));
		request.addEventListener ('error', Delegate.create (this, function (e: Object): Void {
			builder.showProgress = false;
		}));
		
		builder.showProgress = true;
		request.getFeatures (extent, whereClauses);
	}
	
	private function sortFeatures (query: Query, features: Array): Array {
		
		var serviceDescription: ServiceDescription = query.serviceDescription,
			sortFields: Array = serviceDescription.sortFields,
			defineSortMethod: Function,
			sortMethod: Function,
			sf: Object,
			i: Number,
			context: Object;
		
		sortMethod = function (): Number { return 0; };
		
		for (i = sortFields.length - 1; i >= 0; -- i) {
			context = {
				fieldName: sortFields[i].searchFieldName,
				direction: sortFields[i].direction == 'asc' ? 1 : -1,
				chain: sortMethod
			};
			sortMethod = Delegate.create (context, function (a: ServiceFeature, b: ServiceFeature): Number {
				var aValue: String = String (a.getValue (this.fieldName)).toLowerCase (),
					bValue: String = String (b.getValue (this.fieldName)).toLowerCase ();
					
				if (aValue < bValue) {
					return -this.direction;
				} else if (aValue > bValue) {
					return this.direction;
				} else {
					return this.chain (a, b);
				}
			});
		}
		
		return features.sort (sortMethod);
	}
	
	private function dispatchFeatures (query: Query, features: Array): Void {
	
		var i: Number,
			outputFormat: String = query.serviceDescription.outputFormat,
			tooltipFormat: String = query.serviceDescription.tooltipFormat,
			outputFields: Array = query.serviceDescription.outputFields,
			foundLocations: Array = [ ];
		
		// Construct a locationdata object whose properties mirror those that can be found in the LocationFinder
		// configuration with respect to highlight layers. The result viewer expects this object to passed
		// along with every location that is displayed in the viewer:
		var sd: ServiceDescription = query.serviceDescription;		
		var locationdata: Object = {
			highlightmaxscale: sd.highlightMaxScale,
			hllayerid: sd.highlightLayer,
			wmsUrl: sd.highlightWmsUrl,
			sldServletUrl: sd.highlightSldServletUrl,
			featureTypeName: sd.highlightFeatureTypeName,
			propertyName: sd.highlightPropertyName
		};
		
		for (i = 0; i < features.length; ++ i) {
			var feature: ServiceFeature = features[i];
			
			var env: Envelope = feature.getEnvelope ();
			var label: String;
			var tooltip: String;
			var ext: Object = {
					minx: env.getMinX (),
					miny: env.getMinY (),
					maxx: env.getMaxX (),
					maxy: env.getMaxY ()
				};
			
			//_global.flamingo.tracer ("Feature envelope: " + env);
			
			//if its a extent of a point, enlarge it:
			if (ext.minx == ext.maxx && ext.miny == ext.maxy && query.serviceDescription.enlargeExtent != undefined){
				//_global.flamingo.tracer ("   - Enlarging extent");													
				ext.minx = Number(ext.minx) - query.serviceDescription.enlargeExtent;
				ext.miny = Number(ext.miny) - query.serviceDescription.enlargeExtent;
				ext.maxx = Number(ext.maxx) + query.serviceDescription.enlargeExtent;
				ext.maxy = Number(ext.maxy) + query.serviceDescription.enlargeExtent;					
			}
			
			// Construct a location object:
			var loc: Object = {
					// serviceDescription: query.serviceDescription,
					serviceDescriptionId: query.serviceDescription.id,
					extent: ext,
					label: outputFormat
				};
				
			
			// Construct a label by replacing placeholders in the outputFormat string:
			label = outputFormat;
			tooltip = tooltipFormat;
			for (var j: Number = 0; j < outputFields.length; ++ j) {
				var prop: String = outputFields[j];
				var n: Number;
				var value: String = String (feature.getValue (prop));
				
				if (value == undefined) {
					continue;
				}
				
				if ((n = label.indexOf ('[' + prop + ']')) >= 0) {
					label =
						label.substr (0, n)
						+ feature.getValue (prop)
						+ label.substr (n + prop.length + 2);
				}
			
				loc[prop] = value;
				
				if (!tooltip == undefined) {
					continue;
				}
				
				if ((n = tooltip.indexOf ('[' + prop + ']')) >= 0) {
					tooltip =
						tooltip.substr (0, n)
						+ value
						+ tooltip.substr (n + prop.length + 2);
				}
			}
			
			loc.label = label;
			loc.tooltip = tooltip;
			
			// Set property value for layer highlights:
			if (query.serviceDescription.highlightPropertyName) {
				loc.propertyvalue = String (feature.getValue (query.serviceDescription.highlightPropertyName));
			}
			
			// Set the locationdata for the highlight function:
			loc.locationdata = locationdata;
			
			foundLocations.push (loc);
		}
		
		//_global.flamingo.tracer ("Raising onFindLocation: " + foundLocations);
		
		_global.flamingo.raiseEvent (
				this,
				'onFindLocation',
				this,
				foundLocations,
				true				// updateFeatures. Waar dient dit voor?
			);
			
		// TODO: _zoom
	}
	
	/**
	 * This handler is invoked whenever the accordion is resized (which happens when this component is
	 * resized). The new dimensions of the content area of the accordion are calculated and all query builders
	 * are resized to those dimensions.
	 */
	private function onAccordionResize (): Void {
		//t ('Accordion resize: ' + accordion.calcContentWidth() + ', ' + accordion.calcContentHeight ());
		
		var width: Number = container.calcContentWidth ();
		var height: Number = container.calcContentHeight ();
		
		for (var i:Number = 0; i < queryBuilders.length; ++ i) {
			queryBuilders[i].setSize (width, height);	
		}
		
	}
	
	/**
	 * Creates user interface components that are a part of this component.
	 */
	private function createUI (): Void {
		var builder: QueryBuilder;
		
		container = FilterContainer (attachMovie ("FilterContainer", "container", this.getNextHighestDepth ()));
		container.blankSelectionLabel = _global.flamingo.getString (this, 'selectServiceBlank', 'Select a service ...');
		container.selectLabel = _global.flamingo.getString (this, 'selectServiceLabel', 'Service: ');
		container.selectCaption = _global.flamingo.getString (this, 'selectServiceCaption', 'Filters:');
	}
	
	/**
	 * Binds handlers to relevant events on user interface components.
	 */
	private function bindUI (): Void {
		container.addEventListener ('resize', Delegate.create (this, onAccordionResize));
		 
		_global.flamingo.addListener ({
			onResize: Delegate.create (this, resize)
		}, _global.flamingo.getParent (this), this);
	}
	
	/**
	 * Sets the initial state of the UI components based on configuration parameters.
	 */
	private function syncUI (): Void {
		resize ();
	}
	
	
    function setBounds (x:Number, y:Number, width:Number, height:Number): Void {
    	super.setBounds (x, y, width, height);
    	
		container.move (0, 0);
		container.setSize (width, height);
		//if (queryBuilders[0]) 
		//	queryBuilders[0].setSize (width, height);
    }
    
    public function resize (): Void {
        var r: Object = _global.flamingo.getPosition(this);
        this._x = r.x;
        this._y = r.y;
        __width = r.width;
        __height = r.height;
        
        container.move (0, 0);
        container.setSize (__width, __height);
    }
    
	// =========================================================================
	// Working with filters:
	// =========================================================================
	/**
	 * Adds a new mandatory filter for the given query. Mandatory filters have
	 * a preselected search field that can't be changed by the user (which is
	 * displayed using a Label component), furthermore a mandatory filter can
	 * never be deleted.
	 */
	private function addFixedFilter (query: Object, searchField: SearchField, mandatory: Boolean): Void {
		var filter: Filter;
		var queryFilter: QueryFilter;
		
		//_global.flamingo.tracer ("Adding mandatory search field: " + searchField.label + " (" + mandatory + ")");
		
		filter = query.builder.addFilter ();
		filter.fields = [{label: searchField.label, data: searchField}];
		filter.allowFieldSelection = false;
		filter.selectedField = searchField;
		filter.canDelete = false;
		filter.mandatory = mandatory;
		
		queryFilter = query.query.addFilter ();
		
		// Bind the filter first, otherwise we might miss the event that sets possible field values:
		bindFilter (query, filter, queryFilter);
		
		// Configure the filter:
		queryFilter.searchField = searchField;
		queryFilter.value = '';
		
		syncFilter (query, filter, queryFilter);
	}
	
	/**
	 * Adds an optional filter to the given query. An optional filter allows the user to
	 * select a search field from a list of search fields and enter a value. Normally, optional
	 * fields can be deleted from the query, unless it is the only optional filter for that query,
	 * in which case it should not be deleted.
	 */
	private function addOptionalFilter (query: Object, searchFields: Array, canDelete: Boolean): Object {
		var filter: Filter;
		var queryFilter: QueryFilter;
		var fields: Array = [ ];
		var i: Number;
		
		filter = query.builder.addFilter ();
		filter.fields = fields;
		filter.allowFieldSelection = true;
		filter.canDelete = !!canDelete;
		
		queryFilter = query.query.addFilter ();
		queryFilter.searchField = null;
		queryFilter.value = '';
		
		bindFilter (query, filter, queryFilter);
		syncFilter (query, filter, queryFilter);
		
		// Update all remaining optional filters:
		updateOptionalFilters (query);
		
		return {
			filter: filter,
			queryFilter: queryFilter
		};
	}
	
	private function syncFilter (query: Object, filter: Filter, queryFilter: QueryFilter): Void {
		
		if (queryFilter.searchField && queryFilter.searchField.autocomplete) {
			filter.autocomplete = true;
		}
		
		if (queryFilter.searchField && queryFilter.searchField.operator == null) {
			filter.allowOperatorSelection = true;
		}
		
		if (queryFilter.searchField && queryFilter.searchField.enumerate) {
			
			// Clear the field values of the filter so that they will be enumerated on the first
			// change:
			queryFilter.clearFieldValues ();
			
			if (queryFilter == queryFilter.query.firstFilter) {
				// Enumerate the field values of a filter if it is the first filter in the query:
				//_global.flamingo.tracer ("syncFilter enumerate");
				queryFilter.enumerate ();
				filter.disabled = false;
			} else {
				// Disable filters that must be enumerated. They remain disabled until field values become
				// available or until all previous fields in the query become complete:
				filter.disabled = true;
			}
		}
		
		// Set the initial value of the filter:
		if (queryFilter.searchField && queryFilter.searchField.defaultValue && queryFilter.searchField.defaultValue != '') {
			filter.value = queryFilter.searchField.defaultValue;
		}
	}
	
	private function bindFilter (query: Object, filter: Filter, queryFilter: QueryFilter): Void {
		
		filter.selectFieldLabel = _global.flamingo.getString (this, 'selectFieldLabel', 'Select a field ...');
		filter.selectValueLabel = _global.flamingo.getString (this, 'selectValueLabel', 'Select a value ...');
		
		filter.addEventListener ('selectedFieldChanged', Delegate.create (this, function (e: Object): Void {
			var oldValue: SearchField = e.oldValue ? e.oldValue.data : null;
			var newValue: SearchField = e.newValue ? e.newValue.data : null;
			this.onSelectedFieldChanged (query, filter, queryFilter, newValue, oldValue);
		}));
		filter.addEventListener ('valueChanged', Delegate.create (this, function (e: Object): Void {
			this.onValueChanged (query, filter, queryFilter, e.newValue, e.oldValue);
		}));
		filter.addEventListener ('delete', Delegate.create (this, function (e: Object): Void {
			this.onDeleteFilter (query, filter, queryFilter);
		}));
		queryFilter.addEventListener ('fieldValuesAvailable', Delegate.create (this, function (e: Object): Void {
			this.onFieldValuesAvailable (query, filter, queryFilter, e.values);
		}));
		filter.addEventListener ('prefixChanged', Delegate.create (this, function (e: Object): Void {
			this.onPrefixChanged (query, filter, queryFilter, e.prefix);
		}));
		filter.addEventListener ('operatorChanged', Delegate.create (this, function (e: Object): Void {
			this.onOperatorChanged (query, filter, queryFilter, e.newOperator, e.oldOperator);
		}));
		
		onFilterAdded (query, filter, queryFilter);
	}
	
	private function onOperatorChanged (query: Object, filter: Filter, queryFilter: QueryFilter, newOperator: String, oldOperator: String): Void {
		var oldComplete: Boolean = queryFilter.complete;
		
		queryFilter.operator = newOperator;
		
		// Invoke the general change handler for the filter:
		onFilterChanged (query, filter, queryFilter, oldComplete);
	}
	
	private function onSelectedFieldChanged (query: Object, filter: Filter, queryFilter: QueryFilter, newValue: SearchField, oldValue: SearchField): Void {
		//_global.flamingo.tracer ("Field selected: " + (newValue ? newValue.label : '- none -'));
		
		var oldComplete: Boolean = queryFilter.complete;
		
		// Assign the new value to the query filter:
		queryFilter.searchField = newValue;
		
		if (newValue) {
			filter.autocomplete = newValue.autocomplete;
		}
		
		// Invoke the general change handler for the filter:
		onFilterChanged (query, filter, queryFilter, oldComplete);
		
		// Remove the newly selected field from all other optional filters, add the old selected field to
		// all other optional filters:
		updateOptionalFilters (query);
	}
	
	private function updateOptionalFilters (query: Object): Void {
		var optionalFilters: Array = query.builder.getFilters (function (f: Filter): Boolean { return f.allowFieldSelection; }),
			allFilters: Array = query.builder.getFilters (),
			searchFields: Array = query.query.serviceDescription.searchFields,
			usedFields: Array = [ ],
			i: Number,
			j: Number;
			
		// Build a list of all search fields that are currently in use. Only fields that
		// are used with the '=' operator or both the '<' and '>' operators are considered
		// 'used' and will not be applied to the field selection lists.
		for (i = 0; i < searchFields.length; ++ i) {
			var usedLT: Boolean = false,
				usedGT: Boolean = false,
				usedEqual: Boolean = false;
				
			for (j = 0; j < allFilters.length; ++ j) {
				var filter: Filter = allFilters[j],
					selectedField: Object = filter.selectedField;
				
				if (selectedField && selectedField.data == searchFields[i]) {
					if (filter.operator == '=') {
						usedEqual = true;
						break;
					} else if (filter.operator == '<') {
						usedLT = true;
					} else if (filter.operator == '>') {
						usedGT = true;
					}
				}
			}
			
			usedFields[i] = usedEqual || (usedLT && usedGT);
		}

		// Construct a list of fields for each optional filter:		
		for (i = 0; i < optionalFilters.length; ++ i) {
			var fields: Array = [ ],
				filter: Filter = optionalFilters[i],
				selectedField: SearchField = filter.selectedField ? filter.selectedField.data : null; 
			
			for (j = 0; j < searchFields.length; ++ j) {
				if (selectedField == searchFields[j] || !usedFields[j]) {
					fields.push ({ label: searchFields[j].label, data: searchFields[j] });
				}
			}
			
			filter.fields = fields;
		}
	}
	
	private function onValueChanged (query: Object, filter: Filter, queryFilter: QueryFilter, newValue: String, oldValue: String): Void {
		//_global.flamingo.tracer ("Value changed: " + newValue + " (" + queryFilter.searchField.id + ")");
		
		var oldComplete: Boolean = queryFilter.complete;
		
		// Assign the new value to the query filter:
		queryFilter.value = newValue;
		
		// Invoke the general change handler for the filter:
		onFilterChanged (query, filter, queryFilter, oldComplete);
	}
	
	private function onDeleteFilter (query: Object, filter: Filter, queryFilter: QueryFilter): Void {
		//_global.flamingo.tracer ("Delete filter");
		
		query.builder.removeFilter (filter);
		queryFilter.query.removeFilter (queryFilter);
		
		// If the deleted filter was an optional filter, and only one optional filter remains, that filter's
		// canDelete attribute is changed to false:
		var serviceDescription: ServiceDescription = queryFilter.query.serviceDescription;
		var searchField: SearchField = queryFilter.searchField;
		if (!serviceDescription.isFieldMandatory (searchField)) {
			var optionalFilters: Array = query.builder.getFilters (function (f: Filter) { return f.allowFieldSelection; });
			
			if (optionalFilters.length == 1) {
				optionalFilters[0].canDelete = false;
			}
		}
		
		// Update all remaining optional filters:
		updateOptionalFilters (query);
	}
	
	private function onPrefixChanged (query: Object, filter: Filter, queryFilter: QueryFilter, prefix: String): Void {
		//_global.flamingo.tracer ("Filter prefix changed: " + prefix);
		
		if (!filter.disabled) {
			//_global.flamingo.tracer ("onPrefixChanged enumerate");
			queryFilter.enumerate (prefix);
		}
	}
	
	/**
	 * This handler is invoked whenever one of the values of a filter is altered (the field or the value).
	 */
	private function onFilterChanged (query: Object, filter: Filter, queryFilter: QueryFilter, oldComplete: Boolean): Void {
	
		// Activate or deactivate the search button depending on whether the mandatory fields have a value:
		var complete: Boolean = queryFilter.query.complete;
		if (complete != query.builder.canSearch) {
			query.builder.canSearch = complete;
		}
		
		// Add a new optional filter after the current one if this is the last filter and it has
		// both a field and a value. Extra filters are only added if search fields exist in the
		// service description that are not associated with a filter yet.
		var serviceDescription: ServiceDescription = queryFilter.query.serviceDescription;
		if (queryFilter.query.isLastFilter (queryFilter) 
			&& queryFilter.value != '' 
			&& queryFilter.searchField != null
			&& (serviceDescription.maxFields == 0 || serviceDescription.maxFields > queryFilter.query.filters.length)) {
				
			// Fetch a list of unassigned search fields:
			var availableSearchFields: Array = queryFilter.query.availableSearchFields;
			if (availableSearchFields.length > 0) {
				addOptionalFilter (query, availableSearchFields, true);
			}
		}
		
		// Clear the first enumerable filter after the current filter:	
		var i: Number,
			filters: Array = queryFilter.query.filters,
			filterComponents: Array = query.builder.getFilters (),
			disabled: Boolean = false,
			currentIndex: Number = filters.length,
			f: QueryFilter;
		for (i = 0; i < filters.length; ++ i) {
			f = filters[i];
			
			if (f == queryFilter) {
				currentIndex = i;
			}
			
			if (f.searchField && f.searchField.enumerate && i > currentIndex) {
				//_global.flamingo.tracer ("Clearing next enumerable filter: " + f.searchField.id);
				f.clearFieldValues ();
				break;
			}
		}
		
		// Enable all enumerable filters until an incomplete filter is found. Filters that are disabled have their
		// previous field values removed, filters that are enabled will be enumerated if they currently have no field values:
		for (i = 0; i < filters.length; ++ i) {
			f = filters[i];
		
			if (f.searchField && f.searchField.enumerate) {
				if (disabled) {
					//_global.flamingo.tracer ("Clearing disabled filter: " + f.searchField.id);
					f.clearFieldValues ();
				} else {
					//_global.flamingo.tracer ("onFilterChanged enumerate: " + f.searchField.id);
					f.enumerate ();
				}
				filterComponents[i].disabled = disabled;
			}
			
			if (!f.complete) {
				disabled = true;
			}
		}

		
		// Update enumerable filters when a filters becomes (in-)complete. If a filter is
		// enumerable and incomplete, all enumerable filters that follow are disabled.
		// if (oldComplete != queryFilter.complete) {
			/*
			var i: Number;
			var filters: Array = queryFilter.query.filters;
			var filterComponents: Array = query.builder.getFilters ();
			var disabled: Boolean = false;
			var currentFilterIndex: Number = filters.length;
			var enumerated: Boolean = false;
			
			for (i = 0; i < filters.length; ++ i) {
				var f: QueryFilter = filters[i];
				
				if (f == queryFilter) {
					currentFilterIndex = i;
				}
				
				if (!f.searchField || !f.searchField.enumerate) {
					continue;
				}
				
				_global.flamingo.tracer (" - " + f.searchField.id + " status: " + !disabled);
				filterComponents[i].disabled = disabled;
				if (disabled) {
					filterComponents[i].value = null;
					filterComponents[i].possibleValues = [ ];
					filters[i].clearFieldValues ();
				} else if (i > currentFilterIndex) {
					filterComponents[i].possibleValues = [ ];
					filters[i].clearFieldValues ();
					_global.flamingo.tracer ("Clearing filter: " + filters[i].searchField.id);
					if (!enumerated) {
						filters[i].enumerate ();
						enumerated = true;
					}
					break;
				}
				
				if (!f.complete) {
					disabled = true;
				}
			}
			*/
		// }
	}
	
	/**
	 * This handler is invoked whenever a filter is added to a query builder.
	 */
	private function onFilterAdded (query: Object, filter: Filter, queryFilter: QueryFilter): Void {
		
		var i: Number;
		
		// Add close buttons to all optional filters if the newly created filter is optional and
		// there are more optional filters:
		var serviceDescription: ServiceDescription = queryFilter.query.serviceDescription;
		var searchField: SearchField = queryFilter.searchField;
		if (!serviceDescription.isFieldMandatory(searchField)) {
			var optionalFilters: Array = query.builder.getFilters (function (f: Filter) { return f.allowFieldSelection; });
			
			if (optionalFilters.length > 1) {
				for (i = 0; i < optionalFilters.length; ++ i) {
					optionalFilters[i].canDelete = true;
				}
			}
		}
	}
	
	private function onFieldValuesAvailable (query: Object, filter: Filter, queryFilter: QueryFilter, values: Array): Void {
		
		//_global.flamingo.tracer ("Field values have become available for field: " + queryFilter.searchField.label);
		
		if (values === null) {
			filter.possibleValues = null;
		} else {
			var fieldValues: Array = [ ];
			var i: Number;
			for (i = 0; i < values.length; ++ i) {
				fieldValues.push ({
					label: values[i].label,
					value: values[i].value,
					data: values[i]
				});
			}
			
			filter.possibleValues = fieldValues;
		}
	}
	
	// =========================================================================
	// Persisting component state:
	// =========================================================================
	public function persistState (document: XML, node: XMLNode): Void {
		var queriesNode: XMLNode = document.createElement ('Queries');
		
		for (var i: Number = 0; i < queries.length; ++ i) {
			var query: Query = queries[i].query;
			
			query.persistState (document, queriesNode);
		}
		
		node.appendChild (queriesNode);
		
		// Serialize a list of active filters:
		var activeFiltersNode: XMLNode = document.createElement ('ActiveFilters');
		
		for (var id: String in activeFilters) {
			var filterNode: XMLNode = document.createElement ('F');
			filterNode.attributes['id'] = id;
			filterNode.appendChild (document.createTextNode (activeFilters[id]));
			activeFiltersNode.appendChild (filterNode);
		}
		
		node.appendChild (activeFiltersNode);
	}
	
	public function restoreState (node: XMLNode): Void {
		var queriesNode: XMLNode = XMLTools.getChild ('Queries', node),
			activeFiltersNode: XMLNode = XMLTools.getChild ('ActiveFilters', node),
			self: QueryComponent = this;
		
		if (queriesNode) {
			Arrays.each (queriesNode.childNodes, function (query: XMLNode): Void {
				var o: Object;
				
				if (query.nodeName != 'Query' || !query.attributes['service']) {
					return;
				}
				
				for (var i: Number = 0; i < self.queries.length; ++ i) {
					if (self.queries[i].serviceDescription.id == query.attributes['service']) {
						o = self.queries[i];
						break;
					}
				}
				
				if (o) {
					self.restoreQuery (query, o);
				}
			});
		}
		
		if (activeFiltersNode) {
			Arrays.each (activeFiltersNode.childNodes, Delegate.create (this, restoreActiveFilter));
		}
	}
	
	private function restoreActiveFilter (activeFilter: XMLNode): Void {
		var serviceId: String = activeFilter.attributes['id'],
			filter: String = activeFilter.firstChild.nodeValue,
			serviceDescription: ServiceDescription,
			mapId: String = listento[0],
			i: Number;
			
		// Locate the service description:
		for (i = 0; i < queries.length; ++ i) {
			if (queries[i].serviceDescription.id == serviceId) {
				serviceDescription = queries[i].serviceDescription;
				break;
			}
		}
		if (!serviceDescription || !serviceDescription.filterLayer) {
			return;
		}

		activeFilters[serviceDescription.id] = filter;
				
		// Locate the layer:
		var parts: Array = serviceDescription.filterLayer.split ('.'),
			layerId: String = parts[0],
			subLayerId: String = parts[1],
			layerComponentId: String = mapId + '_' + layerId;
			
		// Set the filter after the layer updates for the first time:
		onLayerReady (layerComponentId, function (layerComponent: MovieClip): Void {
			layerComponent.setLayerProperty (subLayerId, "queryable", true);
			layerComponent.setLayerProperty (subLayerId, "query", filter);
			_global.flamingo.getComponent (mapId).refresh ();
		});
	}
	
	private function onLayerReady (layerComponentId: String, callback: Function): Void {
		var mapService: MovieClip = _global.flamingo.getComponent (layerComponentId);
			
		if (mapService && mapService.initialized && !mapService.updating) {
			callback (mapService);
		} else {
			var self: QueryComponent = this;
			var op: Function = function (target: MovieClip): Void {
					_global.flamingo.removeListener (listener, layerComponentId, self);
					callback (target); 
				};
				
			var listener: Object = {
				onUpdateComplete: op
			};
			
			_global.flamingo.addListener (listener, layerComponentId, this);
		}
	}
	
	private function restoreQuery (node: XMLNode, o: Object): Void {
		var filtersNode: XMLNode = XMLTools.getChild ("Filters", node);
		if (!filtersNode) {
			return;
		}
		
		// Create the query instance if it doesn't exist yet:
		if (!o.query) {
			createQuery (o);
		}
		
		var serviceDescription: ServiceDescription = o.serviceDescription,
			query: Query = o.query,
			queryBuilder: QueryBuilder = o.builder,
			filters: Array = query.filters,
			filter: QueryFilter,
			filterComponents: Array = queryBuilder.getFilters (),
			filterComponent: Filter,
			filterNode: XMLNode,
			i: Number,
			j: Number;
			
		// Restore values for the fixed search fields (canDelete is false and allowFieldSelection is false).
		// These must be present in both the query and the XML document:
		for (i = 0; i < filters.length && i < filtersNode.childNodes.length; ++ i) {
			filterNode = filtersNode.childNodes[i];
			filter = filters[i];
			filterComponent = filterComponents[i];
			
			if (filterComponent.canDelete || filterComponent.allowFieldSelection) {
				break;
			}
			 
			// Verify that the search fields match:
			if (!filter.searchField || filterNode.attributes['searchField'] != filter.searchField.id) {
				// Stop parsing this query, the mandatory field list has changed since serializing this filter.
				return; 
			}
			 
			restoreFilterValue (filterNode, filter, filterComponent);
		}
		
		// Remove all optional filters:
		for (j = filters.length - 1; j >= i; -- j) {
			queryBuilder.removeFilter (filterComponents[j]);
			query.removeFilter (filters[j]);
		}

		// Restore values for optional filters:
		for (; i < filtersNode.childNodes.length; ++ i) {
			filterNode = filtersNode.childNodes[i];
			
			restoreOptionalFilter (filtersNode.childNodes[i], o, query, queryBuilder, i == filtersNode.childNodes.length - 1);
		}
		
		// Add an empty filter if there are still search fields that are not used in a query and if
		// the last filter is 'complete':
		if (query.lastFilter && query.lastFilter.complete) {
			var queryComponents: Array = queryBuilder.getFilters ();
			onFilterChanged (o, queryComponents[queryComponents.length - 1], query.lastFilter, false);
			
		}
		
		updateOptionalFilters (o);
	}
	
	private function restoreFilterValue (node: XMLNode, filter: QueryFilter, filterComponent: Filter): Void {
		if (node.attributes['operator']) {
			filterComponent.operator = node.attributes['operator'];
		}
		
		if (node.attributes['value']) {
			filterComponent.value = node.attributes['value'];
		}
	}
	
	private function restoreOptionalFilter (node: XMLNode, o: Object, query: Query, queryBuilder: QueryBuilder, last: Boolean): Void {
		// Temporarily change the maxFields property of the service description to 1 in order to
		// prevent blank search filters from being created after this filter:
		var maxFields: Number = query.serviceDescription.maxFields;
		query.serviceDescription.setAttribute ('maxfields', '1');
		
		var f: Object = addOptionalFilter (o, [], !last),
			filter: QueryFilter = f.queryFilter,
			filterComponent: Filter = f.filter;
		
		
		// Set the search field:
		if (node.attributes['searchField']) {
			var searchField: String = node.attributes['searchField'];
			updateOptionalFilters (o);
			for (var i: Number = 0; i < filterComponent.fields.length; ++ i) {
				if (filterComponent.fields[i].data.id == searchField) {
					filterComponent.selectedField = filterComponent.fields[i];
					break;
				}
			}
		}
		
		// Set the value and operator if they are provided in the node:
		if (node.attributes['value']) {
			filterComponent.value = node.attributes['value'];
		}
		if (node.attributes['operator']) {
			filterComponent.operator = node.attributes['operator'];
		}
		
		query.serviceDescription.setAttribute ('maxfields', String (maxFields));
	}
	
	// =========================================================================
	// Component configuration:
	// =========================================================================
	function setAttribute (name: String, value: String): Void {
		switch (name.toLowerCase ()) {	
			 case 'startupindex':
	    		this.startupIndex = Number(value);
	    	break;
		}
		
		
    }
    
    function addComposite (name: String, config: XMLNode): Void {
    	
    	try {
	    	switch (name.toLowerCase ()) {
	    	case 'filterdescription':
	    	case 'servicedescription':
	    		_serviceDescriptions.push (new ServiceDescription (config));
	    		break;
	    	case 'string':
	    		break;
	    	default:
	    		throw new Error ('Invalid composite: ' + name);
	    	}
    	} catch (e:Error) {
    		_global.flamingo.tracer ("Query component configuration error: " + e.message);
    	}
    }
    
    
    private function t (msg:String):Void {
		
		_global.flamingo.tracer (msg);
	}
}
