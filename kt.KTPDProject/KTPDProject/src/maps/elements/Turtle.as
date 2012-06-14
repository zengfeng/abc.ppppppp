package maps.elements
{
	import maps.elements.animations.AnimationFactory;
	import maps.elements.animations.TurtleAnimation;
	import maps.elements.Element;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-4
	// ============================
	public class Turtle extends Element
	{
		protected var turtleAnimation : TurtleAnimation;

		public function Turtle()
		{
			super();
		}

		public function  reset(quality : int, playerName : String, playerColorStr : String) : void
		{
			turtleAnimation = AnimationFactory.instance.makeTurtle(quality, playerName, playerColorStr);
			setAnimation(turtleAnimation);
		}

		override public function setPosition(x : int, y : int) : void
		{
			super.setPosition(x, y);
		}

		override public function transportTo(toX : int, toY : int) : void
		{
			super.transportTo(toX, toY);
		}
	}
}