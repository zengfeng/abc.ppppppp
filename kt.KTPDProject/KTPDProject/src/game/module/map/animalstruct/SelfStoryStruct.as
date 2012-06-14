package game.module.map.animalstruct
{
	import game.core.user.UserData;
	import game.module.map.CurrentMapData;
	import game.module.map.animal.AnimalType;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-21 ����11:17:15
     */
    public class SelfStoryStruct extends StoryStruct
    {
        public function SelfStoryStruct()
        {
            super();
        }
        
        
        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.SELF_STORY;
        }
        
        
        private var _heroId:int;
        public function get heroId():int
        {
            if(!_heroId)
            {
                _heroId = UserData.instance.myHero.id;
            }
            return _heroId;
        }
        
        private var _cloth:int;
        public function get cloth():int
        {
            if(_cloth == 0)
            {
                _cloth = CurrentMapData.instance.selfPlayerStruct.cloth;
            }
            return _cloth;
        }
    }
}
