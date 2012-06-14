package com.commUI.decorator
{
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;

	/**
	 * @author jian
	 */
	public class TristateDecorator extends AbstractDecorator
	{
		private static var _filter:ColorMatrixFilter = new ColorMatrixFilter([1, 0, 0, 0, 24, 0, 1, 0, 0, 24, 0, 0, 1, 0, 24, 0, 0, 0, 1, 0]);

		override protected function onDecorate():void
		{
			_target.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			_target.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		override protected function onRelease():void
		{
			_target.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_target.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		public function rollOverHandler(event : MouseEvent) : void
		{
			_target.filters = [_filter];
		}

		public function rollOutHandler(event : MouseEvent) : void
		{
			_target.filters = [];
		}
	}
}
