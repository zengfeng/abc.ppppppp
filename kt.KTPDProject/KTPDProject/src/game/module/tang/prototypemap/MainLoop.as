package game.module.tang.prototypemap
{
	import game.module.map.utils.EnterFrameListener;
	
	/**
	 * @author jian
	 */
	public class MainLoop
	{
//		private var _actionQueue:Vector.<IAction>;
		
		public function MainLoop()
		{
			EnterFrameListener.add(onTick);
		}
		
		private function onTick():void
		{
//			for each (var action:IAction in _actionQueue)
//			{
//				action.execute();
//			}
		}
	}
}
