package game.module.daily {
	import game.manager.DailyInfoManager;
	import game.manager.SignalBusManager;

	/**
	 * @author yangyiqiang
	 */
	public class DailyManage
	{
		// ===============================================================
		public static const ID_QUEST:uint = 1;
		public static const ID_CONVOY:uint =2;
		public static const ID_FISHING:uint =3;
		public static const ID_AXE:uint =4;
		public static const ID_COMPETE:uint =5;
		
		public static const STATE_UNOPEN:uint = 1;
		public static const STATE_OPENED:uint = 2;
		public static const STATE_ENDED:uint =3;
		
		// ===============================================================
		private static var _instance : DailyManage;
		
		public function DailyManage()
		{
			if (_instance)
				throw Error("DailyInfoManager 是单类，不能多次初始化!");
			initiate();
		}
		
		private function initiate():void
		{
			SignalBusManager.updateDaily.add(refreshDailyVars);
		}
		
		public static var WEEKDAY:Array=["星期日","星期一","星期二","星期三","星期四","星期五","星期六"];
		
		private var _dailyDic :Vector.<VoDaily> = new Vector.<VoDaily>();

		private var _copyDic : Vector.<VoCopy> = new Vector.<VoCopy>();

		private var _actionDic :  Vector.<VoAction> = new Vector.<VoAction>();
		
		private var _noticeDic : Vector.<VoNotice> = new Vector.<VoNotice>() ;
		
		private var _array :Array =[_dailyDic,_copyDic,_actionDic,_noticeDic];
		
		public static function getInstance() : DailyManage
		{
			if (_instance == null)
				_instance = new DailyManage();
			return _instance;
		}

		public function initDailyVo(vo :VoDaily) : void
		{
			_dailyDic.push(vo);
		}

		public function initCopyVo(vo : VoCopy) : void
		{
			_copyDic.push(vo);
		}

		public function initActionVo(vo : VoAction) : void
		{
			_actionDic.push(vo);
		}
		
		public function initNoticeVo(vo : VoNotice) : void
		{
			_noticeDic.push(vo);
		}
		
		public function refreshVo():void
		{
			var arr:Array;
			for each(var vo:VoDaily in _dailyDic){
				arr=initData(vo.id);
				refreshDailyVars(vo.id,arr[2],arr[0],arr[1]);
			}
		}
		
		public function getVos(type:int=0):*
		{
			return _array[type];
		}
		
		private function refreshDailyVars (id:int, state:int, var1:int, var2:int = 0):void
		{
			for each (var vo:VoDaily in _dailyDic)
			{
				if (vo.id == id)
				{
					vo.state = state;
					vo.refreshVars(var1, var2);
					break;
				}
			}
		}
		
		public function initData(id:int) :Array
		{
			var state:int=0;
			var _vars:Array=[0,0,state];
			switch(id)
			{
				case 1:
					_vars[0] = DailyInfoManager.instance.dailyValue & 0xf;
					if (_vars[0] == 0) state = 3;
					break;
				case 2:
					_vars[0] = (DailyInfoManager.instance.dailyValue & 0xf0) >> 4;
					_vars[1] = (DailyInfoManager.instance.dailyValue & 0xf00) >> 8;
					break;
				case 3:
					_vars[0] = (DailyInfoManager.instance.dailyValue & 0xf000) >> 12;
					break;
				case 4:
					_vars[0] = (DailyInfoManager.instance.dailyValue & 0xf0000) >> 16;
					break;
				case 5:
					_vars[0] = (DailyInfoManager.instance.dailyValue & 0xf00000) >> 20;
					break;
				case 6:
					_vars[0] = (DailyInfoManager.instance.dailyValue & 0xf00000) >> 24;
					break;
				case 9:
					state = DailyInfoManager.instance.dailyStatus & 0x3;
					break;
				case 7:
					state = (DailyInfoManager.instance.dailyStatus & 0xC) >> 2;
					break;
				case 8:
					state = (DailyInfoManager.instance.dailyStatus & 0x30) >> 4;
					break;
			}
			return _vars;
		}
		
	}
}
