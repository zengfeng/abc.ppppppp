package game.module.quest.animation
{
	import game.core.avatar.AvatarThumb;
	import game.module.mapStory.StoryController;

	/**
	 * @author yangyiqiang
	 */
	public class ActionUtil
	{
		public static  function changeAvatarState(vo : Action) : void
		{
			var avatar : AvatarThumb = vo.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(vo.target).avatar;
			switch(int(vo.describe))
			{
				case 1:
					avatar.fontReadyBattle();
					break;
				case 2:
					avatar.fontHit(1);
					break;
				case 3:
					avatar.fontAttack(1);
					break;
				case 4:
					avatar.fontSkillAttack(1);
					break;
				case 5:
					avatar.setAction(int(vo.describe),1);
					break;
				case 6:
					avatar.backReadyBattle();
					break;
				case 7:
					avatar.backHit(1);
					break;
				case 8:
					avatar.backAttack(1);
					break;
				case 9:
					avatar.backSkillAttack(1);
					break;
				case 10:
					break;
				case 20:
					avatar.sitdown();
					break;
				case 21 :
					avatar.player.flipH=true;
					break;
				case 22:
					avatar.player.flipH=false;
					break;
				default:
					avatar.setAction(int(vo.describe) - 15);
					break;
			}
		}
	}
}
