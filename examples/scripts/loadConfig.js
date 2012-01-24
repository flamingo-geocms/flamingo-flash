var conf=null;
var loc=""+window.location;
if (loc.toLowerCase().indexOf("config=") > 0){
	var configString=loc.substring(loc.toLowerCase().indexOf('config=')+7);
	var configs=configString.split(",");
	var conf="config=";
	for (var i=0; i < configs.length; i++){
	    if (i!=0)
	    	conf+=",";
	    conf+="../configs/"+configs[i];
	}
		
}
if (conf==null){
	alert("Configuratie niet meegegeven");

}else{
	var loc="flamingo/flamingo.swf?"+conf;
	var so = new SWFObject(loc, "flamingo", "100%", "100%", "8", "#FFFFFF");
	so.write("flashcontent");
}
document.getElementById("configLink").href="flamingo/"+conf.substring(7);
var flamingo = document.getElementById("flamingo");