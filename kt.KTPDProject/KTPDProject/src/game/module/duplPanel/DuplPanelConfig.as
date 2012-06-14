package game.module.duplPanel
{
    import com.utils.ColorUtils;
    import game.core.user.UserData;

    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-12
     */
    public class DuplPanelConfig
    {
        /** 头像图标半径 */
        public static const HEAD_ICON_RADIUS : int = 45;
        /** 头像图标宽 */
        public static const HEAD_ICON_WIDTH : int = 90;
        /** 头像图标高 */
        public static const HEAD_ICON_Height : int = 90;
        public static var LOG_SPECIFICATION : String = "<font size='14'><b>挂机小提示：</b></font>\n1.离线也可挂机\n2.当包裹满时停止挂机";
        public static var LOG_START : String = "挂机开始啦";
        public static var LOG_HOOK_NUM : String = "<b>第__NUM__次挂机</b>";
        public static var LOG_MONSTER_BATTLEING : String = "第__NUM__个怪，战斗中……";
        public static var LOG_MONSTER_WIN : String = "第__NUM__个怪，战斗胜利";
        public static var LOG_AWARD_EXP : String = "经验<font color='#279f15'>__EXP__</font> ";
        public static var LOG_AWARD_SILVER : String = "银币<font color='#279f15'>__SILVER__</font> ";
        public static var LOG_AWARD_GOODS : String = "__GOODS__ ";
        public static var LOG_PACK_FULL : String = "<font color='" + ColorUtils.WARN + "'>包裹不足，已停止挂机</font>";
        public static var LOG_GOLD_OUTOF : String = "<font color='" + ColorUtils.WARN + "'>元宝不足，已停止挂机</font>";
        public static var LOG_NORMAL_OVER : String = "完成";
        public static var LOG_STOP : String = "手动停止";
        public static var LOG_AWARD_GOODS_NUM_COLOR : String = "#FF3300";
        /** 副本挂机最少需要包裹 */
        public static const HOOK_MIN_PACK_EMPTY : int = 15;
        /** 购买副本次数费用 */
        public static var HOOK_FAST_GOLD : int = 10;

        /** 购买副本次数费用 */
        public static function get BUY_NUM_GOLD() : uint
        {
            return UserData.instance.dungeonGold;
        }
    }
}
