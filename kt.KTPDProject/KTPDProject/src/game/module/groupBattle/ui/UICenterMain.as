package game.module.groupBattle.ui
{
	import com.utils.FilterUtils;
	import com.utils.UrlUtils;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.definition.UI;
	import game.module.groupBattle.GBConfig;
	import gameui.controls.GImage;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-9
	 */
	public class UICenterMain extends GComponent
	{
		public  const TEXT_SCORE : String = "积分：__NUM__";
		public  const TEXT_FIRST_PLAYER : String = "<font color='__COLOR__'>__PLAYER_NAME__</font>   <font color='#FFFF00'>__MAX_KILL_COUNT__连杀</font>";
		// 背景
		private var bridgeBg : Sprite;
		private var groupIconBgLeft : Sprite;
		private var groupIconBgRight : Sprite;
		private var textureBg : Sprite;
		private var overTimeBg : Sprite;
		/** 游戏结束时间 */
		public var overTimer : UiOverTimer;
		/** 组A积分Label */
		private var scoreTFA : TextField;
		/** 组B积分Label */
		private var scoreTFB : TextField;
		/** 组A图标 */
		private var iconA : GImage;
		/** 组B图标 */
		private var iconB : GImage;
		/** 第一名玩家名称 */
		private var firstPalyerTF : TextField;

		public function UICenterMain(width : Number = 580)
		{
			_base = new GComponentData();
			_base.width = width;
			_base.height = 87;
			_base.minWidth = 545;
			_base.maxHeight = 900;
			super(_base);
			initViews();
			initLayout();
			// 临时
			// test();
		}

		public function test() : void
		{
			overTimer.time = 755;
			setScore(454, 0);
			setScore(946, 1);
			setIconA(0);
			setIconB(1);
			setFirstPlayer("大海明月", GBConfig.GROUP_COLOR_STR_B, 86);
		}

		private var groupIconBgRadius : int = 45;

		public function updateLayout() : void
		{
			_base.width = width;
			bridgeBg.width = _base.width - groupIconBgRadius * 2;
			bridgeBg.x = groupIconBgRadius;

			textureBg.x = _base.width / 2;

			overTimeBg.x = textureBg.x;

			groupIconBgRight.x = _base.width - groupIconBgRadius;

			overTimer.x = overTimeBg.x - overTimer.width / 2;

			scoreTFB.x = groupIconBgRight.x - groupIconBgRadius - 60 - scoreTFB.width;
			iconALayout();
			iconBLayout();

			firstPalyerTF.x = ( _base.width - firstPalyerTF.width) >> 1;
		}

		public function initLayout() : void
		{
			bridgeBg.width = _base.width - groupIconBgRadius * 2;
			bridgeBg.x = groupIconBgRadius;
			bridgeBg.y = groupIconBgRadius - bridgeBg.height / 2;

			textureBg.x = _base.width / 2;
			textureBg.y = bridgeBg.y + bridgeBg.height / 2;

			overTimeBg.x = textureBg.x;
			overTimeBg.y = textureBg.y ;

			groupIconBgLeft.x = groupIconBgRadius;
			groupIconBgLeft.y = groupIconBgRadius;

			groupIconBgRight.x = _base.width - groupIconBgRadius;
			groupIconBgRight.y = groupIconBgRadius;

			overTimer.x = overTimeBg.x - overTimer.width / 2;
			overTimer.y = bridgeBg.y + (bridgeBg.height - overTimer.height ) / 2 + 2;

			scoreTFA.x = groupIconBgLeft.x + groupIconBgRadius + 60;
			scoreTFA.y = bridgeBg.y + (bridgeBg.height - scoreTFA.height ) / 2;

			scoreTFB.x = groupIconBgRight.x - groupIconBgRadius - 60 - scoreTFB.width;
			scoreTFB.y = scoreTFA.y ;

			// iconALayout();
			// iconBLayout();

			firstPalyerTF.x = ( _base.width - firstPalyerTF.width) >> 1;
			firstPalyerTF.y = 68;
		}

		public function initViews() : void
		{
			// 背景
			bridgeBg = UIManager.getUI(new AssetData("GroupBattleCenterMain_BridgeBg"));
			addChild(bridgeBg);
			//
			textureBg = UIManager.getUI(new AssetData("GroupBattleCenterMain_TextureBg"));
			addChild(textureBg);
			//
			overTimeBg = UIManager.getUI(new AssetData("GroupBattleCenterMain_GroupOverTimeBg"));
			addChild(overTimeBg);
			//
			groupIconBgLeft = UIManager.getUI(new AssetData(UI.HEAD_ICON_BACKGROUND));
			addChild(groupIconBgLeft);
			groupIconBgRight = UIManager.getUI(new AssetData(UI.HEAD_ICON_BACKGROUND));
			addChild(groupIconBgRight);

			// 游戏结束时间
			overTimer = new UiOverTimer();
			overTimer.x = (_base.width - overTimer.width) / 2;
			overTimer.y = 31;
			addChild(overTimer);

			// 组A积分Label
			var textFormat : TextFormat;
			var tempTF : TextField;
			textFormat = new TextFormat();
			textFormat.size = 14;
			textFormat.bold = true;
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.color = GBConfig.GROUP_COLOR_A;
			tempTF = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.filters = [FilterUtils.defaultTextEdgeFilter];
			tempTF.width = 150;
			tempTF.height = 20;
			tempTF.x = 90;
			tempTF.y = 32;
			tempTF.text = "积分：0";
			addChild(tempTF);
			scoreTFA = tempTF;
			// 组B积分Label
			textFormat.align = TextFormatAlign.RIGHT;
			textFormat.color = GBConfig.GROUP_COLOR_B;
			tempTF = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.filters = [FilterUtils.defaultTextEdgeFilter];
			tempTF.width = 150;
			tempTF.height = 20;
			tempTF.x = 297;
			tempTF.y = 32;
			tempTF.text = "积分：0";
			addChild(tempTF);
			scoreTFB = tempTF;

			// 组A图标
			var imageData : GImageData;
			var image : GImage;
			imageData = new GImageData();
			imageData.x = 0;
			imageData.y = -4;
			imageData.width = 109;
			imageData.height = 91;
			image = new GImage(imageData);
			addChild(image);
			iconA = image;
			// 组B图标
			imageData = new GImageData();
//			imageData.x = 428;
//			imageData.y = -4;
//			imageData.width = 109;
//			imageData.height = 91;
			image = new GImage(imageData);
			addChild(image);
			iconB = image;

			// 第一名玩家名称
			textFormat = new TextFormat();
			textFormat.size = 16;
			// textFormat.bold = true;
			textFormat.align = TextFormatAlign.CENTER;
			firstPalyerTF = new TextField();
			firstPalyerTF.selectable = false;
			firstPalyerTF.defaultTextFormat = textFormat;
			firstPalyerTF.filters = [FilterUtils.defaultTextEdgeFilter];
			firstPalyerTF.width = 326;
			firstPalyerTF.height = 30;
			firstPalyerTF.x = (_base.width - firstPalyerTF.width ) >> 1;
			firstPalyerTF.y = 68;
			addChild(firstPalyerTF);
			firstPalyerTF.visible = false;
		}

		// =================
		// 第一名玩家
		// =================
		public function setFirstPlayer(name : String, colorStr : String, maxKillCount : int) : void
		{
			// var colorStr:String = groupId % 2 == 0 ? GBConfig.GROUP_COLOR_STR_A : GBConfig.GROUP_COLOR_STR_B;
			var str : String = TEXT_FIRST_PLAYER.replace(/__COLOR__/, colorStr);
			str = str.replace(/__PLAYER_NAME__/, name);
			str = str.replace(/__MAX_KILL_COUNT__/, maxKillCount);
			firstPalyerTF.htmlText = str;
			firstPalyerTF.visible = name != null && name != "";
		}

		// =================
		// 积分
		// =================
		public function setScore(value : int, groupId : int) : void
		{
			var str : String = TEXT_SCORE.replace(/__NUM__/, value);
			if (groupId % 2 == 0)
			{
				scoreTFA.text = str;
			}
			else
			{
				scoreTFB.text = str;
			}
		}

		// =================
		// 组图标
		// =================
		private var iconAGroupId : int = 0;
		private var iconBGroupId : int = 1;

		public function setIconA(groupId : int) : void
		{
			iconAGroupId = groupId;
			var url : String = UrlUtils.getGroupBattleGroupIcon(groupId);
			iconA.url = url;
			iconALayout();
		}

		public function setIconB(groupId : int) : void
		{
			iconBGroupId = groupId;
			var url : String = UrlUtils.getGroupBattleGroupIcon(groupId);
			iconB.url = url;
			iconBLayout();
		}

		private function iconALayout() : void
		{
			if (iconAGroupId == 0)
			{
				iconA.width = 147;
				iconA.height = 184;
				iconA.x  = groupIconBgLeft.x  - 60;
				iconA.y = groupIconBgLeft.y - 140;
			}
			else
			{
				iconA.width = 212;
				iconA.height = 184;
				iconA.x  = groupIconBgLeft.x  - 55;
				iconA.y = groupIconBgLeft.y - 139;
			}
		}

		private function iconBLayout() : void
		{
			if (iconBGroupId == 1)
			{
				iconB.width = 147;
				iconB.height = 184;
				iconB.x  = groupIconBgRight.x  - 78;
				iconB.y = groupIconBgRight.y - 139;
			}
			else
			{
				iconB.width = 147;
				iconB.height = 184;
				iconB.x  = groupIconBgRight.x  - 80;
				iconB.y = groupIconBgRight.y - 137;
			}
		}
	}
}
