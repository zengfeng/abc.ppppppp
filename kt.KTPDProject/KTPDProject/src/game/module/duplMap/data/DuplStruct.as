package game.module.duplMap.data
{
	import flash.utils.Dictionary;
	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
	 */
	public class DuplStruct
	{
		/** 副本ID */
		public var id:int = 0;
        /** 副本名称 */
        public var name : String;
        /** 锁妖塔进入等级 */
		public var enterLevel:int = 0;
        /** 掉落物品*/
		public var itemStr:String;
		
		/** 副本层字典 */
		public var layerDic:Dictionary = new Dictionary();
        /** BOSS列表 以副本地图为key= duplMapId */
        public var bossDic:Dictionary = new Dictionary();
		
		public function getLayer(layerId:int):LayerStruct
		{
			return layerDic[layerId];
		}
	}
}
