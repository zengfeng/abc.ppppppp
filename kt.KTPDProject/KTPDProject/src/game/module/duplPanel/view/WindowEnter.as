package game.module.duplPanel.view
{
	import com.commUI.GCommonWindow;
	import com.utils.UIUtil;
	import com.utils.UrlUtils;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.definition.UI;
	import game.manager.ViewManager;
	import gameui.data.GTitleWindowData;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-12
	 */
	public class WindowEnter extends GCommonWindow
	{
		/** 单例对像 */
		private static var _instance : WindowEnter;

		/** 获取单例对像 */
		public static function get instance() : WindowEnter
		{
			if (_instance == null)
			{
				_instance = new WindowEnter();
			}
			return _instance;
		}

		public function WindowEnter()
		{
			_data = new GTitleWindowData();
			_data.visible = false;
			_data.width = 540;
			_data.height = 370;
			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;
			super(_data);
		}

		/** 文本 今日剩余免费进入次数: */
		public const TEXT_REMAIN_NUM_FREE : String = "今日剩余免费进入次数:<font color='#FF3300'>__NUM__</font>";
		/** 文本 今日可购买次数: */
		public const TEXT_REMAIN_NUM : String = "今日可购买次数: <font color='#FF3300'>__NUM__</font>";
		/** ICON区块宽 */
		private const ICON_BOX_WIDTH : int = 505;
		/**  ICON区块高 */
		private const  ICON_BOX_HEIGHT : int = 305;
		/**  ICON区块容器 */
		private var iconBoxContainer : Sprite;
		/** 正文容器 */
		private var bodyContainer : Sprite;
		/** 剩余次数Label */
		private var remainNumTF : TextField;

		override protected function initViews() : void
		{
			super.initViews();
			title = "副本名称";

			var bodyBg : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND));
			bodyBg.width = 522;
			bodyBg.height = 362;
			bodyBg.x = 6;
			_contentPanel.addChild(bodyBg);

			var iconsBoxBg : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
			iconsBoxBg.width = ICON_BOX_WIDTH;
			iconsBoxBg.height = ICON_BOX_HEIGHT;
			iconsBoxBg.x = bodyBg.x + (bodyBg.width - iconsBoxBg.width ) / 2 ;
			iconsBoxBg.y = 32;
			_contentPanel.addChild(iconsBoxBg);

			bodyContainer = new Sprite();
			bodyContainer.x = 15;
			bodyContainer.y = 10;
			_contentPanel.addChild(bodyContainer);

			iconBoxContainer = new Sprite();
			iconBoxContainer.x = iconsBoxBg.x;
			iconBoxContainer.y = iconsBoxBg.y;
			_contentPanel.addChild(iconBoxContainer);

			var textFormat : TextFormat = new TextFormat();
			textFormat.font = UIManager.defaultFont;
			textFormat.size = 12;
			textFormat.color = 0x2F1F00;
			textFormat.align = TextFormatAlign.LEFT;
			var tempTF : TextField = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.width = 200;
			tempTF.height = 20;
			tempTF.x = 0;
			tempTF.y = 0;
			tempTF.htmlText = "今日剩余免费进入次数:<font color='#FF3300'>10</font>";
			bodyContainer.addChild(tempTF);
			remainNumTF = tempTF;

			// 安装Icon列表
			installIcons();
		}

		public function testWH() : void
		{
			var g : Graphics = iconBoxContainer.graphics;
			g.beginFill(0xFF0000, 0.1);
			g.drawRect(0, 0, ICON_BOX_WIDTH, ICON_BOX_HEIGHT);
			g.endFill();
		}

		// ===================
		// 赋值
		// ===================
		/** 设置剩余次数 */
		public function setRemainNum(num : int, isFree : Boolean) : void
		{
			var str : String;
			if (isFree == true)
			{
				str = TEXT_REMAIN_NUM_FREE;
			}
			else
			{
				str = TEXT_REMAIN_NUM;
			}
			str = str.replace(/__NUM__/gi, num);
			remainNumTF.htmlText = str;
		}

		// ===================
		// Icon列表
		// ===================
		private var icons : Vector.<HeadIconEnter> = new Vector.<HeadIconEnter>();

		/** 安装Icon列表 */
		private function installIcons() : void
		{
			const RANK_COUNT : int = 3;
			var row : int = 0;
			var rank : int = 0;
			var x_0 : int = ICON_BOX_WIDTH / RANK_COUNT;
			var paddLeft : int = 35;
			var arrY : Array = [15, 170];
			var icon : HeadIconEnter;
			for (var i : int = 0; i < 6; i++)
			{
				icon = new HeadIconEnter();
				row = Math.floor(i / RANK_COUNT) ;
				rank = i - row * RANK_COUNT;
				icon.x = x_0 * rank + paddLeft ;
				icon.y = arrY[row];
				iconBoxContainer.addChildAt(icon, 0);
				icons.push(icon);
			}

			// test();
		}

		public function test() : void
		{
			icons[0].enable = true;
			icons[1].enable = true;
			icons[2].enable = true;

			icons[0].isOpenHook = true;
			icons[1].isOpenHook = true;

			var url : String;
			url = UrlUtils.getMonster(4150);
			icons[0].setImageUrl(url);
			url = UrlUtils.getMonster(4152);
			icons[1].setImageUrl(url);
			url = UrlUtils.getMonster(4153);
			icons[2].setImageUrl(url);
		}

		/** 清理Icon列表 */
		public function clearIcons() : void
		{
			var icon : HeadIconEnter;
			for (var i : int = 0; i < icons.length; i++)
			{
				icon = icons[i];
				icon.clear();
			}
		}

		/** 获取Icon根据索引 */
		public function getIconByIndex(index : int) : HeadIconEnter
		{
			return icons[index];
		}

		/** 获取Icon根据ID */
		public function getIconById(id : int) : HeadIconEnter
		{
			var icon : HeadIconEnter;
			for (var i : int = 0; i < icons.length; i++)
			{
				icon = icons[i];
				if (icon.id != id)
				{
					icon = null;
				}
				else
				{
					return icon;
				}
			}
			return icon;
		}

		// ===================
		// 布局
		// ===================
		public function updateLayout(event : Event = null) : void
		{
			UIUtil.alignStageCenter(this);
		}

		// ===================
		// 设置显示隐藏
		// ===================
		private var _visible : Boolean = false;

		override public function get visible() : Boolean
		{
			return _visible;
		}

		override public function set visible(value : Boolean) : void
		{
			if (_visible == value) return;
			_visible = value;
			if (value)
			{
				updateLayout();
				show();
				stage.addEventListener(Event.RESIZE, updateLayout);
			}
			else
			{
				stage.removeEventListener(Event.RESIZE, updateLayout);
				if(parent) parent.removeChild(this);
//				hide();
			}
		}
		
		public var onClickCloseCall:Function;
		override protected function onClickClose(event : MouseEvent) : void
		{
			if(onClickCloseCall != null)
			{
				onClickCloseCall.apply();
				return;
			}
			super.onClickClose(event);
			_visible = false;
		}

		// ===================
		// 常用Getter
		// ===================
		private var _stage : Stage;

		override public function get stage() : Stage
		{
			if (_stage) return _stage;
			_stage = UIUtil.stage;
			return _stage;
		}
	}
}
