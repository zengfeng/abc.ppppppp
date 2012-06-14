package game.module.duplPanel {
	import game.module.duplMap.DuplProto;
	import game.net.core.Common;
	import game.net.data.CtoS.CSAutoDungeon;
	import game.net.data.CtoS.CSAutoDungeonComplete;
	import game.net.data.CtoS.CSQueryDungeon;
	import game.net.data.StoC.SCAutoDungeon;
	import game.net.data.StoC.SCDungeonCount;
	import log4a.Logger;


    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
     */
    public class DuplPanelProto
    {
        public function DuplPanelProto(singleton : Singleton)
        {
            singleton;
            sToC();
        }

        /** 单例对像 */
        private static var _instance : DuplPanelProto;

        /** 获取单例对像 */
        public static function get instance() : DuplPanelProto
        {
            if (_instance == null)
            {
                _instance = new DuplPanelProto(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var _duplPanelController : DuplPanelController ;

        public function get duplPanelController() : DuplPanelController
        {
            if (_duplPanelController == null)
            {
                _duplPanelController = DuplPanelController.instance;
            }
            return _duplPanelController;
        }

        /** 协议监听 */
        private function sToC() : void
        {
            // 协议监听 -- 0x80 查询副本信息
            Common.game_server.addCallback(0x0080, sc_info);
            // 协议监听 -- 0x82 副本挂机信息
            Common.game_server.addCallback(0x0082, sc_HookInfo);
//            // 协议监听 -- 0x83 副本挂机加速完成
//            Common.game_server.addCallback(0x0083, sc_HookFastComplete);
        }

        // ============================
        // 协议监听--  副本主面板
        // ============================
        /** 协议监听 -- 0x80 查询副本信息 */
        private function sc_info(msg : SCDungeonCount) : void
        {
            // 类型: 1-收费 0-免费
            var type : int = msg.countLeft >> 6;
            var isFree : Boolean = type == 0;
            var isPrePlay:Boolean = type == 2;
            var count : int = msg.countLeft - (type << 6);
            Logger.info("协议监听 -- 0x80 查询副本信息type=" + type + " count=" + count + " isFree=" +isFree + " isPrePlay=" +isPrePlay);
            duplPanelController.sc_duplInfo(count, isFree, isPrePlay);
        }

        // ============================
        // 协议监听--  副本挂机面板
        // ============================
        /** 协议监听 -- 0x0082 副本挂机信息 */
        private function sc_HookInfo(msg : SCAutoDungeon) : void
        {
            duplPanelController.windowHook_scInfo(msg);
        }

        /** 协议监听 -- 0x0083 副本挂机加速完成 */
//        private function sc_HookFastComplete(msg : SCAutoDungeonComplete) : void
//        {
//        }

        // ============================
        // 发送协议--  副本主面板
        // ============================
        /** 发送协议[0x0080] -- 查询副本信息 */
        public function cs_info() : void
        {
            var msg : CSQueryDungeon = new CSQueryDungeon();
            Common.game_server.sendMessage(0x0080, msg);
        }

        /** 发送协议[0x24] -- 进入副本 */
        public function cs_enterDupl(duplMapID : int) : void
        {
            DuplProto.instance.cs_enterDupl(duplMapID);
        }

        // ============================
        // 发送协议--  副本挂机面板
        // ============================
        /** 发送协议[0x0082] -- 开始挂机 */
        public function cs_HookStart(duplMapId : uint, num : uint) : void
        {
            var msg : CSAutoDungeon = new CSAutoDungeon();
            msg.start = true;
            msg.dungeonId = duplMapId;
            msg.count = num;
            Logger.info("发送协议[0x0082] -- 开始挂机 msg.start=" + msg.start + " msg.dungeonId=" + msg.dungeonId + " msg.count=" + msg.count);
            Common.game_server.sendMessage(0x0082, msg);
        }

        /** 发送协议[0x0082] -- 停止挂机 */
        public function cs_HookStop(duplMapId : uint) : void
        {
            var msg : CSAutoDungeon = new CSAutoDungeon();
            msg.start = false;
            msg.dungeonId = duplMapId;
            msg.count = 0;
            Common.game_server.sendMessage(0x0082, msg);
        }

        /** 发送协议[0x0083] -- 副本挂机加速完成 */
        public function cs_HookFastComplete() : void
        {
            var msg : CSAutoDungeonComplete = new CSAutoDungeonComplete();
            Common.game_server.sendMessage(0x0083, msg);
        }
    }
}
class Singleton
{
}