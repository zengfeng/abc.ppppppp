package game.module.map
{
	import game.core.user.UserData;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.struct.MapStruct;
	import game.module.map.utils.MapUtil;

	import flash.geom.Point;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����3:03:58
     * 当前地图数据
     */
    public final class CurrentMapData
    {
        function CurrentMapData(singleton : Singleton) : void
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : CurrentMapData;

        /** 获取单例对像 */
        static public function get instance() : CurrentMapData
        {
            if (_instance == null)
            {
                _instance = new CurrentMapData(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 控制器 */
        private var controller : MapController;
        /** 模型 */
        private var model : MapModel = MapModel.instance;
        /** 地图ID */
        private var _mapId : uint;
        /** 地图数据结构 */
        public var mapStruct : MapStruct;
        /** 是否需要预加载 */
        private var _isNeedPreload : Boolean;
        /** 安装地图时自己的位置 */
        public var setupPostion : Point = new Point();
        /** 自己玩家数据结构 */
        private var _selfPlayerStruct : SelfPlayerStruct;
        /** 安装NPC列表 */
        public var setupNpcList : Vector.<uint> = new Vector.<uint>();
        /** 安装怪物列表 */
        public var setupMonsterList : Vector.<MonsterStruct> = new Vector.<MonsterStruct>();

        public function setNpcVisible(npcId : uint, visible : Boolean) : void
        {
            var index : int = setupNpcList.indexOf(npcId);
            if (visible == true)
            {
                if (index == -1) setupNpcList.push(npcId);
            }
            else
            {
                if (index != -1) setupNpcList.splice(index, 1);
            }
        }

        /** 自己玩家数据结构 */
        public function get selfPlayerStruct() : SelfPlayerStruct
        {
            if (_selfPlayerStruct == null)
            {
                // 自己玩家
                _selfPlayerStruct = new SelfPlayerStruct();
                _selfPlayerStruct.id = UserData.instance.playerId;
                _selfPlayerStruct.name = UserData.instance.playerName;
                _selfPlayerStruct.job = UserData.instance.myHero.job;
                _selfPlayerStruct.heroId = UserData.instance.myHero.id;
            }
            return _selfPlayerStruct;
        }

        public function set selfPlayerStruct(struct : SelfPlayerStruct) : void
        {
            _selfPlayerStruct = struct;
        }

        /** 地图ID */
        public function get mapId() : uint
        {
            return _mapId;
        }

        public function set mapId(mapId : uint) : void
        {
            if (controller) controller = MapController.instance;
            if (mapId <= 0) return;
            _mapId = mapId;
            mapStruct = model.getMapStruct(mapId);
            // 设置 是否需要预加载
            _isNeedPreload = MapUtil.isDungeonMap(mapId) ? true : false;
            // _isNeedPreload = MapUtil.isSpecialMap(mapId) ? true : false;
        }

        /** 是否需要预加载 */
        public function get isNeedPreload() : Boolean
        {
            return _isNeedPreload;
        }


        public function clear() : void
        {
        }

        public function clearSetup() : void
        {
            while (setupNpcList.length > 0)
            {
                setupNpcList.shift();
            }

            while (setupMonsterList.length > 0)
            {
                setupMonsterList.shift();
            }
        }
    }
}
class Singleton
{
}
