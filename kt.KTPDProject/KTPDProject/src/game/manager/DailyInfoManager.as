package game.manager {
	import game.module.daily.DailyManage;
	import game.net.core.Common;
	import game.net.data.StoC.SCDailyInfo;
	/**
	 * @author yangyiqiang
	 */
	public class DailyInfoManager {
		private static var _instance : DailyInfoManager;

		public function DailyInfoManager() {
			if (_instance) {
				throw Error("---DailyInfoManager--is--a--single--model---");
			}
			Common.game_server.addCallback(0x13, dailyInfo);
		}

		public static function get instance() : DailyInfoManager {
			if (_instance == null) {
				_instance = new DailyInfoManager();
			}
			return _instance;
		}
		
		public var dailyValue : uint;
		public var dailyStatus : uint;
		public var stampoff : Number = 0 ;

		private function dailyInfo(info:SCDailyInfo) : void {
			dailyValue = info.dailyValue;
			dailyStatus = info.dailyStatus;
			stampoff = (info.timestamp - (new Date()).time / 1000) * 1000 ;
			DailyManage.getInstance().refreshVo();
		}
		
		public function get weekday() : int
		{
			var date : Date = new Date() ;
			date.time = date.time + stampoff ;
			return date.day ;
		}
	}
}
