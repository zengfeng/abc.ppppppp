package game.module.map.preload
{
	import flash.utils.Dictionary;
	import game.module.duplMap.DuplMapData;
	import game.module.duplMap.DuplUtil;
	import game.module.duplMap.data.LayerStruct;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.struct.MapStruct;
	import game.module.map.utils.MapUtil;
	import net.LibData;



	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-18
	 */
	public class PreloadDuplMap
	{
		function PreloadDuplMap(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : PreloadDuplMap;

		/** 获取单例对像 */
		static public function get instance() : PreloadDuplMap
		{
			if (_instance == null)
			{
				_instance = new PreloadDuplMap(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var mapPreloadMananger : MapPreloadManager = MapPreloadManager.instance;
		private var isSetCommon : Boolean = false;

		public function setLoadList(duplMapId : int) : void
		{
			return;
			var mapId : int = duplMapId;
			var mapStruct : MapStruct = MapUtil.getMapStruct(mapId);
			var list : Vector.<LibData> = new Vector.<LibData>();
			var libData : LibData;
			libData = LibDataUtil.pathDataSwf(mapStruct.assetsMapId);
			list.push(libData);
//			libData = LibDataUtil.thumbnail(mapStruct.assetsMapId);
//			list.push(libData);
			LibDataUtil.mapPieceList(mapId, list);
			monsterList(duplMapId, list);
//			mapPreloadMananger.list = list;
			if (isSetCommon == false)
			{
				setCommon();
			}
		}

		private function setCommon() : void
		{
			isSetCommon = true;
		}

		private function monsterList(duplMapId : int, list : Vector.<LibData>) : Vector.<LibData>
		{
			var duplId : int = DuplUtil.getDuplId(duplMapId);
			var layerId : int = DuplUtil.getLayerId(duplMapId);
			var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
			var mlist : Vector.<MonsterStruct> = layerStruct.monsterList;
			var monsterStruct : MonsterStruct;
			var dic : Dictionary = new Dictionary();
			for (var i : int = 0; i < mlist.length; i++ )
			{
				monsterStruct = mlist[i];
				var avatarId : int = monsterStruct.voBase.avatarId;
				if (!dic[avatarId])
				{
					dic[avatarId] = true;
					var libData : LibData = LibDataUtil.monster(avatarId);
					list.push(libData);
				}
			}

			return list;
		}
	}
}
class Singleton
{
}
