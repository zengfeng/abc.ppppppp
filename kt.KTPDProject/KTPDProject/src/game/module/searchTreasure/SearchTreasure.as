package game.module.searchTreasure {
	/**
	 * @author Lv
	 */
	public class SearchTreasure {
		private static var _instance :SearchTreasure;
		public function SearchTreasure(control:Control):void{
		}
		public static function get instance():SearchTreasure{
			if(_instance == null){
				_instance = new SearchTreasure(new Control());
			}
			return _instance;
		}
	}
}
class Control{}