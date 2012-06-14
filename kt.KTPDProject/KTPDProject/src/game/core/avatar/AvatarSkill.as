package game.core.avatar
{
	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * @author yangyiqiang
	 */
	public class AvatarSkill extends AbstractAvatar
	{
		public function AvatarSkill()
		{
			super();
		}

		override protected function initComplete(event : Event) : void
		{
			// setAction(_action,1);
			// player.addEventListener(Event.COMPLETE, skillComplete);
			// _avatarBd.removeEventListener(Event.COMPLETE, initComplete);
			// updateDisplays();
			// playShowAction();
			// change();
			//trace("initComplete");
		}

		private var _mc : MovieClip;

		private var _isMc : Boolean = false;

		override public function setAction(value : int, loop : int = 0, index : int = 0, arr : Array = null) : void
		{
			if (_isMc)
			{
				if (_mc)
					_mc.gotoAndPlay(1);
				return;
			}
			super.setAction(value, loop, index, arr);
		}

		protected function skillComplete(event : Event) : void
		{
			hide();
			dispose();
		}

		override public function dispose() : void
		{
		
		}
	}
}
