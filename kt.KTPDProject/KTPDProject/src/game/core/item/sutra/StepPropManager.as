package game.core.item.sutra
{
	import flash.utils.Dictionary;
	import game.core.item.prop.ItemProp;
	import game.module.prop.PropManager;

	/**
	 * @author jian
	 */
	public class StepPropManager
	{
		// ===============================================================
		// 单例
		// ===============================================================
		private static var __instance:StepPropManager;
		
		public static function get instance ():StepPropManager
		{
			if (!__instance)
				__instance = new StepPropManager();
			
			return __instance;
		}
		
		public function StepPropManager():void
		{
			if (__instance)
				throw (Error("单例错误!"));

			init();
		}
		
		// ===============================================================
		// 属性
		// ===============================================================
		private var _stepProps:Dictionary;
		private var _nullProp:ItemProp = new ItemProp();
		
		// ===============================================================
		// 方法
		// ===============================================================
		private function init():void
		{
			_stepProps = new Dictionary();
		}
		
		public function getStepProp(job:uint, step:uint):ItemProp /* of Prop */
		{
			if (step == 0)
				return _nullProp;
				
			var prop:ItemProp = _stepProps[getKey(job, step)];
			
			if (!prop)
				throw(Error("未知的法宝属性!" + job + " " + step));
			return prop;
		}
		
		private function setStepProp(sutraId:uint, step:uint, prop:ItemProp):void
		{
			_stepProps[getKey(sutraId, step)] = prop;
		}
		
		public function parseTable(arr:Array):void
		{
			if (arr[0] != 1)
				return;
			
			var job:uint = arr[1];
			var step:uint = arr[2];
			var prop:ItemProp = new ItemProp();
			var len:uint = arr.length;
			var propId:uint;
			var propKey:String;
			var value:uint;
			
			for (var i:uint = 3; i< len; i+=2)
			{
				if (!arr[i])
					break;
					
				propId = arr[i];
				value = arr[i+1];
				propKey = PropManager.instance.getPropByID(propId).key;
				prop[propKey] = value;
			}
			
			setStepProp(job, step, prop);
		}
		
		private static function getKey(job:uint, step:uint):String
		{
			return (job + "_" + step);
		}
	}
}
