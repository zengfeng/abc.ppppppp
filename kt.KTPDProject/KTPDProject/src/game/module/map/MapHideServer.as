package game.module.map
{
    import com.commUI.alert.Alert;
    import flash.geom.Point;
    import game.module.map.animalManagers.FollowManager;
    import game.module.map.animalManagers.HidePlayerManager;
    import game.module.map.animalManagers.PlayerManager;
    import game.module.map.animalstruct.MonsterStruct;
    import game.module.map.utils.MapUtil;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-10 ����2:57:22
     */
    public class MapHideServer
    {
        public function MapHideServer(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : MapHideServer;

        /** 获取单例对像 */
        static public function get instance() : MapHideServer
        {
            if (_instance == null)
            {
                _instance = new MapHideServer(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var mapId : int = 1;
        public var selfPostion : Point = new Point();
        /** 安装NPC列表 */
        public var setupNpcList : Vector.<uint> = new Vector.<uint>();
        /** 安装怪物列表 */
        public var setupMonsterList : Vector.<MonsterStruct> = new Vector.<MonsterStruct>();
        /** 玩家(地图)数据结构管理 */
        private var playerManager : PlayerManager = PlayerManager.instance;
        /** 隐藏玩家(地图)数据结构管理 */
        private var hidePlayerManager : HidePlayerManager = HidePlayerManager.instance;
        /** 当前地图数据 */
        private var _curData : CurrentMapData;

        /** 当前地图数据 */
        public function get curData() : CurrentMapData
        {
            if (_curData == null)
            {
                _curData = CurrentMapData.instance;
            }
            return _curData;
        }

        /** 控制器 */
        private static var _controller : MapController ;

        /** 控制器 */
        private static function get controller() : MapController
        {
            if (_controller == null)
            {
                _controller = MapController.instance;
            }
            return _controller;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function clear() : void
        {
            while (setupNpcList.length > 0)
            {
                setupNpcList.shift();
            }

            hidePlayerManager.clear();
        }
		
		public function setNpcVisible(npcId:int, visible:Boolean):void
		{
			var index:int = setupNpcList.indexOf(npcId);
			if(visible == true)
			{
				if(index == -1)
				{
					setupNpcList.push(npcId);
				}
			}
			else
			{
				if(index != -1)
				{
					setupNpcList.splice(index, 1);
				}
			}
		}

        /** 将隐藏地图转为当前地图 */
        public function convertToCurrent() : void
        {
//            Alert.show("convertToCurrent");
            // 位置
            curData.setupPostion.x = selfPostion.x;
            curData.setupPostion.y = selfPostion.y;
            curData.selfPlayerStruct.x = selfPostion.x;
            curData.selfPlayerStruct.y = selfPostion.y;

            // NPC
            if (curData.setupNpcList == null) curData.setupNpcList = new Vector.<uint>();
            while (curData.setupNpcList.length > 0)
            {
                curData.setupNpcList.shift();
            }

            for (var i : int = 0; i < setupNpcList.length; i++)
            {
                curData.setupNpcList.push(setupNpcList[i]);
            }
            // 怪物
            if (curData.setupMonsterList == null) curData.setupMonsterList = new Vector.<MonsterStruct>();
            while (curData.setupMonsterList.length > 0)
            {
                curData.setupMonsterList.shift();
            }

            for (i = 0; i < setupMonsterList.length; i++)
            {
                curData.setupMonsterList.push(setupMonsterList[i]);
            }

            hidePlayerManager.syncToPlayerManagerList();

            if (controller.mapId == mapId)
            {
                setupMapIsSelfMap();
            }
            else
            {
                setupMapIsOtherMap();
            }
            clear();
        }

        /** 按装地图，地图不是当前地图的时候 */
        private function setupMapIsOtherMap() : void
        {
            MapSystem.setupMap(mapId, selfPostion);
        }

        /** 按装地图，地图是当前地图的时候 */
        private function setupMapIsSelfMap() : void
        {
            controller.addSelfPlayer(curData.selfPlayerStruct);
            // 添加NPC列表
            controller.addNpcList(curData.setupNpcList);
            controller.addPlayerList(playerManager.getPlayerList());
            // 添加怪物列表
            controller.addMonsterList(curData.setupMonsterList);
            MapSystem.mapMoveTo(curData.setupPostion.x, curData.setupPostion.y, 0);
            
            FollowManager.instance.reset();
        }

        /** 将当前地图数据转为隐藏地图 */
        public function convertFromCurrent() : void
        {
            
//            Alert.show("convertFromCurrent");
            // 地图ID
            mapId = MapUtil.getCurrentMapId();
            // 位置
            selfPostion = MapUtil.selfPlayerPosition;
            hidePlayerManager.syncFromPlayerManagerList();

            // NPC
            while (setupNpcList.length > 0)
            {
                setupNpcList.shift();
            }
            var i : int;
            if (curData.setupNpcList != null)
            {
                for (i = 0; i < curData.setupNpcList.length; i++)
                {
                    setupNpcList.push(curData.setupNpcList[i]);
                }
            }
            // 怪物
            while (setupMonsterList.length > 0)
            {
                setupMonsterList.shift();
            }

            if (curData.setupMonsterList != null)
            {
                for (i = 0; i < curData.setupMonsterList.length; i++)
                {
                    setupMonsterList.push(curData.setupMonsterList[i]);
                }
            }
        }
    }
}
class Singleton
{
}