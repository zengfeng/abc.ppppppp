package game.core.menu
{
	import com.commUI.button.ExitButton;
	import com.utils.TextFormatUtils;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	import game.manager.SoundManager;
	import game.manager.ViewManager;
	import game.module.map.MapSystem;
	import game.module.map.struct.MapStruct;
	import game.module.map.utils.MapUtil;
	import gameui.controls.GButton;
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 * @author yangyiqiang
	 */
	public class MapMenu extends GComponent
	{
		public function MapMenu()
		{
			_base = new GComponentData();
			_base.parent = ViewManager.instance.getContainer(ViewManager.AUTO_CONTAINER);
			_base.width = 180;
			_base.height = 92;
			_base.align = new GAlign(-1, 1, 0);
			super(_base);
			initView();
		}

		private var _back : Sprite;

		private var _titleLabel : TextField;

		private var _openMusicBt : GButton;

		private var _closeMusicBt : GButton;

		private function initView() : void
		{
			_back = UIManager.getUI(new AssetData("MinimapBack"));
			addChild(_back);
			_titleLabel = new TextField();
			_titleLabel.x = -15;
			_titleLabel.y = 5;
			_titleLabel.embedFonts = true;
			_titleLabel.selectable = false;
			_titleLabel.mouseEnabled = false;
			_titleLabel.autoSize = TextFieldAutoSize.CENTER;
			_titleLabel.defaultTextFormat = TextFormatUtils.mapTitle;
			_titleLabel.filters = [new DropShadowFilter(0, 45, 0xFFBB00, 0.8, 3, 3, 2)];
			_titleLabel.width = 120;
			_titleLabel.height = 28;
			if (MapUtil.getMapStruct())
				_titleLabel.htmlText = MapUtil.getMapStruct().name;
			addChild(_titleLabel);

			var _data : GButtonData = new GButtonData();
			_data.width = _data.height = 23;
			_data.downAsset = new AssetData("musicClick");
			_data.overAsset = new AssetData("musicOver");
			_data.upAsset = new AssetData("music");
			_data.width=31;
			_data.height=31;
			_data.x = 97;
			_data.y = 40;
			_closeMusicBt = new GButton(_data);
			_data = _data.clone();
			_data.downAsset = new AssetData("musicOpenClick");
			_data.overAsset = new AssetData("musicOpenOver");
			_data.upAsset = new AssetData("musicOpen");
			_openMusicBt = new GButton(_data);
			addChild(_closeMusicBt);
			addChild(_openMusicBt);
			_closeMusicBt.hide();
			_openMusicBt.addEventListener(MouseEvent.CLICK, onClick);
			_closeMusicBt.addEventListener(MouseEvent.CLICK, onClick);
			MapSystem.addChangeMapCallFun(changeMapId);
			
			var exitButton:ExitButton = ExitButton.instance;
			exitButton.x = _base.width - exitButton.width - 5;
			exitButton.y = 80;
			if(exitButton.visible == false) exitButton.setVisible(false, null);
			addChild(exitButton);
		}

		public function  changeMapId(mapStruct : MapStruct) : void
		{
			_titleLabel.htmlText = mapStruct.name;
			_titleLabel.setTextFormat(TextFormatUtils.mapTitle);
		}

		private var _time : uint;

		private function onClick(event : MouseEvent) : void
		{
			if (getTimer() - _time > 500)
			{
				if (_openMusicBt.parent != null)
				{
					SoundManager.instance.playSound(SoundManager.EVIL);
					_openMusicBt.hide();
					_closeMusicBt.show();
				}
				else
				{
					SoundManager.instance.pauseSound(SoundManager.EVIL);
					_openMusicBt.show();
					_closeMusicBt.hide();
				}
			}
			event.stopPropagation();
		}
	}
}
