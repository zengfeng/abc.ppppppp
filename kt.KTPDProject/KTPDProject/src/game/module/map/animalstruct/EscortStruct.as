package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-20 ����3:38:55
     */
    public class EscortStruct extends AbstractStruct
    {
        public function EscortStruct()
        {
        }

        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.ESCORT;
        }
    }
}