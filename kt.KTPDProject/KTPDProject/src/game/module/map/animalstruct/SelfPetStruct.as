package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����6:18:24
     */
    public class SelfPetStruct extends PetStruct
    {
        public function SelfPetStruct()
        {
        }
        
        /** 动物类型 */
        override public function get animalType():String
        {
            return AnimalType.SELF_PET;
        }
    }
}
