package maps.elements.animations
{
	import game.core.avatar.AvatarThumb;
	import maps.elements.ElementSignals;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-1
	// ============================
	public class SimpleAnimation
	{
		protected var x : int;
		protected var y : int;
		protected var avatar : AvatarThumb;

		protected function setAvatar(avatar : AvatarThumb) : void
		{
			this.avatar = avatar;
			ElementSignals.ADD_TO_LAYER.dispatch(avatar, 0);
		}

		public function destory() : void
		{
			ElementSignals.REMOVE_FROM_LAYER.dispatch(avatar);
			AvatarFactory.destoryAvatar(avatar);
			avatar = null;
		}

		public function setPosition(x : int, y : int) : void
		{
			this.x = x;
			this.y = y;
			avatar.x = x;
			avatar.y = y;
		}

		public function stand() : void
		{
			avatar.stand();
		}
		
		public function standDirection(targetX:int, targetY:int, x:int = 0, y:int = 0):void
		{
			avatar.standDirection(targetX, targetY, x, y);
		}

		public function run(fromX : int, fromY : int, toX : int, toY : int) : void
		{
			avatar.run(toX, toY, fromX, fromY);
		}

		public function attack(targetX : int) : void
		{
			if (targetX > x)
			{
				avatar.fontAttack();
			}
			else
			{
				avatar.backAttack();
			}
		}
	}
}
