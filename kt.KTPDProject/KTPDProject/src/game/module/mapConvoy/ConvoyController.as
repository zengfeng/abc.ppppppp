package game.module.mapConvoy
{
    import com.commUI.alert.Alert;
    import flash.utils.setTimeout;
    import game.core.user.UserData;
    import game.manager.EnWalkManager;
    import game.manager.ViewManager;
    import game.module.map.MapController;
    import game.module.map.MapSystem;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animalstruct.PlayerStruct;
    import game.module.map.utils.MapUtil;
    import game.module.map.utils.PlayerModelUtil;
    import game.module.mapConvoy.element.ConvoyPlayer;
    import game.module.mapConvoy.element.ConvoySelfPlayer;
    import game.module.mapConvoy.ui.ConvoyInfoBox2;
    import game.net.data.StoC.SCConvoyInfoRes;




    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-6   ����4:52:52 
     */
    public class ConvoyController
    {
        public function ConvoyController(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : ConvoyController;

        /** 获取单例对像 */
        static public function get instance() : ConvoyController
        {
            if (_instance == null)
            {
                _instance = new ConvoyController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;
        /** 龟仙拜佛玩家管理器 */
        private var convoyPlayerManager : ConvoyPlayerManager = ConvoyPlayerManager.instance;

        /** 获取玩家动物 */
        private function getPlayerAnimal(playerId : int) : PlayerAnimal
        {
            return animalManager.getPlayer(playerId);
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 是否进仙龟拜佛 */
        private var _isEnter : Boolean = true;

        /** 是否进仙龟拜佛 */
        public function get isEnter() : Boolean
        {
            return _isEnter;
        }

        /** 自己玩家ID */
        private function get selfPlayerId() : int
        {
            return UserData.instance.playerId;
        }

        /** 自己龟拜玩家 */
        private var convoySelfPlayer : ConvoySelfPlayer;

        /** 自己是否在龟拜中 */
        public function get selfIsConvoying() : Boolean
        {
            return convoySelfPlayer ? true : false;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 地图安装完成 */
        public function mapSetupComplete() : void
        {
            if (MapUtil.getCurrentMapId() == MapSystem.MAIN_MAP_ID)
            {
                enterMap();
            }
            else
            {
                quitMap();
            }
        }

        /** 进入仙龟拜佛地图 */
        public function enterMap() : void
        {
            _isEnter = true;
        }

        /** 退出仙龟拜佛地图 */
        public function quitMap() : void
        {
            _isEnter = false;
            convoyPlayerManager.clear();
            sc_over();
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var infoBox : ConvoyInfoBox2;

        /** 服务器发来开始 */
        public function sc_start(quality : int, time : int, isRate : Boolean) : void
        {
            infoBox = ConvoyInfoBox2.instance;
            infoBox.quality = quality;
            infoBox.time = time + 4 * 2;
            infoBox.fastForwarding = false;
            infoBox.isShowIconCircle = isRate;
            infoBox.show();
            if (convoySelfPlayer)
            {
                infoBox.getItemIconContentCall = convoySelfPlayer.getTipContent;
            }
        }

        /** 服务器发来结束 */
        public function sc_over() : void
        {
            if (infoBox)
            {
                infoBox.stopTimer();
                infoBox.hide();
            }
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 验证玩家是否在仙龟拜佛 */
        public function checkPlayer(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null) return;
            if (PlayerModelUtil.isNormal(playerStruct.model) == true)
            {
                playerOut(playerStruct.id);
            }
            else if (PlayerModelUtil.isConvory(playerStruct.model) == true)
            {
                playerIn(playerStruct.id, playerStruct.model);
            }
        }

        /** 自己进入仙龟拜佛模式 */
        public function selfIn() : void
        {
            MapController.instance.enMouseMove = false;
            ViewManager.refreshShowState();
            if (infoBox)
            {
                infoBox.getItemIconContentCall = convoySelfPlayer.getTipContent;
            }
            EnWalkManager.addCheckEnWalk(checkEnWalk);
        }

        /** 自己退出仙龟拜佛模式 */
        public function selfOut() : void
        {
            EnWalkManager.removeCheckEnWalk(checkEnWalk);
            // Alert.show("自己退出仙龟拜佛模式");
            MapController.instance.enMouseMove = true;
            ViewManager.refreshShowState();
            animalManager.selfPlayer.stopMove();

            sc_over();
        }

        private var checkEnWalkPassArr : Array = [EnWalkManager.TO_MAP, EnWalkManager.TRANSPORT_TO];

        public function checkEnWalk(doWhat : int = 0) : Boolean
        {
            if ( checkEnWalkPassArr.indexOf(doWhat) != -1)
            {
                return true;
            }
            infoBox.quitButtonOnClick();
            return false;
        }

        /** 玩家进入仙龟拜佛模式 */
        public function playerIn(playerId : int, model : int) : void
        {
            var convoyPlayer : ConvoyPlayer = convoyPlayerManager.getPlayer(playerId);
            // 如果该玩家已经在龟拜中
            if (convoyPlayer != null)
            {
                convoyPlayer.updateModel(model);

                if (playerId == selfPlayerId && infoBox != null)
                {
                    var isSpeedUp : Boolean = ConvoyUtil.modelIsSpeedUp(model);
                    if (isSpeedUp == false)
                    {
                        setTimeout(function() : void
                        {
                            infoBox.fastForwarding = false;
                        }, 2000);
                    }
                    else
                    {
                        infoBox.fastForwarding = true;
                    }
                }
                return;
            }

            convoyPlayer = playerId != selfPlayerId ? new ConvoyPlayer() : new ConvoySelfPlayer();
            convoyPlayer.playerId = playerId;
            convoyPlayer.model = model;
            convoyPlayer.playerAnimal = getPlayerAnimal(playerId);
            if(convoyPlayer.playerAnimal == null) return;
            convoyPlayer.initialize();
            convoyPlayerManager.addPlayer(convoyPlayer);
            if (playerId == selfPlayerId)
            {
                convoySelfPlayer = convoyPlayer as ConvoySelfPlayer;
                selfIn();
                convoySelfPlayer.toNextWayPoint();
            }
        }

        /** 玩家退出仙龟拜佛模式 */
        public function playerOut(playerId : int) : void
        {
            // Alert.show("玩家退出仙龟拜佛模式 "+playerId);
            var convoyPlayer : ConvoyPlayer = convoyPlayerManager.getPlayer(playerId);
            if (convoyPlayer == null) return;
            convoyPlayer.out();
            convoyPlayerManager.removePlayer(playerId);
            if (playerId == selfPlayerId)
            {
                convoySelfPlayer = null;
                selfOut();
            }
        }

        /** 协议监听 -- 0xD1 到达指定地点返回*/
        public function sc_arrivePonit(wayPointIndex : int, time : int) : void
        {
            if (convoySelfPlayer == null) return;
            convoySelfPlayer.scCheckArriveWayPoint(wayPointIndex, time);
            // Alert.show("wayPointIndex="+wayPointIndex + "   time="+time);
            if (wayPointIndex == ConvoyConfig.WAY_POINT_COUNT && time == 0)
            {
                sc_over();
            }

            if (infoBox && time == 0)
            {
                infoBox.immediatelyGold = 100 - wayPointIndex * 25;
            }
        }

        /** 协议监听 -- 0xD2 玩家香炉信息返回*/
        public function sc_convoyInfo(msg : SCConvoyInfoRes) : void
        {
            var convoyPlayer : ConvoyPlayer = convoyPlayerManager.getPlayer(msg.playerId);
            if (convoyPlayer == null) return;
            convoyPlayer.sc_convoyInfo(msg);
            if (msg.playerId == selfPlayerId)
            {
                if (infoBox) infoBox.updateItemIconTipContent();
            }
        }

        /** 协议监听 -- 0xD5 加速运镖*/
        public function sc_instantConvoy(fastForward : Boolean, time : int) : void
        {
            if (infoBox)
            {
                infoBox.time = time + convoySelfPlayer.wayPointIndex * 2;
                infoBox.fastForwarding = true;
            }

            if (convoySelfPlayer) convoySelfPlayer.toNextWayPoint();

            if (fastForward == false && convoySelfPlayer != null)
            {
                convoySelfPlayer.toCompleteWayPoint();
            }
        }
    }
}
class Singleton
{
}
