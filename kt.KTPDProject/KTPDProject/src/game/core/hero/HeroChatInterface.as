package game.core.hero
{
	import com.utils.SerializeUtils;

	/**
	 * @author jian
	 */
	public class HeroChatInterface
	{
		public static function encodeHeroToString(hero : VoHero) : String
		{
			var vo : Object = getChatVOFromHero(hero);
			return SerializeUtils.encodeObjectToString(vo);
		}

		public static function decodeStringToHero(str : String) : VoHero
		{
			var vo : Object = SerializeUtils.decodeStringToObject(str);
			var hero : VoHero = getHeroFromChatVO(vo);
			return hero;
		}

		private static function getChatVOFromHero(hero : VoHero) : Object
		{
			var vo : Object = new Object();

			vo["id"] = hero.id;
			vo["level"] = hero.level;

			return vo;
		}

		private static function getHeroFromChatVO(vo : Object) : VoHero
		{
			if (vo["id"] == undefined)
				return null;

			var hero : VoHero = HeroManager.instance.newHero(vo["id"],vo["level"]);

			return hero;
		}
	}
}
