package game.module.daily
{
	import gameui.controls.GButton;
	import gameui.controls.GImage;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.manager.UIManager;

	import net.AssetData;

	import com.commUI.button.KTButtonData;
	import com.utils.StringUtils;
	import com.utils.UICreateUtils;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * @author yangyiqiang
	 */
	public class CopyItem extends GComponent
	{
		private var _vo : VoCopy;

		private var _id : int;

		public function CopyItem(vo : VoCopy, id : int)
		{
			_base = new GComponentData();
			_base.width = 516;
			_base.height = 106;
			_vo = vo;
			_id = id;
			super(base);
		}

		private var _back : Sprite;

		private var _img : GImage;

		override protected function create() : void
		{
			_back = UIManager.getUI(new AssetData(_id % 2 == 0 ? "Shop_LigthBg" : "Shop_DarkBg"));
			_back.width = 516;
			_back.height = 106;
			addChildAt(_back, 0);

			var data : GImageData = new GImageData();
			data.x = 80;
			data.y = 5;
			_img = new GImage(data);
			_img.url = _vo.getIcoUrl();
			addChild(_img);
			var mc : Sprite = UIManager.getUI(new AssetData("textBackground_1"));
			mc.x = 0;
			mc.y = 5;
			addChild(mc);
			addLable();
			addButton();
		}

		private var _name : TextField;

		public var _dropText : TextField ;

		public var _description : TextField ;

		private var _buttonText : TextField;

		private function addLable() : void
		{
			_name = UICreateUtils.createTextField(null, StringUtils.addBold(_vo.name), 120, 25, 14, 5, UIManager.getTextFormat(14, 0xffffff));
			_dropText = UICreateUtils.createTextField(null, _vo.dropString, 160, 90, 260, 18, UIManager.getTextFormat());
			_dropText.htmlText=_vo.dropString;
			_description = UICreateUtils.createTextField("副本掉落：", null, 60, 25, 209, 0, UIManager.getTextFormat(12, 0x2f1f00));
			_buttonText = UICreateUtils.createTextField("今日已结束", null, 70, 18, 425, 43, UIManager.getTextFormat(12, 0x695939));
			
			_name.filters=UIManager.getEdgeFilters(0x000000,0.7);
			addChild(_name);
			addChild(_description);
			addChild(_dropText);
			addChild(_buttonText);
		}

		private var _goButton : GButton;

		private function addButton() : void
		{
			var data : KTButtonData = new KTButtonData(KTButtonData.SMALL_BUTTON);
			data.width = 70;
			data.height = 25;
			data.x = 425;
			data.y = 43;
			_goButton = new GButton(data);
			_goButton.text = "传送";
			addChild(_goButton);
		}

		private function onClick(event : MouseEvent) : void
		{
			_vo.execute();
		}

		override protected function onShow() : void
		{
			super.onShow();
			_goButton.addEventListener(MouseEvent.CLICK, onClick);
		}

		override protected function onHide() : void
		{
			super.onHide();
			_goButton.removeEventListener(MouseEvent.CLICK, onClick);
		}
	}
}
