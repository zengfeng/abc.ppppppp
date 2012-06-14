package game.module.mapClanEscort
{
    import com.commUI.button.ExitButton;
    import game.module.map.MapSystem;
    import game.module.map.utils.MapUtil;
    import com.commUI.UIPlayerStatus;
    import com.commUI.alert.Alert;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    import game.core.menu.QuitButton;
    import game.core.user.StateManager;
    import game.core.user.UserData;
    import game.module.battle.view.BTSystem;
    import game.module.map.MapController;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.AnimalType;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animal.SelfPlayerAnimal;
    import game.module.mapClanEscort.element.Dray;
    import game.module.mapClanEscort.element.RelationStruct;




    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-23   ����10:49:29 
     */
    public class MCEController {
        public function MCEController(singleton : Singleton)
        {
            singleton;
        }
		
		public var deadplayerlist:Vector.<uint> = new Vector.<uint>() ;
		public var battleplayerlist:Vector.<uint> = new Vector.<uint>();
		public var battleplayerpath : Vector.<uint>;
		public var selfstatus:int = 0;
		public var selftime:int = 0 ;
        public var selfPath : int = -1 ;
        /** 单例对像 */
        private static var _instance : MCEController;

        /** 获取单例对像 */
        static public function get instance() : MCEController
        {
            if (_instance == null)
            {
                _instance = new MCEController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var proto : MCEProto = MCEProto.instance;
        /** 镖车字典 */
        public var drayDic : Dictionary = new Dictionary();
		public var drayList : Vector.<Dray> ;

        /** 获取镖车 */
        public function getDray(drayId : int) : Dray
        {
            return drayDic[drayId];
        }

        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;

        /** 获取地图控制器 */
        private function get mapController() : MapController
        {
            return MapController.instance;
        }

        /** 自己是否死亡 */
        private var _selfIsDie : Boolean = false;

        /** 自己玩家ID */
        public function get selfPlayerId() : int
        {
            return UserData.instance.playerId;
        }

        /** 自己是否死亡 */
        public function get selfIsDie() : Boolean
        {
            return _selfIsDie;
        }

        /** 获取自己玩家 */
        public function get selfPlayer() : SelfPlayerAnimal
        {
            return animalManager.selfPlayer;
        }

        /** 获取玩家 */
        public function getPlayer(playerId : int) : PlayerAnimal
        {
            return animalManager.getAnimal(playerId, AnimalType.PLAYER) as PlayerAnimal;
        }

//        /** 离开按钮 */
//        private function get quitButton() : QuitButton
//        {
//            return QuitButton.instance;
//        }

        /** 自己玩家状态UI */
        private var _uiPlayerStatus : UIPlayerStatus;

        public function get  uiPlayerStatus() : UIPlayerStatus
        {
            if (_uiPlayerStatus == null)
            {
                _uiPlayerStatus = UIPlayerStatus.instance;
            }
            return _uiPlayerStatus;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 战斗玩家字典 */
        public var battlePlayerDic : Dictionary = new Dictionary();
        /** 死亡玩家字典 */
        public var diePlayerDic : Dictionary = new Dictionary();

        /** 将玩家加入战斗玩家字典 */
        public function addBattlePlayerToDic(playerId : int, drayId : int = -1) : void
        {
            var relationStruct : RelationStruct = battlePlayerDic[playerId];
            if (relationStruct)
            {
                relationStruct.drayId = drayId;
            }
            else
            {
                relationStruct = new RelationStruct(playerId, drayId);
                battlePlayerDic[playerId] = relationStruct;
            }
        }

        /** 将玩家从战斗玩家字典移除 */
        public function removeBattlePlayerFromDic(playerId : int) : void
        {
            delete battlePlayerDic[playerId];
        }

        /** 正常化所有战斗玩家字典里的玩家 */
        public function normalBattlePlayerList() : void
        {
            for each (var relationStruct:RelationStruct in battlePlayerDic)
            {
                playerNormal(relationStruct.playerId);
                delete battlePlayerDic[relationStruct.playerId];
            }
        }

        /** 将玩家加入死亡玩家字典 */
        public function addDiePlayerToDic(playerId : int, drayId : int = -1) : void
        {
            var relationStruct : RelationStruct = diePlayerDic[playerId];
            if (relationStruct)
            {
                relationStruct.drayId = drayId;
            }
            else
            {
                relationStruct = new RelationStruct(playerId, drayId);
                diePlayerDic[playerId] = relationStruct;
            }
        }

        /** 将玩家从死亡玩家字典移除 */
        public function removeDiePlayerFromDic(playerId : int) : void
        {
            delete diePlayerDic[playerId];
        }

        /** 正常化所有死亡玩家字典里的玩家 */
        public function normalDiePlayerList() : void
        {
            for each (var relationStruct:RelationStruct in diePlayerDic)
            {
                playerNormal(relationStruct.playerId);
                delete diePlayerDic[relationStruct.playerId];
            }
        }

        /** 玩家是死亡中 */
        public function playerIsDieing(playerId : int) : Boolean
        {
            return diePlayerDic[playerId] != null;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 进入 */
        public function sc_enter() : void
        {
            isEnter = true;
            isOver = false;
			ExitButton.instance.setVisible(true, cs_quit);
//            quitButton.clickCall = cs_quit;
//            quitButton.show();
			drayList = new Vector.<Dray>() ;
            // 临时测试
//            testDrawWay();
        }
		
//		private function onClickExit():void{
//			StateManager.instance.checkMsg(225,null,null,null,Alert.OK );
//		}
		
        public var isEnter : Boolean = false;
        private var isOver : Boolean = false;

        public function sc_over() : void
        {
            isOver = true;
            normalBattlePlayerList();
            normalDiePlayerList();
            _selfIsDie = false;
			if (faseReviveAlert) {
				faseReviveAlert.hide();
				faseReviveAlert = null ;
			}
        }

        /** 退出 */
        public function sc_quit() : void
        {
            isEnter = false;
            BTSystem.INSTANCE().removeEndCall(playerDie);
			ExitButton.instance.setVisible(false, null);
//            quitButton.clickCall = null;
//            quitButton.hide();

            for (var key:String in drayDic)
            {
                var dray : Dray = drayDic[key];
                dray.quit();
                delete drayDic[key];
            }

            normalBattlePlayerList();
            normalDiePlayerList();
            uiPlayerStatus.hide();
            _selfIsDie = false;
			if (faseReviveAlert) {
				faseReviveAlert.hide();
				faseReviveAlert = null ;
			}
            while (pList.length > 0)
            {
                var c : Sprite = pList.shift();
                c.parent.removeChild(c);
            }
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function testDrawWay() : void
        {
            var dic : Dictionary = MCEConfig.placeDic;
            for each (var placeStruct : MCEPlaceStruct in dic)
            {
                var c : Sprite = circle();
                c.x = placeStruct.x;
                c.y = placeStruct.y;
                pList.push(c);
                MapController.instance.elementLayer.addChild(c);
            }
        }

        private var pList : Vector.<Sprite> = new Vector.<Sprite>();

        public function circle() : Sprite
        {
            var sprite : Sprite = new Sprite();
            var g : Graphics = sprite.graphics;
            g.beginFill(0xFF0000);
            g.drawCircle(0, 0, 3);
            g.endFill();
            return sprite;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 向服务器发送离开 */
        public function cs_quit() : void
        {
            proto.cs_quit();
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 
         * 镖镖车被毁
         * @param id 镖车ID 
         */
        public function drayBeDestroy(drayId : int, destruct : Boolean = false) : void
        {
            var dray : Dray = getDray(drayId);
            if (dray != null)
            {
                if (destruct == false) dray.destroy();
            }
        }

        /** 
         * 镖车到达完成
         * @param id 镖车ID
         */
        public function drayComplete(drayId : int, destruct : Boolean = false) : void
        {
        }

        /** 
         * 镖车退出
         * @param id 镖车ID
         */
        public function drayQuit(drayId : int, destruct : Boolean = false) : void
        {
            if (destruct == false)
            {
                var dray : Dray = getDray(drayId);
                if (dray != null)
                {
                    dray.quit();
                }
            }
            delete drayDic[drayId] ;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 
         * 玩家战斗
         * @param playerId 玩家ID
         * @param isWin 是否胜利
         */
        public function playerBattle(playerId : int, isWin : Boolean = false, drayId : int = -1) : void
        {
            if (isOver == true) return;
            if (playerId <= 0) playerId = selfPlayerId;
            // 如果玩家正在死亡中
            if (playerIsDieing(playerId) == true) return;
            var player : PlayerAnimal = getPlayer(playerId);
            if (player)
            {
                var dray : Dray = getDray(drayId);

                if (playerId == selfPlayerId)
                {
                    _selfIsDie = !isWin;
                    uiPlayerStatus.battleing();
                    // BTSystem.addEndCall(playerDie);
                }

                var attackTargetX : Number = 5000;
                var attackTargetY : Number = 0;

                if (dray && dray.monster)
                {
                    attackTargetX = dray.monster.x;
                    attackTargetY = dray.monster.y;
                }
                else if (dray)
                {
                    attackTargetX = dray.x;
                    attackTargetY = dray.y;
                }
				player.stopMove() ;
                player.attackAction(attackTargetX, attackTargetY);
                addBattlePlayerToDic(playerId, drayId);
            }
        }

        /** 玩家恢复正常 */
        public function playerNormal(playerId : int, preIsBattle : Boolean = true) : void
        {
            if (playerId <= 0) playerId = selfPlayerId;
            var player : PlayerAnimal = getPlayer(playerId);
            if (player)
            {
                // 从战斗动作恢复
                if (preIsBattle)
                {
                    player.stand();
                }
                // 从死亡状态恢复
                else
                {
                    playerRevive(playerId);
                }

                if (playerId == selfPlayerId)
                {
                    uiPlayerStatus.hide();
                    // BTSystem.addEndCall(playerDie);
                }
                removeBattlePlayerFromDic(playerId);
                removeDiePlayerFromDic(playerId);
            }
        }

        /** 玩家死亡 */
        public function playerDie(playerId : int = 0, dieTime : int = 0) : void
        {
            if (isOver == true) return;
            if (playerId <= 0) playerId = selfPlayerId;
            var player : PlayerAnimal = getPlayer(playerId);
            if (player)
            {
                player.die();
                if (playerId == selfPlayerId)
                {
                    _selfIsDie = true;
                    // BTSystem.removeEndCall(playerDie);
                    if (dieTime > 0)
                    {
                        uiPlayerStatus.setCDTime(dieTime);
                        uiPlayerStatus.cdQuickenBtnCall = faseReviveCall;
                        uiPlayerStatus.cdCompleteCall = reviveCompleteCall;
                        uiPlayerStatus.cdTimer.setTimersTip(10);
                    }
                }
                addDiePlayerToDic(playerId);
            }
        }

        /** 玩家复活 */
        public function playerRevive(playerId : int) : void
        {
            if (playerId <= 0) playerId = selfPlayerId;
            var player : PlayerAnimal = getPlayer(playerId);
            if (player)
            {
                player.revive();
                if (playerId == selfPlayerId)
                {
                    if (faseReviveAlert) faseReviveAlert.hide();
                    _selfIsDie = false;
                    uiPlayerStatus.hide();
                }
            }

            removeBattlePlayerFromDic(playerId);
            removeDiePlayerFromDic(playerId);
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 添加镖车 */
        public function addDray(dray : Dray) : void
        {
//            dray.initialize();
            drayDic[dray.id] = dray;
			drayList.push(dray);
        }
		
		public function initEscor():void
		{
			if( mapController.mapId == MapSystem.CLAN_ESCORT_MAP_ID ){
				
				for each( var dray:Dray in drayList )
				{
					if( dray.HP != 0 || dray.status != 3 )
						dray.initialize();
				}
				for each( var id:uint in deadplayerlist )
					playerDie(id);
				for ( var i:uint = 0 ; i < battleplayerlist.length ; ++ i )
				{
					setTimeout(playerBattle,1000, battleplayerlist[i],false ,battleplayerpath[i] << 4);
				}
//				for each( var id1:uint in battleplayerlist )
//					setTimeout( playerBattle, 1000, id1);
				if (selfstatus == 1)
                {
                    setTimeout(playerBattle, 300, selfPlayerId, true, selfPath << 4 );
                    MapController.instance.enMouseMove = false;
                }
                else if (selfstatus == 2)
                {
                    playerDie(selfPlayerId, selftime);
                }
                else if (selfstatus == 3)
                {
                    setTimeout(playerBattle, 300, selfPlayerId, false , selfPath << 4);
                    MapController.instance.enMouseMove = false;
                }
				
				deadplayerlist = null ;
				battleplayerlist = null ;
				battleplayerpath = null ;
				selfstatus = 0;
				selftime = 0 ;
				selfPath = -1 ;
			}
		}

        /** 快速复活对话框 */
        private var faseReviveAlert : Alert;

        /** 快速复活 */
        private function faseReviveCall() : void
        {
            faseReviveAlert = StateManager.instance.checkMsg(126, [], faseReviveAlertCall);
        }

        /** 快速复活对话框回调 */
        private function faseReviveAlertCall(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    if (UserData.instance.gold > MCEConfig.faseReviveGold )
                    {
                        proto.cs_playerFastRevive();
                        return false;
                    }
                    break;
            }
            return true;
        }

        /** 复活时间到 */
        private function reviveCompleteCall() : void
        {
            // playerRevive(selfPlayerId);
        }
    }
}
class Singleton
{
}
