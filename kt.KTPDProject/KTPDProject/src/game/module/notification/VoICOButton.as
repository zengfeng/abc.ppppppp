package game.module.notification
{
	/**
	 * @author yangyiqiang
	 */
	public class VoICOButton
	{
		public var id : int;

		public var name : String;

		public var type : int;

		public var openType : int;

		private var _tips : String;

		public var ioc : String;

		public var classString : String;

		public var  description : String;
		
		public var dailyId:int;

		public function getTips(paramNum : Vector.<uint>, paramStr : Vector.<String>) : String
		{
			var tips : String = _tips;
			if (paramNum)
			{
				for (var i : int = 0;i < paramNum.length;i++)
					tips = tips.replace(new RegExp("xx1" + String(i), "g"), paramNum[i]);
			}
			if (paramStr)
			{
				for ( i = 0;i < paramStr.length;i++)
					tips = tips.replace(new RegExp("xx2" + String(i), "g"), paramStr[i]);
			}
			return tips;
		}
		
		public function getOldTips():String
		{
			return _tips;
		}

		public function prase(xml : XML) : void
		{
			if (xml.@id == undefined) return;
			id = xml.@id;
			name = xml.@name;
			type = xml.@type;
			openType = xml.@openType;
			_tips = xml.children();
			ioc = xml.@ioc;
			classString = xml.@classString;
			description = xml.@description;
			dailyId=xml.@dailyId;
		}
	}
}
