package com.commUI.decorator
{
	import flash.filters.GlowFilter;

	/**
	 * @author jian
	 */
	public class GlowDecorator extends AbstractDecorator
	{
		private static var _filter : GlowFilter = new GlowFilter();
		private var _running : Boolean = false;

		override protected function onDecorate() : void
		{
			if (!_running)
			{
				_running = true;
				_target.filters = [_filter];
			}
		}
		
		override protected function onRelease() : void
		{
			if (_running)
			{
				_running = false;
				_target.filters = [];
			}
		}
	}
}
