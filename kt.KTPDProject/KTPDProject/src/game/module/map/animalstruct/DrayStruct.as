package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-27   ����12:33:08 
     */
    public class DrayStruct extends AbstractStruct
    {
        public function DrayStruct()
        {
        }
        
        
        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.DRAY;
        }
    }
}
