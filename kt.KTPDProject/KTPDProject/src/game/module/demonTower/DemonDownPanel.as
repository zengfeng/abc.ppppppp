package game.module.demonTower {
	import com.commUI.alert.Alert;
	import com.commUI.button.KTButtonData;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.utils.StringUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarThumb;
	import game.core.avatar.AvatarType;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.module.duplMap.DuplMapData;
	import game.module.duplMap.DuplOpened;
	import game.module.duplMap.DuplUtil;
	import game.module.duplMap.data.DuplStruct;
	import game.module.map.animalstruct.MonsterStruct;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;
	import gameui.data.GLabelData;
	import gameui.manager.UIManager;
	import net.AssetData;







	/**
	 * @author Lv
	 */
	public class DemonDownPanel extends GComponent {
		private var itemVec : Vector.<DemonDownItem> = new Vector.<DemonDownItem>();
		private var pressDemonBtn : GButton;
		private var hangUpBtn : GButton;
		private var bossName : GLabel;
		private var challengeTime : GLabel;
		private var bossAvatar : AvatarThumb;
		private var itemSpVec : Vector.<Sprite> = new Vector.<Sprite>();

		public function DemonDownPanel() {
			_base = new GComponentData();
			initData();
			super(_base);
			initView();
			initEvent();
		}

		private function initData() : void {
			_base.width = 594;
			_base.height = 325;
		}

		private function initEvent() : void {
			pressDemonBtn.addEventListener(MouseEvent.CLICK, onPressBtn);
			hangUpBtn.addEventListener(MouseEvent.CLICK, onHangUpBtn);
		}

		private function onHangUpBtn(event : MouseEvent) : void {
			HangUpPanelContollor.instance.openWindowHook(duplstruct, monster);
			DemonContral.instance.quitDemon();
		}

		private function onPressBtn(event : MouseEvent) : void {
			if (!itemVec[mouseDownIndex].getLockStatus && DemonProxy.noPassChallengTimes != 20) {
				challenge();
				return;
			}

			if (DemonProxy.isCharge) {
				StateManager.instance.checkMsg(300, [DemonProxy.BUY_ONCE_MONEY], windowHook_onClickStartNoFreeGoldAlert);
			} else {
				if (UserData.instance.tryPutPack(DemonProxy.NEED_PAGE) < 0) {
					// StateManager.instance.checkMsg(302);
					return;
				} else {
					var id : int = DuplUtil.getDemonBossId(monster.duplId, monster.layerId);
					DemonProxy.instance.challengeBoss(id);
				}
			}
		}

		private function challenge() : void {
			var id : int = DuplUtil.getDemonBossId(monster.duplId, monster.layerId);
			DemonProxy.instance.challengeBoss(id);
		}

		private function windowHook_onClickStartNoFreeGoldAlert(eventType : String) : Boolean {
			switch(eventType) {
				case Alert.OK_EVENT:
					windowHook_csStart();
					break;
			}
			return true;
		}

		private function windowHook_csStart() : void {
			var myGold : int = UserData.instance.gold + UserData.instance.goldB;
			if (myGold > DemonProxy.BUY_ONCE_MONEY - 1) {
				if (UserData.instance.tryPutPack(DemonProxy.NEED_PAGE) < 0) {
					StateManager.instance.checkMsg(302);
					return;
				} else {
					var id : int = DuplUtil.getDemonBossId(monster.duplId, monster.layerId);
					DemonProxy.instance.challengeBoss(id);
				}
			} else {
				StateManager.instance.checkMsg(4);
			}
		}

		private function initView() : void {
			setBgToStage();
			setItemToStage();
			setButToStage();
			setBossNameToSatage();
		}

		private function setBossNameToSatage() : void {
			var data : GLabelData = new GLabelData();
			data.x = 175;
			data.y = 9;
			data.text = "变异树妖";
			data.textColor = 0xFFFFFF;
			data.textFormat.size = 18;
			bossName = new GLabel(data);
			this.addChild(bossName);
			data.clone();
			data.text = "剩余挑战次数: " + StringUtils.addColor("0", "#FF0000");
			data.textFormat.size = 12;
			data.x = 188;
			data.y = 248;
			data.width = 200;
			challengeTime = new GLabel(data);
			this.addChild(challengeTime);
		}

		public function refreshData(demon : DuplStruct) : void {
			refreshDemon(demon);
			refreshText();
		}

		public function refreshText() : void {
			var str : String = String(DemonProxy.noPassChallengTimes);
			challengeTime.text = "剩余挑战次数: " + StringUtils.addColor(str, "#FF0000");
			if (DemonProxy.noPassChallengTimes == 0) {
				challengeTime.text = StringUtils.addColor("今日挑战次数已满", "#FFFFFF");
				if (!itemVec[mouseDownIndex].getLockStatus)
					pressDemonBtn.visible = false;
				else
					pressDemonBtn.visible = true;
			}

			if (itemVec[mouseDownIndex].getLockStatus) {
				challengeTime.visible = false;
				return;
			}
			var tiemr : int = DemonProxy.noPassChallengTimes;
			if (0 < tiemr && tiemr < 20)
				challengeTime.visible = true;
			else
				challengeTime.visible = false;
		}

		private var duplstruct : DuplStruct;

		private function refreshDemon(demon : DuplStruct) : void {
			var dic : Dictionary = demon.bossDic;
			duplstruct = demon;
			var monsterVec : Vector.<MonsterStruct> = new Vector.<MonsterStruct>();
			for each (var monsterStruct:MonsterStruct in dic) {
				monsterVec.push(monsterStruct);
			}
			monsterVec.sort(monsterVecSort);
			setMonster(monsterVec);
		}

		public function monsterVecSort(a : MonsterStruct, b : MonsterStruct) : int {
			return a.mapId - b.mapId;
		}

		private function setMonster(monsterVec : Vector.<MonsterStruct>) : void {
			var isThrough : Boolean;
			closeItem();
			for (var i : int = 0; i < monsterVec.length ; i++) {
				var item : DemonDownItem = itemVec[i];
				item.refreshData(monsterVec[i]);
				isThrough = DuplOpened.isPassDuplMapId(monsterVec[i].mapId);
				item.setLockStatus = isThrough;
				var demonBossId : int = DuplUtil.getDemonBossIdByDuplMapId(monsterVec[i].mapId);
				var isOpen : Boolean = DuplOpened.isOpenDuplMapId(demonBossId);
				var isPass : Boolean = DuplOpened.isPassDuplMapId(demonBossId);
				itemSpVec[i].mouseEnabled = isOpen;
				item.setLockStatus = isPass;
				setBossTips(item.getMonster,itemSpVec[i]);
			}
			starPanel();
		}

		public function refreshMonster() : void {
			var max : int = itemVec.length;
			for (var i : int = 0; i < max ; i++) {
				itemVec[i].refreshOpen();
				var monster : MonsterStruct = itemVec[i].getMonster;
				var demonBossId : int = DuplUtil.getDemonBossIdByDuplMapId(monster.mapId);
				var isOpen : Boolean = DuplOpened.isOpenDuplMapId(demonBossId);
				var isPass : Boolean = DuplOpened.isPassDuplMapId(demonBossId);
				itemSpVec[i].mouseEnabled = isOpen;
				itemVec[i].setLockStatus = isPass;
				setBossTips(monster,itemSpVec[i]);
			}
			var item : DemonDownItem = itemVec[mouseDownIndex];
			showBtn(item.getLockStatus);

			var clockTimer : int = DemonProxy.demonTimes;
			var challengTiemr : int = DemonProxy.noPassChallengTimes;
			if ((clockTimer == 0) && ((challengTiemr == 0) || (challengTiemr == 20))) {
				allUsetimer();
			}
		}

		private function setButToStage() : void {
			var data : GButtonData = new KTButtonData();
			data.labelData.text = "锁妖";
			data.y = 273;
			data.x = 133;
			pressDemonBtn = new GButton(data);
			this.addChild(pressDemonBtn);
			data.clone();
			data.labelData.text = "挂机";
			data.x = 242;
			hangUpBtn = new GButton(data);
			this.addChild(hangUpBtn);
		}

		private function setItemToStage() : void {
			var item : DemonDownItem ;
			var gap : int = 58;
			var sp : Sprite;
			for (var i : int = 0 ; i < 3 ; i++) {
				item = new DemonDownItem();
				item.x = 444;
				item.y = 40 + (item.height + gap) * i;
				item.name = "x_" + i;
				this.addChild(item);
				itemVec.push(item);
			}
			for (var j : int = 0 ;j < 3;j++) {
				sp = new Sprite();
				sp.graphics.beginFill(0x555555);
				sp.graphics.drawRect(444, 40 + (44 + gap) * j, 133, 44);
				sp.graphics.endFill();
				this.addChild(sp);
				itemSpVec.push(sp);
				sp.name = "x_" + j;
				sp.alpha = 0;
				sp.addEventListener(MouseEvent.CLICK, onmouseDown);
				sp.addEventListener(MouseEvent.ROLL_OVER, onOver);
				sp.addEventListener(MouseEvent.ROLL_OUT, onOut);
			}
		}

		private var rollIndex : Number = -2;
		private var rollItem : DemonDownItem;

		private function onOut(event : MouseEvent) : void {
			if (mouseDownIndex == rollIndex) return;
			rollItem.mouseUp();
		}

		public function starPanel() : void {
			closeItem();
			mouseDownIndex = 0;
			var item : DemonDownItem = itemVec[mouseDownIndex];
			item.mouseDown();
			if (item.getMonster == null) return;
			bossName.text = item.getMonsterName.text;
			monster = item.getMonster;
			setAvatar(item.getMonster);
			showBtn(item.getLockStatus);
			var clockTimer : int = DemonProxy.demonTimes;
			var challengTiemr : int = DemonProxy.noPassChallengTimes;
			if (clockTimer == 0 && (challengTiemr == 0 || challengTiemr == 20)) {
				allUsetimer();
			}
		}

		private function setAvatar(getMonster : MonsterStruct) : void {
			if (bossAvatar != null) clearAvatar();
			var bossID : int = getMonster.voBase.avatarId;
			bossAvatar = AvatarManager.instance.getAvatar(bossID, AvatarType.MONSTER_TYPE);
			bossAvatar.x = 220;
			bossAvatar.y = 200;
			bossAvatar.scaleX = bossAvatar.scaleY = 0.8;
			bossAvatar.mouseEnabled = false;
			bossAvatar.mouseChildren = false;
			this.addChild(bossAvatar);
			this.addChild(bossName);
			this.addChild(challengeTime);
		}

		private function setBossTips(getMonster : MonsterStruct,itemSP:Sprite) : void {
			var layerId : int = getMonster.layerId;
			var duplMapId : int = DuplUtil.getDuplMapId(getMonster.duplId, layerId);
			var tipStr : String = DuplMapData.instance.getLayerTip(duplMapId, 10);
			if (tipStr != null) {
				ToolTipManager.instance.registerToolTip(itemSP, ToolTip, tipStr);
			} else {
				ToolTipManager.instance.destroyToolTip(itemSP);
			}
		}

		private function clearAvatar() : void {
			this.removeChild(bossAvatar);
		}

		private function onOver(event : MouseEvent) : void {
			rollIndex = int(event.currentTarget.name.split("_")[1]);
//			var item : DemonDownItem = itemVec[rollIndex];
//			if (item != null)
//				setBossTips(item.getMonster);
			if (mouseDownIndex == rollIndex) return;
			rollItem = itemVec[rollIndex];
			rollItem.mouseDown();
		}

		private var mouseDownIndex : Number = -1;
		private var monster : MonsterStruct;

		private function onmouseDown(event : Event) : void {
			var idex : int = int(event.currentTarget.name.split("_")[1]);
			if (mouseDownIndex == idex) return;
			closeItem();
			mouseDownIndex = idex;
			var item : DemonDownItem = itemVec[mouseDownIndex];
			item.mouseDown();
			showBtn(item.getLockStatus);
			bossName.text = item.getMonsterName.text;
			setAvatar(item.getMonster);
			monster = item.getMonster;

			var clockTimer : int = DemonProxy.demonTimes;
			var challengTiemr : int = DemonProxy.noPassChallengTimes;
			if (clockTimer == 0 && (challengTiemr == 0 || challengTiemr == 20)) {
				allUsetimer();
			}
		}

		// 是否显示挂机按钮
		private function showBtn(getLockStatus : Boolean) : void {
			showTwoBtn();
			if (getLockStatus) {
				showTwoBtn();
				challengeTime.visible = false;
				if (DemonProxy.demonTimes == 0) {
					allUsetimer();
				}
			} else {
				showOneBtn();
				var tiemr : int = DemonProxy.noPassChallengTimes;
				if (0 < tiemr && tiemr < 20) {
					challengeTime.visible = true;
					refreshText();
				} else {
					challengeTime.visible = false;
				}
			}
		}

		private function showOneBtn() : void {
			pressDemonBtn.visible = true;
			hangUpBtn.visible = false;
			pressDemonBtn.x = 188;
		}

		private function showTwoBtn() : void {
			pressDemonBtn.visible = true;
			hangUpBtn.visible = true;
			pressDemonBtn.x = 133;
		}

		// 所有进入次数都已用完
		private function allUsetimer() : void {
			pressDemonBtn.visible = false;
			hangUpBtn.visible = false;
			challengeTime.visible = true;
			challengeTime.text = StringUtils.addColor("今日锁妖次数已满", "#FFFFFF");
		}

		private function closeItem() : void {
			for each (var item:DemonDownItem in itemVec) {
				item.mouseUp();
			}
		}

		private function setBgToStage() : void {
			var bg : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
			bg.width = 594;
			bg.height = 325;
			this.addChild(bg);
			var bg1 : Sprite = UIManager.getUI(new AssetData("demonBossBG"));
			this.addChild(bg1);
		}
	}
}
