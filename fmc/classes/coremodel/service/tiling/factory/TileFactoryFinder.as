/*-----------------------------------------------------------------------------
 Copyright (C)
 
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
import coremodel.service.tiling.factory.*;
import gui.layers.TilingLayer;
import tools.Logger;
/**
 * Finds the correct TileFactory
 * @author Roy Braam
 */
class coremodel.service.tiling.factory.TileFactoryFinder{
    private var log:Logger;
    
    public function TileFactoryFinder(){
        this.log = new Logger("coremodel.service.tiling.factory.TileFactoryFinder",_global.flamingo.getLogLevel(),_global.flamingo.getScreenLogLevel());        
    }
        
    public function findFactory(options:Object):TileFactoryInterface{
        log.debug("try to create tileFactory: "+options[AbstractTileFactory.TILINGTYPE_KEY]);
        if (options[AbstractTileFactory.SERVICEURL_KEY]==undefined){
            log.critical("Param "+AbstractTileFactory.SERVICEURL_KEY+" is mandatory for tiling");
            return null;
        }else if (options[AbstractTileFactory.MAP_KEY]==undefined){
            log.critical("Param "+AbstractTileFactory.MAP_KEY+" is mandatory for tiling");
            return null;
        }else if(!options[AbstractTileFactory.RESOLUTIONS_KEY]){
            log.critical("Param "+AbstractTileFactory.RESOLUTIONS_KEY+" is mandatory for tiling");
            return null;
        }else if(!options[AbstractTileFactory.BBOX_KEY]){
            log.critical("Param "+AbstractTileFactory.BBOX_KEY+" is mandatory for tiling");
            return null;
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
            
		}else if (options[AbstractTileFactory.TILINGTYPE_KEY]==TilingLayer.ARCGISREST_TILINGTYPE){			
			factory= new ArcGisRestTileFactory(options[AbstractTileFactory.RESOLUTIONS_KEY]
														,options[AbstractTileFactory.BBOX_KEY]
														,options[AbstractTileFactory.SERVICEURL_KEY]
														,options[AbstractTileFactory.MAP_KEY]);
						
        }else if (options[AbstractTileFactory.TILINGTYPE_KEY]==TilingLayer.OSM_TILINGTYPE){			
			factory= new OSMTileFactory(options[AbstractTileFactory.RESOLUTIONS_KEY]
														,options[AbstractTileFactory.BBOX_KEY]
														,options[AbstractTileFactory.SERVICEURL_KEY]
														,options[AbstractTileFactory.MAP_KEY]);
						
        }
        var extraParams:Object = new Object();
        for (var optionsKey in options){
            if (optionsKey!= AbstractTileFactory.RESOLUTIONS_KEY &&
                    optionsKey!= AbstractTileFactory.BBOX_KEY &&
                    optionsKey!= AbstractTileFactory.SERVICEURL_KEY &&
                    optionsKey!= AbstractTileFactory.MAP_KEY &&
                    optionsKey!= AbstractTileFactory.TILINGTYPE_KEY)
                    {
                extraParams[optionsKey]=options[optionsKey];
            }
        }
        factory.setExtraParams(extraParams);
        return factory;
    }   
}