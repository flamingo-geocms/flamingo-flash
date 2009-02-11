class flamingo.groenloket.GebisPakket {
    
    var id:String = null;
    var description:String = null;
    var url:String = null;
    
    function GebisPakket(id:String, description:String, url:String) {
        this.id = id;
        this.description = description;
        this.url = url;
    }
    
    function getID():String {
        return id;
    }
    
    function getDescription():String {
        return description;
    }
    
    function getURL():String {
        return url;
    }
    
}
