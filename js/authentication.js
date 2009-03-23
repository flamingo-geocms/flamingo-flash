function addSWFObjectWithAuthentication(configURL, params) {
    if (location.search.indexOf("roles=") == -1) {
        var request = getRequest();
        request.open("GET", configURL, false);
        request.send("");
        var componentNodes = request.responseXML.documentElement.childNodes;
        for (var i = 0; i < componentNodes.length; i++) {
            if (componentNodes[i].nodeName == "fmc:Authentication") {
                var nodes = componentNodes[i].childNodes;
                var node = null;
                var serverURL = null;
                var resourceName = null;
                var roles = "";
                for (var j = 0; j < nodes.length; j++) {
                    node = nodes[j];
                    if (node.nodeName == "fmc:Resource") {
                        serverURL = node.attributes[1].nodeValue;
                        resourceName = node.attributes[0].nodeValue;
                    } else if (node.nodeName == "fmc:Role") {
                        if (roles != "") {
                            roles += ";";
                        }
                        roles += node.attributes[0].nodeValue + ":" + node.attributes[1].nodeValue;
                    }
                }
                location.href = serverURL + "/back-2-future.jsp?resource=" + resourceName + "&future=" + location.href + "&roles=" + roles;
                break;
            }
        }
        addSWFObject(configURL, params);
    } else {
        var roles = location.search.substr(location.search.indexOf("roles=") + 6);
        if (roles.indexOf("&") > -1) {
            roles = roles.substr(0, roles.indexOf("&"));
        }
        if (params == null) {
            params = "roles=" + roles;
        } else {
            params += "&roles=" + roles;
        }
        addSWFObject(configURL, params);
    }
}

function addSWFObject(configURL, params) {
    if (configURL.indexOf(":") == -1) { // No colon means a relative url.
        configURL = "../" + configURL;
    }
    if (params == null) {
        params = "";
    } else {
        params = "&" + params;
    }
    
    childPopups  = new Array();
    childPopupNr = 0;

    var so = new SWFObject("flamingo/flamingo.swf?config=" + configURL + params, "flamingo", "100%", "100%", "8", "#eaeaea");
    so.write("flashcontent");
}

function getRequest() {
    var request = false;
    
/*@cc_on @*/
/*@if (@_jscript_version >= 5)
    
    try {
        request = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
        try {
            request = new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e1) {
            request = false;
        }
    }
    
@end @*/
    
    if (!request && typeof XMLHttpRequest!='undefined') {
        try {
            request = new XMLHttpRequest();
        } catch (e) {
            request = false;
        }
    }
    if (!request && window.createRequest) {
        try {
            request = window.createRequest();
        } catch (e) {
            request = false;
        }
    }
    
    return request;
}
