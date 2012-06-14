package game.module.mapClanEscort
{
    import com.commUI.alert.Alert;
    import flash.utils.setTimeout;
    import game.core.user.StateManager;
    import game.core.user.UserData;
    import game.module.map.MapController;
    import game.module.mapClanEscort.element.Dray;
    import game.module.mapClanEscort.ui.ClanEscortResultPanel;
    import game.net.core.Common;
    import game.net.data.CtoS.CSGEEnter;
    import game.net.data.CtoS.CSGELeave;
    import game.net.data.CtoS.CSGEPlayerBattle;
    import game.net.data.CtoS.CSGEPlayerFastRevive;
    import game.net.data.StoC.GEDrayData;
    import game.net.data.StoC.SCGEDrayComplete;
    import game.net.data.StoC.SCGEDraySyn;
    import game.net.data.StoC.SCGEEnterInfo;
    import game.net.data.StoC.SCGEInfo;
    import game.net.data.StoC.SCGELeave;
    import game.net.data.StoC.SCGEPlayerBattle;
    import game.net.data.StoC.SCGEPlayerBattleEnd;
    import game.net.data.StoC.SCGEPlayerRevive;
    import game.net.data.StoC.SCGEResult;



    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-23   ����10:39:55 
     */
    public class MCEProto
    {
        public function MCEProto(singleton : Singleton)
        {
            singleton;
            sToC();
        }

        /** 单例对像 */
        private static var _instance : MCEProto;

        /** 获取单例对像 */
        static public function get instance() : MCEProto
        {
            if (_instance == null)
            {
                _instance = new MCEProto(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 控制器 */
        private var _controller : MCEController;

        /** 控制器 */
        public function get controller() : MCEController
        {
            if (_controller == null)
            {
                _controller = MCEController.instance;
            }
            return _controller;
        }

        /** 自己玩家ID */
        public function get selfPlayerId() : int
        {
            return UserData.instance.playerId;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 协议监听 */
        private function sToC() : void
        {
            // 协议监听 -- 0x2F2 家族运镖信息
            Common.game_server.addCallback(0x2F2, sc_info);
        }

        private function addCallBackList() : void
        {
            // 协议监听 -- 0x2F3 镖车同步消息
            Common.game_server.addCallback(0x2F3, sc_draySynchro);
            // 协议监听 -- 0x2F4 镖车到达完成
            Common.game_server.addCallback(0x2F4, sc_drayComplete);
            // 协议监听 -- 0x2F5 玩家战斗
            Common.game_server.addCallback(0x2F5, sc_playerBattle);
            // 协议监听 -- 0x2F6 玩家复活
            Common.game_server.addCallback(0x2F6, sc_playerRevive);
            // 协议监听 -- 0x2F7 结算
            Common.game_server.addCallback(0x2F7, sc_result);
            // 协议监听 -- 0x2F8 退出
            Common.game_server.addCallback(0x2F8, sc_quit);
            // 协议监听 -- 0x2F9 玩家死亡
            Common.game_server.addCallback(0x2F9, sc_playerEnter);
            // 协议监听 -- 0x2FA 玩家战斗结束
            Common.game_server.addCallback(0x2FA, sc_playerBattleEnd);
        }

        private function removeCallBackList() : void
        {
            // 协议监听 -- 0x2F3 镖车同步消息
            Common.game_server.removeCallback(0x2F3, sc_draySynchro);
            // 协议监听 -- 0x2F4 镖车到达完成
            Common.game_server.removeCallback(0x2F4, sc_drayComplete);
            // 协议监听 -- 0x2F5 玩家战斗
            Common.game_server.removeCallback(0x2F5, sc_playerBattle);
            // 协议监听 -- 0x2F6 玩家复活
            Common.game_server.removeCallback(0x2F6, sc_playerRevive);
            // 协议监听 -- 0x2F7 结算
            Common.game_server.removeCallback(0x2F7, sc_result);
            // 协议监听 -- 0x2F8 退出
            Common.game_server.removeCallback(0x2F8, sc_quit);
            // 协议监听 -- 0x2F9 玩家死亡
            Common.game_server.removeCallback(0x2F9, sc_playerEnter);
        }

        /** 协议监听 -- 0x2F2 家族运镖信息 */
        private function sc_info(msg : SCGEInfo) : void
        {
            addCallBackList();
            controller.sc_enter();
            var dray : Dray;
            var drayData : GEDrayData;

            // 设置镖车
            for (var i : int = 0; i < msg.drayList.length; i++)
            {
                drayData = msg.drayList[i];
                dray = new Dray();
                dray.id = drayData.drayId;
                dray.pathId = MCEUtil.getPathIdByDrayId(drayData.drayId);
                dray.status = drayData.status >> 29;
                dray.placeId = drayData.status & 0xFFFF;
                dray.walkedTime = (drayData.status & 0x1FFF0000) >> 16;
                // Alert.show("dray.id = " +dray.id + "   dray.status=" + dray.status + "  dray.placeId="+ dray.placeId  + "dray.walkedTime" + dray.walkedTime);
                dray.HP = drayData.hP;
                if (drayData.hasMonsterTotalHP) dray.monsterTotalHP = drayData.monsterTotalHP;
                dray.monsterHP = drayData.hasMonsterHP ? drayData.monsterHP : drayData.monsterTotalHP;
                controller.addDray(dray);
            }
            // 设置死亡玩家
            //for (i = 0; i < msg.diePlayerList.length; i++)
            //{
                //controller.playerDie(msg.diePlayerList[i]);
            //}
            controller.deadplayerlist = msg.diePlayerList ;

            // 设置战斗玩家
//            for (i = 0; i < msg.battlePlayerList.length; i++)
//            {
//                setTimeout(controller.playerBattle, 1000, msg.battlePlayerList[i]);
//            }
			controller.battleplayerlist = msg.battlePlayerList ;
			controller.battleplayerpath = msg.battlePlayerPath ;

            // 设置自己状态
            if (msg.hasRevtime == true)
            {
                // 14-15bit: 1:战斗->胜利, 2:死亡 , 3:战斗->死亡, 没有:打酱油
                controller.selfstatus = msg.revtime >> 14;
                controller.selftime = msg.revtime & 0x3FFF;
				controller.selfPath = msg.hasPath ? msg.path : -1 ;
//                if (selfStatus == 1)
//                {
//                    setTimeout(controller.playerBattle, 300, selfPlayerId, true);
//                    MapController.instance.enMouseMove = false;
//                }
//                else if (selfStatus == 2)
//                {
//                    controller.playerDie(selfPlayerId, selfTime);
//                }
//                else if (selfStatus == 3)
//                {
//                    setTimeout(controller.playerBattle, 300, selfPlayerId, false);
//                    MapController.instance.enMouseMove = false;
//                }
            }
        }

        /** 协议监听 -- 0x2F3 镖车同步消息 */
        public function sc_draySynchro(msg : SCGEDraySyn) : void
        {
            var drayData : GEDrayData = msg.dray;
            var dray : Dray = controller.getDray(drayData.drayId);
            dray.status = drayData.status >> 29;
            dray.placeId = drayData.status & 0xFFFF;
            if (drayData.hasHP) dray.HP = drayData.hP;
            if (drayData.hasMonsterTotalHP) dray.monsterTotalHP = drayData.monsterTotalHP;
            if (drayData.hasMonsterHP) dray.monsterHP = drayData.monsterHP;
            // //trace("镖车同步 id=" + dray.id + "   status=" + dray.status + "   HP=" + dray.HP + "   pathId=" + dray.pathId + "   placeId=" + dray.placeId + "   monsterHP=" + dray.monsterHP + "   monsterTotalHP=" + dray.monsterTotalHP);
            dray.refreshStatus();
        }

        /** 协议监听 -- 0x2F4 镖车到达完成  */
        private function sc_drayComplete(msg : SCGEDrayComplete) : void
        {
            var dray : Dray = controller.getDray(msg.drayId);
            if (dray == null) return;
            if (msg.success == true)
            {
                dray.complete();
            }
            else
            {
                dray.destroy();
            }
        }

        /** 协议监听 -- 0x2F5 玩家战斗  */
        private function sc_playerBattle(msg : SCGEPlayerBattle) : void
        {
            var dray : Dray = controller.getDray(msg.drayId);
            dray.monsterHP = msg.health;
            var isWin : Boolean = msg.health <= 0;
            setTimeout(controller.playerBattle, 1000, msg.playerId, isWin, msg.drayId);
        }

        /** 协议监听 -- 0x2FA 玩家战斗结束  */
        private function sc_playerBattleEnd(msg : SCGEPlayerBattleEnd) : void
        {
            // 战斗胜利
            if (msg.hasDeadtim == false)
            {
                controller.playerNormal(msg.player, true);
            }
            // 战斗失败
            else
            {
                // var status:Number = msg.deadtim >> 14;
                // var time:Number = msg.deadtim - (status << 14);
                controller.playerDie(msg.player, msg.deadtim);
            }

            // 如果是自己玩家
            if (msg.player == selfPlayerId)
            {
//                Alert.show("自己战斗结束");
                MapController.instance.enMouseMove = true;
            }
        }

        /** 协议监听 -- 0x2F6 玩家复活  */
        private function sc_playerRevive(msg : SCGEPlayerRevive) : void
        {
            controller.playerRevive(msg.playerId);
            // 如果是自己玩家
            if (msg.playerId == selfPlayerId)
            {
                MapController.instance.enMouseMove = true;
            }
        }

        /** 协议监听 -- 0x2F7 结算  */
        private function sc_result(msg : SCGEResult) : void
        {
//            Alert.show("结算");
            if(controller.isEnter == false) return;
            ClanEscortResultPanel.instance.scMsg(msg);
            controller.sc_over();
        }

        /** 协议监听 -- 0x2F8 退出  */
        private function sc_quit(msg : SCGELeave) : void
        {
            removeCallBackList();
//            Alert.show("离开");
            msg;
            controller.sc_quit();
        }

        /** 协议监听 -- 0x2F9 刚进来的人是死亡了的  */
        private function sc_playerEnter(msg : SCGEEnterInfo) : void
        {
            // 0正常 1战斗失败 2死亡 3战斗死亡
            if (msg.status == 1)
            {
                setTimeout(controller.playerBattle, 1000, msg.player, true);
            }
            else if (msg.status == 2)
            {
                controller.playerDie(msg.player);
            }
            else if (msg.status == 3)
            {
                setTimeout(controller.playerBattle, 1000, msg.player, false);
            }
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 发送协议[0x2F2] -- 进入家族运镖地图 */
        public function cs_enter() : void
        {
            var msg : CSGEEnter = new CSGEEnter();
            Common.game_server.sendMessage(0x2F2, msg);
        }

        /** 发送协议[0x2F3] -- 玩家战斗 */
        public function cs_playerBattle(drayId : int) : void
        {
            if (controller.selfIsDie == true)
            {
                StateManager.instance.checkMsg(223);
                return;
            }
            // 让玩家不能点得太快
            MapController.instance.enMouseMove = false;

            var msg : CSGEPlayerBattle = new CSGEPlayerBattle();
            msg.drayId = drayId;
            Common.game_server.sendMessage(0x2F3, msg);
        }

        /** 设置鼠标是否能控制地图 */
        private function setEnMouseMove(value : Boolean = true) : void
        {
            MapController.instance.enMouseMove = value;
        }

        /** 发送协议[0x2F4] -- 玩家快速复活 */
        public function cs_playerFastRevive() : void
        {
            var msg : CSGEPlayerFastRevive = new CSGEPlayerFastRevive();
            Common.game_server.sendMessage(0x2F4, msg);
        }

        /** 发送协议[0x2F5] -- 退出 */
        public function cs_quit() : void
        {
            var msg : CSGELeave = new CSGELeave();
            Common.game_server.sendMessage(0x2F5, msg);
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
    }
}
class Singleton
{
}