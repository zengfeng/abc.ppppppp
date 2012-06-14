package game.module.duplMap {
	import game.module.map.BarrierOpened;
	import game.module.map.Path;
	import com.commUI.alert.Alert;
	import com.utils.CallFunStruct;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import game.core.avatar.AvatarMonster;
	import game.core.user.StateManager;
	import game.manager.GetValManager;
	import game.manager.MouseManager;
	import game.manager.SignalBusManager;
	import game.module.debug.GMMethod;
	import game.module.duplMap.data.LayerStruct;
	import game.module.duplMap.ui.DuplMapGetReward;
	import game.module.duplMap.ui.DuplMapUIC;
	import game.module.duplMap.ui.MapNameMovieClip;
	import game.module.duplPanel.DuplPanelController;
	import game.module.duplPanel.DuplPanelQuest;
	import game.module.map.CurrentMapData;
	import game.module.map.MapController;
	import game.module.map.MapProto;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.MonsterAnimal;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.animalManagers.GlobalPlayerManager;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.army.ArmyManager;
	import game.module.map.preload.PreloadDuplMap;
	import game.module.map.struct.GateStruct;
	import game.module.map.struct.MapStruct;
	import game.module.map.utils.MapPosition;
	import game.module.map.utils.MapUtil;



    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
     */
    public class DuplMapController
    {
        public function DuplMapController(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : DuplMapController;

        /** 获取单例对像 */
        public static function get instance() : DuplMapController
        {
            if (_instance == null)
            {
                _instance = new DuplMapController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var quitDuplId : int = 0;
        public var duplId : int;
        public var layerId : int;
        public var duplMapId : int;
        public var wave : int;
        public var isPass : Boolean = false;
        public var layerStruct : LayerStruct;
        public var duplProto : DuplProto = DuplProto.instance;
        public var hasItems : Boolean = false;
        /** 是否退出到父地图 */
        public var isQuitParentMap : Boolean = true;
        /** 动物管理 */
        public var animalManager : AnimalManager = AnimalManager.instance;
        /** 阵营管理 */
        private var armyManager : ArmyManager = ArmyManager.instance;
        private var uic : DuplMapUIC = DuplMapUIC.instance;
        private var mapNameMovieClip : MapNameMovieClip;

        public function setIsQuitParentMap(value : Boolean = true) : void
        {
            isQuitParentMap = value;
        }

        /** 检查路口 */
        public function checkGate(gateStruct : GateStruct) : void
        {
            if (gateStruct == null) return;
            // 从父地图进入副本
            if (MapUtil.isDungeonMap() == false && MapUtil.isDungeonMap(gateStruct.toMapId))
            {
                var duplId : int = DuplUtil.getDuplId(gateStruct.toMapId);
                DuplPanelController.instance.cs_duplInfo(duplId);
                DuplConfig.QUIT_OPEN_WEINDOW_ENTER = true;
            }
            // 退出副本
            else if (MapUtil.isDungeonMap() == true)
            {
                cs_quit();
            }
        }

        /** 进入 */
        public function enter(duplMapId : int, wave : int, enterHaveItems : Boolean) : void
        {
            if (GMMethod.isDebug) Alert.show("duplMapId=" + duplMapId + duplMapId + " wave=" + wave + "   enterHaveItems=" + enterHaveItems);
            if (wave == 0)
            {
                Alert.show("波数不正确wave=" + wave);
                return;
            }
            GetValManager.addCheckEnOpenMapWorld(checkEnOpenWorldMap);
            SignalBusManager.setIsQuitParentMap.add(setIsQuitParentMap);
            this.duplMapId = duplMapId;
            duplId = DuplUtil.getDuplId(duplMapId);
            layerId = DuplUtil.getLayerId(duplMapId);
            isPass = wave >= DuplConfig.WAVE_PASS;
            layerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
            this.wave = isPass == false ? wave : layerStruct.getMaxWave();
            hasItems = enterHaveItems;
            _gateVisible = isPass == true && hasItems == false ;
            quitDuplId = duplId;
            setup();
        }

        public function checkEnOpenWorldMap() : Boolean
        {
            Alert.show("在副本中不能打开世界地图");
            return false;
        }

        public function checkEnExit() : Boolean
        {
            if (isPass == false)
            {
                StateManager.instance.checkMsg(11, [], noPassAlertCall);
                return false;
            }
            else if (hasItems == true)
            {
                StateManager.instance.checkMsg(9);
                return false;
            }
            return true;
        }

        /** 还没通关就退出对话框回调 */
        private function noPassAlertCall(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    cs_quit(true);
                    break;
            }
            return true;
        }

        public function cs_quit(force : Boolean = false) : void
        {
            if (force == false) if (checkEnExit() == false) return;
            DuplPanelQuest.instance.cheackDefeatBossGuide(duplId, layerId, isPass);
            var parentMapId : int = DuplUtil.getParentMapId(duplMapId);
            var inMapId : int = DuplUtil.getInMapId(parentMapId);
            var postition : Point = MapUtil.getGateStandPosition(inMapId, parentMapId);
            MapProto.instance.cs_changeMap(parentMapId);
        }

        public function sc_quit() : void
        {
            GetValManager.removeCheckEnOpenMapWorld(checkEnOpenWorldMap);
            SignalBusManager.setupMapComplete.remove(sc_quit);
            SignalBusManager.mapStoryIsEnter.remove(mapStoryIsEnterCall);
            if (quitDuplId != 0 && DuplConfig.QUIT_OPEN_WEINDOW_ENTER == true)
            {
                DuplPanelController.instance.cs_duplInfo(quitDuplId);
            }
            quitDuplId = 0;
            duplMapId = 0;
            duplId = 0;
            layerId = 0;
            wave = 1;
            isPass = false;
            _gateVisible = false;
            layerStruct = null;

            armyManager.selfGroup.clear();
            armyManager.dungeonMonsterGroup.clear();
            armyManager.quit();
            uic.visible = false;
            if (mapNameMovieClip) mapNameMovieClip.hide();
            MouseManager.cursor = MouseManager.ARROW;
        }

        public function setup() : void
        {
            armyManager.init();
            var position : Point = MapUtil.getGateCenter(duplMapId, duplMapId);
            var selfPlayerStruct : SelfPlayerStruct = GlobalPlayerManager.instance.selfPlayer;
            selfPlayerStruct.x = position.x;
            selfPlayerStruct.y = position.y;
            selfPlayerStruct.checkVer();
            PreloadDuplMap.instance.setLoadList(duplMapId);
            SignalBusManager.setupMapComplete.add(mapSetupComplete);
            MapController.instance.preSetupMap(duplMapId, position);
            // SignalBusManager.setupMap.dispatch(duplMapId, position);
        }

        /** 地图安装完成 */
        public function mapSetupComplete() : void
        {
            if (MapUtil.isDungeonMap() == false)
            {
                return;
            }
            SignalBusManager.setupMapComplete.remove(mapSetupComplete);
            uic.onClickExitCall = onClickExit;
            uic.nextDoButton.onClickGotoBattleCall = gotoBattle;
            uic.nextDoButton.onClickGotoExitCall = gotoExitGate;
            uic.nextDoButton.onClickGetRewardCall = gotoGetReward;
            uic.visible = true;

            if (isPass == false)
            {
                installMonster();
                setNextDo(NextDo.GOTO_BATTLE);
            }
            else if (hasItems == true)
            {
                installDieBoss();
                setNextDo(NextDo.GET_REWARD);
            }
            else
            {
                setNextDo(NextDo.GOTO_EXIT);
            }

            if (mapNameMovieClip == null)
            {
                mapNameMovieClip = MapNameMovieClip.instance;
            }
            var mapStruct : MapStruct = MapUtil.getMapStruct();
            mapNameMovieClip.setName(mapStruct.name);
            mapNameMovieClip.show();

            SignalBusManager.setupMapComplete.add(sc_quit);
            SignalBusManager.mapStoryIsEnter.add(mapStoryIsEnterCall);
        }

        public function installMonster() : void
        {
//            var monsterList : Vector.<MonsterStruct> = layerStruct.monsterList;
//            var length : int = monsterList.length;
//            for (var i : int = wave - 1; i < length; i++)
//            {
//                var monsterStruct : MonsterStruct = monsterList[i];
//                var monsterAnimal : MonsterAnimal = animalManager.addAnimal(monsterStruct) as MonsterAnimal;
//                monsterAnimal.addBattleeCallFun(cs_battle);
//                armyManager.dungeonMonsterGroup.add(monsterAnimal);
//            }
//
//            // 添加触发剧情怪物
//            var duplPanelQuest : DuplPanelQuest = DuplPanelQuest.instance;
//            if (duplPanelQuest.hasDuplStoryBattlePre(duplId, layerId))
//            {
//                monsterStruct = DuplPanelQuest.instance.getStoryActivateMonsterStruct();
//                monsterAnimal = animalManager.addAnimal(monsterStruct) as MonsterAnimal;
//                monsterAnimal.avatar.alpha = 0;
//                monsterAnimal.addBattleeCallFun(monsterActivateStory);
//                armyManager.dungeonMonsterGroup.add(monsterAnimal);
//            }
//
//            armyManager.selfGroup.add(selfPlayerAnimal);
//
//            // 阵营开始运行
//            armyManager.start();
        }

        public function installDieBoss() : void
        {
            armyPause();
            var monsterStruct : MonsterStruct = layerStruct.getMonster(wave);
            var monsterAnimal : MonsterAnimal = animalManager.addAnimal(monsterStruct) as MonsterAnimal;
            battleMonsterIsBoss = true;
            battleMonsterAnimal = monsterAnimal;
            battleMonsterAnimal.die();
            battleMonsterAnimal.avatar.addClickCall(friskCall);
            duplProto.cs_getAwardInfo();
        }

        public function armyPlay() : void
        {
//            armyManager.selfGroup.add(selfPlayerAnimal);
//            armyManager.play();
        }

        public function armyPause() : void
        {
//            armyManager.pause();
//            armyManager.selfGroup.remove(selfPlayerAnimal);
        }

        /** 战斗怪物 */
        public var battleMonsterAnimal : MonsterAnimal;
        public var battleMonsterIsBoss : Boolean = false;

        /** 发送:怪物要战斗 */
        public function cs_battle(monsterAnimal : MonsterAnimal) : void
        {
//            SignalBusManager.battleEnd.add(battleEnd);
//            battleMonsterAnimal = monsterAnimal;
//            battleMonsterIsBoss = battleMonsterAnimal.monsterStruct.isBoss;
//            MapController.instance.enMouseMove = false;
//            armyPause();
//            duplProto.cs_battle();
//            MouseManager.cursor = MouseManager.ARROW;
        }

        public const  BATTLE_OVER_WIN : int = 1;
        public const  BATTLE_OVER_LOSE : int = 2;
        public const  BATTLE_OVER_PASS : int = 3;
        private var battleOver : int;
        private var nextWave : int;

        /** 接收:战斗胜利 */
        public function sc_battleWin(nextWave : int) : void
        {
            this.nextWave = nextWave;
            battleOver = BATTLE_OVER_WIN;
        }

        /** 接收:战斗通关 */
        public function sc_battlePass() : void
        {
            this.nextWave = wave;
            battleOver = BATTLE_OVER_PASS;
            isPass = true;
        }

        /** 接收:战斗失败 */
        public function sc_battleLose() : void
        {
            this.nextWave = wave;
            battleOver = BATTLE_OVER_LOSE;
            selfMoveToPreWave();
        }

        /** 战斗结束 */
        public function battleEnd() : void
        {
//            SignalBusManager.battleEnd.remove(battleEnd);
//
//            // 处置战斗怪物
//            if (battleMonsterAnimal)
//            {
//                if (battleOver == BATTLE_OVER_LOSE)
//                {
//                    battleMonsterAnimal.armyStart();
//                    armyPlay();
//                    setNextDo(NextDo.GOTO_BATTLE);
//                }
//                else
//                {
//                    if (battleMonsterIsBoss == true)
//                    {
//                        battleMonsterAnimal.die();
//                        battleMonsterAnimal.avatar.addClickCall(friskCall);
//                        setNextDo(NextDo.GET_REWARD);
//                    }
//                    else
//                    {
//                        battleMonsterAnimal.quit();
//                        openPathWave(wave);
//                        wave = nextWave;
//                        checkGateVisible();
//
//                        if (isPass == true)
//                        {
//                            setNextDo(NextDo.GOTO_EXIT);
//                        }
//                        else
//                        {
//                            setNextDo(NextDo.GOTO_BATTLE);
//                        }
//                    }
//                }
//            }
//
//            if (battleMonsterIsBoss == false)
//            {
//                armyPlay();
//            }
//
//            MapController.instance.enMouseMove = true;
        }

        /** 接收:获取完奖励 */
        public function sc_getAward() : void
        {
            hasItems = false;
            getRewardView.close();
        }

        /** 接收:获取奖励信息 */
        public function sc_getAwardInfo(items : Vector.<uint>) : void
        {
            hasItems = items && items.length > 0;
            getRewardView.setItems(items);
        }

        private var friskCall : CallFunStruct = new CallFunStruct(frisk, null);
        public var getRewardView : DuplMapGetReward = new DuplMapGetReward();

        /** 搜身 */
        public function frisk() : void
        {
            MouseManager.cursor = MouseManager.ARROW;
            (battleMonsterAnimal.avatar as AvatarMonster).hideArrow();
            battleMonsterAnimal.avatar.removeClickCall(friskCall);
            getRewardView.addGetCompleteCallFun(getRewardComplete);

            var monsterGlobalPostion : Point = MapUtil.mapToStage(battleMonsterAnimal.position);
            getRewardView.setMonsterGlobalPostion(monsterGlobalPostion);
            setTimeout(function() : void
            {
                selfPlayerAnimal.stopMove();
            }, 3);

            getRewardView.show();
        }

        /** 获得奖励完成 */
        public function getRewardComplete() : void
        {
            getRewardView.removeGetCompleteCallFun(getRewardComplete);
            battleMonsterAnimal.quit();
            openPathWave(wave);
            checkGateVisible();
            armyPlay();
            wave = nextWave;
            setNextDo(NextDo.GOTO_EXIT);
        }

        /** 自己移动到入口 */
        public function selfMoveToInGate() : void
        {
            var postition : Point = MapUtil.getGateCenter(duplMapId, duplMapId);

            selfPlayerAnimal.moveTo(postition.x, postition.y);
            MapPosition.instance.center();
        }

        /** 自己移动到上一个怪位置 */
        public function selfMoveToPreWave() : void
        {
            var preWave : int = wave - 1;
            if (preWave <= 0)
            {
                selfMoveToInGate();
                return;
            }
            var monsterStruct : MonsterStruct = layerStruct.getMonster(preWave);
            selfPlayerAnimal.moveTo(monsterStruct.x, monsterStruct.y);
            MapPosition.instance.center();
        }

        public function checkGateVisible() : void
        {
            gateVisible = isPass == true && hasItems == false;
        }

        /** 是否开放路口 */
        private var _gateVisible : Boolean = false;

        /** 是否开放路口 */
        public function get gateVisible() : Boolean
        {
            return _gateVisible;
        }

        public function set gateVisible(value : Boolean) : void
        {
            _gateVisible = value;
            SignalBusManager.setGateListVisible.dispatch(_gateVisible);
        }

        /** 开放打过的寻路道路 */
        public function openPathPass() : void
        {
            for (var i : int = 1; i < wave; i++)
            {
                openPathWave(i);
            }

            if (isPass == true && hasItems == false)
            {
                openPathWave(wave);
            }
        }

        /** 开放当前战斗胜利的寻路道路 */
        public function openPathWave(wave : int) : void
        {
            var monsterStruct : MonsterStruct = layerStruct.getMonster(wave);
            if (monsterStruct && monsterStruct.passColor != 0x000000 && monsterStruct.passColor != 0xFFFFFF)
            {
				 BarrierOpened.setState(monsterStruct.passColor , true);
            }
        }

        public function onClickExit() : void
        {
            cs_quit();
        }

        public function setNextDo(what : String) : void
        {
            SignalBusManager.selfStartWalk.remove(checkRestNextDo);
            uic.nextDoButton.nextDo = what;
        }

        public function checkRestNextDo() : void
        {
            uic.nextDoButton.nextDo = uic.nextDoButton.nextDo;
        }

        /** 去拿奖励 */
        public function gotoGetReward() : void
        {
            if (getRewardView.visible == false) MapSystem.mapTo.toAvatarPosition(battleMonsterAnimal.x, battleMonsterAnimal.y, frisk);
            SignalBusManager.selfStartWalk.add(checkRestNextDo);
        }

        /** 去打下一个怪 */
        public function gotoBattle() : void
        {
            // Alert.show("去打一个怪：" + wave);
            var monsterStruct : MonsterStruct = layerStruct.getMonster(wave);
            MapSystem.mapTo.toAvatarPosition(monsterStruct.x, monsterStruct.y, null);
            setNextDo(NextDo.WALKING);
            SignalBusManager.selfStartWalk.add(checkRestNextDo);
        }

        /** 去出口退出 */
        public function gotoExitGate() : void
        {
            MapSystem.mapTo.toGate(MapSystem.PRE_MAP_ID, 0, false, false, cs_quit);
            SignalBusManager.selfStartWalk.add(checkRestNextDo);
        }

        public function get selfPlayerAnimal() : SelfPlayerAnimal
        {
            return animalManager.selfPlayer;
        }

        /** 地图剧情是否进入 */
        public function mapStoryIsEnterCall(value : Boolean) : void
        {
            uic.visible = !value;
            if (value == false && DuplPanelQuest.instance.hasDuplStoryBattlePre(duplId, layerId))
            {
                storyBattlePreEnd();
            }
        }

        /**触发战斗前剧情*/
        public function monsterActivateStory(monsterAnimal : MonsterAnimal) : void
        {
            if (GMMethod.isDebug) Alert.show("触发战斗前剧情");
            selfPlayerAnimal.stopMove();
            checkRestNextDo();
            monsterAnimal.quit();
			DuplPanelQuest.instance.monsterActivateStory();
        }

        /**战斗前剧情触结束发战斗*/
        public function storyBattlePreEnd() : void
        {
            var monsterAnimal : MonsterAnimal = animalManager.getMonster(wave);
            cs_battle(monsterAnimal);
        }
    }
}
class Singleton
{
}