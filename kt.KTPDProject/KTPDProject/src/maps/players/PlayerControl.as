package maps.players
{
	import mx.core.Singleton;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-25
	 */
	public class PlayerControl
	{
		/** 单例对像 */
		private static var _instance : PlayerControl;

		/** 获取单例对像 */
		public static  function get instance() : PlayerControl
		{
			if (_instance == null)
			{
				_instance = new PlayerControl(new Singleton());
			}
			return _instance;
		}

		function PlayerControl(singleton : Singleton) : void
		{
			singleton;
		}
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
	}
}
