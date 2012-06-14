package game.module.enhance
{
	import gameui.controls.BDPlayer;
	import gameui.core.GComponentData;

	/**
	 * @author jian
	 */
	public class EffectPlayer extends BDPlayer
	{
		public function EffectPlayer(base : GComponentData)
		{
			super(base);
		}
		
		override public function action(timer : uint) : void
		{
			super.action(timer);
		}
	}
}
