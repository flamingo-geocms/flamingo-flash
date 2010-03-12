import coremodel.service.tiling.factory.*;
import gui.layers.TilingLayer;
import tools.Logger;
class coremodel.service.tiling.factory.TileFactoryFinder{
	private var log:Logger;
	
	public function TileFactoryFinder(){
		this.log = new Logger("coremodel.service.tiling.factory.TileFactoryFinder",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());		
	}
		
	public function findFactory(options:Object):TileFactoryInterface{
		log.debug("try to create tileFactory: "+options[AbstractTileFactory.TILINGTYPE_KEY]);
		if (options[AbstractTileFactory.SERVICEURL_KEY]==undefined){
			log.critical("Param "+AbstractTileFactory.SERVICEURL_KEY+" is mandatory for tiling");
			return;
		}else if (options[AbstractTileFactory.MAP_KEY]==undefined){
			log.critical("Param "+AbstractTileFactory.MAP_KEY+" is mandatory for tiling");
			return;
		}else if(!options[AbstractTileFactory.RESOLUTIONS_KEY]){
			log.critical("Param "+AbstractTileFactory.RESOLUTIONS_KEY+" is mandatory for tiling");
			return;
		}else if(!options[AbstractTileFactory.BBOX_KEY]){
			log.critical("Param "+AbstractTileFactory.BBOX_KEY+" is mandatory for tiling");
			return;
		}
		var factory:TileFactoryInterface;
		//create tiling tms factory
		if (options[AbstractTileFactory.TILINGTYPE_KEY].toLowerCase()=="tms"){			
		//check if its necessary to get the params with the url.
			factory= new TMSTileFactory(options[AbstractTileFactory.RESOLUTIONS_KEY]
														,options[AbstractTileFactory.BBOX_KEY]
														,options[AbstractTileFactory.SERVICEURL_KEY]
														,options[AbstractTileFactory.MAP_KEY]);
						
		}else if (options[AbstractTileFactory.TILINGTYPE_KEY].toLowerCase()=="wmsc"){
			factory= new WMScTileFactory(options[AbstractTileFactory.RESOLUTIONS_KEY]
														,options[AbstractTileFactory.BBOX_KEY]
														,options[AbstractTileFactory.SERVICEURL_KEY]
														,options[AbstractTileFactory.MAP_KEY]);
			
		}
		var extraParams:Object = new Object();
		for (var optionsKey in options){
			if (optionsKey!= AbstractTileFactory.RESOLUTIONS_KEY &&
					optionsKey!= AbstractTileFactory.BBOX_KEY &&
					optionsKey!= AbstractTileFactory.SERVICEURL_KEY &&
					optionsKey!= AbstractTileFactory.MAP_KEY){
				extraParams[optionsKey]=options[optionsKey];
			}
		}
		factory.setExtraParams(extraParams);
		return factory;
	}	
}