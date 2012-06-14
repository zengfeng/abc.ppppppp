package game.module.duplPanel.view
{
	import com.utils.ColorChange;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.definition.UI;
	import game.module.duplPanel.DuplPanelConfig;
	import gameui.controls.GImage;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.manager.UIManager;
	import net.AssetData;






	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-12
	 */
	public class HeadIcon extends GComponent
	{
		/** 背景 */
		public var bg : Sprite;
		/** 头像图片 */
		protected var image : GImage;
		/** 名称Label */
		protected var nameTF : TextField;
		/** 未知图标 */
		protected var unkonwIcon : Sprite;

		public function HeadIcon()
		{
			_base = new GComponentData();
			_base.width = DuplPanelConfig.HEAD_ICON_WIDTH;
			_base.height = DuplPanelConfig.HEAD_ICON_Height;
			super(_base);

			initView();
			enable = false;
		}

		public function testWH() : void
		{
			var g : Graphics = this.graphics;
			g.beginFill(0x00FF00, 0.1);
			g.drawRect(0, 0, _base.width, _base.height);
			g.endFill();
		}

		public function initView() : void
		{
			bg = UIManager.getUI(new AssetData(UI.HEAD_ICON_BACKGROUND));
            bg.mouseEnabled = true;
			bg.width = DuplPanelConfig.HEAD_ICON_WIDTH;
			bg.height = DuplPanelConfig.HEAD_ICON_Height;
			bg.x = DuplPanelConfig.HEAD_ICON_RADIUS;
			bg.y = DuplPanelConfig.HEAD_ICON_RADIUS;
			addChild(bg);

			var imageData : GImageData = new GImageData();
			imageData.width = 121;
			imageData.height = 184;
			imageData.x = -8;
			imageData.y = (bg.height - imageData.height );
            imageData.enabled = false;
			image = new GImage(imageData);
			addChild(image);

			unkonwIcon = UIManager.getUI(new AssetData(UI.ICON_UNKNOWN));
            unkonwIcon.mouseEnabled = false;
			unkonwIcon.x = (DuplPanelConfig.HEAD_ICON_WIDTH - unkonwIcon.width) >> 1;
			unkonwIcon.y = (DuplPanelConfig.HEAD_ICON_Height - unkonwIcon.height) >> 1;
			addChild(unkonwIcon);

			var textFormat : TextFormat = new TextFormat();
			textFormat.font = UIManager.defaultFont;
			textFormat.size = 12;
			textFormat.color = 0x2F1F00;
			textFormat.bold = true;
			textFormat.align = TextFormatAlign.CENTER;
			var tempTF : TextField = new TextField();
			tempTF.selectable = false;
			tempTF.defaultTextFormat = textFormat;
			tempTF.width = DuplPanelConfig.HEAD_ICON_WIDTH;
			tempTF.height = 20;
			tempTF.x = 0;
			tempTF.y = DuplPanelConfig.HEAD_ICON_Height + 10;
			tempTF.htmlText = "斑斓蘑菇";
			nameTF = tempTF;
			addChild(nameTF);
		}

		
		// ===================
		// 滤镜区域
		// ===================
		private static var _colorMatrixFilter_disable : ColorMatrixFilter;

		public static function get colorMatrixFilter_disable() : ColorMatrixFilter
		{
			if (_colorMatrixFilter_disable == null)
			{
				var colorChange : ColorChange = new ColorChange();
				colorChange.adjustSaturation(-100);
				_colorMatrixFilter_disable = new ColorMatrixFilter(colorChange);
			}
			return _colorMatrixFilter_disable;
		}


		// ===================
		// enable区块
		// ===================
		protected var _enable : Boolean = true;

		public function get enable() : Boolean
		{
			return _enable;
		}

		public function set enable(value : Boolean) : void
		{
			if (_enable == value) return;
			_enable = value;
			if (value == false)
			{
				this.filters = [colorMatrixFilter_disable];
			}
			else
			{
				this.filters = [];
			}

			image.visible = value;
			nameTF.visible = value;
			unkonwIcon.visible = !value;
		}
		
		/** 是否开放挂机 */
		protected var _isOpenHook : Boolean = true;

		public function  get isOpenHook() : Boolean
		{
			return _isOpenHook;
		}

		public function set isOpenHook(value : Boolean) : void
		{
			if(_isOpenHook == value) return;
			_isOpenHook = value;
		}

		public function setName(name : String) : void
		{
			nameTF.text = name;
		}

		public function setImageUrl(url : String) : void
		{
			image.url = url;
		}

		public function clear() : void
		{
			image.clearUp();
			nameTF.text = "未知怪物";
			isOpenHook = false;
			enable = false;
		}
		
		public var id:int;
		
		/** 设置数据 */
		public function setData(id:int, name:String, imageUrl:String, enable:Boolean = true, isOpenHook:Boolean = true):void
		{
			clear();
			this.id = id;
			setName(name);
			setImageUrl(imageUrl);
			this.enable = enable;
			this.isOpenHook =isOpenHook;
		}
	}
}
