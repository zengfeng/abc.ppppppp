package game.module.sutra {
	import com.utils.HeroUtils;
	import game.core.hero.HeroManager;
	import game.core.hero.VoHero;
	import game.core.user.UserData;
	/**
	 * @author Lv
	 */
	public class SutraContral {
		private static var _instance:SutraContral;
		public function SutraContral(contral:Contral):void{}
		public static function get instance():SutraContral{
			if(_instance == null)
				_instance = new SutraContral(new Contral());
			return _instance;
		}
		private var _sutraImg:SutraImg;
		private var _sutraSubmit:SutraSubmitPanel;
		public function sutraImg():SutraImg{
			if(_sutraImg == null)
				_sutraImg = new SutraImg();
			return _sutraImg;
		}
		public function sutraSubmit():SutraSubmitPanel{
			if(_sutraSubmit == null)
				_sutraSubmit = new SutraSubmitPanel();
			return _sutraSubmit;
		}
		
		public function refreshSubmit(heroID:int):void{
			var voHero:VoHero ;
			voHero = HeroManager.instance.getTeamHeroById(heroID);
			sutraSubmit().refreshPanel(voHero.sutra,voHero);
			sutraImg().changeIMG(voHero);
		}
		public function refreInputText():void{
			sutraSubmit().refreshInputOnce();
		}
		public function weapLevelUp():void{
			_sutraImg.upLevel();
		}
	}
}
class Contral{}
