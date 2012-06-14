package game.module.map.animal
{
    import game.core.avatar.AvatarThumb;
    import game.module.map.animalstruct.AbstractStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-21 ����11:21:22
     */
    public class SelfStoryAnimal extends StoryAnimal
    {
        public function SelfStoryAnimal(avatar : AvatarThumb, struct : AbstractStruct)
        {
            super(avatar, struct);
        }
    }
}
