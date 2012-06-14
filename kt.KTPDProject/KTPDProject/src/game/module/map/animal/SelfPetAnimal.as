package game.module.map.animal
{
    import game.core.avatar.AvatarThumb;
    import game.module.map.animalstruct.AbstractStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����6:23:08
     */
    public class SelfPetAnimal extends PetAnimal
    {
        public function SelfPetAnimal(avatar : AvatarThumb, struct : AbstractStruct)
        {
            super(avatar, struct);
        }
    }
}
