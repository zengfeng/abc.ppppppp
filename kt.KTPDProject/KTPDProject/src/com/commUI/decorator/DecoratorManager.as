package com.commUI.decorator
{
	import flash.events.Event;
	import flash.display.InteractiveObject;
	import flash.utils.Dictionary;
	import flash.display.DisplayObject;
	/**
	 * @author jian
	 */
	public class DecoratorManager
	{
		// ===============================================================
		// 单例
		// ===============================================================
		private static var __instance : DecoratorManager;

		public static function get instance() : DecoratorManager
		{
			if (!__instance)
				__instance = new DecoratorManager();
			return __instance;
		}

		public function DecoratorManager() : void
		{
			if (__instance)
				throw (Error("Singleton Error"));
			
			_targetRegister = new Dictionary();
		}
		
		// ===============================================================
		// 属性
		// ===============================================================
		private var _targetRegister:Dictionary;
		
		// ===============================================================
		// 方法
		// ===============================================================
		public function registerDecorator (target:DisplayObject, clazz:Class):void
		{
			if (!target)
				return;
				
			var decorator:IDecorator = new clazz();
			
			var decorators:Array = _targetRegister[target];
			if (!decorators)
				decorators = [];
			
			decorators.push(decorator);
				
			_targetRegister[target] = decorators;
			
			if (target is InteractiveObject)
			{
				(target as InteractiveObject).addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
				(target as InteractiveObject).addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			}
		}
		
		private function onAddedToStage(event:Event):void
		{
			var target:DisplayObject = event.target as DisplayObject;
			var decorators:Array = _targetRegister[target];
			
			for each (var decorator:IDecorator in decorators)
			{
				decorator.target = target;
				decorator.decorate();
			}
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			var decorators:Array = _targetRegister[event.target];
			
			for each (var decorator:IDecorator in decorators)
			{
				decorator.release();
				decorator.target = null;
			}			
		}
	}
}
