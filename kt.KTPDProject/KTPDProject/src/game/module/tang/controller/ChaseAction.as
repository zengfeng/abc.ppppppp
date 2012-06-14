package game.module.tang.controller
{
	import game.module.map.animal.Animal;
	/**
	 * @author jian
	 */
	public class ChaseAction
	{
		private var _source:Animal;
		private var _target:Animal;
		// 追逐状态：空闲，追逐中，成功，失败
		private var _state:int;
		
		public function ChaseAction (source:Animal, target:Animal)
		{
			
		}
		
		public function execute():void
		{
		}
		
	}
}
