package game.module.sutra
{
	import flash.utils.Dictionary;
	import game.core.hero.HeroManager;
	import game.core.hero.VoHero;

	/**
	 * @author 1
	 */
	public class SutraStaticValue {
		//存储各个将领法宝今日提交次数 K:将领id
		public static var sutraNowDoaySumbitDic:Dictionary = new Dictionary();
		//存储各个将领法宝提交个数 K:将领id
		public static var sutraSumbitRateDic:Dictionary = new Dictionary();
		
		public function SutraStaticValue()
		{
			
		}
		/**
		 * ID:该将领的id
		 */
		public static function GetSurtSumbit(ID:int):void
		{
			var hero:VoHero = HeroManager.instance.getTeamHeroById(ID) as VoHero;
			if(50<= hero.level <60)
			{
				
			}
			else if(60<= hero.level < 70)
			{
				
			}
			else if(70<= hero.level<80)
			{
				
			}
		}
	}
}
