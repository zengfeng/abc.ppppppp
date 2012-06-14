package game.module.mapBossWar
{
    import game.module.map.BarrierOpened;
    import com.commUI.UIPlayerStatus;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    import flash.utils.clearTimeout;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;
    import game.core.avatar.AvatarThumb;
    import game.manager.SignalBusManager;
    import game.module.duplMap.NextDo;
    import game.module.duplMap.ui.NextDoButton;
    import game.module.map.CurrentMapData;
    import game.module.map.MapProto;
    import game.module.map.MapSystem;
    import game.module.map.animal.Animal;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.NpcAnimal;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animal.SelfPlayerAnimal;
    import game.net.core.Common;
    import game.net.data.StoC.SCPlayerWalk;
    import game.net.data.StoC.SCTransport;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����2:28:53
     */
    public class BWMapController
    {
        function BWMapController(singleton : Singleton) : void
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : BWMapController;

        /** 获取单例对像 */
        public static function get instance() : BWMapController
        {
            if (_instance == null)
            {
                _instance = new BWMapController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 当前地图数据 */
        private var _currData : CurrentMapData;

        /** 当前地图数据 */
        public function get currData() : CurrentMapData
        {
            if (_currData == null)
            {
                _currData = CurrentMapData.instance;
            }
            return _currData;
        }

        private var animalManger : AnimalManager = AnimalManager.instance;

        public function get selfPlayer() : SelfPlayerAnimal
        {
            return animalManger.selfPlayer;
        }

        public function getPlayer(playerId : int) : PlayerAnimal
        {
            return animalManger.getPlayer(playerId);
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var doorsill : AvatarThumb;

        /** 进入地图时初始化关卡 */
        public function initPathPass() : void
        {
            MapSystem.setNpcVisible(2005, true);
            var anima : Animal = animalManger.getNpc(2005);
            if (anima)
            {
                doorsill = anima.avatar;
                doorsill.mouseEnabled = false;
                doorsill.mouseChildren = false;
            }

            if (isSelfDie == false)
            {
                openDiePassPath();
            }
        }

        /** 开放复活路口 */
        private function openDiePassPath() : void
        {
			BarrierOpened.setState(BWMapConfig.diePassColor, true);
            if (doorsill) doorsill.visible = false;
            if (nextDoButton) nextDoButton.visible = true;
        }

        /** 关闭复活路口 */
        private function closeDiePassPath() : void
        {
			BarrierOpened.setState(BWMapConfig.diePassColor, false);
            if (doorsill) doorsill.visible = true;
            setNextDo(NextDo.GOTO_BATTLE);
            if (nextDoButton) nextDoButton.visible = false;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 进入 */
        public function enter() : void
        {
            // 清理死亡玩家
            clearDiePlayer();
            // initPathPass();

            // 协议监听 -- 0x20 玩家走路
            Common.game_server.addCallback(0x20, sc_playerWalk);
            // 协议监听 -- 0x25 直接传送
            Common.game_server.addCallback(0x25, sc_transport);
            enterTime = getTimer();
        }

        private var enterTime : Number = 0;

        /** 退出 */
        public function quit() : void
        {
            // 协议监听 -- 0x20 玩家走路
            Common.game_server.removeCallback(0x20, sc_playerWalk);
            // 协议监听 -- 0x25 直接传送
            Common.game_server.removeCallback(0x25, sc_transport);

            SignalBusManager.battleEnd.remove(setSelfPlayerDie);
            SignalBusManager.selfStartWalk.remove(checkRestNextDo);

            // 复活
            revive();
            // 复活所有死亡玩家
            reviveAllDiePlayer();
            // 清理死亡玩家
            clearDiePlayer();
        }

        /** 自己是否死亡 */
        private var isSelfDie : Boolean = false;

        /** 玩家走路 */
        private function sc_playerWalk(msg : SCPlayerWalk) : void
        {
            if (MapSystem.hideServerMode == false)
            {
                var toX : int = msg.xy & 0x3FFF;
                var toY : int = msg.xy >> 14;
                var fromX:int = msg.fromXY & 0x3FFF;
                var fromY:int = msg.fromXY >> 14;
                checkPlayerIsReive(msg.playerId, toX, toY, fromX, fromY);
            }
        }

        /** 协议监听 -- 0x25 传送 */
        private function sc_transport(msg : SCTransport) : void
        {
            checkPlayerIsDie(msg.playerId);
        }

        /** 死亡玩家列表 */
        private var diePlayerList : Vector.<uint> = new Vector.<uint>();

        /** 加入死亡玩家 */
        private function addDiePlayer(playerId : int) : void
        {
            var index : int = diePlayerList.indexOf(playerId);
            if (index == -1)
            {
                diePlayerList.push(playerId);
            }
        }

        /** 移除死亡玩家 */
        private function removeDiePlayer(playerId : int) : void
        {
            var index : int = diePlayerList.indexOf(playerId);
            if (index != -1)
            {
                diePlayerList.splice(index, 1);
            }
        }

        /** 清理死亡玩家 */
        private function clearDiePlayer() : void
        {
            while (diePlayerList.length > 0)
            {
                diePlayerList.shift();
            }
        }

        /** 是否死亡 */
        private function isDie(playerId : int) : Boolean
        {
            return diePlayerList.indexOf(playerId) != -1;
        }

        /** 检查玩家是否复活 */
        private function checkPlayerIsReive(playerId : int, toX : int, toY : int, fromX:int, fromY:int) : void
        {
            if (isDie(playerId) == false)
            {
                return;
            }

            if (fromX < 1800 && fromY < 1104)
            {
                return;
            }

            if (BWMapConfig.reviveArea.isInArea(toX, toY) == false)
            {
                revive(playerId);
            }
        }

        /** 检查玩家是否死亡 */
        private function checkPlayerIsDie(playerId : int) : void
        {
            if (isDie(playerId) == false)
            {
                return;
            }

            setPlayerDie(playerId);
        }

        /** 设置自己玩家死亡 */
        private function setSelfPlayerDie() : void
        {
            // Alert.show("设置自己玩家死亡");
            setPlayerDie(selfPlayer.id);
        }

        private var _battleEndCallObj : Object;

        private function get battleEndCallObj() : Object
        {
            if (_battleEndCallObj == null)
            {
                _battleEndCallObj = new Object();
                _battleEndCallObj["fun"] = setSelfPlayerDie;
                _battleEndCallObj["arg"] = [];
            }
            return _battleEndCallObj;
        }

        private var setPlayerBattleTimerDic : Dictionary = new Dictionary();

        /** 死亡 */
        public function die(playerId : int = 0) : void
        {
            if (playerId == selfPlayer.id || playerId == 0)
            {
                isSelfDie = true;
                selfPlayer.stopMove();
                if (getTimer() - enterTime > 1000)
                {
                    // setTimeout(setSelfPlayerDie, 10000);
                    SignalBusManager.battleEnd.add(setSelfPlayerDie);
                }
                else
                {
                    setSelfPlayerDie();
                }
            }
            else
            {
                addDiePlayer(playerId);
                if (getTimer() - enterTime > 1000)
                {
                    var timer : uint = setTimeout(setPlayerBattle, 500, playerId);
                    setPlayerBattleTimerDic[playerId] = timer;
                }
                else
                {
                    var playerAnimal : PlayerAnimal;
                    playerAnimal = getPlayer(playerId);
                    if (playerAnimal.y <= 1300)
                    {
                        setTimeout(setPlayerBattle, 500, playerId);
                        setPlayerBattleTimerDic[playerId] = timer;
                    }
                    else
                    {
                        setPlayerDie(playerId);
                    }
                }
                // setPlayerBattle(playerId);
            }
            // Alert.show(playerId + "  DIE");
        }

        /** 设置玩家战斗状态 */
        public function setPlayerBattle(playerId : int) : void
        {
            var playerAnimal : PlayerAnimal;
            if (playerId == selfPlayer.id || playerId == 0)
            {
                playerAnimal = selfPlayer;
            }
            else
            {
                playerAnimal = getPlayer(playerId);
            }

            if (playerAnimal)
            {
                playerAnimal.stopMove();
                playerAnimal.attackAction(1370, 900);
            }
        }

        /** 设置玩家死亡状态 */
        public function setPlayerDie(playerId : int) : void
        {
            var playerAnimal : PlayerAnimal;
            if (playerId == selfPlayer.id || playerId == 0)
            {
                closeDiePassPath();
                playerAnimal = selfPlayer;
                deliveryToDieArea();
                isSelfDie = true;
            }
            else
            {
                var timer : uint = setPlayerBattleTimerDic[playerId];
                if (timer) clearTimeout(timer);
                playerAnimal = getPlayer(playerId);
                addDiePlayer(playerId);
            }

            if (playerAnimal)
            {
                playerAnimal.stand();
                playerAnimal.die();
            }
        }

        /** 复活所有死亡玩家 */
        public function reviveAllDiePlayer() : void
        {
            while (diePlayerList.length > 0)
            {
                revive(diePlayerList.shift());
            }
        }

        /** 复活 */
        public function revive(playerId : int = 0) : void
        {
            // Alert.show("revive playerId = " + playerId);
            var playerAnimal : PlayerAnimal;
            if (playerId == selfPlayer.id || playerId == 0)
            {
                SignalBusManager.battleEnd.remove(setSelfPlayerDie);
                openDiePassPath();
                stopReviveTime();
                playerAnimal = selfPlayer;
                isSelfDie = false;
            }
            else
            {
                var timer : uint = setPlayerBattleTimerDic[playerId];
                if (timer) clearTimeout(timer);
                playerAnimal = getPlayer(playerId);
                removeDiePlayer(playerId);
            }

            if (playerAnimal) playerAnimal.revive();
        }

        /** 复活CD时间UI */
        private var _uiPlayerStatus : UIPlayerStatus;

        /** 复活CD时间UI */
        private function get uiPlayerStatus() : UIPlayerStatus
        {
            if (_uiPlayerStatus == null)
            {
                _uiPlayerStatus = UIPlayerStatus.instance;
            }
            return _uiPlayerStatus;
        }

        /** 设置复活时间 */
        public function setReviveTime(value : int = 0) : void
        {
            if (value > 1)
            {
                uiPlayerStatus.cdQuickenBtnCall = fastReviveButtonClickCall;
                uiPlayerStatus.cdCompleteCall = reviveCompleteCall;
                uiPlayerStatus.setCDTime(value);
            }
            else
            {
                uiPlayerStatus.clearCD();
            }
        }

        /** 设置快速复活按钮的tips **/
        public function setReviveBtnTips(pic : int) : void
        {
            uiPlayerStatus.cdTimer.setTimersTip(pic);
        }

        /** 停止复活时间 */
        public function stopReviveTime() : void
        {
            uiPlayerStatus.clearCD();
        }

        /** 快速复活按钮 点击事件 */
        public var fastReviveButtonClickCall : Function;
        /** 复活时间到了 */
        public var reviveCompleteCall : Function;

        /** 传送到复活区域 */
        private function deliveryToDieArea() : void
        {
            var position : Point = getRandomDieAreaPoint();
            // selfPlayer.moveTo(position.x, position.y);
            // MapPosition.instance.center();
            MapProto.instance.cs_transport(position.x, position.y);
        }

        /** 随机复活区域 */
        private function getRandomDieAreaPoint() : Point
        {
            return BWMapConfig.dieArea.getRandomAreaPoint();
        }

        private var _nextDoButton : NextDoButton;

        public function set nextDoButton(value : NextDoButton) : void
        {
            _nextDoButton = value;
            _nextDoButton.onClickGotoBattleCall = gotoBattle;
            _nextDoButton.visible = isSelfDie;
            setNextDo(NextDo.GOTO_BATTLE);
        }

        public function get nextDoButton() : NextDoButton
        {
            return _nextDoButton;
        }

        public function setNextDo(what : String) : void
        {
            SignalBusManager.selfStartWalk.remove(checkRestNextDo);
            if (nextDoButton) nextDoButton.nextDo = what;
        }

        public function checkRestNextDo() : void
        {
            nextDoButton.nextDo = nextDoButton.nextDo;
        }

        public function gotoBattle() : void
        {
            var npcAnimation : NpcAnimal = animalManger.getNpc(5001);
            if (npcAnimation) npcAnimation.avatar.mouseClickAction();
            setNextDo(NextDo.WALKING);
            SignalBusManager.selfStartWalk.add(checkRestNextDo);
        }
    }
}
class Singleton
{
}