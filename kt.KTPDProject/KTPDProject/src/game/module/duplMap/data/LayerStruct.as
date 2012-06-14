package game.module.duplMap.data
{
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.quest.VoBase;

	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
	 */
	public class LayerStruct
	{
		/** 层ID */
		public var id : int;
		/** 地图ID */
		public var mapId : int;
		/** 怪物列表 */
		public var monsterList:Vector.<MonsterStruct> = new Vector.<MonsterStruct>();

		public function getMonster(wave : int) : MonsterStruct
		{
			if(monsterList.length < wave) return null;
			var index:int = wave - 1;
			return monsterList[index];
		}
		
		public function getIconMonster():MonsterStruct
		{
			return getMonster(1);
		}
		
		public function getMaxWave():int
		{
			return monsterList.length;
		}
        
        //====================
        //  层的其他信息
        //====================
        public var coverMonsterVoBase:VoBase;
        public var items:Vector.<uint> = new Vector.<uint>();
	}
}
