package game.module.map.preload
{
	import net.RESManager;
	import net.LibData;
	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-18
	 */
	public class MapUnloadManager
	{
		function MapUnloadManager(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : MapUnloadManager;

		/** 获取单例对像 */
		static public function get instance() : MapUnloadManager
		{
			if (_instance == null)
			{
				_instance = new MapUnloadManager(new Singleton());
			}
			return _instance;
		}
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public var list:Vector.<LibData> = new Vector.<LibData>();
		
		public function unload():void
		{
			while(list.length > 0)
			{
				var libData:LibData = list.pop();
				RESManager.instance.remove(libData.key);
				//trace(libData.key);
			}
		}
		
		public function add(libData:LibData):void
		{
			var index:int = list.indexOf(libData);
			if(index == -1)
			{
				list.push(libData);
			}
		}
		
		public function remove(libData:LibData):void
		{
			var index:int =list.indexOf(libData);
			if(index != -1)
			{
				list.splice(index, 1);
			}
		}
	}
}
class Singleton
{
}
