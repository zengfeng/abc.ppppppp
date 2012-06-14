package game.module.demonTower {
	import com.commUI.alert.Alert;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.signalbus.Signal;
	import com.utils.UrlUtils;
	import flash.events.MouseEvent;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.definition.ID;
	import game.manager.EnWalkManager;
	import game.module.duplMap.DuplMapData;
	import game.module.duplMap.DuplUtil;
	import game.module.duplMap.data.DuplStruct;
	import game.module.duplMap.data.LayerStruct;
	import game.module.duplPanel.DuplPanelConfig;
	import game.module.duplPanel.view.HeadIcon;
	import game.module.duplPanel.view.WindowHook;
	import game.module.map.animalstruct.MonsterStruct;
	import game.net.data.StoC.SCAutoDemon;
	import log4a.Logger;




	/**
	 * @author Lv
	 */
	public class HangUpPanelContollor {
		private static var _instance : HangUpPanelContollor;

		public function HangUpPanelContollor(controll : Controll) : void {
			controll;
		}

		public static function get instance() : HangUpPanelContollor {
			if (_instance == null)
				_instance = new HangUpPanelContollor(new Controll());
			return _instance;
		}

		// ---------------------------------挂机----------------------------------------------
		public var windowHook : WindowHook;
		private var monster : MonsterStruct;
		public var duplId : int;
		public var isFree : Boolean = true;
		public var count : int;
		public var isPrePlay : Boolean = false;
		public var duplStruct : DuplStruct;
		public var layerId : int = 0;
		public var duplMapId : int = 0;
		public var windowIsRelevanceByWalk : Boolean = false;
		// =========================
		// 挂机面板
		// =========================
		/** 挂机面板 -- 是否开始 */
		private var windowHook_isStart : Boolean = false;
		/** 挂机面板 -- 是否加速 */
		private var windowHook_isFast : Boolean = false;
		/** 挂机面板 -- 是否发的加速协议 */
		private var windowHook_isSendFastProto : Boolean = false;
		/** 挂机面板 -- 设定次数 */
		private var windowHook_preStartCount : int = 0;
		private var windowHook_hookCount : int = 0;
		private var windowHook_monsterCount : int = 0;
		private  var windowHook_hookNum : int = 0;
		private var windowHook_monsterNum : int = 0;
		private var windowHook_timeleft : int = 0;
		/** 挂机面板 -- 是否是因为关闭停止 */
		private var windowHook_stopOfClose : Boolean = false;

		// 进入挂机状态
		public function openWindowHook(dup : DuplStruct, mon : MonsterStruct) : void {
			duplStruct = dup;
			monster = mon;
			duplId = mon.duplId;
			layerId = mon.layerId;
			duplMapId = mon.mapId;
			count = DemonProxy.demonTimes;
			isFree = !DemonProxy.isCharge;
			if (windowHook == null) {
				windowHook = new WindowHook(1);
				windowHook.buyGold = DemonProxy.BUY_ONCE_MONEY;
			}
			windowHook.visible = true;
			windowHook.buttonState_default();
			windowHook_open();
		}

		/** 挂机面板 -- 打开 */
		public function windowHook_open() : void {
			windowHook.onClickCloseCall = windowHook_close;
			windowHook.startButton.addEventListener(MouseEvent.CLICK, windowHook_onClickStartButton);
			windowHook.stopButton.addEventListener(MouseEvent.CLICK, windowHook_onClickStopButton);
			windowHook.fastButton.addEventListener(MouseEvent.CLICK, windowHook_onClickFastButton);
			windowHook.visible = true;
			windowHook.numTextInput.enabled = true;
			windowHook.timeLeftLabel.visible = false;
			windowHook.title = '锁妖挂机';
			windowHook.setRemainNum(count, isFree);
			if (count == 0) {
				windowHook.buttonState_noNum();
			} else {
				windowHook.buttonState_default();
			}
			var icon : HeadIcon = windowHook.icon;
			var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
			var iconMonster : MonsterStruct = layerStruct.getIconMonster();
			var name : String = iconMonster.name;
			var imageUrl : String = UrlUtils.getDungeonLayerIcon(duplMapId);
			icon.setData(0, name, imageUrl);
			var tipStr : String = DuplMapData.instance.getLayerTip(duplMapId, 10);
			if (tipStr) {
				ToolTipManager.instance.registerToolTip(icon.bg, ToolTip, tipStr);
			} else {
				ToolTipManager.instance.destroyToolTip(icon.bg);
			}
			windowHook.logBox. clearMsgs();
			windowHook.logBox.appendMsg_specification();
			windowHook.goodsBox.clear();
		}

		/** 挂机面板 -- 服务器反回挂机信息 */
		public function windowHook_scInfo(msg : SCAutoDemon) : void {
			var exp : int = msg.exp;
			var items : Vector.<uint> = msg.items;
			var silver : int = setItems(items);

			var preHookNum : int;
			var isNeedHookNum : Boolean = false;

			// Alert.show(msg.result + "," + msg.countLeft + ", " + count);
			// 挂机结果  0-开始挂机 1-继续挂机 2-完成挂机 3-用户主动中断 4-背包不足停止 5-元宝不足停止
			switch(msg.result) {
				// 开始挂机
				case 0:
					if (windowHook.visible == false) {
						duplMapId = msg.dungeonId;
						duplId = DuplUtil.getDuplId(duplMapId);
						layerId = DuplUtil.getLayerId(duplMapId);
						duplStruct = DuplMapData.instance.getDuplStruct(duplId);
						windowHook_open();
						windowHook_hookCount = msg.countLeft;
						var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
						windowHook_monsterCount = layerStruct.monsterList.length;
					} else {
						isPrePlay = true;
					}
					windowHook.logBox.clearMsgs();
					windowHook.goodsBox.clear();
					windowHook_isStart = true;
					windowHook_hookNum = 1;
					windowHook_monsterNum = 1;
					windowHook_timeleft = windowHook_hookCount;
					isNeedHookNum = true;
					windowHook.logBox.appendMsg_hookNuming(windowHook_hookNum, windowHook_monsterNum, isNeedHookNum);
					windowHook.buttonState_start();
					break;
				// 继续挂机
				case 1:
					isPrePlay = false;
					windowHook.logBox.appendMsg_hookNumWin(windowHook_hookNum, windowHook_monsterNum, exp, silver, items);
					preHookNum = windowHook_hookNum;
					windowHook_hookNum = windowHook_hookCount - msg.countLeft + 1;
					if (preHookNum < windowHook_hookNum) {
						windowHook_monsterNum = 1;
						isNeedHookNum = true;
						count--;
					} else {
						windowHook_monsterNum++;
						isNeedHookNum = false;
					}
					windowHook_timeleft = msg.countLeft;
					windowHook.logBox.appendMsg_hookNuming(windowHook_hookNum, windowHook_monsterNum, isNeedHookNum);
					if (windowHook_isSendFastProto == true && windowHook_isFast == false) {
						windowHook_isFast = true;
						windowHook.buttonState_fast();
					}
					// DemonProxy.isHangup = true;
					// DemonProxy.instance.checkManage(DemonProxy.nowlayerNumbeer);
					break;
				// 完成挂机
				case 2:
					isPrePlay = false;
					windowHook_isStart = false;
					windowHook_isFast = false;
					windowHook.logBox.appendMsg_hookNumWin(windowHook_hookNum, windowHook_monsterNum, exp, silver, items);
					count--;
					// if (windowHook_monsterCount == 1) count--;
					preHookNum = windowHook_hookNum;
					windowHook_hookNum = windowHook_hookCount;
					windowHook_monsterNum = windowHook_hookCount;
					windowHook_timeleft = 0;
					windowHook.logBox.appendMsg_normalOverl();
					windowHook.buttonState_default();
					if(count == 0)
						DemonProxy.isHangup = true;
					// DemonProxy.instance.checkManage(DemonProxy.nowlayerNumbeer);
					break;
				// 用户主动中断
				case 3:
					if (windowHook_monsterCount != 1 && windowHook_monsterNum > 1) {
						count--;
					}
					windowHook_isStart = false;
					windowHook_isFast = false;
					windowHook.logBox.appendMsg_stop();
					windowHook_timeleft = 0;
					if (windowHook_stopOfClose == true) {
						windowHook_stopOfClose = false;
						windowHook_close();
					}
					windowHook.buttonState_default();
					break;
				// 背包不足停止
				case 4:
					if (windowHook_monsterCount != 1 && windowHook_monsterNum > 1) {
						count--;
					}
					windowHook_isStart = false;
					windowHook_isFast = false;
					windowHook.logBox.appendMsg_packFull();
					StateManager.instance.checkMsg(153);
					windowHook_timeleft = 0;
					windowHook.buttonState_default();
					break;
				// 元宝不足停止
				case 5:
					if (windowHook_monsterCount != 1 && windowHook_monsterNum > 1) {
						count--;
					}
					windowHook_isStart = false;
					windowHook_isFast = false;
					windowHook.logBox.appendMsg_goldOutof();
					StateManager.instance.checkMsg(4);
					windowHook_timeleft = 0;
					windowHook.buttonState_default();
					break;
			}

			windowHook.setNum(msg.countLeft);
			windowHook.setRemainNum(count, isFree, !windowHook_isStart);
			windowHook.setTimeleft(windowHook_timeleft);
			windowHook.numTextInput.enabled = !windowHook_isStart;
			windowHook.timeLeftLabel.visible = windowHook_isStart;
			if (count == 0 && isFree == true && windowHook_isStart == false && windowHook.visible == true) {
				DemonProxy.isShow = false;
//				DemonProxy.isHangup = true;
//				DemonProxy.instance.checkManage(0);
				DemonContral.instance.refreshView();
			}
			DemonProxy.instance.checkManage(DemonProxy.nowlayerNumbeer);
		}

		public function windowHook_updateNum(coun : int, isfree : Boolean) : void {
			windowHook.setRemainNum(count, isFree);
		}

		/** 挂机面板 -- 点击开始按钮 */
		private function windowHook_onClickStartButton(event : MouseEvent) : void {
			windowHook_isFast = false;
			windowHook_isSendFastProto = false;
			windowHook_preStartCount = count;
			windowHook_hookCount = windowHook.getNum();
			var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
			windowHook_monsterCount = layerStruct.monsterList.length;

			if (count <= 0) {
				StateManager.instance.checkMsg(5);
				return;
			}

			if (isFree == false) {
				var needGold : int = windowHook_hookCount * DuplPanelConfig.BUY_NUM_GOLD;
				if (isPrePlay == true) needGold -= DuplPanelConfig.BUY_NUM_GOLD;

				Logger.info("isPrePlay = " + isPrePlay + "  needGold =" + needGold);
				if (UserData.instance.gold < needGold && needGold > 0) {
					StateManager.instance.checkMsg(4, [needGold]);
					return;
				}

				if (UserData.instance.tryPutPack(DuplPanelConfig.HOOK_MIN_PACK_EMPTY) < 0) {
					StateManager.instance.checkMsg(7, [DuplPanelConfig.HOOK_MIN_PACK_EMPTY]);
					return;
				}

				if (needGold > 0) {
					// StateManager.instance.checkMsg(19, [windowHook_hookCount], windowHook_onClickStartNoFreeGoldAlert);
					StateManager.instance.checkMsg(301, [windowHook_hookCount * DemonProxy.BUY_ONCE_MONEY, windowHook_hookCount], windowHook_onClickStartNoFreeGoldAlert);
					return;
				}
			}
			if (UserData.instance.tryPutPack(DuplPanelConfig.HOOK_MIN_PACK_EMPTY) < 0) {
				StateManager.instance.checkMsg(7, [DuplPanelConfig.HOOK_MIN_PACK_EMPTY]);
				return;
			}
			windowHook_csStart();
		}

		private function windowHook_onClickStartNoFreeGoldAlert(eventType : String) : Boolean {
			switch(eventType) {
				case Alert.OK_EVENT:
					windowHook_csStart();
					break;
			}
			return true;
		}

		/** 挂机面板 -- 点击开始按钮发送协议 */
		private function windowHook_csStart() : void {
			DemonProxy.instance.hangupDemon(duplMapId, windowHook_hookCount);
		}

		/** 挂机面板 -- 点击停止按钮 */
		private function windowHook_onClickStopButton(event : MouseEvent) : void {
			StateManager.instance.checkMsg(6, [], windowHook_onClickStopButtonAlert);
		}

		/** 挂机面板 -- 点击立即完成按钮对话框回调 */
		private function windowHook_onClickStopButtonAlert(eventType : String) : Boolean {
			switch(eventType) {
				case Alert.OK_EVENT:
					windowHook_stopOfClose = false;
					// proto.cs_HookStop(duplMapId);
					DemonProxy.instance.stopHangupDemon();
					break;
			}
			return true;
		}

		/** 挂机面板 -- 点击立即完成按钮 */
		private function windowHook_onClickFastButton(event : MouseEvent) : void {
			var countleft : int = (windowHook_hookCount - windowHook_hookNum + 1);
			windowHook_fastNeedGold = DuplPanelConfig.HOOK_FAST_GOLD * countleft;
			StateManager.instance.checkMsg(3, [windowHook_fastNeedGold, countleft], windowHook_onClickFastButtonAlert);
		}

		private var windowHook_fastNeedGold : int = 0;

		/** 挂机面板 -- 点击立即完成按钮对话框回调 */
		private function windowHook_onClickFastButtonAlert(eventType : String) : Boolean {
			switch(eventType) {
				case Alert.OK_EVENT:
					if (UserData.instance.gold < windowHook_fastNeedGold) {
						StateManager.instance.checkMsg(4, [windowHook_fastNeedGold]);
						return false;
					}
					windowHook_isSendFastProto = true;
					// proto.cs_HookFastComplete();
					DemonProxy.instance.quickenComplete();
					break;
			}
			return true;
		}

		private var windowHook_checkWalkSignal : Signal;

		// private function windowHook_updateNum() : void {
		// windowHook.setRemainNum(count, isFree);
		// }
		public function windowHookHangup(con : int, free : Boolean) : void {
			count = con;
			isFree = free;
			windowHook.setRemainNum(count, isFree);
		}

		/** 挂机面板 -- 关闭 */
		public function windowHook_close() : void {
			if (windowHook_checkEnClose() == false) {
				return;
			}
			EnWalkManager.removeCheckEnWalk(windowHook_checkEnWalk);
			windowHook.visible = false;
			windowHook.logBox. clearMsgs();
			windowHook.goodsBox.clear();
			if (windowHook_checkWalkSignal) {
				windowHook_checkWalkSignal.dispatch();
				windowHook_checkWalkSignal = null;
			}
			DemonContral.instance.hangUpOpenView();
		}

		private function windowHook_checkEnWalk(doWhat : int = 0) : Boolean {
			doWhat;
			if (windowHook_isStart == true) {
				windowHook_checkWalkSignal = EnWalkManager.continueWalk;
				windowIsRelevanceByWalk = true;
				windowHook_close();
				return false;
			} else {
				windowIsRelevanceByWalk = true;
				windowHook_close();
				return true;
			}
			return true;
		}

		/** 挂机面板 -- 验证关闭 */
		public function windowHook_checkEnClose() : Boolean {
			if (windowHook_isStart == true) {
				StateManager.instance.checkMsg(6, [], windowHook_checkEnCloseButtonAlert);
				return false;
			}
			return true;
		}

		/** 挂机面板 -- 点击立即完成按钮对话框回调 */
		private function windowHook_checkEnCloseButtonAlert(eventType : String) : Boolean {
			switch(eventType) {
				case Alert.OK_EVENT:
					windowHook_stopOfClose = true;
					DemonProxy.instance.stopHangupDemon();
					break;
				case Alert.CANCEL_EVENT :
					windowHook_checkWalkSignal = null;
					windowIsRelevanceByWalk = false;
					break;
			}
			return true;
		}

		private function setItems(items : Vector.<uint>) : int {
			var silver : int = 0;
			var length : int = items.length;
			for (var i : int = 0; i < length; i++) {
				var num : uint = items[i];
				var itemBindFlag : uint = num >> 31;
				var itemBind : Boolean = (itemBindFlag) ? true : false;
				var itemId : int = (num - (itemBindFlag << 31)) >> 16;
				var itemCount : int = num - ((itemBindFlag << 31) + (itemId << 16));
				windowHook.goodsBox.addItem(itemId, itemCount, itemBind);

				if (itemId == ID.SILVER) {
					silver = itemCount;
				}
			}
			return silver;
		}
	}
}
class Controll {
}
