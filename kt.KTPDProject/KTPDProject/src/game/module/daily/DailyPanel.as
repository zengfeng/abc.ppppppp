package game.module.daily
{
	import com.commUI.GCommonWindow;
	import com.utils.UICreateUtils;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import game.definition.UI;
	import game.manager.ViewManager;
	import gameui.containers.GPanel;
	import gameui.containers.GTabbedPanel;
	import gameui.data.GPanelData;
	import gameui.data.GTabbedPanelData;
	import gameui.data.GTitleWindowData;
	import gameui.manager.UIManager;
	import net.AssetData;
	import net.RESManager;





	/**
	 * @author yangyiqiang
	 */
	public class DailyPanel extends GCommonWindow
	{
		private var _tabbedPanel : GTabbedPanel;

		private var _dailyActionPanel : GPanel;

		private var _dungeonPanel : GPanel;

		private var _specialPanel : GPanel;

		public function DailyPanel()
		{
			_data = new GTitleWindowData();
			_data.width = 550;
			_data.height = 385;
			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;
			super(_data);
		}

		private var _array : Array;

		override protected function initViews() : void
		{
			title = "日常";
			super.initViews();
			var panelData : GPanelData = new GPanelData();
			panelData.bgAsset = new AssetData(UI.PANEL_BACKGROUND);
			panelData.x = 6;
			panelData.y = 0;
			panelData.width = 535;
			panelData.height = 350;
			panelData.horizontalScrollPolicy=GPanelData.OFF;

			_dailyActionPanel = new GPanel(panelData.clone());
			_dungeonPanel = new GPanel(panelData.clone());
//			panelData.verticalScrollPolicy=GPanelData.ON;
			_specialPanel = new GPanel(panelData);

			_array = [_dailyActionPanel, _dungeonPanel, _specialPanel];

			var data : GTabbedPanelData = new GTabbedPanelData();
			data.tabData.padding = 2;
			data.tabData.gap = 1;
			data.tabData.x = 6;
			data.viewStackData.width = 535;
			data.viewStackData.height = 355;

			_tabbedPanel = new GTabbedPanel(data);
			_tabbedPanel.addTab("每日活动", _dailyActionPanel);

			_tabbedPanel.addTab("  副本   ", _dungeonPanel);

			_tabbedPanel.addTab("特定活动", _specialPanel);

			_tabbedPanel.group.selectionModel.index = 0;
			initDaily();
			initCopy();
			initAction();
			this.contentPanel.add(_tabbedPanel);
		}

		/** 切页 */
		private function tab_changeHandler(event : Event) : void
		{
		}

		private var _copyText : TextField;

		private function initCopy() : void
		{
			var item : CopyItem;
			var arr : Vector.<VoCopy>=DailyManage.getInstance().getVos(1);
			for (var i : int = 0;i < arr.length;i++)
			{
				item = new CopyItem(arr[i], i);
				item.x = 1;
				item.y = i * 106 + 35;
				_dungeonPanel.add(item);
			}
			_copyText = UICreateUtils.createTextField("今日免费进入次数1212次", null, 209, 20, 10, 10, UIManager.getTextFormat());
			var mc2 : MovieClip = RESManager.getMC(new AssetData("topGoldLine"));
			mc2.x = 5;
			mc2.y = 33;
			_dungeonPanel.add(mc2);
			var mc3 : MovieClip = RESManager.getMC(new AssetData("topGoldLine"));
			mc3.x = 5;
			mc3.y = 343;
			_dungeonPanel.add(mc3);
			_dungeonPanel.add(_copyText);
		}

		private function initDaily() : void
		{
			var item : DailyItem;
			var arr : Vector.<VoDaily>=DailyManage.getInstance().getVos();
			for (var i : int = 0;i < arr.length;i++)
			{
				item = new DailyItem(arr[i], i);
				item.x = 1;
				item.y = i * 70 + 1;
				_dailyActionPanel.add(item);
			}
		}

		private function initAction() : void
		{
			var item : ActionItem;
			var _back : Sprite = UIManager.getUI(new AssetData("common_background_03"));
			_back.x = 5;
			_back.y = 135;
			_back.width = 525;
			_back.height = 210;
			_specialPanel.add(_back);
			var num : int = 0;
			var arr : Vector.<VoAction>=DailyManage.getInstance().getVos(2);
			for (var i : int = 0;i < arr.length;i++)
			{
				item = new ActionItem(arr[i]);
				if (arr[i].isToday)
				{
					item.x = 5;
					item.y = 10;
				}
				else
				{
					item.x = (num % 3) * 171 + 12;
					item.y = num < 3 ? 138 : 240;
					num++;
				}
				_specialPanel.add(item);
			}
			var mc3 : MovieClip = RESManager.getMC(new AssetData("topGoldLine"));
			mc3.x = 5;
			mc3.y = 343;
			_dungeonPanel.add(mc3);
		}

		override protected function onShow() : void
		{
			super.onShow();
			_tabbedPanel.group.selectionModel.addEventListener(Event.CHANGE, tab_changeHandler);
		}

		override protected function onHide() : void
		{
			super.onHide();
			_tabbedPanel.group.selectionModel.removeEventListener(Event.CHANGE, tab_changeHandler);
		}
	}
}
