// fscripts.js
//
// A set of helper functions for embedding the Flamingo 2 mapviewer in a
// web page.
//
// This code is "public domain" and is not part of Flamingo MapComponents.
//
// The code is provided AS IS and should mainly serve as an example
// or starting point for your own helper functions. Please note that
// a Flamingo map configuration can operate perfectly with less
// Javascript or even without.
// Refer to the Flamingo MapComponents website (http://www.flamingo-mc.org/)
// for other examples of embedding Flamingo.
//
// You are invited to improve this code and share your code on the Flamingo
// website Forum.
//
// Date: 2007-07-12
// Author: Flamingo Change Advisory Board
// Copyright: Interprovinciale overleggroep voor geo-informatie (IOG-Geo)

function goFlamingo(p0,p1) {
	configDir = p0; // note the path is relative to the location of the flamingo.swf movie
	configFiles = new Array();
	configFiles = p1.split(",");
	self.moveTo(10, 10);
	self.resizeTo(screen.availWidth-20,screen.availHeight-20);
	childPopups = new Array();
	childPopupNr = 0;
	// set required Flash Player version
	var requiredVersion = 8;
	var installedVersion = deconcept.SWFObjectUtil.getPlayerVersion();
	if (installedVersion['major'] >= requiredVersion) {
		var so = new SWFObject("flamingo/flamingo.swf", "flamingo", "100%", "1010", requiredVersion, "#ffffff");
		so.addParam("align", "middle");
		so.addParam("quality", "high");
		so.addParam("allowScriptAccess", "sameDomain");
		so.write("flashcontent");
	}
	else {
		// insert a message which displays when the Flash Player is missing or too old
		document.write('<blockquote>');
		// *** Dutch text:
		document.write('<font face="Arial, Verdana, Helvetica, Sans Serif" size="+1" color="#666666">De vereiste versie van de Adobe Flash Player is niet gevonden</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-1">');
		if (installedVersion['major'] > 0) {
			document.write("De ge&iuml;nstalleerde versie (versie "+ installedVersion['major'] +"."+ installedVersion['minor'] +"."+ installedVersion['rev']+") is te oud.");
		}
		else {
			document.write('Het lijkt er op dat u geen Flash Player ge&iuml;nstalleerd hebt.');
		}
		document.write('<p><a href="http://www.adobe.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"><img src="http://www.adobe.com/images/shared/download_buttons/get_flashplayer_trans.gif" border="0" width="88" height="31" align="left" style="margin-right: 8px;"></a>');
		document.write('De juiste versie van de Macromedia Flash Player kunt u ophalen op de website van Macromedia. Klik daarvoor op de afbeelding links van deze tekst.<p>Neem s.v.p. contact op met de PC beheerder als u dat zelf niet bent. In dat geval heeft u waarschijnlijk niet voldoende rechten om Flash Player te kunnen installeren.</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-2">Adobe en Flash zijn geregistreerde handelsmerken van Adobe Systems Incorporated.</font>');
		// *** English text:
		document.write('<hr><font face="Arial, Verdana, Helvetica, Sans Serif" size="+1" color="#666666">The required version of the Adobe Flash Player could not be found</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-1">');
		if (installedVersion['major'] > 0) {
			document.write("The installed version (version "+ installedVersion['major'] +"."+ installedVersion['minor'] +"."+ installedVersion['rev']+") is too old.");
		}
		else {
			document.write('It seems you don\'t have a Flash Player installed.');
		}
		document.write('<p><a href="http://www.adobe.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"><img src="http://www.adobe.com/images/shared/download_buttons/get_flashplayer_trans.gif" border="0" width="88" height="31" align="left" style="margin-right: 8px;"></a>');
		document.write('To download the Flash Player click on the image to the left of this text.<p>Please contact your IT support department in case you do not have the rights required to install the Flash Player.</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-2">Adobe and Flash are registered trademarks of Adobe Systems Incorporated.</font>');
		// *** German text:
		document.write('<hr><font face="Arial, Verdana, Helvetica, Sans Serif" size="+1" color="#666666">Die erforderliche Version des Adobe Flash Player wurde nicht gefunden</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-1">');
		if (installedVersion['major'] > 0) {
			document.write("Die installierte version (version "+ installedVersion['major'] +"."+ installedVersion['minor'] +"."+ installedVersion['rev']+") ist zu alt.");
		}
		else {
			document.write('Es scheint, da&szlig; keine Flash Player installiert ist.');
		}
		document.write('<p><a href="http://www.adobe.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"><img src="http://www.adobe.com/images/shared/download_buttons/get_flashplayer_trans.gif" border="0" width="88" height="31" align="left" style="margin-right: 8px;"></a>');
		document.write('Die geeignete Version des Flash Player k�nnen Sie auf der Webseite von Adobe herunterladen. Klicken Sie hierzu einfach auf die Abbildung links neben diesem Text.<p>Bitte wenden Sie sich an Ihren Systemadministrator, falls Sie selbst keine Administratorrechte f�r Ihren PC haben. In diesem Fall sind Sie vermutlich nicht berechtigt, den Flash Player selbst zu installieren.</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-2">Adobe und Flash sind eingetragene Marken oder Marken von Adobe Systems Incorporated.</font>');
		// *** French text:
		document.write('<hr><font face="Arial, Verdana, Helvetica, Sans Serif" size="+1" color="#666666">La version requise d\'Adobe Flash Player n\'a pas &eacute;t&eacute; trouv&eacute;e</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-1">');
		if (installedVersion['major'] > 0) {
			document.write("La version install&eacute;e (version "+ installedVersion['major'] +"."+ installedVersion['minor'] +"."+ installedVersion['rev']+") est trop vieille.");
		}
		else {
			document.write('Il semble que vous ne faites pas installer Flash Player.');
		}
		document.write('<p><a href="http://www.adobe.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"><img src="http://www.adobe.com/images/shared/download_buttons/get_flashplayer_trans.gif" border="0" width="88" height="31" align="left" style="margin-right: 8px;"></a>');
		document.write('La version ad&eacute;quate du Flash Player est disponible sur le site Internet d\'Adobe. Veuillez cliquer sur l\'illustration &agrave; gauche de ce texte.<p>Veuillez prendre contact avec l\'administrateur de votre PC si vous ne l\'&ecirc;tes pas vous-m&ecirc;me. Dans ce cas, il se peut que vous ne disposiez pas des droits suffisants pour installer vous-m&ecirc;me le logiciel Flash Player.</font>');
		document.write('<p><font face="Arial, Verdana, Helvetica, Sans Serif" size="-2">Adobe et Flash sont des marques commerciales d&eacute;pos&eacute;es d\'Adobe Systems Incorporated.</font>');

		document.write('</blockquote>');
	}
}


function flamingo_onInit() {

	var app = getMovie("flamingo");

	//get params
	var cfgdir  = getURLParam("cfgdir"); // e.g. cfgdir=../extraconfigs (no trailing slash)
	var cfg     = getURLParam("cfg");    // e.g. cfg=extra,anotherconfig
	var ext     = getURLParam("ext");    // e.g. ext=222800,584800,223200,585100
	var gem     = getURLParam("gem");    // e.g. gem=amsterdam (gem is short for municipality)
	var regio   = getURLParam("regio");  // e.g. regio=twente
	// handle a parameter like ?amsterdam as if it was defined as ?gem=amsterdam
	if (gem.length <= 0) {
		var gem = getURLParam("");
	}
	var gemeente     = getURLParam("gemeente");    // e.g. gemeente=amsterdam, but this time WITHOUT use of the xml for municipalities
	var lang  = getURLParam("lang");   // e.g. lang=de
	var loc   = getURLParam("loc");    // e.g. loc=places,amsterdam
	var postcode4  = getURLParam("postcode4");     // e.g. postcode4=9801 (a postcode)
	var prv   = getURLParam("prv");    // e.g. prv=utrecht (prv is short for province)
	var provincie     = getURLParam("provincie");    // e.g. provincie=Drenthe, but this time WITHOUT use of the xml for municipalities
	var thema     = getURLParam("thema");    // e.g. provincie=Drenthe, but this time WITHOUT use of the xml for municipalities
	// var title = getURLParam("title");  // e.g. title=Groundwatermap (set HTML page TITLE tag value)
	var laag = getURLParam("laag");
	var vis = getURLParam("vis");
    	var hid = getURLParam("hid");

	// set HTML page TITLE tag
	//document.title = title;

	// uncomment the alert to see parameters passed
	//alert("configDir=" + configDir + "\nconfigFiles=" + configFiles + "\ncfgdir=" + cfgdir + "\ncfg=" + cfg + "\next=" + ext + "\ngem=" + gem + "\nlang=" + lang + "\nloc=" + loc +  "\npc=" + pc + "\nprv=" + prv + "\ntitle=" + title);

	// set language or default to Dutch
	if (lang.length > 0) {
		app.call("flamingo" , "setLanguage", lang);
	}
	else {
		app.call("flamingo" , "setLanguage", "nl");
	}

	if (configDir.length <= 0) {
		configDir = cfgdir;
	}

	// load configuration files passed from the HTML page
	if (configFiles[0] != "") {
		for ( var i = 0; i < configFiles.length; i++ ) {
			app.call("flamingo","loadConfig", configDir+"/"+configFiles[i]+".xml");
		}
	}

	// load configuration files passed as URL parameters
	if (cfg.length > 0){
		configFiles = cfg.split(",");
		if (cfgdir.length > 0) {
			for ( var i = 0; i < configFiles.length; i++ ) {
				app.call("flamingo","loadConfig", cfgdir+"/"+configFiles[i]+".xml");
			}
		}
		else {
			for ( var i = 0; i < configFiles.length; i++ ) {
				app.call("flamingo","loadConfig", configDir+"/"+configFiles[i]+".xml");
			}
		}
	}

	// load extra configuration file for a municipality or province or regio
	if (gem.length > 0) {
		app.call("flamingo","loadConfig", configDir + "/" + gem + ".xml");
	}
	if (prv.length > 0) {
		app.call("flamingo","loadConfig", configDir + "/" + prv + ".xml");
	}
	if (regio.length > 0) {
		app.call("flamingo","loadConfig", configDir + "/" + regio + ".xml");
	}
	
	//set theme
	if (thema.length > 0){
	  app.call("flamingo" , "setArgument", "themeselector" , "currentTheme" , thema);
	}

	// set extent
	if (ext.length > 0) {
		app.call("flamingo" , "setArgument", "map" , "extent" , ext);
	} else if (loc.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , loc);
	} else if (postcode4.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , "postcode,"+postcode4);
	} else if (gem.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , "gemeente,"+gem);
	} else if (regio.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , "regio,"+regio);
	} else if (prv.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , "provincie,"+prv);
	} else if (gemeente.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , "gemeente,"+gemeente);
	} else if (provincie.length > 0) {
		app.call("flamingo" , "setArgument", "locationfinder" , "find" , "provincie,"+provincie);
	} 
	
	if (vis.length > 0) {
      		app.call("flamingo" , "setArgument", "map_" + laag, "visible" , vis);
   	} if (hid.length > 0) {
      		app.call("flamingo" , "setArgument", "map_" + laag, "hidden" , hid);  	
  	}	
}


function getMovie(movieName) {
	if (navigator.appName.indexOf("Microsoft") != -1) {
		return window[movieName];
	}else {
		return document[movieName];
	}
}


function getURLParam(strParamName){
	var strReturn = "";
	var strHref = window.location.href;
	if ( strHref.indexOf("?") > -1 ){
		var strQueryString = strHref.substr(strHref.indexOf("?")+1);
		var aQueryString = strQueryString.split("&");
		for ( var iParam = 0; iParam < aQueryString.length; iParam++ ){
			var aParam = aQueryString[iParam].split("=");
			if ( strParamName == "") {
				if ( aParam[1] == undefined) {
					strReturn = aParam[0];
					break;
				}
			}
			else {
			  if ( aQueryString[iParam].toLowerCase().indexOf(strParamName.toLowerCase() + "=") > -1 ){
  			  strReturn = aParam[1];
				break;
	  		}
			}
		}
	}
	return unescape(strReturn);
}


function popWin(URLtoOpen, windowName, windowFeatures) {
	if ((windowFeatures == "") || (windowFeatures == undefined)) {
		windowFeatures = "width=500,height=400,top=60,left=60,toolbar=no,scrollbars=yes,resizable=yes";
	}
	// open a child popup
	var newWin = window.open("", windowName, windowFeatures);
	if (newWin != null) {
		newWin.location.href = URLtoOpen;
		newWin.focus();
		childPopups[childPopupNr++] = newWin;
	}
}

function closePopWins() {
	// Close any open child popup windows (called from body onUnload event)
	for (var i = 0; i < childPopups.length; i++) {
		if (childPopups[i] && !childPopups[i].closed) {
			childPopups[i].close();
		}
	}
}


function printMap() {
	// basic printing facility using the browser print function
	var app = getMovie("flamingo");
	var lang = app.call("flamingo", "getLanguage");
	if (window.print) {
		if (lang == "nl")
			alert("Het beste resultaat behaalt u door uw printer \nin te stellen op liggend papierformaat.");
		if (lang == "en")
			alert("For the best result please set your printer to landscape.");
		if (lang == "de")
			alert("F�r das beste Resultat bitte stellen Sie Ihrem\nDrucker auf Querformat ein.");
		if (lang == "fr")
			alert("Le meilleur r&eacute;sultat vous obtient en instituant votre imprimante en l'orientation paysage.");
		window.print();
	}
	else {
		if (lang == "nl")
			alert("Uw browser ondersteunt deze functie niet.");
		if (lang == "en")
			alert("Your browser does not support this function.");
		if (lang == "de")
			alert("Ihr Browser unterst�tzt diese Funktion nicht.");
		if (lang == "fr")
			alert("Votre navigateur ne soutient pas cette fonction.");
	}
}
