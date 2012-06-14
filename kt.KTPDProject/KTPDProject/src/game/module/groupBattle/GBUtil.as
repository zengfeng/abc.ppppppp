package game.module.groupBattle
{
    import flash.geom.Point;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-14 ����4:18:52
     */
    public class GBUtil
    {
        /** 玩家管理工具 */
        public static var _gbPlayerManager : GBPlayerManager;

        /** 玩家管理工具 */
        public static function get gbPlayerManager() : GBPlayerManager
        {
            if (_gbPlayerManager == null)
            {
                _gbPlayerManager = GBPlayerManager.instance;
            }
            return _gbPlayerManager;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 获取组级别 */
        public static function getGroupLevel(groupId : int) : int
        {
            var groupLevel : int = groupId == 0 || groupId == 1 ? GBSystem.GROUP_LEVEL_1 : GBSystem.GROUP_LEVEL_2;
            return groupLevel;
        }

        /** 获取组AB */
        public static function getGroupAB(groupId : int) : int
        {
            return groupId % 2 == 0 ? GBSystem.GROUP_A_ID : GBSystem.GROUP_B_ID;
        }

        /** 获取组列表 */
        public static function getGroupList(groupLevel : int) : Vector.<GBGroup>
        {
            var list : Vector.<GBGroup> = new Vector.<GBGroup>();
            var group : GBGroup;
            if (groupLevel == GBSystem.GROUP_LEVEL_1)
            {
                group = new GBGroup();
                group.id = 1;
                group.name = "朱雀组";
                group.color = 0xFE9966;
                group.colorStr = "#FE9966";
                group.minLevel = 1;
                group.maxLevel = 69;
                list.push(group);

                group = new GBGroup();
                group.id = 2;
                group.name = "玄武组";
                group.color = 0xD2B6FF;
                group.colorStr = "#D2B6FF";
                group.minLevel = 1;
                group.maxLevel = 69;
                list.push(group);
            }
            else
            {
                group = new GBGroup();
                group.id = 1;
                group.name = "青龙组";
                group.color = 0x63C365;
                group.colorStr = "#63C365";
                group.minLevel = 70;
                group.maxLevel = -1;
                list.push(group);

                group = new GBGroup();
                group.id = 2;
                group.name = "白虎组";
                group.color = 0xEBEDEE;
                group.colorStr = "#EBEDEE";
                group.minLevel = 70;
                group.maxLevel = -1;
                list.push(group);
            }
            return list;
        }

        /** 获取组,根据组Id */
        public static function getGroup(groupId : int) : GBGroup
        {
            return gbPlayerManager.getGroup(groupId);
        }

        /** 获取随机位置 */
        public static function getRandomPosition(groupAB :int, status : int) : Point
        {
            var point : Point;
            if (status == GBPlayerStatus.DIE)
            {
                point = groupAB == GBSystem.GROUP_A_ID ? getRandomPositionGroupA() : getRandomPositionGroupB();
            }
            else if(status == GBPlayerStatus.VS)
            {
                point = getRandomPositionVS(groupAB);
            }
            else
            {
                point = getRandomPositionRest(groupAB);
            }
            return point;
        }

        /** 获取组A随机位置 */
        public static function getRandomPositionGroupA() : Point
        {
            return GBPositionArea.aArea.getRandomAreaPoint();
        }

        /** 获取组B随机位置 */
        public static function getRandomPositionGroupB() : Point
        {
            return GBPositionArea.bArea.getRandomAreaPoint();
        }

        /** 获取PK区随机位置 */
        public static function getRandomPositionVS(groupAB : int) : Point
        {
            return GBPositionArea.vsArea.getRandomVSAreaPoint(groupAB);
        }
        
        /** 获取PK区储备中一个位置 */
        public static function getVSPosition(groupAB : int):Point
        {
            return GBPositionArea.vsPostion.getPoint(groupAB);
        }
        
        /** 获取PK区储备中一个位置根据索引 */
        public static function getVSPositionByIndex(index:int, groupAB : int):Point
        {
            return GBPositionArea.vsPostion.getPointByIndex(index, groupAB);
        }
        
        public static function get vsPositionIndex():int
        {
            return GBPositionArea.vsPostion.index;
        }
        
        /** 设置PK区储备中一个位置空闲 */
        public static function setVSPositionEmpty(point:Point, groupAB : int):void
        {
            GBPositionArea.vsPostion.setEmptyIndex(point);
            GBPositionArea.vsPostion.setEmpty(point, groupAB);
        }
        
        /** 获取休息区随机位置 */
        public static function getRandomPositionRest(groupAB : int):Point
        {
            return GBPositionArea.vsArea.getRandomRestAreaPoint(groupAB);
        }
        
        /** 获取组区自己玩家位置 */
        public static function getSelfPositionGroup():Point
        {
            return null;
        }
        
        

        /** 获取所在区域 */
        public static function getArea(x : int, y : int) : String
        {
            if (isInAreaA(x, y))
            {
                return GBPositionArea.A_AREA;
            }
            else if (isInAreaB(x, y))
            {
                return GBPositionArea.B_AREA;
            }
            else if (isInAreaVS(x, y))
            {
                return GBPositionArea.VS_AREA;
            }

            return GBPositionArea.UNKNOW_AREA;
        }

        /** 是否在A区域 */
        public static function isInAreaA(x : int, y : int) : Boolean
        {
            return GBPositionArea.aArea.isInArea(x, y);
        }

        /** 是否在B区域 */
        public static function isInAreaB(x : int, y : int) : Boolean
        {
            return GBPositionArea.bArea.isInArea(x, y);
        }
        
        /** 是否是在休息区域 */
        public static function isInAreaRest(x : int, y : int):Boolean
        {
            return GBPositionArea.vsArea.isInAreaRest(x, y);
        }

        /** 是否在PK区域 */
        public static function isInAreaVS(x : int, y : int) : Boolean
        {
            return GBPositionArea.vsArea.isInAreaVS(x, y);
        }
    }
}
