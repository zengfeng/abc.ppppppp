package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-27 ����4:50:03
     */
    public class PetStruct extends AbstractStruct
    {
        /** 动物类型 */
        override public function get animalType():String
        {
            return AnimalType.PET;
        }
    }
}
