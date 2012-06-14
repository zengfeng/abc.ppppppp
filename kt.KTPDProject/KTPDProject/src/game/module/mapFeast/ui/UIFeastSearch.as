package game.module.mapFeast.ui
{
	import flash.display.MovieClip;
	import game.module.mapFeast.FeastConfig;
	import gameui.containers.GPanel;
	import gameui.data.GPanelData;
	import net.AssetData;
	import net.RESManager;




	/**
	 * @author 1
	 */
	public class UIFeastSearch extends GPanel implements FeastUI
	{
		private var _searchText : MovieClip ;

		public function UIFeastSearch(data : GPanelData)
		{
			data.bgAsset = new AssetData(FeastConfig.FEAST_SEARCH, "embedFont");
			data.width = 90 ;
			data.height = 85.85 ;
			super(data);
			addSearchText() ;
		}

		private function addSearchText() : void
		{
			_searchText = RESManager.getMC(new AssetData(FeastConfig.FEAST_SEARCH_TEXT, "embedFont"));
			if (!_searchText) return;
			_searchText.x = 5 ;
			_searchText.y = 68 ;
			addChild(_searchText);
		}

		public function onAttach() : void
		{
			if (!_searchText) return;
			_searchText.gotoAndPlay(0);
		}

		public function onDetach() : void
		{
			if (!_searchText) return;
			_searchText.stop();
		}
	}
}
