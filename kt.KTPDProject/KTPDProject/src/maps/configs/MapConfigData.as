package maps.configs
{
	import game.core.user.UserData;
	import game.manager.RSSManager;
	import game.module.duplMap.DuplMapData;
	import game.module.quest.VoNpc;

	import maps.MapUtil;
	import maps.configs.structs.GateStruct;
	import maps.configs.structs.MapStruct;
	import maps.elements.structs.NpcStruct;

	import flash.geom.Point;
	import flash.utils.Dictionary;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class MapConfigData
    {
        /** 单例对像 */
        private static var _instance : MapConfigData;

        /** 获取单例对像 */
        static public function get instance() : MapConfigData
        {
            if (_instance == null)
            {
                _instance = new MapConfigData(new Singleton());
            }
            return _instance;
        }

        public function MapConfigData(singleton : Singleton)
        {
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 地图字典,存入 MapStruct 使用 id 做索引 */
        public var mapDic : Dictionary = new Dictionary();

        /** 获取地图数据结构 */
        public function getMapStruct(mapId : uint) : MapStruct
        {
            return mapDic[mapId];
        }

        public function parseMaps(mapXmlDic : Dictionary) : void
        {
            for each (var map:XML in mapXmlDic)
            {
                var mapXml : XMLList = map.child("scene");
                var mapStruct : MapStruct = new MapStruct();
                // 地图基本信息
                mapStruct.id = int(mapXml.attribute("id"));
                mapStruct.assetId = int(mapXml.attribute("assetsMapId")) ;
                mapStruct.assetId = mapStruct.assetId ? mapStruct.assetId : mapStruct.id ;
                mapStruct.name = mapXml.attribute("name");
                mapStruct.mapWidth = int(mapXml.attribute("width"));
                mapStruct.mapHeight = int(mapXml.attribute("height"));
                mapStruct.pieceCountX = mapStruct.mapWidth / LandConfig.PIECE_WIDTH;
                mapStruct.pieceCountY = mapStruct.mapHeight / LandConfig.PIECE_HEIGHT;
                mapStruct.mapWidth = mapStruct.pieceCountX * LandConfig.PIECE_WIDTH;
                mapStruct.mapHeight = mapStruct.pieceCountY * LandConfig.PIECE_HEIGHT;

                // NPC数据
                var npcStruct : NpcStruct;
                var voNpc :VoNpc;
                var pointXmlList : XMLList;
                var max : int;
                var j : int;
                var npcXml : XMLList = mapXml.child("npc");
                var npcId : int;
                for (var i : int = 0; i < npcXml.length(); i++)
                {
                    npcId = npcXml[i].@id;
                    voNpc = RSSManager.getInstance().getNpcById(npcId);
                    if (!voNpc) continue;
                    voNpc.mapId = mapStruct.id;
                    voNpc.x = npcXml[i].@x;
                    voNpc.y = npcXml[i].@y;
                    npcStruct = new NpcStruct();
                    npcStruct.id = npcId;
                    npcStruct.name = voNpc.name;
                    npcStruct.x = voNpc.x;
                    npcStruct.y = voNpc.y ;
                    npcStruct.position.x = npcStruct.x;
                    npcStruct.position.y = npcStruct.y;
                    pointXmlList = npcXml[i]["point"];
                    max = pointXmlList.length();
                    for (j = 0; j < max; j++)
                    {
                        npcStruct.standPostion.push(new Point(pointXmlList[j].@x, pointXmlList[j].@y));
                    }
                    mapStruct.npcDic[npcStruct.id] = npcStruct;
                }

                // 注入怪物数据
                if (MapUtil.isDuplMap(mapStruct.id) == true)
                {
                    var duplMapData : DuplMapData = DuplMapData.instance;
                    var monsterXml : XMLList = mapXml.child("monster");
                    duplMapData.parseMapXML(mapStruct.id, monsterXml);
                }

                // 注入gate数据
                var gateXml : XMLList = mapXml.child("gate");
                for (i = 0; i < gateXml.length(); i++)
                {
                    var gateStruct : GateStruct = new GateStruct();
                    gateStruct.x = gateXml[i].@x;
                    gateStruct.y = gateXml[i].@y;
                    gateStruct.position.x = gateStruct.x ;
                    gateStruct.position.y = gateStruct.y ;

                    gateStruct.standX = gateXml[i].@standX;
                    gateStruct.standY = gateXml[i].@standY;
                    gateStruct.standPosition.x = gateStruct.standX ;
                    gateStruct.standPosition.y = gateStruct.standY ;
                    if (gateXml[i].@kind == "in")
                    {
                        gateStruct.toMapId = mapStruct.id;
                        mapStruct.freeGates[gateStruct.toMapId] = gateStruct;
                    }
                    else
                    {
                        gateStruct.toMapId = gateXml[i].@toScene;
                        mapStruct.linkGates[gateStruct.toMapId] = gateStruct;
                    }
                }
                mapDic[mapStruct.id] = mapStruct;
            }

            MapUtil.setCurrentMapId(UserData.instance.loginMapId);
        }
    }
}
class Singleton
{
}