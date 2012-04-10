/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import tools.*;
/**
 * tools.Randomizer
 */
class tools.Randomizer {
    
    static private var number:Number = 0;
    /**
     * getNumber
     * @return
     */
    static function getNumber():Number {
        return number++;
    }
    
}
