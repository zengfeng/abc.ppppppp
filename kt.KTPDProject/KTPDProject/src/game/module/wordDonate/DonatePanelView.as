package game.module.wordDonate {
	import com.commUI.GCommonWindow;
	import com.commUI.icon.ItemIcon;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.utils.UICreateUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.core.item.config.ItemConfigManager;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.core.user.StateManager;
	import game.definition.UI;
	import game.manager.ViewManager;
	import game.module.pack.ManagePack;
	import game.module.shop.itemVo.GoodItem;
	import game.module.wordDonate.donateManage.DonateManage;
	import game.module.wordDonate.donateManage.DonateRewardManager;
	import game.module.wordDonate.donateManage.DonateVo;
	import game.net.core.Common;
	import game.net.data.CtoC.CCPackChange;
	import game.net.data.CtoS.CSDonate;
	import game.net.data.CtoS.CSDonateList;
	import game.net.data.CtoS.CSDonateListCount;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.controls.GProgressBar;
	import gameui.controls.GTextInput;
	import gameui.core.GAlign;
	import gameui.data.GButtonData;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.data.GProgressBarData;
	import gameui.data.GTextInputData;
	import gameui.data.GTitleWindowData;
	import gameui.data.GToolTipData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;



















	/**
	 * @author Lv
	 */
	public class DonatePanelView extends GCommonWindow {
		private var submitBtn : GButton;
		private var textInputG : GTextInput;
		private var myRanking : GLabel;
		private var weekContribution : GLabel;
		private var expPro : GProgressBar;
		private var expTotal : GLabel;
		private var firstStep : GLabel;
		private var endStep : GLabel;
		private var vo : DonateVo;
		private var fontTipSp : Sprite;
		private var icon : ItemIcon;

		public function DonatePanelView() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}

		override protected function initData() : void {
			_data.width = 373;
			_data.height = 310;
			_data.parent = ViewManager.instance.uiContainer;
			_data.panelData.bgAsset = new AssetData(SkinStyle.emptySkin);
			_data.allowDrag = true;
			super.initData();
		}

		private function initEvents() : void {
			submitBtn.addEventListener(MouseEvent.CLICK, ondown);
			textInputG.addEventListener(FocusEvent.FOCUS_OUT, listenerFocus);
			textInputG.addEventListener(KeyboardEvent.KEY_UP	, ontextInput);
			textInputG.addEventListener(KeyboardEvent.KEY_DOWN	, ontextInput);
			textInputG.addEventListener(Event.CHANGE, ontextInput1);
		}

		private function ontextInput1(event : Event) : void {
			var total:uint = ItemManager.instance.getPileItem(1800).nums;
			var now:uint = uint(textInputG.text);
			if(now>total)
			{
				textInputG.text = String(total);
			}
		}

		private function ontextInput(event : KeyboardEvent) : void {
			var total:uint = ItemManager.instance.getPileItem(1800).nums;
			var now:uint = uint(textInputG.text);
			if(now>total)
			{
				textInputG.text = String(total);
			}
			//textInputG.text = String(ItemManager.instance.getPileItem(1800).nums);
		}

		private function listenerFocus(event : FocusEvent) : void {
			if(int(textInputG.text) == 0){
				textInputG.text = String(ItemManager.instance.getPileItem(1800).nums);
			}
		}

		override protected function onClickClose(event : MouseEvent) : void {
			MenuManager.getInstance().changMenu(MenuType.DONATE);
		}

		override protected function initViews() : void {
			title = "开天斧";
			super.initViews();
			addBG();
			addPanel();
		}

		private function addBG() : void {
			var bg : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND));
			bg.x = 10;
			bg.y = 5;
			bg.width = 348;
			bg.height = 295;
			_contentPanel.addChild(bg);

			var bg2 : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
			bg2.x = 20;
			bg2.y = 189;
			bg2.width = 328;
			bg2.height = 72;
			_contentPanel.addChild(bg2);
			
			icon = UICreateUtils.createItemIcon({x:125, y:200, showBorder:true, showBg:true, showNums:true, showToolTip:true});
			_contentPanel.addChild(icon);
		}

		private function updateIcon() : void {
			icon.source = ItemManager.instance.getPileItem(1800);
		}

		private function ondown(event : MouseEvent) : void {
			if (uint(textInputG.text) > 0) {
				var cmd : CSDonate = new CSDonate();
				cmd.count = uint(textInputG.text);
				Common.game_server.sendMessage(0x100, cmd);
				
				var cmd1:CSDonateList = new CSDonateList();
				cmd1.page = DonateProxy.nowPageNum;
				Common.game_server.sendMessage(0x103,cmd1);
				
				var cmd2:CSDonateListCount = new CSDonateListCount();
				Common.game_server.sendMessage(0x102,cmd2);
				StateManager.instance.checkMsg(207);
			}else{
				StateManager.instance.checkMsg(204);
			}
		}

		public function setPanel() : void {
			vo = DonateManage.getDonateDic[DonateProxy.donateLevel];
			var vo2 : DonateVo;
			vo2 = DonateManage.getDonateDic[DonateProxy.donateLevel + 1];
			if(DonateProxy.nowWeekRank == 0)
				myRanking.text = "未入围";
			else
				myRanking.text = String(DonateProxy.nowWeekRank);
			//是否更改
			textInputG.text = String(ItemManager.instance.getPileItem(1800).nums);
			
			weekContribution.text = DonateProxy.nowWeekContributionVaule + "个";
			if (DonateManage.getDonateMaxLevel == vo.level) {
				firstStep.text = "满级";
				endStep.visible = false;
				expTotal.visible = false;
				expPro.visible = false;
			} else {
				endStep.visible = true;
				expTotal.visible = true;
				expPro.visible = true;
				firstStep.text = DonateProxy.donateLevel + "级 → ";
				endStep.text = (DonateProxy.donateLevel + 1) + "级";
				expTotal.text = String(DonateProxy.nowContributionVaule)+"/"+ String(vo2.expVaule);
				expPro.value = ((DonateProxy.nowContributionVaule) / (vo2.expVaule)) * 100;
			}
			expTotal.x = (this.width - expTotal.width)/2;
			var one : String = "";
			one = "<b><font color='0xFFFFFF' bold = '2' size = '14'>开天斧 " + vo.level + "级</font></b>" + "<font color='#FFFFFF' size = '12'>(当前等级)</font>\n" + "<font color='#FFCC00' size = '12'>+" + vo.percentageUp + "%挂机修炼经验</font>\n\n";
			var two : String = "";
			if (DonateManage.getDonateMaxLevel != vo.level) {
				two = "<b><font color='#FFFFFF' size = '14'>开天斧 " + vo2.level + "级</font></b>\n" + "<font color='#FFCC00' size = '12'>+" + vo2.percentageUp + "%挂机修炼经验</font>";
			}
			imgTipsStr = one + two;
			var maxRank:int = DonateRewardManager.saveDonateRewardMaxRank;
			var rank:int = DonateProxy.nowWeekRank;
			if(rank == 0)return;
			var str:String = "";
			if(rank < maxRank)
				str = DonateRewardManager.saveDonateRewardDic[rank];
			else
				str = DonateRewardManager.saveDonateRewardDic[maxRank];
			str = str.split("：")[1];
			str = str.split("、")[0] + "\n" +"和"+ str.split("、")[1];
			nameTipsStr = "保持我的本周排名至下周一00:00时\n你将获得"+str+"\n<font color='#555555'>排名越高获得奖励越多 </font>";
		}

		// 开天斧图标上的tips上的值
		private var imgTipsStr : String = "未加载";

		// 开天斧图标上的tips
		private function setImgTips() : String {
			return imgTipsStr;
		}

		// 名称tips上的值
		private var nameTipsStr : String = "未贡献" ;

		// 名称上的tips
		private function nameTips() : String {
			return nameTipsStr;
		}

		private function addPanel() : void {
			var data : GLabelData = new GLabelData();
			data.text = "我的排名：";
			data.textFormat.size = 12;
			data.x = 20;
			data.y = 19;
			var text1 : GLabel = new GLabel(data);
			_contentPanel.addChild(text1);
			data.clone();
			data.x = text1.width + text1.x ;
			data.text = "排名555";
			myRanking = new GLabel(data);
			_contentPanel.addChild(myRanking);
			data.clone();
			data.text = "本周贡献：";
			data.y = text1.y + text1.height + 2;
			data.x = text1.x;
			var text2 : GLabel = new GLabel(data);
			_contentPanel.addChild(text2);
			data.clone();
			data.text = "200个";
			data.x = text2.x + text2.width;
			weekContribution = new GLabel(data);
			_contentPanel.addChild(weekContribution);
			data.clone();
			data.y = 162;
			data.text = "9999/9999";
			data.x = (this.width - data.width)/2;
			expTotal = new GLabel(data);
			data.clone();
			data.text = "1级 → ";
			data.x = 154;
			data.y = 142;
			firstStep = new GLabel(data);
			_contentPanel.addChild(firstStep);
			data.clone();
			data.text = "2级";
			data.x = firstStep.x + firstStep.width;
			endStep = new GLabel(data);
			_contentPanel.addChild(endStep);

			var datainput : GTextInputData = new GTextInputData();
			datainput.borderAsset = new AssetData("sutraTextInput");
			datainput.width = 70;
			datainput.height = 22;
			datainput.x = 176;
			datainput.y = 215;
			datainput.restrict = "0-9";
			textInputG = new GTextInput(datainput);
			_contentPanel.addChild(textInputG);

			var dataBtn : GButtonData = new GButtonData();
			dataBtn.labelData.text = "贡献";
			dataBtn.x = 146;
			dataBtn.y = 267;
			submitBtn = new GButton(dataBtn);
			_contentPanel.addChild(submitBtn);

			var dataExp : GProgressBarData = new GProgressBarData();
			dataExp.trackAsset = new AssetData("DonatePro_bg");
			dataExp.barAsset = new AssetData("DonatePro_exp");
//			dataExp.toolTipData = new GToolTipData();
			dataExp.height = 20;
			dataExp.width = 327;
			dataExp.x = 20;
			dataExp.y = 160;
			dataExp.paddingX = 3;
			dataExp.paddingY = 3;
			dataExp.padding = 3;
			expPro = new GProgressBar(dataExp);
			_contentPanel.addChild(expPro);
			expPro.value = 0 / 100 * 100;
//			expPro.toolTip.source = "10000/10000";

//			_contentPanel.addChild(expNow);
			_contentPanel.addChild(expTotal);
			expTotal.mouseEnabled = false;

			fontTipSp = new Sprite();
			fontTipSp.graphics.beginFill(0x555555);
			fontTipSp.graphics.drawRect(20, 19, 100, 38);
			fontTipSp.graphics.endFill();
			_contentPanel.addChild(fontTipSp);
			fontTipSp.alpha = 0;
			ToolTipManager.instance.registerToolTip(fontTipSp, ToolTip, nameTips);
			
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0xFF0000);
			sp.graphics.drawRect(165, 65, 50, 50);
			sp.graphics.endFill();
			_contentPanel.addChild(sp);
			ToolTipManager.instance.registerToolTip(sp, ToolTip, setImgTips);
		}

		override protected function onShow() : void {
			super.onShow();
			updateIcon();
			Common.game_server.addCallback(0xFFF2, onPackChange);
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2, -1, (UIManager.stage.stageHeight - this.height) / 2, -1);
		}

		override protected function onHide() : void {
			super.onHide();
			Common.game_server.removeCallback(0xFFF2, onPackChange);
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2, -1, (UIManager.stage.stageHeight - this.height) / 2, -1);
		}

		private function onPackChange(msg : CCPackChange) : void {
			if (msg.topType | Item.EXPEND) {
				updateIcon();
			}
		}
	}
}
