package game.module.groupBattle.ui
{
	import com.commUI.button.ExitButton;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipData;
	import com.greensock.TweenLite;
	import com.utils.UICreateUtils;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import game.core.user.UserData;
	import game.manager.ViewManager;
	import game.module.groupBattle.GBController;
	import game.module.groupBattle.GBPlayerStatus;
	import game.module.groupBattle.GBProto;
	import game.net.data.StoC.SCGroupBattlePlayerUpdate;
	import gameui.controls.GButton;
	import gameui.data.GButtonData;
	import gameui.manager.GToolTipManager;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-16 ����5:15:16
	 */
	public class GBUC extends Sprite
	{
		/** 蜀山论剑控制器 */
		private var gbController : GBController = GBController.instance;
		/** (蜀山论剑)协议 */
		private var _gbProto : GBProto;
		/** 中间面板容器 */
		private var centerBox : Sprite = new Sprite();
		/** 排名 */
		public var fontSort : UiFontSortBox;
		/** 自己信息 */
		public var selfInfo : UiSelfInfoBox;
		/** 动态 */
		public var newsPanel : UiNewsPanel;
		/** 退出按钮 */
		private var exitButton : ExitButton;
		/** 帮助按钮 */
		private var helpButton : GButton;
		/** 游戏结束时间 */
		public var overTimer : UiOverTimer;
		/** 中间主UI */
		public var centerMain : UICenterMain;
		/** 玩家列表A */
		public var playerListA : UiPlayerList;
		/** 玩家列表B */
		public var playerListB : UiPlayerList;
		private var centerBoxWidth : int = 490;
		private var centerBoxHeight : int = 222;
		
		private var centerMainPaddLeft:int = 350;
		private var centerMainPaddRight:int = 350;

		/** (蜀山论剑)协议 */
		public function get gbProto() : GBProto
		{
			if (_gbProto == null)
			{
				_gbProto = GBProto.instance;
			}
			return _gbProto;
		}

		/** 舞台场景 宽 */
		public function get stageWidth() : int
		{
			return UIManager.stage.stageWidth;
		}

		/** 舞台场景 高 */
		public function get stageHeight() : int
		{
			return UIManager.stage.stageHeight;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function GBUC()
		{
			alpha = 0;
			// 初始化视图
			initViews();
			overTimer = centerMain.overTimer;

			// addTestButton();
		}

		/** 舞台场景大小变化 */
		private function onStageResize(stage : Stage = null, preStageWidth : Number = 0, preStageHeight : Number = 0) : void
		{
			stage;
			var centerMainWidth:int = stageWidth - centerMainPaddLeft - centerMainPaddRight;
			if(centerMainWidth < 545) 
			{
				centerMainWidth = 545;
			}
			else if(centerMainWidth > 900)
			{
				centerMainWidth = 900;
			}
			centerMain.width =  centerMainWidth;
			centerMain.x = (stageWidth - centerMain.width) >> 1;
			centerMain.updateLayout();
			playerListA.x = centerMain.x + 45  - playerListA.width / 2;
			playerListB.x = centerMain.x + centerMain.width - 45 - playerListA.width / 2;
			
			var newsPanelX:int =  (stageWidth - newsPanel.width) >> 1 ;
			if(newsPanelX < 410) newsPanelX = 410;
			newsPanel.x = newsPanelX;
			newsPanel.y = stageHeight - newsPanel.height - 65;

//			centerBox.x = (stageWidth - centerBox.width) / 2;
//			centerBox.y = stageHeight - centerBox.height - 65;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 初始化视图 */
		protected function initViews() : void
		{
			

			// 中间面板容器 背景
			var centerBoxBg : Sprite = UIManager.getUI(new AssetData("GroupBattle_InfoBg"));
			centerBoxBg.width = centerBoxWidth;
			centerBoxBg.height = centerBoxHeight;
			centerBox.addChild(centerBoxBg);

			// 排名
			fontSort = new UiFontSortBox();
			fontSort.x = 0;
			fontSort.y = 0;
			centerBox.addChild(fontSort);
			// 自己信息
			selfInfo = new UiSelfInfoBox();
			selfInfo.x = 50;
			selfInfo.y = 113;
			addChild(selfInfo);

			// 动态
			newsPanel = new UiNewsPanel();
			newsPanel.y = stageHeight - newsPanel.height - 65;
			var newsPanelX:int =  (stageWidth - newsPanel.width) >> 1 ;
			if(newsPanelX < 410) newsPanelX = 410;
			newsPanel.x = newsPanelX;
			addChild(newsPanel);
//			newsPanel.y = fontSort.height + 25;
//			centerBox.addChild(newsPanel);

			// 帮助按钮
			helpButton = UICreateUtils.createHelpGbutton();
			helpButton.x = centerBoxWidth - helpButton.width - 5;
			helpButton.y = 5;
			var helpStr : String = "<b><font size='14' color='#FFCC00'>分组规则：</font></b>系统将根据参赛者的等级随机分配至任意一组\n";
			helpStr += "<b><font size='14' color='#FFCC00'>胜败机制：</font></b>蜀山论剑结束时，获得总积分较多的一组为胜利组";
			var toolTipData : ToolTipData = new ToolTipData();
			toolTipData.labelData.minWidth = 210;
			var helpToolTip : ToolTip = new ToolTip(toolTipData);
			helpToolTip.source = helpStr;
			helpButton.toolTip = helpToolTip;
			GToolTipManager.registerToolTip(helpToolTip);
			centerBox.addChild(helpButton);

//			 //中间面板容器
//			addChild(centerBox);
//			centerBox.x = (stageWidth - centerBox.width) / 2;
//			centerBox.y = stageHeight - centerBox.height - 65;

			// 退出按钮
			exitButton = ExitButton.instance;
			exitButton.setVisible(true, cs_quit);

			// 中间主UI
			var centerMainWidth:int = stageWidth - centerMainPaddLeft - centerMainPaddRight;
			if(centerMainWidth < 545) 
			{
				centerMainWidth = 545;
			}
			else if(centerMainWidth > 900)
			{
				centerMainWidth = 900;
			}
			centerMain = new UICenterMain(stageWidth - centerMainPaddLeft - centerMainPaddRight);
			centerMain.x = (stageWidth - centerMain.width) >> 1;
			centerMain.y = 5;
			addChild(centerMain);
			
			var playerList : UiPlayerList;
			// 玩家列表A
			playerList = new UiPlayerList(180, 292);
//			playerList.x = stageWidth / 2 - 130 - playerList.width;
			playerList.y = 80;
			addChild(playerList);
			playerListA = playerList;

			// 玩家列表B
			playerList = new UiPlayerList(180, 292);
//			playerList.x = stageWidth / 2 + 130;
			playerList.y = 80;
			addChild(playerList);
			playerListB = playerList;
			
			playerListA.x = centerMain.x + 45  - playerListA.width / 2;
			playerListB.x = centerMain.x + centerMain.width - 45 - playerListA.width / 2;
		}

		private function cs_quit(event : MouseEvent = null) : void
		{
			gbProto.cs_quit();
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function addTestButton() : void
		{
			var buttonData : GButtonData;
			var button : GButton;
			buttonData = new GButtonData();
			buttonData.x = 50;
			buttonData.y = 50;
			buttonData.labelData.text = "战斗";
			button = new GButton(buttonData);
			button.addEventListener(MouseEvent.CLICK, vs);
			addChild(button);

			buttonData = buttonData.clone();
			buttonData.x = 200;
			buttonData.labelData.text = "死亡";
			button = new GButton(buttonData);
			button.addEventListener(MouseEvent.CLICK, die);
			addChild(button);

			buttonData = buttonData.clone();
			buttonData.x = 400;
			buttonData.labelData.text = "等待";
			button = new GButton(buttonData);
			button.addEventListener(MouseEvent.CLICK, wait);
			addChild(button);

			buttonData = buttonData.clone();
			buttonData.x = 600;
			buttonData.labelData.text = "休息";
			button = new GButton(buttonData);
			button.addEventListener(MouseEvent.CLICK, rest);
			addChild(button);
		}

		private function vs(event : Event) : void
		{
			var msg : SCGroupBattlePlayerUpdate = new SCGroupBattlePlayerUpdate();
			msg.playerId = UserData.instance.playerId;
			msg.playerSatus = GBPlayerStatus.VS;
			gbProto.sc_GroupBattlePlayerUpdate(msg);
		}

		private function die(event : Event) : void
		{
			var msg : SCGroupBattlePlayerUpdate = new SCGroupBattlePlayerUpdate();
			msg.playerId = UserData.instance.playerId;
			msg.playerSatus = GBPlayerStatus.DIE;
			gbProto.sc_GroupBattlePlayerUpdate(msg);
		}

		private function wait(event : Event) : void
		{
			var msg : SCGroupBattlePlayerUpdate = new SCGroupBattlePlayerUpdate();
			msg.playerId = UserData.instance.playerId;
			msg.playerSatus = GBPlayerStatus.WAIT;
			gbProto.sc_GroupBattlePlayerUpdate(msg);
		}

		private function rest(event : Event) : void
		{
			var msg : SCGroupBattlePlayerUpdate = new SCGroupBattlePlayerUpdate();
			msg.playerId = UserData.instance.playerId;
			msg.playerSatus = GBPlayerStatus.REST;
			gbProto.sc_GroupBattlePlayerUpdate(msg);
		}

		public function show() : void
		{
			onStageResize();
			ViewManager.addStageResizeCallFun(onStageResize);
			ViewManager.instance.uiContainer.addChild(this);
			TweenLite.to(this, 2, {alpha:1});
			exitButton.setVisible(true, cs_quit);
		}

		public function hide() : void
		{
			exitButton.setVisible(false, null);
			ViewManager.removeStageResizeCallFun(onStageResize);
			if (parent) parent.removeChild(this);
			alpha = 0;
		}
	}
}
