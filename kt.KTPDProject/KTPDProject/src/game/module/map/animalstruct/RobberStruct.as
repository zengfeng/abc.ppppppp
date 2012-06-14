package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-27   ����6:09:22 
     */
    public class RobberStruct extends AbstractStruct
    {
        public function RobberStruct()
        {
        }
        
        
        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.ROBBER;
        }
    }
}
