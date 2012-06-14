package game.module.daily
{
	import gameui.core.GAlign;
	import com.commUI.button.KTButtonData;
	import com.utils.StringUtils;
	import com.utils.UICreateUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import game.core.user.UserData;
	import gameui.controls.GButton;
	import gameui.controls.GImage;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 * @author yangyiqiang
	 */
	public class DailyItem extends GComponent
	{
		private var _vo : VoDaily;

		private var _id : int;

		public function DailyItem(vo : VoDaily, id : int)
		{
			_base = new GComponentData();
			_base.width = 524;
			_base.height = 70;
			_vo = vo;
			_id = id;
			super(base);
		}

		private var _back : Sprite;

		private var _img : GImage;

		override protected function create() : void
		{
			_back = UIManager.getUI(new AssetData(_id % 2 == 0 ? "Shop_LigthBg" : "Shop_DarkBg"));
			_back.width = 524;
			_back.height = 70;
			addChildAt(_back, 0);
			
			var data : GImageData = new GImageData();
			data.x = 8;
			data.y = 9;
			data.iocData.align=new GAlign();
			_img = new GImage(data);
			_img.url = _vo.getIcoUrl();
			addChild(_img);
			addLable();
			addButton();
			_vo.addEventListener("refresh", onRefresh);
		}
		
		private function onRefresh(event:Event):void
		{
			_description.text=_vo.description;
			if(_vo.state!=3){
				_goButton.visible=true;
				_goButton.text = getButtonStr();
			}else{
				_goButton.visible=false;
				_buttonText.visible=true;
			}
		}

		private var _name : TextField;

		public var _description : TextField ;

		public var _description2 : TextField ;

		private var _buttonText : TextField;

		private function addLable() : void
		{
			_name = UICreateUtils.createTextField(null, StringUtils.addBold(_vo.name), 120, 25, 74, 14, UIManager.getTextFormat(14));
			_description = UICreateUtils.createTextField(_vo.description, null, 300, 18, 142, 14, UIManager.getTextFormat());
			_description2 = UICreateUtils.createTextField(_vo.description2, null, 320, 50, 74, 35, UIManager.getTextFormat(12, 0x695939));
			_buttonText = UICreateUtils.createTextField("今日已结束", null, 70, 18, 427, 22, UIManager.getTextFormat(12, 0x695939));

			addChild(_name);
			addChild(_description);
			addChild(_description2);
			addChild(_buttonText);
		}

		private var _goButton : GButton;

		private function addButton() : void
		{
			var data : KTButtonData = new KTButtonData(KTButtonData.SMALL_BUTTON);
			data.width = 70;
			data.height = 25;
			data.x = 427;
			data.y = 21;
			_goButton = new GButton(data);
			_goButton.text = getButtonStr();
			addChild(_goButton);
		}

		private function getButtonStr() : String
		{
			if (_vo.type == 3) return "打开";
			if (_vo.type == 2 && UserData.instance.vipLevel < 1) return "前往";
			return "传送";
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
