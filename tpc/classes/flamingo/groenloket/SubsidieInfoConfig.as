
import flamingo.tools.XMLTools;
import flamingo.groenloket.GebisPakket;

class flamingo.groenloket.SubsidieInfoConfig {
    private var texts:Object = null; // Associative array.
    private var pakketten:Array = null;
    
    function SubsidieInfoConfig() {
        texts = new Object();
        pakketten = new Array();

        
        //flamingo.tracer("SubsidieInfoConfig");
        var env:SubsidieInfoConfig = this;
        var xml:XML = new XML();
        xml.ignoreWhite = true;
        xml.onLoad = function(successful):Void {
            if (successful) {
                env.onLoadXML(this.firstChild);
            }
        }
        xml.load(_global.flamingo.correctUrl("tpc/classes/flamingo/groenloket/SubsidieInfoConfig.xml"));
    }
    
    function onLoadXML(rootNode:XMLNode):Void {
        var textsNode:XMLNode = XMLTools.getChild("Texts", rootNode);
        var textNodes:Array = XMLTools.getChildNodes("Text", textsNode);
        var textNode:XMLNode = null;

        //flamingo.tracer("SubsidieInfoConfig.onLoadXML");
        
        for (var i:Number = 0; i < textNodes.length; i++) {
            textNode = XMLNode(textNodes[i]);
            texts[XMLTools.getStringValue("Name", textNode)] = XMLTools.getStringValue("Value", textNode);
        }
        
        var sanPakkettenNode:XMLNode = XMLTools.getChild("SANPakketten", rootNode);
        var sanPakketNodes:Array = XMLTools.getChildNodes("SANPakket", sanPakkettenNode);
        var snPakkettenNode:XMLNode = XMLTools.getChild("SNPakketten", rootNode);
        var snPakketNodes:Array = XMLTools.getChildNodes("SNPakket", snPakkettenNode);
        var lgpPakkettenNode:XMLNode = XMLTools.getChild("LGPPakketten", rootNode);
        var lgpPakketNodes:Array = XMLTools.getChildNodes("LGPPakket", lgpPakkettenNode);
        
        var gebisPakketNode:XMLNode = null;
        var id:String = null;
        var description:String = null;
        var url:String = null;
        
        for (var i:Number = 0; i < sanPakketNodes.length; i++) {
            gebisPakketNode = XMLNode(sanPakketNodes[i]);
            id = XMLTools.getStringValue("ID", gebisPakketNode);
            description = XMLTools.getStringValue("Description", gebisPakketNode);
            url = XMLTools.getStringValue("URL", gebisPakketNode);
            pakketten.push(new GebisPakket("SAN " + id, description, url));
        }
        for (var i:Number = 0; i < snPakketNodes.length; i++) {
            gebisPakketNode = XMLNode(snPakketNodes[i]);
            id = XMLTools.getStringValue("ID", gebisPakketNode);
            description = XMLTools.getStringValue("Description", gebisPakketNode);
            url = XMLTools.getStringValue("URL", gebisPakketNode);
            pakketten.push(new GebisPakket("SN " + id, description, url));
        }
        for (var i:Number = 0; i < lgpPakketNodes.length; i++) {
            gebisPakketNode = XMLNode(lgpPakketNodes[i]);
            id = XMLTools.getStringValue("ID", gebisPakketNode);
            description = XMLTools.getStringValue("Description", gebisPakketNode);
            url = XMLTools.getStringValue("URL", gebisPakketNode);
            pakketten.push(new GebisPakket("LGP " + id, description, url));
        }
    }
    
    function getText(name:String):String {
        return texts[name];
    }
    
    function getPakket(id:String):GebisPakket {
        var pakket:GebisPakket = null;
        for (var i:Number = 0; i < pakketten.length; i++) {
            pakket = GebisPakket(pakketten[i]);
            if (pakket.getID().toUpperCase() == id.toUpperCase()) {
                return pakket;
            }
        }
        return null;
    }
        
    function getPakketten(prefix:String):Array {
        return pakketten.concat();
    }
    
}
