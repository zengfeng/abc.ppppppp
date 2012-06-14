package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-15 ����2:29:38
     */
    public class FollowerStruct extends AbstractStruct
    {
        public function FollowerStruct()
        {
        }
        
        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.FOLLOWER;
        }
    }
}
