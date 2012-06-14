package game.module.duplMap
{
    import com.commUI.alert.Alert;
    import com.utils.ColorUtils;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    import game.core.item.Item;
    import game.core.item.ItemManager;
    import game.manager.RSSManager;
    import game.module.duplMap.data.DuplStruct;
    import game.module.duplMap.data.LayerStruct;
    import game.module.map.animalstruct.MonsterStruct;



    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
     */
    public class DuplMapData
    {
        function DuplMapData(singleton : Singleton)
        {
        }

        /** 单例对像 */
        private static var _instance : DuplMapData;

        /** 获取单例对像 */
        public static function get instance() : DuplMapData
        {
            if (_instance == null)
            {
                _instance = new DuplMapData(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var duplDic : Dictionary = new Dictionary();

        public function getDuplStruct(duplId : int) : DuplStruct
        {
            return duplDic[duplId];
        }

        public function getLayerStruct(duplId : int, layerId : int) : LayerStruct
        {
            var duplStruct : DuplStruct = getDuplStruct(duplId);
            if (duplStruct)
            {
                return duplStruct.getLayer(layerId);
            }
            return null;
        }

        public function getMonsterStrct(duplId : int, layerId : int, wave : int) : MonsterStruct
        {
            var duplStruct : DuplStruct = getDuplStruct(duplId);
            if (duplStruct)
            {
                var layerStruct : LayerStruct = getLayerStruct(duplId, layerId);
                if (layerStruct )
                {
                    return layerStruct.getMonster(wave);
                }
            }
            return null;
        }

        public function getLevelDownDuplStructList(level : int) : Vector.<DuplStruct>
        {
            var list : Vector.<DuplStruct> = new Vector.<DuplStruct>();
            for each(var duplStruct:DuplStruct in duplDic)
            {
				var demonDuplId:int = duplStruct.id / 10;
                if(duplStruct.enterLevel <= level && DuplOpened.isOpened(demonDuplId))
                {
                    list.push(duplStruct);
                }
            }
            return list;
        }

        public function parseDungeonInfoCSV(tempArray : Array) : void
        {
            if (tempArray == null)
            {
                return;
            }
            var duplStruct : DuplStruct ;
            for each (var arr:Array in tempArray)
            {
                var id : int = parseInt(arr[0]) ;
                var name : String = arr[1];
                duplStruct = duplDic[id];
                if (duplStruct == null)
                {
                    duplStruct = new DuplStruct();
                }
                duplStruct.id = id;
                duplStruct.name = name;
                duplStruct.enterLevel = parseInt(arr[2]) ;
                duplStruct.itemStr = arr[3];
                duplDic[duplStruct.id] = duplStruct;
            }
        }

        public function parseDungeonCSV(tempArray : Array) : void
        {
            var duplStruct : DuplStruct ;
            var layerStruct : LayerStruct;
            var arr : Array;
            for each (arr in tempArray)
            {
                var monsterStruct : MonsterStruct = new MonsterStruct();
                monsterStruct.parse(arr);
                duplStruct = duplDic[monsterStruct.duplId];
                if (duplStruct)
                {
                    layerStruct = duplStruct.layerDic[monsterStruct.layerId];
                    if (layerStruct == null)
                    {
                        layerStruct = new LayerStruct();
                        layerStruct.id = monsterStruct.layerId;
                        layerStruct.mapId = monsterStruct.mapId;
                        duplStruct.layerDic[monsterStruct.layerId] = layerStruct;
                    }
                    layerStruct.monsterList.push(monsterStruct);
                    if (monsterStruct.isBoss) duplStruct.bossDic[monsterStruct.mapId] = monsterStruct;
                }
            }
        }

        public function parseMapXML(mapId : int, monsterXMLList : XMLList) : void
        {
            var duplId : int = DuplUtil.getDuplId(mapId);
            var layerId : int = DuplUtil.getLayerId(mapId);
            var layerStruct : LayerStruct = getLayerStruct(duplId, layerId);
            if (layerStruct == null)
            {
                Alert.show("DuplMapData::parseMapXML 没有找到 layerStruct" + mapId);
                return;
            }
            var length : int = monsterXMLList.length();
            for (var i : int = 0; i < length; i++)
            {
                var wave : uint = monsterXMLList[i].@wave;
                var monsterStruct : MonsterStruct = layerStruct.getMonster(wave);
                if (monsterStruct)
                {
                    monsterStruct.position.x = monsterXMLList[i].@x;
                    monsterStruct.position.y = monsterXMLList[i].@y;
                    monsterStruct.moveRadius = monsterXMLList[i].@moveRadius;
                    monsterStruct.attackRadius = monsterXMLList[i].@attackRadius;
                    monsterStruct.passColor = monsterXMLList[i].@passColor;
                    var pointXMLList : XMLList = monsterXMLList[i]["point"];
                    var pointXmlListLength : int = pointXMLList.length();
                    for (var j : int = 0; j < pointXmlListLength; j++)
                    {
                        monsterStruct.standPoint.push(new Point(pointXMLList[j].@x, pointXMLList[j].@y));
                    }
                    monsterStruct.standPoint.push(monsterStruct.position);
                }
            }
        }

        public function parseDungeonLayerTipCSV(tempArray : Array) : void
        {
            var arr : Array;
            for each (arr in tempArray)
            {
                var duplMapId : int = parseInt(arr[0]) ;
                var monsterId : int = parseInt(arr[1]) ;
                var itemsStr : String = arr[2];

                var itemsArr : Array = itemsStr.length > 0 ? itemsStr.split("/") : [];

                var duplId : int = DuplUtil.getDuplId(duplMapId);
                var layerId : int = DuplUtil.getLayerId(duplMapId);
                var layerStruct : LayerStruct = getLayerStruct(duplId, layerId);

                layerStruct.coverMonsterVoBase = RSSManager.getInstance().getMosterById(monsterId);
                while (itemsArr.length > 0)
                {
                    var itemId : int = parseInt(itemsArr.pop());
                    if (itemId != 0)
                    {
                        layerStruct.items.push(itemId);
                    }
                }
            }
        }

        public function parseDungeonLayerTipXML(xml : XML) : void
        {
            var xmlList : XMLList = xml..layer;
            var length : int = xmlList.length();
            for (var i : int = 0; i < length; i++)
            {
                var layerXML : XML = xmlList[i];
                var duplMapId : uint = layerXML.@id;
                var tipStr : String = layerXML.children()[0];
                tipStr = tipStr.replace(/\\n/img, "\n");
                layerTipDic[duplMapId] = tipStr;
            }
        }

        private var layerTipDic : Dictionary = new Dictionary();
        private const TEXT_TIP : String = "<font color='" + ColorUtils.HIGHLIGHT_DARK + "'><b>__MONSTER_NAME__</b></font>\n<font color='#FFFFFF'>掉落：</font>\n";
        private const TEXT_TIP_ITEM : String = "<font color='__COLOR__'>__NAME__</font>\n";

        public function getLayerTip(duplMapId : int, type:int = 100) : String
        {
			if(type == 10)
			{
				duplMapId = DuplUtil.getDemonBossIdByDuplMapId(duplMapId);
			}
            var str : String = layerTipDic[duplMapId];
            if (str)
            {
                return str;
            }
            return null;
            var duplId : int = DuplUtil.getDuplId(duplMapId);
            var layerId : int = DuplUtil.getLayerId(duplMapId);
            var layerStruct : LayerStruct = getLayerStruct(duplId, layerId);
            str = TEXT_TIP.replace(/__MONSTER_NAME__/i, layerStruct.coverMonsterVoBase.name);
            for (var i : int = 0; i < layerStruct.items.length; i++)
            {
                var voItem : Item = ItemManager.instance.newItem(layerStruct.items[i]);
                var itemStr : String = TEXT_TIP_ITEM.replace(/__NAME__/i, voItem.name);
                itemStr = itemStr.replace(/__COLOR__/i, ColorUtils.TEXTCOLOR[voItem.color]);
                str += itemStr;
            }
            str = str.substring(0, str.length - 2);
            layerTipDic[duplMapId] = str;
            return str;
        }
    }
}
class Singleton
{
}