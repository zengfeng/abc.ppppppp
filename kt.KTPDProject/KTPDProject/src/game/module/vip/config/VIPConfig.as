package game.module.vip.config
{
	/**
	 * @author ME
	 */
	public class VIPConfig
	{
		// ======================================================
		// 属性
		// ======================================================
		public var itemId : int;
		public var level : int;
		public var name : String;
		public var gold : int;
		public var open : Boolean;
		public var openNumber : int;
		public var text : String;
		public var defaultNum : int;

		// ======================================================
		// 方法
		// ======================================================
		public function get timesString() : String
		{
			if (open == false)
			{
				// return "无";
				if (defaultNum == -1)
					return "无";
				else
					return String(defaultNum) + text;
			}
			else
			{
				if (openNumber == 0)
					return "开启";
				else
					return String(openNumber) + text;
			}
		}

		public function get nextLevelChangeTextColor() : uint
		{
			// if (openNumber == 0)
			return 0xff3300;
			// else
			// return 0x279f15;
		}
	}
}
