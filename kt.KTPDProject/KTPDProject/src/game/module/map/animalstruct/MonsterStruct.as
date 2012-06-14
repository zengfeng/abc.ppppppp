package game.module.map.animalstruct
{
	import flash.geom.Point;
	import game.manager.RSSManager;
	import game.module.duplMap.DuplUtil;
	import game.module.map.animal.AnimalType;
	import game.module.quest.VoBase;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-27 ����1:52:47
     */
    public class MonsterStruct extends AbstractStruct
    {
        /** 地图ID号 */
        public var mapId:uint;
        /** 副本ID */
        public var duplId:uint;
        /** 层Id */
        public var layerId:uint;
        /** 怪物ID */
        public var monsterId:int;
        /** 第几波 */
        public var wave:uint;
        /** 是否是Boss */
        public var isBoss:Boolean = false;
        /** 怪物移动站立点 */
		public var standPoint:Vector.<Point> = new Vector.<Point>;
        /** 怪物的巡逻范围以position为中心 */
		public var moveRadius:uint = 300;
        /** 怪物的攻击范围以position为中心 */
		public var attackRadius:uint = 50;
        /** 怪物列表 */
        public var monsterIdList:Vector.<uint> = new Vector.<uint>();
        /** 关卡颜色 */
        public var passColor:uint = 0;
		public var voBase:VoBase;
        
        override public function get id():int
        {
            return wave;
        }
        
        override public function set id(value:int):void
        {
            wave = value;
        }
        
		public function parse(arr : Array) : void
		{
			if (!arr) return;
			mapId = parseInt(arr[0]);
			duplId = DuplUtil.getDuplId(mapId);
			layerId = DuplUtil.getLayerId(mapId);
			wave =  arr[1];
            //怪物ID
			var idStr:String = arr[2];
            idStr = idStr.replace(/\=/gi, ":");
            var ids:Array = idStr.split("|");
            for(var i:int = 0; i < ids.length; i++)
            {
                var idStr2:String = ids[i];
                var ids2:Array = idStr2.split(":");
                monsterIdList.push(parseInt(ids2[0]));
            }
            monsterId = monsterIdList[0];
			voBase = RSSManager.getInstance().getNpcById(monsterId);
			name = voBase ? voBase.name : "未知怪物";
            
            var booleanInt:int =  parseInt(arr[4]) ;
            isBoss = booleanInt == 0 ? false : true;
		}
        
        /** 动物类型 */
        override public function get animalType():String
        {
            return AnimalType.MONSTER;
        }
    }
}
