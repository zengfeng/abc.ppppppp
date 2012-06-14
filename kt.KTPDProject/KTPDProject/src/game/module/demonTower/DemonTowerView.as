package game.module.demonTower
{
	import game.core.user.UserData;
	import game.definition.UI;
	import game.manager.SignalBusManager;
	import game.manager.ViewManager;
	import game.net.core.Common;
	import game.net.data.CtoC.CCSendDemonToMassage;

	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.data.GLabelData;
	import gameui.data.GTitleWindowData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import net.AssetData;

	import com.commUI.GCommonWindow;
	import com.utils.StringUtils;

	import flash.display.Sprite;





	/**
	 * @author Lv
	 */
	public class DemonTowerView extends GCommonWindow {
		private var demonup : DemonUpPanel;
		private var demonDown : DemonDownPanel;
		private var tips : GLabel;
		public function DemonTowerView() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}

		override protected function initData() : void {
			_data.width = 634;
			_data.height = 409;
			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;
			super.initData();
		}

		private function initEvents() : void {
			Common.game_server.addCallback(0xFFF9, cCSendDemonToMassage);
		}

		private function cCSendDemonToMassage(e:CCSendDemonToMassage) : void {
			refreshTextData();
		}

		override protected function initViews() : void {
			title = "锁妖塔";
			super.initViews();
			setBgToStage();
			setPanelToStage();
			setTipsToStage();
		}

		private function setTipsToStage() : void {
			var data : GLabelData = new GLabelData();
			data.text = "今日免费锁妖次数：" + StringUtils.addColor("10", "#FF3300");
			data.y = 25;
			data.x = 460;
			data.textColor = 0x2F1F00;
			data.textFieldFilters = [];
			data.width = 160;
			tips = new GLabel(data);
			_contentPanel.addChild(tips);
		}

		public function refreshTextData() : void {
			var con : String = String(DemonProxy.demonTimes);
			var vip : int = UserData.instance.vipLevel;
			if (vip == 0) {
				tips.text = "今日免费锁妖次数：" + StringUtils.addColor(con, "#FF3300");
			} else {
				if (DemonProxy.isCharge == false)
					tips.text = "今日免费锁妖次数：" + StringUtils.addColor(con, "#FF3300");
				else if (DemonProxy.isCharge == true)
					tips.text = StringUtils.addColor("今日购买锁妖次数：" + con, "#FF3300");
			}
		}

		private function setPanelToStage() : void {
			demonDown = DemonContral.instance.demonDown;
			demonDown.x = 17;
			demonDown.y = 70;
			_contentPanel.addChild(demonDown);
			demonup = DemonContral.instance.demonUp;
			demonup.x = 17;
			demonup.y = 13;
			_contentPanel.addChild(demonup);
			DemonProxy.isOpend = true;
			DemonContral.instance.changeBossCave();
			DemonContral.instance.changeStarInto();
		}

		private function setBgToStage() : void {
			var bg : Sprite = UIManager.getUI(new AssetData(UI.CAST_SUTRA_PANEL_BG));
			bg.x = 7;
			bg.width = 615;
			bg.height = 402;
			_contentPanel.addChild(bg);
			var bg1:Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
			bg1.x = 17;
			bg1.y = 13;
			bg1.width = 415;
            bg1.height = 52;
			_contentPanel.addChild(bg1);
		}

		override public function show() : void {
			super.show();
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2, -1, (UIManager.stage.stageHeight - this.height) / 2, -1);
			GLayout.layout(this);
			SignalBusManager.duplOpened.add(duplOpened);
		}

		private function duplOpened(duplMapId : int) : void {
			if (duplMapId >= 10 && duplMapId < 100) {
				if (duplMapId % 10 == 0) {
					updateDupl();
				} else {
					updateMonster();
				}
			}
		}

		private function updateDupl() : void {
			DemonContral.instance.changeBossCave();
		}

		private function updateMonster() : void {
			refreshTextData();
			DemonContral.instance.openBoss();
		}

		override public function hide() : void {
			super.hide();
			SignalBusManager.duplOpened.remove(duplOpened);
		}
	}
}
