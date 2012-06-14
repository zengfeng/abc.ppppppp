package maps.elements.actions
{
	import game.core.avatar.AvatarThumb;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderWalkAction
    {
        private var avatar:AvatarThumb;
        function RenderWalkAction(avatar:AvatarThumb):void
        {
            this.avatar = avatar;
        }
        
         /** 走路 */
		public function walkAction(goX : int, goY : int, targetX : int, targetY : int) : void
		{
            avatar.run(goX, goY, targetX, targetY);
		}
    }
}