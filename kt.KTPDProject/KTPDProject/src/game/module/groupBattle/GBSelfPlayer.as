package game.module.groupBattle
{
	import com.commUI.UIPlayerStatus;
	import com.commUI.alert.Alert;
	import com.utils.Glow;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.module.groupBattle.ui.UiSelfInfoBox;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.utils.MapPosition;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-16 ����10:44:25
	 */
	public class GBSelfPlayer extends GBPlayer
	{
		// private var dieGlow : Glow = new Glow(0x0099CC);
		private var dieGlow : Glow = new Glow(0xEEff00);
		private var normal : Glow = new Glow(0xEEff00);
		/** 鼓舞等级 */
		public var inspireLevel : uint = 0;
		/** UI自己玩家信息面板 */
		private var _uiSelfInfo : UiSelfInfoBox;
		/** 复活CD时间UI */
		private var _uiPlayerStatus : UIPlayerStatus;

		public function GBSelfPlayer(playerStruct : PlayerStruct)
		{
			super(playerStruct);
		}

		/** 复活CD时间UI */
		private function get uiPlayerStatus() : UIPlayerStatus
		{
			if (_uiPlayerStatus == null)
			{
				_uiPlayerStatus = UIPlayerStatus.instance;
			}
			return _uiPlayerStatus;
		}

		/** 快速复活对话框 */
		private var faseReviveAlert : Alert;

		/** 快速复活 */
		private function faseReviveCall() : void
		{
			if (faseReviveAlert == null)
			{
				faseReviveAlert = StateManager.instance.checkMsg(126, [], faseReviveAlertCall);
			}
			else
			{
				faseReviveAlert.show();
			}
		}

		/** 快速复活对话框回调 */
		private function faseReviveAlertCall(eventType : String) : Boolean
		{
			switch(eventType)
			{
				case Alert.OK_EVENT:
					if (UserData.instance.gold < GBConfig.faseReviveGold )
					{
						StateManager.instance.checkMsg(4);
						return false;
					}
					GBProto.instance.cs_fastResurrection();
					break;
			}
			return true;
		}

		/** 设置复活时间 */
		private function setDieTime(value : int = 0) : void
		{
			if (uiPlayerStatus == null)
			{
			}
			if (value > 1)
			{
				uiPlayerStatus.cdQuickenBtnCall = faseReviveCall;
				uiPlayerStatus.setCDTime(value);
                uiPlayerStatus.cdTimer.setTimersTip(10);
			}
			else
			{
				uiPlayerStatus.clearCD();
			}
		}

		private var testStr : String = "";

		public function test(str : String) : void
		{
			testStr += "\n" + str;
			//trace(testStr);
		}

		/** 去大本营区域 */
		override public function toAreaGroup() : void
		{
			super.toAreaGroup();
			MapPosition.instance.center();
		}

		override public function set animal(animal : PlayerAnimal) : void
		{
			super.animal = animal;
			if (_animal)
			{
				normal.addDisplayObject(animal.avatar);
			}
		}

//		override public function set playerStatus(value : int) : void
//		{
//			super.playerStatus = value;
//			if (animal && animal.avatar && animal.avatar.player)
//			{
//				if (value == GBPlayerStatus.DIE)
//				{
//					normal.removeDisplayObject(animal.avatar.player);
//					dieGlow.addDisplayObject(animal.avatar.player);
//					normal.pause();
//				}
//				else
//				{
//					dieGlow.removeDisplayObject(animal.avatar.player);
//					normal.addDisplayObject(animal.avatar.player);
//					dieGlow.pause();
//				}
//			}
//		}

		override public function setPlayerStatus(status : int, time : int) : void
		{
			super.setPlayerStatus(status, time);
			// 设置复活时间
			if (status == GBPlayerStatus.DIE)
			{
				setDieTime(time);
			}
			else
			{
				setDieTime(0);
			}
		}

		override public function quit() : void
		{
			if (animal && animal.avatar && animal.avatar.player )
			{
				normal.removeDisplayObject(animal.avatar);
//				dieGlow.removeDisplayObject(animal.avatar.player);
				dieGlow.pause();
				normal.pause();
				animal.avatar.filters = [];
			}

			if (_uiPlayerStatus)
			{
				_uiPlayerStatus.clear();
			}
			if (faseReviveAlert != null) faseReviveAlert.hide();
			super.quit();
		}

		/** UI自己玩家信息面板 */
		public function get uiSelfInfo() : UiSelfInfoBox
		{
			return _uiSelfInfo;
		}

		public function set uiSelfInfo(uiSelfInfo : UiSelfInfoBox) : void
		{
			_uiSelfInfo = uiSelfInfo;
			if (_uiSelfInfo)
			{
				_uiSelfInfo.setPlayer(this);
				// _uiSelfInfo.maxKillCount =maxKillCount;
				// _uiSelfInfo.killCount = killCount;
				// _uiSelfInfo.winCount = winCount;
				// _uiSelfInfo.loseCount = loseCount;
				// _uiSelfInfo.silver = silver;
				// _uiSelfInfo.darksteel = darksteel;
			}
		}

		/** 连杀数 */
		override public function set killCount(killCount : uint) : void
		{
			super.killCount = killCount;
			if (uiSelfInfo)
			{
				uiSelfInfo.killCount = killCount;
			}
		}

		/** 最高连杀数 */
		override public function set maxKillCount(maxKillCount : uint) : void
		{
			super.maxKillCount = maxKillCount;
			if (uiSelfInfo)
			{
				uiSelfInfo.maxKillCount = maxKillCount;
			}
		}

		/** 胜利场数 */
		override public function set winCount(winCount : uint) : void
		{
			super.winCount = winCount;
			if (uiSelfInfo)
			{
				uiSelfInfo.winCount = winCount;
			}
		}

		/** 失败场数 */
		override public function set loseCount(loseCount : uint) : void
		{
			super.loseCount = loseCount;
			if (uiSelfInfo)
			{
				uiSelfInfo.loseCount = loseCount;
			}
		}

		/** 银币 */
		override public function set silver(value : int) : void
		{
			super.silver = value;
			if (uiSelfInfo)
			{
				uiSelfInfo.silver = value ;
			}
		}

		/** 玄铁 */
		override public function set darksteel(value : int) : void
		{
			super.darksteel = value;
			if (uiSelfInfo)
			{
				uiSelfInfo.darksteel = value ;
			}
		}
	}
}
