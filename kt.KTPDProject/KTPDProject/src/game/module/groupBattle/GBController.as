package game.module.groupBattle
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.utils.setTimeout;
    import game.core.user.UserData;
    import game.manager.SignalBusManager;
    import game.manager.ViewManager;
    import game.module.battle.view.BTSystem;
    import game.module.groupBattle.ui.GBUC;
    import game.module.groupBattle.ui.UiFontSortBox;
    import game.module.groupBattle.ui.UiNewsPanel;
    import game.module.groupBattle.ui.UiPlayerList;
    import game.module.groupBattle.ui.UiSelfInfoBox;
    import game.module.map.CurrentMapData;
    import game.module.map.MapController;
    import game.module.map.MapSystem;
    import game.module.map.animalstruct.SelfPlayerStruct;
    import game.module.map.struct.MapStruct;
    import game.module.map.utils.MapUtil;
    import game.module.notification.ICOMenuManager;
    import game.module.userBuffStatus.BuffStatusConfig;
    import game.module.userBuffStatus.BuffStatusManager;
    import game.net.data.StoC.SCGroupBattleUpdate;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-12 ����6:30:05
     * 蜀山论剑控制器
     */
    public class GBController
    {
        function GBController(singleton : Singleton) : void
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : GBController;

        /** 获取单例对像 */
        public static function get instance() : GBController
        {
            if (_instance == null)
            {
                _instance = new GBController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 界面容器 */
        public var uc : GBUC;
        /** 地图控制器 */
        private var _mapController : MapController;

        /** 地图控制器 */
        public function get mapController() : MapController
        {
            if (_mapController == null)
            {
                _mapController = MapController.instance;
            }
            return _mapController;
        }

        /** 玩家(蜀山论剑)管理器 */
        private var _gbPlayerManager : GBPlayerManager;

        /** 玩家(蜀山论剑)管理器 */
        public function get gbPlayerManager() : GBPlayerManager
        {
            if (_gbPlayerManager == null)
            {
                _gbPlayerManager = GBPlayerManager.instance;
            }
            return _gbPlayerManager;
        }

        /** (蜀山论剑)协议 */
        private var _gbProto : GBProto;

        /** (蜀山论剑)协议 */
        public function get gbProto() : GBProto
        {
            if (_gbProto == null)
            {
                _gbProto = GBProto.instance;
            }
            return _gbProto;
        }

        /** 是否安装 */
        public function get isSetup() : Boolean
        {
            return mapController.isSetup && mapController.mapId == MapSystem.GROUPBATTLE_MAP_ID;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function testEnter() : void
        {
            // gbProto.testEnter();
            gbProto.cs_enter();
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 发送进入 */
        public function cs_enter() : void
        {
            gbProto.cs_enter();
        }

        /** 接收到进入 */
        public function sc_enter() : void
        {
        }

        /** 发送退出 */
        public function cs_quit() : void
        {
        }

        /** 接收退出 */
        public function sc_quit() : void
        {
        }

        /** 退出清理 */
        public function clear() : void
        {
            if (uc)
            {
				uc.hide();
                if (uc.parent) uc.parent.removeChild(uc);
            }
            SignalBusManager.battleEnd.remove(battleEndCall);
            // CurrentMapData.instance.selfPlayerStruct = null;
            // PlayerManager.instance.clear();
            GBPlayerStatus.clear();
            gbPlayerManager.clear();
            uc.overTimer.stop();
            // 移除鼓舞等级改变回调
            BuffStatusManager.instance.removeStatusCall(BuffStatusConfig.STATUS_ID_INSPIRE, uc.selfInfo.inspireLevel);
			
			MapSystem.enSelectOtherPlayer = true;;
		  ICOMenuManager.getInstance().show();
        }

        /** 安装 */
        public function setup() : void
        {
            MapSystem.addChangeMapCallFun(setupMapComplete);
			MapSystem.enSelectOtherPlayer = false;
            // 安装UI
            setupUI();
            // 安装地图
            setupMap();
        }

        /** 安装UI */
        public function setupUI() : void
        {
		  if(ViewManager.otherPlayerPanel) ViewManager.otherPlayerPanel.hide();
		  ICOMenuManager.getInstance().hide();
            uc = new GBUC();
            var group : GBGroup;
            var uiGroup : UiPlayerList;
            var playerList : Vector.<GBPlayer>;
            // A组
            group = gbPlayerManager.groupA;
			uc.centerMain.setIconA(group.id);
            uiGroup = uc.playerListA;
            // 设置组名
            uiGroup.setGroupName(group.name, group.colorStr, group.minLevel, group.maxLevel);
            uiGroup.setGroupIcon(group.id);
			uiGroup.setPlayerCount(group.playerCount);
            // 设置积分
            uc.centerMain.setScore(group.score, group.id);
            group.uiPlayerList = uiGroup;
			

            // 添加玩家列表
            playerList = group.getPlayerList();
            uiGroup.addPlayerList(playerList);

            // A副组
            group = gbPlayerManager.groupAc;
            group.uiGroup = uiGroup.cGroup;
            group.uiGroup.groupId = group.id;
            group.uiGroup.setGroupName(group.name, group.colorStr, group.minLevel, group.maxLevel);
            group.uiGroup.setTip(group.playerCount, group.score);

            // B组
            group = gbPlayerManager.groupB;
			uc.centerMain.setIconB(group.id);
            uiGroup = uc.playerListB;
            // 设置组名
            uiGroup.setGroupName(group.name, group.colorStr, group.minLevel, group.maxLevel);
            uiGroup.setGroupIcon(group.id);
			uiGroup.setPlayerCount(group.playerCount);
            // 设置积分
            uc.centerMain.setScore(group.score, group.id);
            group.uiPlayerList = uiGroup;
            // 添加玩家列表
            playerList = group.getPlayerList();
            uiGroup.addPlayerList(playerList);

            // B副组
            group = gbPlayerManager.groupBc;
            group.uiGroup = uiGroup.cGroup;
            group.uiGroup.groupId = group.id;
            group.uiGroup.setGroupName(group.name, group.colorStr, group.minLevel, group.maxLevel);
            group.uiGroup.setTip(group.playerCount, group.score);

            // 设置排名
            gbPlayerManager.firstPlayerCall = uc.centerMain.setFirstPlayer;
//            var fontSort : UiFontSortBox = uc.fontSort;
//            gbPlayerManager.fontSort = fontSort;
            // 玩家信息
            var selfInfo : UiSelfInfoBox = uc.selfInfo;
            gbPlayerManager.selfPlayer.uiSelfInfo = selfInfo;

            selfInfo.inspireLevel(BuffStatusManager.instance.getStatus(BuffStatusConfig.STATUS_ID_INSPIRE).level);
            // 添加鼓舞等级改变回调
            BuffStatusManager.instance.addStatusCall(BuffStatusConfig.STATUS_ID_INSPIRE, selfInfo.inspireLevel);
            uc.show();
            
        }

        /** 安装地图 */
        public function setupMap() : void
        {
            var mapId : uint = MapSystem.GROUPBATTLE_MAP_ID;
            var selfPostion : Point = null;
            CurrentMapData.instance.setupPostion.x = 0;
            CurrentMapData.instance.setupPostion.y = 0;
            selfPostion =  CurrentMapData.instance.setupPostion;
            mapController.preSetupMap(mapId, selfPostion);
            SignalBusManager.battleEnd.add(battleEndCall);
        }

        /** 安装地图完成 */
        public function setupMapComplete(mapStruct : MapStruct) : void
        {
            if (MapUtil.isGroupBattleMap(mapStruct.id) == false) return;

            var playerList : Vector.<GBPlayer> = gbPlayerManager.getPlayerList();
            var gbPlayer : GBPlayer;
            for (var i : int = 0; i < playerList.length; i++)
            {
                gbPlayer = playerList[i];
                addPlayer(gbPlayer);
            }
            mapController.enMouseMove = false;
//            testPoint();
        }

        public function testPoint() : void
        {
            var fun : Function = function(cc : Sprite) : void
            {
                mapController.elementLayer.addChild(cc);
            };
            var list : Vector.<Point> = GBPositionArea.vsPostion.listA;
            var point : Point;
            var c : Sprite;

            for (var i : int = 0; i < list.length; i++)
            {
                if(i > 31) break;
                point = list[i];
                c = circle(i + "");
                c.x = point.x;
                c.y = point.y;
                setTimeout(fun, 500 * i, c);
            }
            list = GBPositionArea.vsPostion.listB;
            for (i = 0; i < list.length; i++)
            {
                if(i > 31) break;
                point = list[i];
                c = circle(i + "");
                c.x = point.x;
                c.y = point.y;
                setTimeout(fun, 500 * i, c);
            }
        }

        public function circle(str : String = "") : Sprite
        {
            var sprite : Sprite = new Sprite();
            var g : Graphics = sprite.graphics;
            g.beginFill(0xFF0000);
            g.drawCircle(0, 0, 10);
            g.endFill();
            var tf : TextField = new TextField();
            tf.text = str;
            tf.y = -10;
            tf.x = -10;
            sprite.addChild(tf);
            return sprite;
        }
		
		private function battleEndCall():void
		{
			BTSystem.INSTANCE().endBattleDelay();
		}

        /** 添加玩家 */
        public function addPlayer(gbPlayer : GBPlayer) : void
        {
            if (isSetup == false || gbPlayer == null) return;
            if (gbPlayer.id != UserData.instance.playerId)
            {
                gbPlayer.animal = MapSystem.addPlayer(gbPlayer.playerStruct);
            }
            else
            {
                gbPlayer.animal = MapSystem.addSelfPlayer(gbPlayer.playerStruct as SelfPlayerStruct);
            }
            setTimeout(gbPlayer.updateStatus, 500);
        }

        /** 移动玩家 */
        public function removePlayer(palyerId : uint) : void
        {
            MapSystem.removePlayer(palyerId);
        }

        // 设置 蜀山论剑结束时间
        public function set overTimer(value : int) : void
        {
            if (uc)
            {
                uc.overTimer.time = value;
            }
        }

        /** 动态消息面板 */
        public function get uiNewsPanel() : UiNewsPanel
        {
            if (uc != null && uc.newsPanel != null)
            {
                return uc.newsPanel;
            }

            return null;
        }

        /** 添加动态消息 */
        public function appendNews(msg : SCGroupBattleUpdate) : void
        {
            if (uiNewsPanel == null) return;
            uiNewsPanel.appendBattleNews(msg);
        }
    }
}
class Singleton
{
}