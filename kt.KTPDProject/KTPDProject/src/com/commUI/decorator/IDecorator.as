package com.commUI.decorator
{
	import flash.display.DisplayObject;
	/**
	 * @author jian
	 */
	public interface IDecorator
	{
		function set target(value:DisplayObject):void;
		function get target():DisplayObject;
		
		function decorate ():void;
		function release ():void;
	}
}
