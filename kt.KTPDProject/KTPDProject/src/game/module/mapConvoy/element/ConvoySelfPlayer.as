package game.module.mapConvoy.element
{
    import com.commUI.alert.Alert;
    import com.commUI.tooltip.ToolTipManager;
    import com.utils.ColorUtils;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    import game.core.item.Item;
    import game.core.item.ItemManager;
    import game.manager.SignalBusManager;
    import game.manager.ViewManager;
    import game.module.map.MapSystem;
    import game.module.map.utils.MapTo;
    import game.module.mapConvoy.ConvoyConfig;
    import game.module.quest.QuestUtil;
    import game.net.data.StoC.SCConvoyInfoRes;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-15 ����5:56:52
     */
    public class ConvoySelfPlayer extends ConvoyPlayer
    {
        /** 初始化 */
        override public function initialize() : void
        {
            super.initialize();

            // playerAnimal.avatar.removeClickCall(avatarCallFunStruct);
            // followerAnimal.avatar.removeClickCall(avatarCallFunStruct);
            playerAnimal.avatar.removeEventListener(MouseEvent.CLICK, onClick);
            followerAnimal.avatar.removeEventListener(MouseEvent.CLICK, onClick);
            playerAnimal.avatar.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            followerAnimal.avatar.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }

        override protected function resetFollowerAnimalPosition() : void
        {
        }

        /** 退出龟拜佛模式 */
        override public function out() : void
        {
            clearTimeout(toNextWayPointTimer);
            clearTimeout(csCheckArriveWayPointTimer);
            playerAnimal.stopMove();
            super.out();
        }

        public var wayPointIndex : int = 0;

        /** 去下一个路点 */
        public function toNextWayPoint() : void
        {
            if (wayPointIndex < ConvoyConfig.WAY_POINT_COUNT)
            {
                var nextWayPointIndex : int = wayPointIndex + 1;
            }
            else
            {
                Alert.show("出错 没有下一个路点");
                return;
            }
            var nextWayPoint : Point = ConvoyConfig.getWayPoint(nextWayPointIndex);
            MapSystem.mapTo.toMap(MapSystem.MAIN_MAP_ID, nextWayPoint.x, nextWayPoint.y, false, arriveNextWayPoint, [nextWayPointIndex]);
        }

        /** 去完成路点 */
        public function toCompleteWayPoint() : void
        {
            clearTimeout(toNextWayPointTimer);
            clearTimeout(csCheckArriveWayPointTimer);
            var nextWayPoint : Point = ConvoyConfig.getWayPoint(ConvoyConfig.WAY_POINT_COUNT);
            MapTo.instance.transportTo(nextWayPoint.x, nextWayPoint.y, MapSystem.MAIN_MAP_ID, arriveNextWayPoint, [ConvoyConfig.WAY_POINT_COUNT]);
        }

        /** 完成 */
        public function scComplete() : void
        {
            ViewManager.instance.playAnimation();
            // Alert.show("服务器发来完成");
        }

        /** 到达路径点 */
        public function scArriveWayPoint() : void
        {
            wayPointIndex++;
            // Alert.show("服务器发来到达一个路径点");
        }

        public function arriveNextWayPoint(wayPointIndex : int) : void
        {
            // Alert.show("到达地点" + wayPointIndex);
            csCheckArriveWayPoint();
        }

        public function csCheckArriveWayPoint() : void
        {
            clearTimeout(toNextWayPointTimer);
            clearTimeout(csCheckArriveWayPointTimer);
            SignalBusManager.questCollectProgressPlayComplete.add(progressPlayComplete);
            var wayName : String = ConvoyConfig.getWayPointNameDic(wayPointIndex + 1);
            QuestUtil.progressLoading("参拜<font color='"+ColorUtils.GOOD+"'>" + wayName + "</font>中...");
            // Alert.show("csCheckArriveWayPoint");
        }

        /** 进度完成 */
        private function progressPlayComplete() : void
        {
            SignalBusManager.questCollectProgressPlayComplete.remove(progressPlayComplete);
            convoyProto.cs_arrivePoint();
        }

        public function scCheckArriveWayPoint(wayPointIndex : int, time : int) : void
        {
            clearTimeout(toNextWayPointTimer);
            clearTimeout(csCheckArriveWayPointTimer);
            // Alert.show("服务器发来验证 wayPointIndex =" + wayPointIndex + "   time" + time);
            if (wayPointIndex <= this.wayPointIndex + 1 && time > 0)
            {
                time = time <= 0 ? 1 : time;
                csCheckArriveWayPointTimer = setTimeout(csCheckArriveWayPoint, time * 1000);
                return;
            }
            else if (wayPointIndex == ConvoyConfig.WAY_POINT_COUNT && time == 0)
            {
                scComplete();
                return;
            }
            // scArriveWayPoint();
            this.wayPointIndex = wayPointIndex;
            if (wayPointIndex < ConvoyConfig.WAY_POINT_COUNT)
            {
                toNextWayPointTimer = setTimeout(toNextWayPoint, 2000);
            }
            else
            {
                toNextWayPoint();
            }
        }

        private var toNextWayPointTimer : uint;
        private var csCheckArriveWayPointTimer : uint;

        override public function sc_convoyInfo(msg : SCConvoyInfoRes) : void
        {
            honour = msg.robHonor;
            sivler = msg.robSilver;
            beRobNum = msg.beRobNum;

            if (playerAnimal != null) ToolTipManager.instance.refreshToolTip(playerAnimal.avatar);
            if (followerAnimal != null) ToolTipManager.instance.refreshToolTip(followerAnimal.avatar);
        }

        override public function getTipContent() : String
        {
            var item : Item = ItemManager.instance.getPileItem(ConvoyConfig.xiangLuGoodsDic[quality]);
            var str : String = "";

            // str += "<font color='__PLAYER_COLOR__' size='14'><b>__PLAYER_NAME__</b></font>   __LEVEL__级\n";
            str += "护送香炉:<font color='__XIANG_LU_COLOR__'>__XIANG_LU_NAME__</font>\n";
            // str += "剩余时间:__TIME__\n";
            str += "被截次数:<font color='" + ColorUtils.HIGHLIGHT_DARK + "'>__BE_ROB_NUM__/__BE_ROB_MAX_NUM__</font>\n";
            str += "参拜进程:<font color='" + ColorUtils.HIGHLIGHT_DARK + "'>__WAY__INDEX__/__MAX_WAY_INDEX__</font>\n";
            str += "上香获得:<font color='" + ColorUtils.GOOD + "'>__SIVLER__</font>银币，";
            str += "<font color='" + ColorUtils.GOOD + "'>__HONOUR__</font>声望\n";

            // str = str.replace(/__PLAYER_COLOR__/, playerStruct.colorStr);
            // str = str.replace(/__PLAYER_NAME__/, playerStruct.name);
            // str = str.replace(/__LEVEL__/, playerStruct.level);
            str = str.replace(/__XIANG_LU_COLOR__/, ColorUtils.TEXTCOLOR[item.color]);
            str = str.replace(/__XIANG_LU_NAME__/, item.name);
            // str = str.replace(/__TIME__/, TimeUtil.toMMSS(time));
            str = str.replace(/__BE_ROB_NUM__/, beRobNum);
            str = str.replace(/__BE_ROB_MAX_NUM__/, beRobMaxNum);
            str = str.replace(/__WAY__INDEX__/, wayPointIndex);
            str = str.replace(/__MAX_WAY_INDEX__/, ConvoyConfig.WAY_POINT_COUNT);
            str = str.replace(/__SIVLER__/, sivler);
            str = str.replace(/__HONOUR__/, honour);
            return str;
        }
    }
}
