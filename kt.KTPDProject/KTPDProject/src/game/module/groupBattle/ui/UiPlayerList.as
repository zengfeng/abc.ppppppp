package game.module.groupBattle.ui
{
	import com.commUI.toggleButton.KTToggleButtonData;
	import com.utils.FilterUtils;
	import com.utils.StringUtils;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.module.groupBattle.GBConfig;
	import game.module.groupBattle.GBGroup;
	import game.module.groupBattle.GBPlayer;
	import game.module.groupBattle.GBPlayerStatus;
	import game.module.map.animalstruct.PlayerStruct;
	import gameui.controls.GScrollBar;
	import gameui.controls.GToggleButton;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GScrollBarData;
	import gameui.data.GToggleButtonData;
	import gameui.events.GScrollBarEvent;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-16 ����7:24:56
	 */
	public class UiPlayerList extends GComponent
	{
		/** 背景 */
		private var bg : Sprite;
		/** 背景2 */
		private var bg2 : Sprite;
		/** 阵营名称 */
		private var groupNameTF : TextField;
		/** 等级限制 */
		private var levelLimitTF : TextField;
		/** 人数 */
		private var playerCountTF : TextField;
		/** 容器 */
		private var container : Sprite;
		/** 容器显示区域 */
		private var csr : Rectangle;
		/** 滚动条 */
		private var scrollBar : GScrollBar;
		/** 头高 */
		public var headHeight : uint = 47;
		/** 容器高 */
		public var containerHeight : uint = 198;
		public var itemHeight : int = 20;
		/** 副阵营 */
		public var cGroup : UiGroup;
		/** 最小化还原按钮 */
		public var minRestoreButton : GToggleButton;
		/** 阵营图标 */
		public var groupIcon : Sprite;
		/** 阵营小图标 */
		public var groupSmallIcon : Sprite;

		function UiPlayerList(width : uint, height : uint) : void
		{
			_base = new GComponentData();
			_base.width = width;
			_base.height = height;
			super(_base);
			// 初始化元件
			initViews();

//			test();
		}

		public function test() : void
		{
			var group : GBGroup = new GBGroup();
			var list : Vector.<GBPlayer> = new Vector.<GBPlayer>();
			for (var i : int = 0; i < 100; i++)
			{
				var playerStruct : PlayerStruct = new PlayerStruct();
				playerStruct.id = i;
				playerStruct.name = "玩家" + i;
				var gbPlayer : GBPlayer = new GBPlayer(playerStruct);
				gbPlayer.group = group;
				gbPlayer.maxKillCount = Math.ceil(Math.random() * 500);
				gbPlayer.playerStatus = Math.ceil(Math.random() * 4);
				list.push(gbPlayer);
			}
			addPlayerList(list);
		}
		
		/** 初始化元件 */
		protected function initViews() : void
		{
			// 背景
			bg = UIManager.getUI(new AssetData("common_background_14"));
			bg.y = 12;
			bg.width = _base.width;
			bg.height = _base.height - bg.y;
			bg.filters = [new DropShadowFilter(5, 45, 0x000000, 1, 8, 8, 0.8, 1, false, false)];
//			addChild(bg);

			bg2 = UIManager.getUI(new AssetData("common_background_13"));
			bg2.x = 5;
			bg2.y = headHeight  - 4;
			bg2.width = _base.width - bg2.x * 2;
			bg2.height = _base.height - bg2.y - 5;
//			addChild(bg2);

			var textFormat : TextFormat ;
			var tempTF : TextField ;
			// 等级限制
			textFormat = new TextFormat();
			textFormat.size = 12;
			textFormat.color = 0xFFFF00;
			textFormat.align = TextFormatAlign.RIGHT;
			tempTF = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.filters = [FilterUtils.defaultTextEdgeFilter];
			tempTF.width = 98;
			tempTF.height = 25;
			tempTF.x = 0;
			tempTF.y = 22;
			tempTF.text = "(20-60级)";
//			addChild(tempTF);
			levelLimitTF = tempTF;

			// 人数
			textFormat.align = TextFormatAlign.LEFT;
			tempTF = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.filters = [FilterUtils.defaultTextEdgeFilter];
			tempTF.width = 65;
			tempTF.height = 25;
			tempTF.x = 105;
			tempTF.y =22;
			tempTF.text = "200人";
//			addChild(tempTF);
			playerCountTF = tempTF;

			// 容器
			container = new Sprite();
			// container.graphics.beginFill(0xFF0000, 0.5);
			// container.graphics.drawRect(0, 0, 168, containerHeight);
			// container.graphics.endFill();
			container.x = 7;
			container.y = headHeight + 15;
//			addChild(container);
			// 容器显示区域
			csr = new Rectangle(0, 0, 168, containerHeight);
			container.scrollRect = csr;
			container.addEventListener(MouseEvent.MOUSE_WHEEL, container_onMouseWheel);
			// 滚动条
			var scrollBarData : GScrollBarData = new GScrollBarData();
			scrollBarData.height = containerHeight;
			scrollBarData.x = _base.width - scrollBarData.width - 9;
			scrollBarData.y = container.y;
			scrollBar = new GScrollBar(scrollBarData);
			scrollBar.resetValue(containerHeight, 0, 0, 0);
			scrollBar.visible = false;
//			addChild(scrollBar);
			scrollBar.addEventListener(GScrollBarEvent.SCROLL, scrollHandler);

			// 副阵营
			cGroup = new UiGroup(_base.width, 20);
			cGroup.x = 0;
			cGroup.y = _base.height - cGroup.height - 4;
//			if (GBSystem.hasHighlevel == true) addChild(cGroup);

			// 最小化还原按钮
			var toggleButtonData : GToggleButtonData;
			var toggleButton : GToggleButton;
			toggleButtonData = new KTToggleButtonData(KTToggleButtonData.SWITCH_TOGGLE_BUTTON);
			toggleButtonData.disabledAsset = toggleButtonData.upAsset;
			toggleButtonData.selectedDisabledAsset = toggleButtonData.selectedUpAsset;
			toggleButtonData.width = 70;
			toggleButtonData.x = 50;
			toggleButtonData.y = 2;
			this.toggleButtonData =toggleButtonData ;
			toggleButton = new GToggleButton(toggleButtonData);
			toggleButton.htmlText = "朱雀组";
//			toggleButton.enabled = false;
			addChild(toggleButton);
			minRestoreButton = toggleButton;
			// 阵营名称背景
//			var groupNameBg : Sprite = UIManager.getUI(new AssetData("textBackground_1"));
//			groupNameBg.mouseEnabled = true;
//			groupNameBg.width = 90;
//			groupNameBg.x = (_base.width - groupNameBg.width) >> 1;
//			addChild(groupNameBg);
			// 阵营名称
			textFormat = new TextFormat();
			textFormat.size = 12;
			textFormat.bold = true;
			textFormat.color = GBConfig.GROUP_COLOR_A;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.font = UIManager.defaultFont;
			tempTF = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.filters = [FilterUtils.defaultTextEdgeFilter];
			tempTF.width = 45;
			tempTF.height = 30;
			tempTF.x = ( _base.width - tempTF.width) >> 1;
			tempTF.y = 3;
			tempTF.text = "朱雀组";
//			addChild(tempTF);
			groupNameTF = tempTF;

			minRestoreButton.addEventListener(MouseEvent.MOUSE_UP, minRestoreButton_clickHandler, false, -10);
//			groupNameBg.addEventListener(MouseEvent.MOUSE_UP, setMinRestoreButton);
//			groupNameTF.addEventListener(MouseEvent.MOUSE_UP, setMinRestoreButton);
		}
		private 	var toggleButtonData : GToggleButtonData;

		private function setMinRestoreButton(event : MouseEvent = null) : void
		{
			minRestoreButton.selected = !minRestoreButton.selected;
			minRestoreButton_clickHandler();
		}

		/** 最小化还原按钮 点击事件 */
		private function minRestoreButton_clickHandler(event : MouseEvent = null) : void
		{
			if (minRestoreButton.selected == false)
			{
				if (bg.parent != null) removeChild(bg);
				if (bg2.parent != null) removeChild(bg2);
				if (levelLimitTF.parent != null) removeChild(levelLimitTF);
				if (playerCountTF.parent != null) removeChild(playerCountTF);
				if (container.parent != null) removeChild(container);
				if (scrollBar.parent != null) removeChild(scrollBar);
				if (cGroup.parent != null) removeChild(cGroup);
//				if (groupIcon && groupIcon.parent != null) removeChild(groupIcon);
			}
			else
			{
				if (bg.parent == null) addChildAt(bg, 0);
				if (bg2.parent == null) addChildAt(bg2, 1);
				if (levelLimitTF.parent == null) addChild(levelLimitTF);
				if (playerCountTF.parent == null) addChild(playerCountTF);
				if (groupIcon && groupIcon.parent == null) addChild(groupIcon);
				if (container.parent == null) addChild(container);
				if (scrollBar.parent == null) addChild(scrollBar);
//				if (cGroup.parent == null && GBSystem.hasHighlevel == true) addChild(cGroup);
			}
		}
		

		private function container_onMouseWheel(event : MouseEvent) : void
		{
			var contentHeight : int = container.numChildren * itemHeight;
			var value:int = scrollBar.value;
			value += event.delta > 0 ? -itemHeight : itemHeight;
			if(value <= 0) 
			{
				value = 0;
			}
			else if(value >= contentHeight - containerHeight)
			{
				value =  contentHeight - containerHeight;
			}
			
			if(container.numChildren <= 10)
			{
				value = 0;
			}
			scrollBar.resetValue(containerHeight, 0, contentHeight - containerHeight, value);
		}

		private function scrollHandler(event : GScrollBarEvent) : void
		{
			csr.y = event.position;
			container.scrollRect = csr;
		}

		/** 设置阵营名称 */
		public function setGroupName(name : String, colorStr : String, minLevel : int, maxLevel : int) : void
		{
			var str : String = "<font color='" + colorStr + "' size='12'><b>" + name + "</b></font>";
			minRestoreButton.htmlText = str;
			toggleButtonData.labelData.textColor =StringUtils.StringToColor(colorStr);
			toggleButtonData.textRollOverColor = toggleButtonData.labelData.textColor;
			str = "";
			if (maxLevel < 0)
			{
				str += "(" + minLevel + "级以上)";
			}
			else
			{
				str += "(" + minLevel + "-" + maxLevel + "级)";
			}
			levelLimitTF.text = str;
		}

		/** 玩家数量 */
		public function setPlayerCount(value : int) : void
		{
			playerCountTF.text = value + "人";
		}

		/** 设置阵营图标 */
		public function setGroupIcon(groupId : int) : void
		{
			return;
			if (groupIcon && groupIcon.parent)
			{
				groupIcon.parent.removeChild(groupIcon);
			}

			groupIcon = UIManager.getUI(new AssetData("GroupBattle_GroupIcon_" + groupId));
			if (groupIcon)
			{
				groupIcon.x = _base.width - groupIcon.width;
				groupIcon.y = _base.height - groupIcon.height - 30;

				if (minRestoreButton.selected == false)
				{
					addChildAt(groupIcon, 1);
				}
			}
			groupSmallIcon = UIManager.getUI(new AssetData("GroupBattle_GroupSmalIcon_" + groupId));
			if (groupSmallIcon)
			{
				groupSmallIcon.x = 5;
				groupSmallIcon.y = 5;

				addChild(groupSmallIcon);
			}
		}

		private function getPlayerItemName(playerId : int) : String
		{
			return "player_" + playerId;
		}

		/** 添加玩家 */
		public function addPlayerItem(playerItem : UiPlayerItem) : void
		{
			if (playerItem == null) return;
			playerItem.x = 0;
			playerItem.y = container.numChildren * itemHeight;
			container.addChild(playerItem);
			updateScrollBarValue();
		}

		/** 添加玩家数据 */
		public function addPlayerData(gbPlayer : GBPlayer) : void
		{
			if (gbPlayer == null) return;
			var uiPlayerItem : UiPlayerItem = new UiPlayerItem(gbPlayer.id, gbPlayer.playerName, gbPlayer.colorStr, gbPlayer.playerStatus);
			uiPlayerItem.maxKill = gbPlayer.maxKillCount;
			uiPlayerItem.name = getPlayerItemName(gbPlayer.id);
			gbPlayer.playerItem = uiPlayerItem;

			addPlayerItem(uiPlayerItem);
		}

		/** 添加玩家列表数据 */
		public function addPlayerList(list : Vector.<GBPlayer>) : void
		{
			if (list == null) return;
			var compareFunction : Function = function(a : GBPlayer, b : GBPlayer) : Number
			{
				b;
				if (a.playerStatus == GBPlayerStatus.DIE)
				{
					return 1;
				}

				return 0;
			};
			list.sort(compareFunction);

			for (var i : int = 0; i < list.length; i++)
			{
				var gbPlayer : GBPlayer = list[i];
				addPlayerData(gbPlayer);
			}
		}

		/** 移除玩家 */
		public function removePlayerItem(playerId : int, destruct : Boolean = false) : void
		{
			var itemName : String = getPlayerItemName(playerId);
			var item : UiPlayerItem = container.getChildByName(itemName) as UiPlayerItem;
			if (item)
			{
				if (destruct == false) item.quit();
				var index : int = container.getChildIndex(item);
				container.removeChild(item);
				sortList(index);
				updateScrollBarValue();
			}
		}

		/** 更新滚动条值 */
		public function updateScrollBarValue() : void
		{
			if (container == null) return;
			var contentHeight : int = container.numChildren * itemHeight;
			scrollBar.resetValue(containerHeight, 0, contentHeight - containerHeight, 0);
			scrollBar.visible = contentHeight - containerHeight > itemHeight;
		}

		/** 排序列表 */
		public function sortList(startIndex : int = 0) : void
		{
			for (var i : int = startIndex; i < container.numChildren; i++)
			{
				var item : DisplayObject = container.getChildAt(i);
				item.y = i * itemHeight;
			}
		}
	}
}
