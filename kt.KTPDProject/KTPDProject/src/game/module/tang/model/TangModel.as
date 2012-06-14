package game.module.tang.model
{
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animal.Animal;
	/**
	 * @author jian
	 */
	public class TangModel
	{
		// 副本状态，未开启，开启，胜利，失败
		public var gameState:int;
		// 游戏时间
		public var gameTime:int;
		// 防护罩血量
		public var shieldHP:int;
		// 自己的状态，空闲，战斗，复活
		public var selfState:int;
		// 当前攻击怪物ID
		public var enemy:Animal;
		// 副本玩家列表
		public var playerList:Vector.<PlayerAnimal>;
		// 玩家自己
		public var selfPlayer:SelfPlayerAnimal;
	}
}
