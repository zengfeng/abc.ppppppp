package game.module.tang.controller
{
	import game.module.map.animal.PlayerAnimal;
	import game.core.avatar.AvatarThumb;
	import game.module.map.animalstruct.AbstractStruct;

	/**
	 * @author jian
	 */
	public class TangPlayerAnimal extends PlayerAnimal
	{
		public function TangPlayerAnimal(avatar : AvatarThumb, struct : AbstractStruct)
		{
			super(avatar, struct);
		}
		
		
	}
}
