package com.commUI.decorator
{
	import flash.display.DisplayObject;

	/**
	 * @author jian
	 */
	public class AbstractDecorator implements IDecorator
	{
		protected var _target : DisplayObject;
		
		public function set target (value:DisplayObject):void
		{
			_target = value;
		}
		
		public function get target ():DisplayObject
		{
			return _target;
		}

		public function decorate() : void
		{
			if (_target)
				release();
				
			onDecorate();
		}

		public function release() : void
		{
			onRelease();
		}

		protected function onDecorate() : void
		{
			// To be override
		}

		protected function onRelease() : void
		{
			// To be override
		}
	}
}
