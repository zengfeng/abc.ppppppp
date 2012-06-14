package game.module.quest
{
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.manager.UIManager;
	import com.greensock.TweenLite;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author yangyiqiang
	 */
	public class DialogueItem extends GComponent
	{
		public static const CLICKITEM : String = "clickItem";

		private var _lable : TextField;

		private var _background : Sprite;

		public function DialogueItem(data : GComponentData)
		{
			super(data);
			initView();
			initEvent();
		}

		private function initView() : void
		{
			_lable = new TextField();
			_lable.defaultTextFormat = UIManager.getTextFormat(14);
			_lable.width = 388;
			_lable.x = 30;
			_lable.selectable = false;
			_lable.autoSize = TextFieldAutoSize.LEFT;
			_background=new Sprite();
			_background.alpha = 0;
			var W : int = 388;
			var H : int = 20;
			var matrix : Matrix = new Matrix();
			matrix.createGradientBox(W,H);
			_background.graphics.beginGradientFill(GradientType.LINEAR,[0x000000, 0x000000, 0x000000, 0x000000],[0, 1, 0.5, 0],[0, 20, 160, 255],matrix);
			_background.graphics.drawRect(0,0,W,H);
			_background.graphics.endFill();
			addChild(_background);
			addChild(_lable);
		}

		private function initEvent() : void
		{
			this.addEventListener(MouseEvent.CLICK,onMouseClick);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
		}

		private function onMouseClick(event : MouseEvent) : void
		{
			dispatchEvent(new Event("clickItem",true));
		}

		private function onMouseOut(event : MouseEvent) : void
		{
			TweenLite.to(_background,0.3,{alpha:0});
			_lable.textColor = 0x000000;
		}

		private function onMouseOver(event : MouseEvent) : void
		{
			TweenLite.to(_background,0.3,{alpha:1});
			_lable.textColor = 0xffdd00;
		}

		public function  setText(value : String) : void
		{
			_lable.htmlText = value.split("_")[0];
			id = int(value.split("_")[1]);
		}

		public function getId() : int
		{
			return id;
		}

		private var id : int;

		override public function hide() : void
		{
			this.removeEventListener(MouseEvent.CLICK,onMouseClick);
			this.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			super.hide();
		}

		override public function show() : void
		{
			initEvent();
			super.show();
		}
	}
}
