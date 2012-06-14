package game.module.mapConvoy.element
{
    import com.commUI.alert.Alert;
    import com.commUI.tooltip.ToolTip;
    import com.commUI.tooltip.ToolTipManager;
    import com.utils.CallFunStruct;
    import com.utils.ColorUtils;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;
    import game.core.avatar.AvatarMonster;
    import game.core.avatar.AvatarPlayer;
    import game.core.avatar.AvatarTurtle;
    import game.core.item.Item;
    import game.core.item.ItemManager;
    import game.core.user.StateManager;
    import game.manager.MouseManager;
    import game.manager.RSSManager;
    import game.module.map.MapSystem;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.FollowerAnimal;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animalManagers.FollowManager;
    import game.module.map.animalstruct.FollowerStruct;
    import game.module.map.animalstruct.PlayerStruct;
    import game.module.map.utils.MapUtil;
    import game.module.mapConvoy.ConvoyConfig;
    import game.module.mapConvoy.ConvoyProto;
    import game.module.mapConvoy.ConvoyUtil;
    import game.module.quest.VoBase;
    import game.net.data.StoC.SCConvoyInfoRes;
    import log4a.Logger;








    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-15 ����3:21:06
     */
    public class ConvoyPlayer
    {
        public var playerId : int;
        public var model : int;
        public var quality : int = -1;
        public var sourceSpeed : Number = 20;
        public var playerAnimal : PlayerAnimal;
        public var followerAnimal : FollowerAnimal;
        public var playerStruct : PlayerStruct;
        public var followerStruct : FollowerStruct;
        public var _isSpeedUp : Boolean = false;
        private var initialized : Boolean = false;
        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;
        /** 跟随管理器 */
        private var followManager : FollowManager = FollowManager.instance;
        protected var convoyProto : ConvoyProto = ConvoyProto.instance;
        protected var avatarCallFunStruct : CallFunStruct;
        protected var onClickPosition : Point;

        /** 初始化 */
        public function initialize() : void
        {
            if (initialized == true) return;
            initialized = true;
            if (quality == -1) quality = ConvoyUtil.getQuality(model);
            if (playerStruct == null) playerStruct = playerAnimal.playerStruct;

            if (getTimer() - MapSystem.changeMapTime < 1000)
            {
                if (playerStruct.x != playerStruct.toX || playerStruct.y != playerStruct.toY)
                {
                    playerAnimal.setSpeed(ConvoyUtil.getSpeed(model));
                    playerAnimal.updateMove();
                }
            }
            // if(playerStruct.x != playerStruct.toX || playerStruct.y != playerStruct.toY)
            // {
            // var time:Number = getTimer() - playerAnimal.startTime;
            // Alert.show(time);
            // var speed:Number = ConvoyUtil.getSpeed(model) / 1000;
            // var distance:Number = speed * time;
            // var point:Point = MapUtil.getDistancePoint(playerStruct.x, playerStruct.y, playerStruct.toX, playerStruct.toY, distance);
            // playerAnimal.transport(point.x, point.y);
            // playerAnimal.arrive(playerStruct.toX, playerStruct.toY);
            // }
            // else
            // {
            // playerAnimal.transport(playerStruct.toX, playerStruct.toY);
            // }

            playerAnimal.standAction();
            setTimeout(playerAnimal.avatar.addSeat, 500, 1);
            // playerAnimal.avatar.addSeat(1);
            // 创建龟
            followerStruct = new FollowerStruct();
            var baseId : int = ConvoyUtil.getFollowerAvatarId(quality);
            var voBase : VoBase = RSSManager.getInstance().getNpcById(baseId);
            followerStruct.id = playerId;
            followerStruct.avatarId = voBase.avatarId;
            followerStruct.name = playerStruct.name + "的" + voBase.name;
            followerStruct.x = playerAnimal.x;
            followerStruct.y = playerAnimal.y;
            followerAnimal = animalManager.addAnimal(followerStruct) as FollowerAnimal;
            followManager.add(playerId, followerStruct.animalType, playerId, playerStruct.animalType);

            ToolTipManager.instance.registerToolTip(playerAnimal.avatar, ToolTip, getTipContent);
            ToolTipManager.instance.registerToolTip(followerAnimal.avatar, ToolTip, getTipContent);

            onClickPosition = new Point();
            onClickPosition.x = playerAnimal.x;
            onClickPosition.y = playerAnimal.y;
            avatarCallFunStruct = new CallFunStruct(onClickCall);
            // playerAnimal.avatar.addClickCall(avatarCallFunStruct);
            // followerAnimal.avatar.addClickCall(avatarCallFunStruct);

            playerAnimal.avatar.addEventListener(MouseEvent.MOUSE_OVER, cs_convoyInfo);
            followerAnimal.avatar.addEventListener(MouseEvent.MOUSE_OVER, cs_convoyInfo);
            playerAnimal.avatar.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            followerAnimal.avatar.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            playerAnimal.avatar.addEventListener(MouseEvent.CLICK, onClick);
            followerAnimal.avatar.addEventListener(MouseEvent.CLICK, onClick);

            (followerAnimal.avatar as AvatarTurtle).setQuality(quality);

            // var followerAvatar : AvatarTurtle = followerAnimal.avatar as AvatarTurtle;
            // followerAvatar.removeEventListener(MouseEvent.ROLL_OUT, followerAvatar.onRollOut);
            // followerAvatar.removeEventListener(MouseEvent.ROLL_OVER, followerAvatar.onRollOver);
            isSpeedUp = ConvoyUtil.modelIsSpeedUp(model);
            setTimeout(resetFollowerAnimalPosition, 500);
        }

        protected function resetFollowerAnimalPosition() : void
        {
            if (followerAnimal)
            {
                followerAnimal.stopMove();
                followerAnimal.moveTo(playerAnimal.x, playerAnimal.y);
                playerAnimal.animalFollowDrive.moveStart(playerStruct.toX, playerStruct.toY);
            }
        }

        protected function onClick(event : Event = null) : void
        {
            if (MapSystem.enMouseClickMovePlayer == false) return;
            onClickPosition.x = playerAnimal.x;
            onClickPosition.y = playerAnimal.y;
            MapSystem.mapTo.toAvatarPosition(onClickPosition.x, onClickPosition.y, onClickCall);
            if (event) event.stopPropagation();
        }

        protected function onClickCall() : void
        {
            // Alert.show("onClickCall");

            Logger.info("onClickCall");
            if (followerAnimal == null || playerAnimal == null)
            {
                StateManager.instance.checkMsg(258);
                return;
            }

            var distance : Number = Point.distance(onClickPosition, playerAnimal.position);
            if (distance > 500)
            {
                StateManager.instance.checkMsg(258);
                return;
            }

            convoyProto.cs_attackConvoy(playerId);
        }

        /** 退出龟拜佛模式 */
        public function out() : void
        {
            isSpeedUp = false;
            playerAnimal.speed = playerStruct.speed;
            playerAnimal.avatar.removeEventListener(MouseEvent.MOUSE_OVER, cs_convoyInfo);
            followerAnimal.avatar.removeEventListener(MouseEvent.MOUSE_OVER, cs_convoyInfo);
            playerAnimal.avatar.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            followerAnimal.avatar.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

            // playerAnimal.avatar.removeClickCall(avatarCallFunStruct);
            // followerAnimal.avatar.removeClickCall(avatarCallFunStruct);
            playerAnimal.avatar.removeEventListener(MouseEvent.CLICK, onClick);
            followerAnimal.avatar.removeEventListener(MouseEvent.CLICK, onClick);
            ToolTipManager.instance.destroyToolTip(playerAnimal.avatar);
            ToolTipManager.instance.destroyToolTip(followerAnimal.avatar);
            followManager.removeFollow(playerId, followerAnimal.animalType);
            // playerAnimal.removeFollower(followerAnimal);
            followerAnimal.quit();
            playerAnimal.avatar.removeSeat();
            playerAnimal = null;
            followerAnimal = null;
        }

        public function get isSpeedUp() : Boolean
        {
            return _isSpeedUp;
        }

        public function set isSpeedUp(value : Boolean) : void
        {
            _isSpeedUp = value;
            playerAnimal.speed = _isSpeedUp == false ? ConvoyConfig.NORMAL_SPEED : ConvoyConfig.FAST_SPEED;
            // followerAnimal.speed = playerAnimal.speed;
        }

        public function updateModel(value : int) : void
        {
            model = value;
            quality = ConvoyUtil.getQuality(model);
            isSpeedUp = ConvoyUtil.modelIsSpeedUp(model);
        }

        private function cs_convoyInfo(event : MouseEvent = null) : void
        {
            convoyProto.cs_convoyInfo(playerId);
            if (playerId != MapUtil.selfPlayerId)
            {
                MouseManager.cursor = MouseManager.BATTLE;
            }
        }

        protected function onMouseOut(event : MouseEvent = null) : void
        {
            MouseManager.cursor = MouseManager.ARROW;
        }

        public function sc_convoyInfo(msg : SCConvoyInfoRes) : void
        {
            honour = msg.robHonor;
            sivler = msg.robSilver;
            beRobNum = msg.beRobNum;
            robNum = msg.robNum;

            if (playerAnimal != null) ToolTipManager.instance.refreshToolTip(playerAnimal.avatar);
            if (followerAnimal != null) ToolTipManager.instance.refreshToolTip(followerAnimal.avatar);
        }

        // private var time:uint = 0;
        protected var beRobNum : int = 0;
        protected var beRobMaxNum : int = 2;
        protected var sivler : int = 100;
        protected var honour : int = 10;
        protected var robNum : int = 3;

        public function getTipContent() : String
        {
            var item : Item = ItemManager.instance.getPileItem(ConvoyConfig.xiangLuGoodsDic[quality]);
            var str : String = "";
            str += "<font color='__PLAYER_COLOR__' size='14'><b>__PLAYER_NAME__</b></font>   __LEVEL__级\n";
            str += "护送香炉:<font color='__XIANG_LU_COLOR__'>__XIANG_LU_NAME__</font>\n";
            // str += "剩余时间:__TIME__\n";
            str += "被截次数:<font color='" + ColorUtils.HIGHLIGHT_DARK + "'>__BE_ROB_NUM__/__BE_ROB_MAX_NUM__</font>\n";
            str += "打劫获得:<font color='" + ColorUtils.GOOD + "'>__SIVLER__</font>银币，";
            str += "<font color='" + ColorUtils.GOOD + "'>__HONOUR__</font>修为\n";
            if(beRobNum < beRobMaxNum)
            {
                str += "<font color='" + ColorUtils.HIGHLIGHT_DARK + "'>今天还能打劫__GOB_NUM__次</font>";
            }
            else
            {
                str += "<font color='" + ColorUtils.WARN + "'>该玩家已被劫空</font>";
            }

            str = str.replace(/__PLAYER_COLOR__/, playerStruct.colorStr);
            str = str.replace(/__PLAYER_NAME__/, playerStruct.name);
            str = str.replace(/__LEVEL__/, playerStruct.level);
            str = str.replace(/__XIANG_LU_COLOR__/, ColorUtils.TEXTCOLOR[item.color]);
            str = str.replace(/__XIANG_LU_NAME__/, item.name);
            // str = str.replace(/__TIME__/, TimeUtil.toMMSS(time));
            str = str.replace(/__BE_ROB_NUM__/, beRobNum);
            str = str.replace(/__BE_ROB_MAX_NUM__/, beRobMaxNum);
            str = str.replace(/__SIVLER__/, sivler);
            str = str.replace(/__HONOUR__/, honour);
            str = str.replace(/__GOB_NUM__/, robNum);
            return str;
        }
    }
}
