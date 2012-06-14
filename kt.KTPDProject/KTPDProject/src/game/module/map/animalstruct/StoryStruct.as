package game.module.map.animalstruct
{
	import game.module.map.animal.AnimalType;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-21 ����10:13:54
     */
    public class StoryStruct extends AbstractStruct
    {
        /** 0为正常,1为前景, -1为背景 */
        public var childIndex:int = 0;
        public function StoryStruct()
        {
        }
        
        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.STORY;
        }
    }
}
