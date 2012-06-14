package game.module.map.animal
{
    import game.core.avatar.AvatarThumb;
    import game.module.map.animalstruct.AbstractStruct;

    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-27   ����12:31:50 
     */
    public class DrayAnimal extends Animal
    {
        public function DrayAnimal(avatar : AvatarThumb, struct : AbstractStruct)
        {
            super(avatar, struct);
            speed = 1;
        }
		
		override public function stand():void{
			status = AnimalStatus.STAND;
//			avatar.stand();
//			_avatar.stop();
		}
		
		public function draycomplete():void{
			avatar.stand() ;
		}
    }
}
