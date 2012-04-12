/*-----------------------------------------------------------------------------
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
/** @component NavigationControl
* Navigation control
* @file flamingo/classes/gui/NavigationControl.as (sourcefile)
* @file flamingo/classes/core/AbstractConfigurable.as
* @file flamingo/classes/core/AbstractPositionable.as
* @file flamingo/classes/gui/Button/MoveExtentButton.as 
* @file flamingo/classes/gui/Button/ZoomerV.as 
* @configstring tooltip_north tooltiptext of north button
* @configstring tooltip_south tooltiptext of south button
* @configstring tooltip_west tooltiptext of west button
* @configstring tooltip_east tooltiptext of east button
*/
/** @tag <fmc:NavigationControl>  
* This tag defines navigation control with border panning and a zoomer.
* @hierarchy childnode of <flamingo> or a container component. e.g. <fmc:Window>* 
* @example <fmc:NavigationControl top="50" left="20" height="300" listento="map" showfullextent="true" zoomeroffset="5" zoomerbackgroundoffset="-5" />
* @attr listento the id of the map that must be controlled.
* @attr zoomeroffset (optional; default 7) The y offset in pixels of the move extent buttons.
* @attr zoomerbackgroundoffset (optional; default -5) The y offset of the background of the zoomer
* @attr showFullExtent (optional; default true) if set to true the fullextent button will be added. 
* @attr showZoomerButtons (optional; default true) if set to false the zoomerv buttons will be hidden
* But only if there is a full extent set on the map.
*/
import core.AbstractConfigurable;
import gui.button.ButtonFull;
import gui.button.MoveExtentButton;
import gui.Map;
import gui.ZoomerV;
import mx.data.encoders.Num;
import tools.Logger;
import display.spriteloader.SpriteSettings;
import display.spriteloader.SpriteMap;
/**
 * Navigation control. Creates a navigation control that can move the extent and has a zoomslider.
 * @author <a href="mailto:roybraam@b3partners.nl">Roy Braam</a>
 */
class gui.NavigationControl extends AbstractConfigurable
{	
	private var ZOOMER_OFFSET_PARAM:String = "zoomeroffset"; 
	private var ZOOMER_BACKGROUND_OFFSET_PARAM:String = "zoomerbackgroundoffset"; 
	private var SHOW_FULLEXTENT_PARAM:String = "showfullextent";
	private var SHOW_ZOOMER_BUTTONS:String = "showzoomerbuttons";
	private var _firstTime:Boolean;
	private var _map:Map;
	
	private var _mcloader:MovieClipLoader;
	private var _spriteMap:SpriteMap;
	
	private var _northButton:MoveExtentButton;
	private var _westButton:MoveExtentButton;
	private var _southButton:MoveExtentButton;
	private var _eastButton:MoveExtentButton;
	//corners
	private var _neCorner:MovieClip;
	private var _seCorner:MovieClip;
	private var _swCorner:MovieClip;
	private var _nwCorner:MovieClip;
	private var _mid:MovieClip;
	//zoomerv	
	private var _zoomerBackground:MovieClip;
	private var _zoomerBackgroundBottom:MovieClip;
	private var _zoomer:ZoomerV;
	private var _zoomerOffset:Number;
	private var _zoomerBackgroundOffset:Number;
	//button full
	private var _buttonFull:ButtonFull;
	private var _showFullExtent:Boolean = true;
	private var _showZoomerButtons:Boolean = true;
	
	//var moveExtentButton:MoveExtentButton = new MoveExtentButton(this.id + pos, this.container.createEmptyMovieClip("m" + pos, i), this);
	/**
	 * Constructor for creating this component
	 * @param	id the id of this object
	 * @param	container the container where the visible components must be placed.
	 * @see core.AbstractPositionable
	 */
	public function NavigationControl(id,container) {		
		super(id, container);	
		spriteMap = flamingo.spriteMapFactory.obtainSpriteMap(flamingo.correctUrl( "assets/img/sprite.png"));
		this.mcloader = new MovieClipLoader();
		this.firstTime = true;
		this.zoomerOffset = 7;
		this.zoomerBackgroundOffset = -5;
	}	
	/**
	 * Overwrites the super.setConfig() to call some functions after the config is set.	
	 * @param	xml The xml config
	 * @see AbstractConfigurable#setConfig
	 */
	public function setConfig(xml:XMLNode) {		
		super.setConfig(xml);
		if (firstTime) {
			firstTime = false;
			map = flamingo.getComponent(this.listento[0]);
			addMoveExtentButtons();
			addZoomerV();
		}else {
			if (this.zoomer.showButtons != this.showZoomerButtons) {
				this.zoomer.setShowButtons(this.showZoomerButtons);
			}
		}
		if (this.showFullExtent && this.buttonFull==null) {					
			addButtonFull();
		}else if (!this.showFullExtent && this.buttonFull==null){
			this.buttonFull.setVisible(false);
		}
		resize();
	}
	/**
	 * Passes a configured attribute for this component.
	 * @param name name of the attribute
	 * @param value value of the attribute
	 */
    function setAttribute(name:String, value:String):Void {
        var lowerName = name.toLowerCase();        
		if (lowerName == ZOOMER_OFFSET_PARAM) {
			this.zoomerOffset = Number(value);
		}else if (lowerName == ZOOMER_BACKGROUND_OFFSET_PARAM) {
			this.zoomerBackgroundOffset = Number(value);
		}else if (lowerName == SHOW_FULLEXTENT_PARAM) {
			if (value.toLowerCase()=="true"){
				this.showFullExtent = true;
			}else {
				this.showFullExtent = false;
			}
		}else if (lowerName == SHOW_ZOOMER_BUTTONS) {
			if (value.toLowerCase()=="true"){
				this.showZoomerButtons = true;
			}else {
				this.showZoomerButtons = false;
			}
		}
    }
	
	/**
	 * Resize the component according the set values and parent
	 */
	function resize(){		
		super.resize();
		//flamingo.position(this);
		//Logger.console("parent: "+this.parent);
		var r = flamingo.getPosition(this,this.parent);			
		this.container._x = r.x;
		this.container._y = r.y;
		
		var buttonSize = SpriteSettings.buttonSize;
		var sliderSize = SpriteSettings.sliderSize;		
		if (3 * SpriteSettings.buttonSize > r.width) {
			buttonSize = Math.floor(r.width / 3);
			sliderSize = Math.floor(SpriteSettings.sliderSize * (r.width / 3) / SpriteSettings.buttonSize);
			zoomerOffset = Math.floor(zoomerOffset * (r.width / 3) / SpriteSettings.buttonSize);
			zoomerBackgroundOffset = Math.floor(zoomerBackgroundOffset * (r.width / 3) / SpriteSettings.buttonSize);
		}
		
		//calculate the button positions
		var x:Number = r.x;
		var y:Number = r.y;
		var navigationSize:Number = 3 * buttonSize;
		
		var navBottom:Number = y + navigationSize - buttonSize;
		var navRight:Number = x + navigationSize - buttonSize;
		var navXCenter = x + navigationSize / 2 -buttonSize;
		var navYCenter = y + navigationSize / 2 -buttonSize;
		
		//set the buttons.
		northButton.move(navXCenter, y);
		northButton.container._height = buttonSize;
		northButton.container._width = buttonSize;
		eastButton.move(navRight,navYCenter);
		eastButton.container._height = buttonSize;
		eastButton.container._width = buttonSize;
		southButton.move(navXCenter, navBottom);
		southButton.container._height = buttonSize;
		southButton.container._width = buttonSize;
		westButton.move(x, navYCenter);		
		westButton.container._height = buttonSize;
		westButton.container._width = buttonSize;
		
		//position the corners
		neCorner._x = x+2 * buttonSize;
		neCorner._y = y;
		neCorner._height = buttonSize;
		neCorner._width = buttonSize;
		seCorner._x = x+2 * buttonSize;
		seCorner._y = y+2 * buttonSize;
		seCorner._height = buttonSize;
		seCorner._width = buttonSize;
		swCorner._x = x;
		swCorner._y = y+2 * buttonSize;
		swCorner._height = buttonSize;
		swCorner._width = buttonSize;
		nwCorner._x = x;
		nwCorner._y = y;
		nwCorner._height = buttonSize;
		nwCorner._width = buttonSize;
		mid._x = x + buttonSize;
		mid._y = y + buttonSize;
		mid._height = buttonSize;
		mid._width = buttonSize;
		
		//button full extent
		buttonFull.top = "" +(y + buttonSize);
		buttonFull.left = "" +(x + buttonSize);
		buttonFull.width =  buttonSize;
		buttonFull.height = buttonSize;
		buttonFull.resize();
		//set zoomer background
		zoomerBackground._x = x+buttonSize;
		zoomerBackground._y = y + 3 * buttonSize + zoomerBackgroundOffset;
		zoomerBackground._width = buttonSize;
		zoomerBackground._height = r.height -4 * buttonSize;		
		zoomerBackgroundBottom._x = x+buttonSize;
		zoomerBackgroundBottom._y = y + r.height - buttonSize + zoomerBackgroundOffset;
		zoomerBackgroundBottom._width = buttonSize;
		zoomerBackgroundBottom._height = buttonSize;
				
		//set position zomer
		zoomer.top = ""+(y+3 * buttonSize+zoomerBackgroundOffset+zoomerOffset);
		zoomer.left = ""  + (x+buttonSize+(buttonSize-sliderSize)/2);		
		zoomer.height = "" + (r.height - 3 * buttonSize-zoomerOffset * 2);
		zoomer.width = "" + sliderSize;
		//zoomer.top = "" + (5 * buttonSize);
		zoomer.resize();
		//position zoomer
		//zoomer.container._x = buttonSize;
		//zoomer.container._y = 3 * buttonSize;		
	}	
	/**
	 * Creates and adds the moveExtent buttons.
	 */
	public function addMoveExtentButtons() {	
		var offset = SpriteSettings.buttonSize/2;		
		
		westButton = new MoveExtentButton(this.id + "_west", this.container.createEmptyMovieClip("m" + "_west", this.container.getNextHighestDepth()), this,this.map);
		westButton.setDirectionMatrix(- 1, 0);
		westButton.tooltipId = "tooltip_west";
		westButton.toolDownSettings = new SpriteSettings(0, 21*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offset, true, 100);
		westButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 21*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offset, true, 100);
		westButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 21*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offset, true, 100);
		
		eastButton = new MoveExtentButton(this.id + "_east", this.container.createEmptyMovieClip("m" + "_east", this.container.getNextHighestDepth()), this,map);
		eastButton.setDirectionMatrix(1, 0);
		eastButton.tooltipId = "tooltip_east";
		eastButton.toolDownSettings = new SpriteSettings(0, 18*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offset, true, 100);
		eastButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 18*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offset, true, 100);
		eastButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 18*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, offset, true, 100);
		
		northButton = new MoveExtentButton(this.id + "_north", this.container.createEmptyMovieClip("m" + "_north", this.container.getNextHighestDepth()), this,map);
		northButton.setDirectionMatrix(0, 1);
		northButton.tooltipId = "tooltip_north";
		northButton.toolDownSettings = new SpriteSettings(0,19*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offset, 0, true, 100);
		northButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 19*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offset, 0, true, 100);
		northButton.toolUpSettings = new SpriteSettings(2*SpriteSettings.buttonSize, 19*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offset, 0, true, 100);

		southButton = new MoveExtentButton(this.id + "_north", this.container.createEmptyMovieClip("m" + "_north", this.container.getNextHighestDepth()), this,map);
		southButton.setDirectionMatrix(0, - 1);
		southButton.tooltipId = "tooltip_south";
		southButton.toolDownSettings = new SpriteSettings(0,20*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offset, 0, true, 100);
		southButton.toolOverSettings = new SpriteSettings(1*SpriteSettings.buttonSize, 20*SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offset, 0, true, 100);
		southButton.toolUpSettings = new SpriteSettings(2 * SpriteSettings.buttonSize, 20 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, offset, 0, true, 100);
		
		//add the corners
		neCorner = this.container.createEmptyMovieClip("neCorner", this.container.getNextHighestDepth());		
		spriteMap.attachSpriteTo(neCorner,
			new SpriteSettings(0, 22 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
		seCorner = this.container.createEmptyMovieClip("seCorner", this.container.getNextHighestDepth());		
		spriteMap.attachSpriteTo(seCorner,
			new SpriteSettings(2*SpriteSettings.buttonSize, 22 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
		swCorner = this.container.createEmptyMovieClip("swCorner", this.container.getNextHighestDepth());		
		spriteMap.attachSpriteTo(swCorner,
			new SpriteSettings(0, 23 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
		nwCorner = this.container.createEmptyMovieClip("nwCorner", this.container.getNextHighestDepth());		
		spriteMap.attachSpriteTo(nwCorner,
			new SpriteSettings(SpriteSettings.buttonSize, 22 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
		mid = this.container.createEmptyMovieClip("mid", this.container.getNextHighestDepth());		
		spriteMap.attachSpriteTo(mid,
			new SpriteSettings(SpriteSettings.buttonSize, 23 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
			
		//zoomer background
		zoomerBackground = this.container.createEmptyMovieClip("zoomerBackground", this.container.getNextHighestDepth());
		spriteMap.attachSpriteTo(zoomerBackground,
			new SpriteSettings(0, 24 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
		zoomerBackgroundBottom = this.container.createEmptyMovieClip("zoomerBackgroundBottom", this.container.getNextHighestDepth());
		spriteMap.attachSpriteTo(zoomerBackgroundBottom,
			new SpriteSettings(SpriteSettings.buttonSize, 24 * SpriteSettings.buttonSize, SpriteSettings.buttonSize, SpriteSettings.buttonSize, 0, 0, true, 100));
	}
	public function addButtonFull():Void {
		if (map!=undefined && map.getFullExtent()!=null){
			buttonFull = new ButtonFull(this.id + "_full", this.container.createEmptyMovieClip(this.id + "_full", this.container.getNextHighestDepth()));
			buttonFull.listento = this.listento;	
			buttonFull.setConfig(null);
		}
	}
	/**
	 * Create and adds the zoomerV object.
	 */
	public function addZoomerV():Void {
		zoomer = new ZoomerV(this.id + "_zoomer", this.container.createEmptyMovieClip(this.id + "_zoomer", this.container.getNextHighestDepth()));						
		zoomer.listento = this.listento;
		zoomer.showButtons = this.showZoomerButtons;
		zoomer.setConfig(null);
	}
	
	/** Getters and setters **/
	public function get northButton():MoveExtentButton{
		return _northButton;
	}
	public function set northButton(value:MoveExtentButton):Void {
		_northButton = value;
	}
	public function get westButton():MoveExtentButton {
		return _westButton;
	}
	public function set westButton(value:MoveExtentButton):Void{
		_westButton = value;
	}
	public function get southButton():MoveExtentButton{
		return _southButton;
	}
	public function set southButton(value:MoveExtentButton):Void {
		_southButton = value;
	}
	public function get eastButton():MoveExtentButton {
		return _eastButton;
	}
	public function set eastButton(value:MoveExtentButton):Void {
		_eastButton = value;
	}
	public function get map():Map 
	{
		return _map;
	}
	public function set map(value:Map):Void 
	{
		_map = value;
	}
	public function get mcloader():MovieClipLoader 
	{
		return _mcloader;
	}
	public function set mcloader(value:MovieClipLoader):Void 
	{
		_mcloader = value;
	}
	public function get spriteMap():SpriteMap 
	{
		return _spriteMap;
	}
	public function set spriteMap(value:SpriteMap):Void 
	{
		_spriteMap = value;
	}
	public function get neCorner():MovieClip 
	{
		return _neCorner;
	}
	public function set neCorner(value:MovieClip):Void 
	{
		_neCorner = value;
	}
	public function get seCorner():MovieClip 
	{
		return _seCorner;
	}
	public function set seCorner(value:MovieClip):Void 
	{
		_seCorner = value;
	}
	public function get swCorner():MovieClip 
	{
		return _swCorner;
	}
	public function set swCorner(value:MovieClip):Void 
	{
		_swCorner = value;
	}
	public function get nwCorner():MovieClip 
	{
		return _nwCorner;
	}
	public function set nwCorner(value:MovieClip):Void 
	{
		_nwCorner = value;
	}
	public function get mid():MovieClip 
	{
		return _mid;
	}
	public function set mid(value:MovieClip):Void 
	{
		_mid = value;
	}
	public function get zoomer():ZoomerV 
	{
		return _zoomer;
	}
	public function set zoomer(value:ZoomerV):Void 
	{
		_zoomer = value;
	}
	public function get firstTime():Boolean 
	{
		return _firstTime;
	}
	public function set firstTime(value:Boolean):Void 
	{
		_firstTime = value;
	}
	public function get zoomerBackground():MovieClip 
	{
		return _zoomerBackground;
	}
	public function set zoomerBackground(value:MovieClip):Void 
	{
		_zoomerBackground = value;
	}
	public function get zoomerBackgroundBottom():MovieClip 
	{
		return _zoomerBackgroundBottom;
	}
	public function set zoomerBackgroundBottom(value:MovieClip):Void 
	{
		_zoomerBackgroundBottom = value;
	}
	public function get zoomerOffset():Number 
	{
		return _zoomerOffset;
	}
	public function set zoomerOffset(value:Number):Void 
	{
		_zoomerOffset = value;
	}
	public function get zoomerBackgroundOffset():Number 
	{
		return _zoomerBackgroundOffset;
	}
	public function set zoomerBackgroundOffset(value:Number):Void 
	{
		_zoomerBackgroundOffset = value;
	}
	public function get buttonFull():ButtonFull 
	{
		return _buttonFull;
	}
	public function set buttonFull(value:ButtonFull):Void 
	{
		_buttonFull = value;
	}
	public function get showFullExtent():Boolean 
	{
		return _showFullExtent;
	}
	public function set showFullExtent(value:Boolean):Void 
	{
		_showFullExtent = value;
	}
	public function get showZoomerButtons():Boolean 
	{
		return _showZoomerButtons;
	}
	public function set showZoomerButtons(value:Boolean):Void 
	{
		_showZoomerButtons = value;
	}
	/** Events **/
	/** 
	 * Dispatched when a component is up and ready to run.
	 * @param comp:MovieClip a reference to the component.
	 */
	//public function onInit(comp:MovieClip):Void {
	//}
	
}
