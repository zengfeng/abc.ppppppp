package game.module.map.animal
{
	import game.core.avatar.AvatarThumb;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.playerVisible.PlayerTolimitManager;
	import game.module.map.utils.MapUtil;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-15 ����2:44:28
     */
    public class FollowerAnimal extends Animal
    {
        /** 玩家显示上限管理 */
        protected var playerTolimitManager : PlayerTolimitManager = PlayerTolimitManager.instance;
        /** 关联玩家 */
        protected var relevancePlayer : PlayerAnimal;

        public function FollowerAnimal(avatar : AvatarThumb, struct : AbstractStruct)
        {
            super(avatar, struct);
        }

        /** 初始化前检查是否添加AVATAR到地图 */
        override protected function initCheckIsAddAvatar() : Boolean
        {
            if (playerTolimitManager.enable == true && id != MapUtil.selfPlayerId)
            {
                _visible = false;
                relevancePlayer = animalManager.getPlayer(id);
                if (relevancePlayer)
                {
                    visible = relevancePlayer.visible;
                    relevancePlayer.addVisibleRelevance(this);
                }
                return false;
            }
            return true;
        }

        override public function quit() : void
        {
            if (playerTolimitManager.enable == true && id != MapUtil.selfPlayerId)
            {
                if (relevancePlayer)
                {
                    relevancePlayer.removeVisibleRelevance(this);
                    relevancePlayer = null;
                }
            }
            super.quit();
        }
    }
}
