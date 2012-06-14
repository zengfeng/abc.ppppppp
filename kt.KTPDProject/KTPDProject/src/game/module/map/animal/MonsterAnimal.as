package game.module.map.animal
{
	import game.module.map.animal.Animal;
	import game.module.map.animalstruct.AbstractStruct;
	import game.core.avatar.AvatarThumb;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-12
	// ============================
	public class MonsterAnimal extends Animal
	{
		public function MonsterAnimal(avatar : AvatarThumb, struct : AbstractStruct)
		{
			super(avatar, struct);
		}
	}
}
