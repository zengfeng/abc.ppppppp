package maps.elements.actions
{
	import game.core.avatar.AvatarThumb;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderBattleAction
    {
        private var avatar : AvatarThumb;

        function RenderBattleAction(avatar : AvatarThumb) : void
        {
            this.avatar = avatar;
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
        public function attackAction(targetX : int, targetY : int) : void
        {
            if (targetX > avatar.x)
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
