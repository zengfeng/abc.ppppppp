package maps.elements.animations
{
	import game.core.avatar.AvatarTurtle;

	import maps.elements.animations.SimpleAnimation;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-4
	// ============================
	public class TurtleAnimation extends SimpleAnimation
	{
		protected var turtleAvatar : AvatarTurtle;

		public function reset(quality : int, playerName : String, playerColorStr : String) : void
		{
			turtleAvatar = AvatarFactory.instance.makeTurtle(quality, playerName, playerColorStr);
			setAvatar(turtleAvatar);
		}

		override public function destory() : void
		{
			super.destory();
			turtleAvatar = null;
		}
	}
}
