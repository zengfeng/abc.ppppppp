package game.module.mapFishing.element
{
	import game.core.avatar.AvatarFisher;
	import game.module.fishing.FishingManager;
	import game.module.fishing.pool.FishingChairVO;
	import game.module.fishing.pool.FishingPool;
	import game.module.map.MapSystem;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.utils.MapTo;
	import log4a.Logger;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-15 ����3:21:06
	 */
	public class FishingPlayer
	{
		private static const FISHER_AVATAR_ID : uint = 167772187;
		public var playerId : int;
		public var playerAnimal : PlayerAnimal;
		public var fisherAvatar : AvatarFisher;
		public var chair : FishingChairVO;

		/** 进入钓鱼模式 */
		public function enter() : void
		{
			// chair = FishingPool.instance.takeChair(playerId, onKicked);
			chair = FishingPool.instance.takeChair(playerId, onStand, onSit, playerAnimal.struct.x, playerAnimal.struct.y);

			playerAnimal.avatar.player.visible = false;
			playerAnimal.avatar.hideName();
			Logger.info("进入钓鱼,隐藏玩家avator ");
			if (chair.usage == "sit")
			{
				onSit();
//				playerAnimal.avatar.changeModel(27);
			}
			else if (chair.usage == "stand")
			{
				onStand();
//				playerAnimal.avatar.changeModel(0);
			}
		}

		/** 退出钓鱼模式 */
		public function out() : void
		{
			FishingPool.instance.returnChair(chair, playerId);

			if (fisherAvatar)
				fisherAvatar.hide();

			playerAnimal.avatar.player.visible = true;
			playerAnimal.avatar.showName();
			Logger.info("退出钓鱼,恢复玩家avator ");
		}

		public function updateName() : void
		{
			if (fisherAvatar)
				fisherAvatar.setName(playerAnimal.struct.name, playerAnimal.struct.colorStr);
		}

		protected function onStand() : Boolean
		{
			if (fisherAvatar)
				fisherAvatar.hide();

			return true;
		}

		protected function onSit() : Boolean
		{
			if (!fisherAvatar)
			{
				fisherAvatar = new AvatarFisher(chair.position);
				fisherAvatar.setName(playerAnimal.struct.name, playerAnimal.struct.colorStr);
				fisherAvatar.initAvatar(FISHER_AVATAR_ID);
				fisherAvatar.sit();
			}

			playerAnimal.avatar.addChild(fisherAvatar);
			return true;
		}
	}
}
