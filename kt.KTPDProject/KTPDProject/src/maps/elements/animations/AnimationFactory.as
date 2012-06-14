package maps.elements.animations
{
	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-4
	// ============================
	public class AnimationFactory
	{
		/** 单例对像 */
		private static var _instance : AnimationFactory;

		/** 获取单例对像 */
		public static  function get instance() : AnimationFactory
		{
			if (_instance == null)
			{
				_instance = new AnimationFactory(new Singleton());
			}
			return _instance;
		}

		function AnimationFactory(singleton : Singleton) : void
		{
			singleton;
			avatarFactory = AvatarFactory.instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var avatarFactory : AvatarFactory;

		public function makeTurtle(quality : int, playerName : String, playerColorStr : String) : TurtleAnimation
		{
			var animation:TurtleAnimation = new TurtleAnimation();
			animation.reset(quality, playerName, playerColorStr);
			return animation;
		}
	}
}
class Singleton
{
}
