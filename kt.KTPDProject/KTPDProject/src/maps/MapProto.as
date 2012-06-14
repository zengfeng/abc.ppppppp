package maps
{
    import flash.geom.Point;
    import flash.utils.getTimer;

    import game.net.core.Common;
    import game.net.data.CtoS.CSAvatarChange;
    import game.net.data.CtoS.CSAvatarInfo;
    import game.net.data.CtoS.CSSwitchCity;
    import game.net.data.CtoS.CSTransport;
    import game.net.data.CtoS.CSWalkTo;
    import game.net.data.StoC.PlayerPosition;
    import game.net.data.StoC.SCAvatarInfo;
    import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
    import game.net.data.StoC.SCAvatarInfoChange;
    import game.net.data.StoC.SCCityEnter;
    import game.net.data.StoC.SCCityLeave;
    import game.net.data.StoC.SCCityPlayers;
    import game.net.data.StoC.SCMultiAvatarInfoChange;
    import game.net.data.StoC.SCNPCReaction;
    import game.net.data.StoC.SCPlayerWalk;
    import game.net.data.StoC.SCTransport;

    import maps.elements.structs.PlayerStruct;
    import maps.elements.structs.SelfPlayerStruct;
    import maps.npcs.MapNpcs;
    import maps.players.GlobalPlayers;
    import maps.players.MapPlayers;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-21
     */
    public class MapProto
    {
        /** 单例对像 */
        private static var _instance : MapProto;

        /** 获取单例对像 */
        static public function get instance() : MapProto
        {
            if (_instance == null)
            {
                _instance = new MapProto(new Singleton());
            }
            return _instance;
        }

        public function MapProto(singleton : Singleton)
        {
            singleton;
            globalPlayers = MapFacade.globalPlayers;
            mapPlayers = MapFacade.mapPlayers;
            mapNpcs = MapFacade.mapNpcs;
            mapControl = MapFacade.mapControl;
            sToC();
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var globalPlayers : GlobalPlayers;
        private var mapPlayers : MapPlayers;
        private var mapNpcs : MapNpcs;
        private var mapControl : MapControl;

        /** 协议监听 */
        private function sToC() : void
        {
            // 0x20 玩家走路
            Common.game_server.addCallback(0x20, sc_playerWalk);
            // 0x21 玩家进入地图（非自己）
            Common.game_server.addCallback(0x21, sc_playerEnter);
            // 0x22 自己玩家进入新地图
            Common.game_server.addCallback(0x22, sc_changeMap);
            // 0x23 玩家离开
            Common.game_server.addCallback(0x23, sc_playerLeave);
            // 0x24 设置NPC是否显示
            Common.game_server.addCallback(0x24, sc_setNpcVisible);
            // 0x25  直接传送
            Common.game_server.addCallback(0x25, sc_transport);
            // 0x26  一组多个玩家Avatar信息
            Common.game_server.addCallback(0x26, sc_multipleAvatarChange);
            // 0x27 玩家avatar信息改变
            Common.game_server.addCallback(0x27, sc_playerAvatarInfoChange);
            // 0x28 玩家Avatar信息
            Common.game_server.addCallback(0x28, sc_playerAvatarInfo);
        }

        // ======================
        // 接收
        // ======================
        /** 0x20 玩家走路 */
        private function sc_playerWalk(msg : SCPlayerWalk) : void
        {
            var playerStruct : PlayerStruct = mapPlayers.getPlayer(msg.playerId);
            if (playerStruct == null) return;
            playerStruct.isWalking = true;
            playerStruct.walkStartTime = getTimer();
            playerStruct.toX = msg.xy & 0x3FFF;
            playerStruct.toY = msg.xy >> 14;
            if (msg.hasFromXY)
            {
                playerStruct.fromX = msg.fromXY & 0x3FFF;
                playerStruct.fromY = msg.fromXY >> 14;
            }
        }

        /** 0x21 玩家进入地图（非自己） */
        private function sc_playerEnter(msg : SCCityEnter) : void
        {
            var positionInfo : PlayerPosition = msg.playerPos;
            var playerStruct : PlayerStruct;
            playerStruct = globalPlayers.getPlayer(positionInfo.playerId);
            if (playerStruct == null)
            {
                playerStruct = new PlayerStruct();
                playerStruct.id = positionInfo.playerId;
                globalPlayers.addPlayer(playerStruct);
            }
            playerStruct.x = positionInfo.xy & 0x3FFF;
            playerStruct.y = positionInfo.xy >> 14;
            if (positionInfo.hasToXy)
            {
                playerStruct.toX = positionInfo.toXy & 0x3FFF;
                playerStruct.toY = positionInfo.toXy >> 14;
            }

            if (positionInfo.hasWhen)
            {
                playerStruct.isWalking = true;
                playerStruct.walkStartTime = positionInfo.when;
                playerStruct.fromX = playerStruct.x;
                playerStruct.fromY = playerStruct.y;
            }
            else
            {
                playerStruct.isWalking = false;
                playerStruct.walkStartTime = 0;
            }
            mapPlayers.addWaitInstall(playerStruct);

            playerStruct.newAvatarVer = positionInfo.avatarVer & 0x1F;
            playerStruct.model = positionInfo.avatarVer >> 5;
            if (playerStruct.isNewestAvatar == false)
            {
                cs_avatarInfo(playerStruct.id);
            }
        }

        /** 0x22 自己玩家进入新地图 */
        private function sc_changeMap(msg : SCCityPlayers) : void
        {
            mapPlayers.clear();
            mapNpcs.clear();
            // 如果是副本地图
            if (MapUtil.isDuplMap(msg.cityId))
            {
                msg.myX = 0;
                msg.myY = 0;
                // return;
            }
            // 自己玩家
            var selfPlayerStruct : SelfPlayerStruct = globalPlayers.self;
            selfPlayerStruct.x = msg.myX;
            selfPlayerStruct.y = msg.myY;
            selfPlayerStruct.model = msg.model;
			mapPlayers.self = selfPlayerStruct;
            // 地图加入NPC
            while (msg.npcId.length > 0)
            {
                mapNpcs.add(msg.npcId.shift());
            }

            // 玩家列表
            var playerStruct : PlayerStruct;

            var csAvatarPlayerIdList : Array = [];
            for (var i : int = 0; i < msg.players.length; i++)
            {
                var positionInfo : PlayerPosition = msg.players[i];
                playerStruct = globalPlayers.getPlayer(positionInfo.playerId);
                if (playerStruct == null)
                {
                    playerStruct = new PlayerStruct();
                    playerStruct.id = positionInfo.playerId;
                    globalPlayers.addPlayer(playerStruct);
                }
                playerStruct.x = positionInfo.xy & 0x3FFF;
                playerStruct.y = positionInfo.xy >> 14;
                if (positionInfo.hasToXy)
                {
                    playerStruct.toX = positionInfo.toXy & 0x3FFF;
                    playerStruct.toY = positionInfo.toXy >> 14;
                }

                if (positionInfo.hasWhen)
                {
                    playerStruct.isWalking = true;
                    playerStruct.walkStartTime = positionInfo.when;
                    playerStruct.fromX = playerStruct.x;
                    playerStruct.fromY = playerStruct.y;
                }
                else
                {
                    playerStruct.isWalking = false;
                    playerStruct.walkStartTime = 0;
                }

                playerStruct.newAvatarVer = positionInfo.avatarVer & 0x1F;
                playerStruct.model = positionInfo.avatarVer >> 5;
                if (playerStruct.isNewestAvatar == false)
                {
                    csAvatarPlayerIdList.push(playerStruct.id);
                }
                mapPlayers.addWaitInstall(playerStruct);
            }
            if (selfPlayerStruct.isNewestAvatar == false) csAvatarPlayerIdList.unshift(selfPlayerStruct.id);
            cs_avatarInfo(0, csAvatarPlayerIdList);

            mapControl.reset(msg.cityId, selfPlayerStruct.x, selfPlayerStruct.y);
        }

        /**0x23 玩家离开 */
        private function sc_playerLeave(msg : SCCityLeave) : void
        {
            mapPlayers.remove(msg.playerId);
        }

        /** 0x24 设置NPC是否显示 */
        private function sc_setNpcVisible(msg : SCNPCReaction) : void
        {
            if (msg.reactionId == 1)
            {
                mapNpcs.add(msg.npcId);
            }
            else
            {
                mapNpcs.remove(msg.npcId);
            }
        }

        /** 0x25 传送 */
        private function sc_transport(msg : SCTransport) : void
        {
            var playerStruct : PlayerStruct;
            playerStruct = mapPlayers.getPlayer(msg.playerId);
            if (playerStruct == null) return;
            playerStruct.isWalking = false;
            playerStruct.walkStartTime = 0;
            playerStruct.x = msg.myXy & 0x3FFF;
            playerStruct.y = msg.myXy >> 14;
        }

        /** 0x26  一组多个玩家Avatar信息 */
        public function sc_multipleAvatarChange(msg : SCMultiAvatarInfoChange) : void
        {
            mapPlayers.sc_multipleAvatarInfoChange(msg);
        }

        /** 0x27 玩家avatar信息改变 */
        public function sc_playerAvatarInfoChange(msg : SCAvatarInfoChange) : void
        {
            mapPlayers.sc_playerAvatarInfoChange(msg);
        }

        /** 0x28 玩家Avatar信息 */
        private function sc_playerAvatarInfo(msg : SCAvatarInfo) : void
        {
            for (var i : int = 0; i < msg.players.length; i++)
            {
                var avatarInfo : PlayerAvatar = msg.players[i];
                mapPlayers.sc_playerAvatarInfoInit(avatarInfo);
            }
        }

        // ======================
        // 发送
        // ======================
        /** 0x20 告诉其他玩家自己位置 */
        public function cs_moveTo(toX : int, toY : int, fromX : int = 0, fromY : int = 0) : void
        {
            var msg : CSWalkTo = new CSWalkTo();
            msg.toX = toX;
            msg.toY = toY;
            if (fromX != 0)
            {
                msg.fromX = fromX;
                msg.fromY = fromY;
            }
            Common.game_server.sendMessage(0x20, msg);
        }

        /** 0x24 切换地图 */
        public function cs_changeMap(mapId : uint, x : int = 0, y : int = 0) : void
        {
            var msg : CSSwitchCity = new CSSwitchCity();
            msg.cityId = mapId;
            msg.toX = x;
            msg.toY = y;
            if (!MapUtil.isBackMap(mapId) && x == 0 && y == 0)
            {
                var point : Point = MapUtil.getGateStandPosition(mapId, mapId);
                msg.toX = point.x;
                msg.toY = point.y;
            }
            Common.game_server.sendMessage(0x24, msg);
        }

        /** 0x25 直接传送 */
        public function cs_transport(toX : int, toY : int, mapId : int = 0) : void
        {
            var msg : CSTransport = new CSTransport();
            msg.cityId = mapId <= 0 ? MapUtil.currentMapId : mapId;
            msg.toX = toX;
            msg.toY = toY;
            if (toX == 0 && toY == 0)
            {
                var point : Point = MapUtil.getGateStandPosition(mapId, mapId);
                msg.toX = point.x;
                msg.toY = point.y;
            }
            Common.game_server.sendMessage(0x25, msg);
        }

        /** 0x27 请求Avatar改变信息 */
        public function cs_avatarInfoChange(playerId : int, playerIdList : Array = null) : void
        {
            var msg : CSAvatarChange = new CSAvatarChange();
            if (playerId > 0) msg.playerId.push(playerId);
            if (playerIdList && playerIdList.length > 0)
            {
                while (playerIdList.length > 0)
                {
                    playerId = playerIdList.shift();
                    if (msg.playerId.indexOf(playerId) == -1)
                    {
                        msg.playerId.push(playerId);
                    }
                }
            }
            if (msg.playerId.length <= 0) return;
            Common.game_server.sendMessage(0x27, msg);
        }

        /** 0x28 请求名字模型等信息 */
        public function cs_avatarInfo(playerId : int, playerIdList : Array = null) : void
        {
            var msg : CSAvatarInfo = new CSAvatarInfo();
            if (playerId > 0) msg.playerId.push(playerId);
            if (playerIdList && playerIdList.length > 0)
            {
                while (playerIdList.length > 0)
                {
                    playerId = playerIdList.shift();
                    if (msg.playerId.indexOf(playerId) == -1)
                    {
                        msg.playerId.push(playerId);
                    }
                }
            }
            if (msg.playerId.length <= 0) return;
            Common.game_server.sendMessage(0x28, msg);
        }
    }
}
class Singleton
{
}