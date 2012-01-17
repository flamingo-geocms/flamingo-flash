/*-----------------------------------------------------------------------------
Copyright (C) 2011  Roy Braam / Meine Toonen B3partners BV

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
/**
 * Abstract for registers of listeners. If killed the listener must be removed.
 * @author Roy Braam
 * @author Meine Toonen
 */
import core.AbstractPositionable;
import tools.Logger;

class core.AbstractListenerRegister extends Object
{	
	//the listeners that are added by this listenercreator
	private var _registerdListeners:Object;
	
	public function AbstractListenerRegister (id:String, container:MovieClip) {
		super(id, container);
	}
	
	/**
	 * add the listener that is added as listener in flamingo. Only used for registration purpose
	 * so the listener can be removed when the caller is destroyed.
	 * @param	listenToId the id of the object that the listener is listening to
	 * @param	listener the listener.
	 */
	public function addAddedListener(listenToId:String, listener:Object) {
		if (registerdListeners == undefined) {
			registerdListeners = new Object();
		}
		if (this.registerdListeners[listenToId] == undefined) {
			this.registerdListeners[listenToId] = new Array();
		}
		this.registerdListeners[listenToId].push(listener);
	}
	/**
	 * Remove all the listeners that are registerd by this object.
	 * @param	listenToId the id of the object that the listener is listening to
	 * @param	listener the listener.
	 */
	public function removeAddedListener(listenToId:String, listener:Object) {
		if (registerdListeners == undefined || this.registerdListeners[listenToId] == undefined) {
			return;
		}
		var newListeners:Array = new Array();
		for (var i = 0; i < this.registerdListeners[listenToId].length; i++) {
			if (this.registerdListeners[listenToId][i] != listener) {
				newListeners.push(this.registerdListeners[listenToId][i]);
			}
		}
	}
	
	//fallback for old flamingo classes that are using the comp._addedlisteners
	public function get _addedlisteners():Object {
		return this.registerdListeners;
	}
	
	/******************** getter and setters *******/
	
	public function get registerdListeners():Object 
	{
		return _registerdListeners;
	}
	
	public function set registerdListeners(value:Object):Void 
	{
		_registerdListeners = value;
	}
	
}