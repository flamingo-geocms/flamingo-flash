/*-----------------------------------------------------------------------------
* This file is part of Flamingo MapComponents.
* Author: Michiel J. van Heek.
* IDgis bv
 -----------------------------------------------------------------------------*/

import tools.*;

class tools.Randomizer {
    
    static private var number:Number = 0;
    
    static function getNumber():Number {
        return number++;
    }
    
}
