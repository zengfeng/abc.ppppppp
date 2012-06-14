package game.module.map.animalstruct
{
	import flash.geom.Point;
	import game.manager.RSSManager;
	import game.module.map.animal.AnimalType;
	import game.module.quest.VoNpc;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����7:52:05
     */
    public class NpcStruct extends AbstractStruct
    {
		public var isHit:Boolean;
		public var hasAvatar:Boolean;
		public var moveRadius:uint = 300;
		public var attackRadius:uint = 50;
		public var passColor:uint = 0x0;
        private var _vo :VoNpc;

        public function get vo() : VoNpc
        {
            if(_vo == null)
            {
                _vo = RSSManager.getInstance().getNpcById(id) as VoNpc;
            }
            
            return _vo;
        }

        /** NPC周围角色站立点 */
        public var standPostion : Vector.<Point> = new Vector.<Point>;

        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.NPC;
        }

        /** 名称 */
        override public function get name() : String
        {
            if(vo == null) return "";
            return vo.name;
        }
    }
}
