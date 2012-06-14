package game.module.mapFeast.ui {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import game.module.mapFeast.FeastConfig;
	import gameui.controls.GButton;
	import gameui.data.GButtonData;
	import net.AssetData;
	import net.RESManager;




	/**
	 * @author 1
	 */
	public class UIFeastStartButton extends GButton {
		
		private var _effect:MovieClip ;
		
		public function UIFeastStartButton(data : GButtonData) {
			data.width = 90 ;
			data.height = 90 ;
			data.downAsset = new AssetData( FeastConfig.FEAST_START_DOWN, "embedFont" );
			data.overAsset = new AssetData( FeastConfig.FEAST_START_OVER, "embedFont" );
			data.upAsset = new AssetData( FeastConfig.FEAST_START_UP, "embedFont" );
			_effect = RESManager.getMC(new AssetData(FeastConfig.FEAST_START_EFFECT));
			_effect.x = -1 ;
			_effect.y = 2 ;
			super(data);
			_downSkin.width = 82 ;
			_downSkin.height = 82 ;
			_downSkin.x = 4 ;
			_downSkin.y = 4 ;
			_upSkin.width = 82 ;
			_upSkin.height = 82 ;
			_upSkin.x = 4 ;
			_upSkin.y = 4 ;
			_overSkin.width = 82 ;
			_overSkin.height = 82 ;
			_overSkin.x = 4 ;
			_overSkin.y = 4 ;
			addChild(_effect) ;
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
		}
		
		private function onMouseOver(evt:Event):void
		{
			_effect.y = 0.8 ;
		}
		
		private function onMouseLeave(evt:Event):void
		{
			_effect.y = 2 ;
		}
		
		public function effectOn():void
		{
			_effect.gotoAndPlay(0);
		}
		
		public function effectOff():void
		{
			_effect.stop();
		}
	}
}
