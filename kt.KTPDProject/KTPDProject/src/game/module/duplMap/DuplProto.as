package game.module.duplMap
{
	import com.commUI.alert.Alert;
	import game.module.map.utils.MapUtil;
	import game.net.core.Common;
	import game.net.data.CtoS.CSChallengeDungeon;
	import game.net.data.CtoS.CSDungeonLoot;
	import game.net.data.CtoS.CSSwitchCity;
	import game.net.data.StoC.SCChallengeDungeon;
	import game.net.data.StoC.SCCityPlayers;
	import game.net.data.StoC.SCDungeonLoot;
	import game.net.data.StoC.SCOpenDungeon;

	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
	 */
	public class DuplProto
	{
		public function DuplProto(singleton : Singleton)
		{
			singleton;
//			sToC();
		}

		/** 单例对像 */
		private static var _instance : DuplProto;

		/** 获取单例对像 */
		public static function get instance() : DuplProto
		{
			if (_instance == null)
			{
				_instance = new DuplProto(new Singleton());
			}
			return _instance;
		}
		
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var _controller:DuplMapController;
		public function get controller():DuplMapController
		{
			if(_controller == null)
			{
				return _controller = DuplMapController.instance;
			}
			return _controller;
		}
		 /** 协议监听 */
        private function sToC() : void
        {
            // 协议监听 -- 0x22 进入副本
            Common.game_server.addCallback(0x22, sc_enterDupl);
            // 协议监听 -- 0x81 战斗
            Common.game_server.addCallback(0x0081, sc_battle);
            // 协议监听 -- 0x84 开启副本
            Common.game_server.addCallback(0x84, sc_openDupl);
            // 协议监听 -- 0x85 拾取装备
            Common.game_server.addCallback(0x0085, sc_getAward);
        }
		
		
        /** 发送协议[0x22] -- 进入副本 */
        public function sc_enterDupl(msg : SCCityPlayers) : void
        {
            // 如果不是副本
            if (MapUtil.isDungeonMap(msg.cityId) == false) return;
			var duplMapId:int = msg.cityId;
			var wave:int = msg.myY;
			var isHaveItems:Boolean = msg.myX == 1;
			controller.enter(duplMapId, wave, isHaveItems);
//			if(isHaveItems == true) cs_getAwardInfo();
        }
		
		 /** 协议监听 -- 0x81 战斗 */
        private function sc_battle(msg : SCChallengeDungeon) : void
        {
//            Alert.show(msg.stage);
			if(msg.stage == DuplConfig.WAVE_BATTLE_LOSE)
			{
				controller.sc_battleLose();
			}
			else if(msg.stage == DuplConfig.WAVE_PASS)
			{
				controller.sc_battlePass();
				controller.sc_getAwardInfo(msg.items);
			}
			else
			{
				controller.sc_battleWin(msg.stage);
			}
			
        }
		
		 /** 协议监听 -- 0x84 开启副本 */
        private function sc_openDupl(msg : SCOpenDungeon) : void
        {
			DuplOpened.setOpenedDuplMapId(msg.dungeonId);
        }
		
        /** 协议监听 -- 0x85 拾取装备 */
        private function sc_getAward(msg : SCDungeonLoot) : void
        {
            // 0表示正常拾取，1表示请求物品列表
            if (msg.flag == 1)
            {
				controller.sc_getAwardInfo(msg.items);
            }
            else
            {
				controller.sc_getAward();
            }
        }

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 发送协议[0x24] -- 进入副本 */
		public function cs_enterDupl(duplMapId : int) : void
		{
			var msg : CSSwitchCity = new CSSwitchCity();
			msg.cityId = duplMapId;
			msg.toX = 0;
			msg.toY = 0;
			Common.game_server.sendMessage(0x24, msg);
		}

		/** 发送协议[0x0081] -- 战斗 */
		public function cs_battle() : void
		{
			var msg : CSChallengeDungeon = new CSChallengeDungeon();
			Common.game_server.sendMessage(0x0081, msg);
		}

		/** 发送协议[0x0085] -- 获取掉落装备信息 */
		public function cs_getAwardInfo() : void
		{
			// flag 0表示正常拾取，1表示请求物品列表
			var msg : CSDungeonLoot = new CSDungeonLoot();
			msg.flag = 1;
			Common.game_server.sendMessage(0x0085, msg);
		}

		/** 发送协议[0x0085] -- 获取掉落装备 */
		public function cs_getAward() : void
		{
			// flag 0表示正常拾取，1表示请求物品列表
			var msg : CSDungeonLoot = new CSDungeonLoot();
			msg.flag = 0;
			Common.game_server.sendMessage(0x0085, msg);
		}
	}
}
class Singleton
{
}