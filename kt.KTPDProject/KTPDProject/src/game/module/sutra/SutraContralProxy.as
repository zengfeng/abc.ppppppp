package game.module.sutra {
	/**
	 * @author Lv
	 */
	public class SutraContralProxy {
		private static var _instance:SutraContralProxy;
		public function SutraContralProxy(contral:Contral):void{
			contral;
			sToC();
			cToS();
		}
		public static function get instance():SutraContralProxy{
			if(_instance == null)
				_instance = new SutraContralProxy(new Contral());
			return _instance;
		}

		private function cToS() : void {
		}

		private function sToC() : void {
		}
	}
}
class Contral{}
