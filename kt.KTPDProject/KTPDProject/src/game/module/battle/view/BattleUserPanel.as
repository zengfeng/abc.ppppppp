package game.module.battle.view
{
	import com.utils.PotentialColorUtils;
	import com.utils.StringUtils;
	
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import game.manager.RSSManager;
	import game.manager.VersionManager;
	import game.manager.ViewManager;
	
	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.manager.UIManager;
	
	import net.AssetData;
	import net.LibData;
	
	public class BattleUserPanel extends GComponent
	{
		private var _back : Sprite; //背景图片
		private var _userHead : GImage;
		private var _name : GLabel;
		private var _serverid : GLabel;
		private var _level : GLabel;
		
		private var _array : Array = [6, 3, 0];
		public function BattleUserPanel()
		{
			_base = new GComponentData();
			_base.parent = ViewManager.instance.uiContainer;
			_base.align = new GAlign(0);
			_base.x = 3;
			_base.width = 92; 
			_base.height = 92;	
			super(_base);
			
			initView();
		}
		
		private function initView():void
		{
			_back = UIManager.getUI(new AssetData("BattleHeadPhoto_Bg"));
			_back.x = 5+2;
			_back.y = 15;
			addChild(_back);

			var bag:Sprite = UIManager.getUI(new AssetData("BattleHeadPhoto_Fg"));
			bag.y = 10;
			bag.x= 0+2;
			addChild(bag);
			
			//name
			var data : GLabelData = new GLabelData();
			data.textFormat = UIManager.getTextFormat(16,0xffcc00,TextFormatAlign.CENTER);
			data.textColor = 0xffcc00;
			data.width = 86;
			data.y = 100+2;
			data.text = "";//UserData.instance.playerName;
			_name = new GLabel(data);
			addChild(_name);
			
			data = data.clone();
			data.textColor = 0xffffff;
			data.textFormat = UIManager.getTextFormat(12);
			data.y = 12;
			data.width = 30;
			data.text = String("");
			data.x =0; 
			_level = new GLabel(data);
			addChild(_level);
			
			data = data.clone();
			data.textColor = 0xffffff;
			data.textFormat = UIManager.getTextFormat(10);
			data.y = 103;
			data.width = 20;
			data.text = String("");
			data.x = 4;
			_serverid = new GLabel(data);
			addChild(_serverid);
		}
		
		override public function show():void
		{
			super.show();	
		}
		
		override public function hide():void
		{
			super.hide();
		}
		
		public function setName(name:String):void
		{
			//_name.text = name;
			_name.x = 10;
			_name.htmlText=StringUtils.addBold(name);
		}
		
		public function setBackGround(id:int, turn:Boolean = false):void
		{
			var _imgData:GImageData = new GImageData();
			_imgData.x = 13;
			_imgData.y = 0;
			_imgData.iocData.align = new GAlign(0, 0);
			if(id > 4000 )
				id = RSSManager.getInstance().getMosterById(id).headImg;
			_imgData.libData = new LibData( VersionManager.instance.getUrl("assets/ico/BattleHeadPng/" + id + ".png"), VersionManager.instance.getUrl("assets/ico/BattleHeadPng/" + id + ".png"));
			
			_userHead = new GImage(_imgData);
			
			//图片是否翻转
			if(turn)
			{
				_userHead.scaleX = -1;
			}
			
			if(!this.contains(_userHead))
			{
				addChild(_userHead);
				_userHead.x = 0;
				if(turn)
				{
					_userHead.x = _base.width+12;
				}
				else
				{
					_userHead.x = 0;
				}
				_userHead.y = -75;
			}

			this.setChildIndex(_userHead, 1);
		}
		
		public function setLevel(l:int):void
		{
			_level.text = l.toString();
			_level.x = _array[_level.text.length - 1];
		}
		
		public function setPlayerColor(c:uint):void
		{
			_name.textColor = PotentialColorUtils.getColor(c);
		}
		
	}	
}