package game.module.map.animal
{
	import log4a.Logger;
	import game.core.avatar.AvatarThumb;

    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-27   ����6:27:11 
     */
    public class AnimalAction
    {
        /** Avatar */
        protected var _avatar : AvatarThumb;

        /** Avatar */
        public function get avatar() : AvatarThumb
        {
            return _avatar;
        }

        function AnimalAction(avatar : AvatarThumb) : void
        {
            _avatar = avatar;
        }

        
        /** 跑步 */
		public function runAction(goX : int, goY : int, targetX : int, targetY : int) : void
		{
            avatar.run(goX, goY, targetX, targetY);
		}

		/** 站立 */
		public function standAction() : void
		{
            avatar.stand();
		}
		
		/** 站立方向 */
		public function standDirection(targetX:int, targetY:int, x:int = 0, y:int = 0):void
		{
			avatar.standDirection(targetX, targetY, x, y);
		}

		/** 打坐 */
		public function sitdownAction() : void
		{
            avatar.sitdown();
		}

		/** 正面准备战斗(战斗站立) */
		public function fontReadyBattleAction() : void
		{
            avatar.fontReadyBattle();
		}

		/** 背面准备战斗(战斗站立) */
		public function backReadyBattleAction() : void
		{
            avatar.backReadyBattle();
		}

		/** 正面物理攻击 */
		public function fontAttackAction() : void
		{
            avatar.fontAttack();
		}

		/** 背面物理攻击 */
		public function backAttackAction() : void
		{
            avatar.backAttack();
		}

		/** 正面技能攻击 */
		public function fontSkillAttackAction() : void
		{
            avatar.fontSkillAttack();
		}

		/** 背面技能攻击 */
		public function backSkillAttackAction() : void
		{
            avatar.backSkillAttack();
		}

		/** 正面被攻击 */
		public function fontHitAction() : void
		{
            avatar.fontHit();
		}

		/** 背面被攻击 */
		public function backHitAction() : void
		{
            avatar.backHit();
		}

        
		/** 物理攻击 */
		public function attackAction(targetX:int ,targetY:int) : void
		{
			Logger.info("player attack");
            if(targetX > avatar.x)
            {
                fontAttackAction();
            }
            else
            {
                
                backAttackAction();
            }
        }
    }
}
