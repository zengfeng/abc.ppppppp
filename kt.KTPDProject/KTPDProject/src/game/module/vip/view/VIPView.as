package game.module.vip.view
{
	import com.commUI.GCommonSmallWindow;
	import com.commUI.button.KTButtonData;
	import com.utils.StringUtils;
	import com.utils.UICreateUtils;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.manager.ViewManager;
	import game.module.vip.VIPItemVO;
	import game.module.vip.config.VIPConfig;
	import game.module.vip.config.VIPConfigManager;
	import game.net.core.Common;
	import game.net.data.StoC.SCPlayerInfoChange;
	import gameui.controls.GButton;
	import gameui.controls.GList;
	import gameui.controls.GProgressBar;
	import gameui.data.GListData;
	import gameui.data.GPanelData;
	import gameui.data.GProgressBarData;
	import gameui.data.GTitleWindowData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;






	/**
	 * @author ME
	 */
	public class VIPView extends GCommonSmallWindow
	{
		// ======================================================
		// 属性
		// ======================================================
		private var _progressBar : GProgressBar;
		private var _vipList : GList;
		private var _nowVipLevelText : TextField;
		private var _nextVipLevelText : TextField;
		private var _vipInfoLevelText : TextField;
		private var _vipInfoLevelUpText : TextField;
		private var _button : GButton;
		private var _currVIPConfig : Array = [];
		private var _nextVIPConfig : Array = [];
		private var _hyperlink : TextField;
		private var _maxVipLevel : int;

		// ======================================================
		// 方法
		// ======================================================
		// --------------------------------------------
		// 创建
		// --------------------------------------------
		public function VIPView()
		{
			var data : GTitleWindowData = new GTitleWindowData();
			data.width = 445;
			data.height = 435;
			data.allowDrag = true;
			data.parent = ViewManager.instance.uiContainer;
			super(data);
		}

		override protected function create() : void
		{
			super.create();
			title = "vip充值";
			_maxVipLevel = VIPConfigManager.instance.getMaxVipLevel();

			addVipViewBg();
			addVipListTitleBg();
			addVipIcon();
			addVipInfoText();
			addVipProgressBar();
			addRechargeButton();
			addVipListTitle();
			addVipListText();
			addHyperlinkText();
		}

		private function addVipViewBg() : void
		{
			var viewBg : Sprite = UIManager.getUI(new AssetData(UI.VIP_BG));
			viewBg.x = 5;
			viewBg.y = 0;
			viewBg.width = 435;
			viewBg.height = 430;
			addChild(viewBg);
		}

		private function addVipListTitleBg() : void
		{
			var listTitleBg : Sprite = UIManager.getUI(new AssetData(UI.VIP_LIST_TITLE_BG));
			listTitleBg.x = 12.5;
			listTitleBg.y = 75;
			listTitleBg.width = 420;
			listTitleBg.height = 24;
			addChild(listTitleBg);

			var listBg : Sprite = UIManager.getUI(new AssetData(UI.VIP_LIST_BG));
			listBg.x = 12;
			listBg.y = 100;
			listBg.width = 420 - 10;
			listBg.height = 301;
			addChild(listBg);
		}

		private function addVipIcon() : void
		{
			var vipIcon : Sprite = UIManager.getUI(new AssetData(UI.VIP_ICON));
			vipIcon.x = -4;
			vipIcon.y = 4;
			vipIcon.width = 151;
			vipIcon.height = 72;
			addChild(vipIcon);
		}

		private function addVipInfoText() : void
		{
			_vipInfoLevelText = UICreateUtils.createTextField(null, "", 100, 20, 131, 12, UIManager.getTextFormat(12, 0x2f1f00, TextFormatAlign.LEFT));
			addChild(_vipInfoLevelText);

			_vipInfoLevelUpText = UICreateUtils.createTextField(null, "", 200, 20, 131, 30, UIManager.getTextFormat(12, 0x2f1f00, TextFormatAlign.LEFT));
			addChild(_vipInfoLevelUpText);
		}

		private function addVipProgressBar() : void
		{
			var data : GProgressBarData = new GProgressBarData();
			data.x = 130;
			data.y = 50;
			data.width = 296;
			data.height = 14;
			data.padding = 4;
			data.paddingY = 4;
			data.paddingX = 4;
			data.trackAsset = new AssetData(UI.VIP_PROGRESSBAR_TRACKSKIN);
			data.barAsset = new AssetData(UI.VIP_PROGRESSBAR_BARSKIN);
			_progressBar = new GProgressBar(data);
			addChild(_progressBar);
		}

		private function addRechargeButton() : void
		{
			_button = UICreateUtils.createGButton("充值", 80, 30, 347, 12, KTButtonData.NORMAL_RED_BUTTON);
			addChild(_button);
		}

		private function addVipListTitle() : void
		{
			var vipPrivilegeText : TextField = UICreateUtils.createTextField("VIP特权", null, 130, 20, 10, 79, UIManager.getTextFormat(12, 0xffffff, TextFormatAlign.CENTER));
			addChild(vipPrivilegeText);

			_nowVipLevelText = UICreateUtils.createTextField("", null, 50, 20, 216, 79, UIManager.getTextFormat(12, 0xffffff, TextFormatAlign.CENTER));
			addChild(_nowVipLevelText);

			_nextVipLevelText = UICreateUtils.createTextField("", null, 50, 20, 364, 79, UIManager.getTextFormat(12, 0xffffff, TextFormatAlign.CENTER));
			addChild(_nextVipLevelText);
		}

		private function addVipListText() : void
		{
			var data : GListData = new GListData();
			data.padding = 0;
			data.x = 12;
			data.y = 100;
			data.width = 420;
			data.height = 300;
			data.hGap = 0;
			// data.rows = VIPConfigManager.instance.getNItems();
			data.rows = 0;
			data.bgAsset = new AssetData(SkinStyle.emptySkin);
			data.verticalScrollPolicy = GPanelData.ON;
			data.cell = VIPListCell;
			data.cellData.width = 420;
			data.cellData.height = 25;
			_vipList = new GList(data);
			addChild(_vipList);
		}

		private function addHyperlinkText() : void
		{
			_hyperlink = UICreateUtils.createTextField(null, "", 150, 20, 305, 405);
			_hyperlink.textColor = 0xff6633;
			_hyperlink.htmlText = "<u>点击查看更多VIP功能</u>";
			_hyperlink.mouseEnabled = true;
			addChild(_hyperlink);
		}

		// ------------------------------------------------
		// 更新
		// ------------------------------------------------
		private function updateVIP() : void
		{
			_currVIPConfig = VIPConfigManager.instance.getConfigItems(UserData.instance.vipLevel);
			_nextVIPConfig = VIPConfigManager.instance.getConfigItems(UserData.instance.vipLevel + 1);
		}

		private function updateVipInfoText() : void
		{
			if (UserData.instance.vipLevel < _maxVipLevel)
			{
				_vipInfoLevelText.htmlText = StringUtils.addColor("VIP等级:", "#2f1f00") + StringUtils.addColor(String(UserData.instance.vipLevel), "#ff3300");
				_vipInfoLevelUpText.htmlText = StringUtils.addColor("再充", "#2f1f00") + StringUtils.addColor(String(_nextVIPConfig[0].gold - UserData.instance.totalTopup), "#ff3300") + StringUtils.addColor("元宝  将成为VIP", "#2f1f00") + StringUtils.addColor(String(UserData.instance.vipLevel + 1), "#ff3300");
			}
			else
			{
				_vipInfoLevelText.htmlText = StringUtils.addColor("VIP等级:", "#2f1f00") + StringUtils.addColor(String(UserData.instance.vipLevel), "#ff3300");
				_vipInfoLevelUpText.visible = false;
			}
		}

		private function updateVipProgressBar() : void
		{
			if (UserData.instance.vipLevel < _maxVipLevel)
			{
				_progressBar.value = UserData.instance.totalTopup / _nextVIPConfig[0].gold * 100;
				_progressBar.text = String(UserData.instance.totalTopup) + "/" + String(_nextVIPConfig[0].gold);
			}
			else
			{
				_progressBar.value = UserData.instance.totalTopup / _currVIPConfig[0].gold * 100;
				_progressBar.text = String(UserData.instance.totalTopup) + "/" + String(_currVIPConfig[0].gold);
			}
		}

		private function updateVipListTitle() : void
		{
			if (UserData.instance.vipLevel == 0)
			{
				_nowVipLevelText.text = "普通";
				_nextVipLevelText.text = "VIP" + String(UserData.instance.vipLevel + 1) + "级";
			}
			else
			{
				if (UserData.instance.vipLevel < _maxVipLevel)
				{
					_nowVipLevelText.text = "VIP" + String(UserData.instance.vipLevel) + "级";
					_nextVipLevelText.text = "VIP" + String(UserData.instance.vipLevel + 1) + "级";
				}
				else
				{
					_nowVipLevelText.text = "VIP" + String(UserData.instance.vipLevel) + "级";
					_nextVipLevelText.visible = false;
				}
			}
		}

		private function updateVipListText() : void
		{
			var cellItems : Array = [];
			var bg : int = 0;
			var vo : VIPItemVO ;
			var i : int;
			if (UserData.instance.vipLevel < _maxVipLevel)
			{
				for ( i = 0; i < _nextVIPConfig.length; i++)
				{
					if (_nextVIPConfig[i].open == true)
					{
						vo = new VIPItemVO();

						vo.name = _nextVIPConfig[i].name;
						vo.currState = (_currVIPConfig[i] as VIPConfig).timesString;
						vo.nextState = (_nextVIPConfig[i] as VIPConfig).timesString;

						// 判断特权是否有变化，有变化才给下一级特权开启情况文字赋上指定红色颜色，否则为默认棕色
						if (vo.currState != vo.nextState)
							vo.nextLevelColor = (_nextVIPConfig[i] as VIPConfig).nextLevelChangeTextColor;
						else
							vo.nextLevelColor = 0x2f1f00;

						vo.bgInt = bg % 2;
						cellItems.push(vo);
						bg++;
					}
				}
			}
			else
			{
				for (var j : int = 0; j < _currVIPConfig.length; j++)
				{
					if (_currVIPConfig[j].open == true)
					{
						var _vo : VIPItemVO = new VIPItemVO();

						_vo.name = _currVIPConfig[j].name;
						_vo.currState = (_currVIPConfig[j] as VIPConfig).timesString;
						_vo.nextState = "";

						_vo.bgInt = bg % 2;
						cellItems.push(_vo);
						bg++;
					}
				}
			}

			_vipList.model.source = cellItems;
		}

		// ------------------------------------------------
		// 交互
		// ------------------------------------------------
		override public function show() : void
		{
			super.show();
			updateVIP();
			updateVipInfoText();
			updateVipProgressBar();
			updateVipListTitle();
			updateVipListText();

			Common.game_server.addCallback(0x11, playerInfoChange);
			_button.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			_hyperlink.addEventListener(MouseEvent.ROLL_OVER, hyperlinkRollOverHandler);
			_hyperlink.addEventListener(MouseEvent.CLICK, hyperlinkClickHandler);
			_hyperlink.addEventListener(MouseEvent.ROLL_OUT, hyperlinkRollOutHandler);
		}

		override public function hide() : void
		{
			Common.game_server.removeCallback(0x11, playerInfoChange);
			_button.removeEventListener(MouseEvent.CLICK, buttonClickHandler);
			_hyperlink.removeEventListener(MouseEvent.ROLL_OVER, hyperlinkRollOverHandler);
			_hyperlink.removeEventListener(MouseEvent.CLICK, hyperlinkClickHandler);
			_hyperlink.removeEventListener(MouseEvent.ROLL_OUT, hyperlinkRollOutHandler);
			super.hide();
		}

		private function playerInfoChange(e : SCPlayerInfoChange) : void
		{
			updateVIP();
			updateVipInfoText();
			updateVipProgressBar();
			updateVipListTitle();
			updateVipListText();
		}

		private function buttonClickHandler(event : MouseEvent) : void
		{
			var url : URLRequest = new URLRequest("http://www.xd.com/orders/create/");
			navigateToURL(url, "_blank");
		}

		private function hyperlinkRollOverHandler(event : MouseEvent) : void
		{
			_hyperlink.textColor = 0xff924f;
		}

		private function hyperlinkClickHandler(event : MouseEvent) : void
		{
			_hyperlink.textColor = 0xd04f24;
			var url : URLRequest = new URLRequest("http://www.xd.com/orders/create/");
			navigateToURL(url, "_blank");
		}

		private function hyperlinkRollOutHandler(event : MouseEvent) : void
		{
			_hyperlink.textColor = 0xff6633;
		}
	}
}
