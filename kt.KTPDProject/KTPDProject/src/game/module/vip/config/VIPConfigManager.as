package game.module.vip.config
{
	import flash.utils.Dictionary;
	import game.module.vip.view.VIPView;


	/**
	 * @author ME
	 */
	public class VIPConfigManager
	{
		// ===============================================================
		// 单例
		// ===============================================================
		private static var __instance : VIPConfigManager;

		public static function get instance() : VIPConfigManager
		{
			if (!__instance)
				__instance = new VIPConfigManager();

			return __instance;
		}

		public function VIPConfigManager()
		{
			if (__instance)
				throw(Error("单例错误"));
		}

		// ===============================================================
		// 属性
		// ===============================================================
		private var _vipView : VIPView;
		private var _configDict : Dictionary = new Dictionary();
		private var _nItems : int;
		private var _nLevel : int;

		// ===============================================================
		// Getter/Setter
		// ===============================================================
		public function get vipView() : VIPView
		{
			if (!_vipView)
				_vipView = new VIPView();

			return _vipView;
		}

		// ===============================================================
		// 方法
		// ===============================================================
		public function parseVIPXml(xml : XML) : void
		{
			var itemDict : Dictionary = new Dictionary();
			var nItems : int = 0;
			var itemId : int;
			var name : String;
			var text : String;
			var defaultNum : int;

			for each (var item:XML in xml["item"])
			{
				itemId = item.@id;
				name = item.@name;
				text = item.@text;
				defaultNum = item.@defaultNum;

				itemDict[itemId] = {itemId:itemId, name:name, text:text, defaultNum:defaultNum};
				nItems++;
			}

			_nItems = nItems;

			for each (var configXML:XML in xml["vipconfig"])
			{
				var configItems : Array = [];
				var opens : Array = configXML.@open.split(",");
				var openNumbers : Array = configXML.@openNumber.split(",");
				var level : int = configXML.@level;
				var nLevel : int;

				for each (var itemObj:Object in itemDict)
				{
					var config : VIPConfig = new VIPConfig();
					config.level = configXML.@level;
					config.gold = configXML.@gold;
					config.name = itemObj.name;
					config.text = itemObj.text;
					config.itemId = itemObj.itemId;
					config.defaultNum =  itemObj.defaultNum;

					var index : int = opens.indexOf(String(config.itemId));
					if (index >= 0)
					{
						config.open = true;
						config.openNumber = openNumbers[index];
					}
					else
					{
						config.open = false;
					}

					configItems.push(config);
				}

				_configDict[level] = configItems;
				nLevel++;
			}

			_nLevel = nLevel - 1;
		}

		public function getConfigItem(vipLevel : int, itemId : int) : VIPConfig
		{
			return getConfigItems(vipLevel)[itemId];
		}

		public function getConfigItems(vipLevel : int) : Array
		{
			return _configDict[vipLevel];
		}

		public function getNItems() : int
		{
			return _nItems;
		}

		public function getMaxVipLevel() : int
		{
			return _nLevel;
		}
	}
}
