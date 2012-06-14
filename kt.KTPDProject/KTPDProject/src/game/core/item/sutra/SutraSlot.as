package  game.core.item.sutra
{
	import game.core.hero.VoHero;
	import game.core.item.equipable.HeroSlot;
	import game.core.item.equipable.IEquipable;

	/**
	 * @author jian
	 */
	public class SutraSlot extends HeroSlot
	{
		public function SutraSlot(hero : VoHero)
		{
			super(hero, HeroSlot.SUTRA, 0xF);
		}
		
		override public function onEquipped(source : IEquipable) : void
		{
			(source as Sutra).slot = hero.sutraSlot;
			(source as Sutra).hero = hero;
			_equipable = source;
		}
	}
}
