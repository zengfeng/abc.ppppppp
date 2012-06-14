package game.module.duplPanel
{
    import com.commUI.alert.Alert;
    import com.commUI.tooltip.ToolTip;
    import com.commUI.tooltip.ToolTipManager;
    import com.signalbus.Signal;
    import com.utils.UrlUtils;
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.getTimer;
    import game.core.user.StateManager;
    import game.core.user.UserData;
    import game.definition.ID;
    import game.manager.EnWalkManager;
    import game.manager.GetValManager;
    import game.module.duplMap.DuplMapData;
    import game.module.duplMap.DuplOpened;
    import game.module.duplMap.DuplUtil;
    import game.module.duplMap.data.DuplStruct;
    import game.module.duplMap.data.LayerStruct;
    import game.module.duplPanel.view.HeadIcon;
    import game.module.duplPanel.view.HeadIconEnter;
    import game.module.duplPanel.view.WindowEnter;
    import game.module.duplPanel.view.WindowHook;
    import game.module.map.animalstruct.MonsterStruct;
    import game.module.map.preload.MapPreloadManager;
    import game.module.quest.guide.GuideMange;
    import game.net.data.StoC.SCAutoDungeon;
    import log4a.Logger;





    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-12
     */
    public class DuplPanelController
    {
        public function DuplPanelController(singleton : Singleton)
        {
            singleton;
            init();
        }

        /** 单例对像 */
        private static var _instance : DuplPanelController;

        /** 获取单例对像 */
        public static function get instance() : DuplPanelController
        {
            if (_instance == null)
            {
                _instance = new DuplPanelController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var	duplPanelQuest : DuplPanelQuest = DuplPanelQuest.instance;
        public var proto : DuplPanelProto = DuplPanelProto.instance;
        public var duplId : int;
        public var isFree : Boolean = true;
        public var count : int;
        public var isPrePlay : Boolean = false;
        public var duplStruct : DuplStruct;
        public var layerId : int = 0;
        public var duplMapId : int = 0;
        public var windowEnter : WindowEnter = WindowEnter.instance;
        public var windowHook : WindowHook = WindowHook.instance;
        public var windowIsRelevance : Boolean = true;
        public var windowIsRelevanceByWalk : Boolean = false;

        private function init() : void
        {
            GetValManager.guide_inDuplDefeatBossReturnCall = guide_inDuplDefeatBossReturnCall;
        }

        private function guide_inDuplDefeatBossReturnCall() : Boolean
        {
            return DuplPanelQuest.instance.hasCurrentDuplGuide(duplId);
        }

        /** 发送 查询副本信息 */
        public function cs_duplInfo(duplId : int) : void
        {
            if (DuplOpened.isOpened(duplId) == false)
            {
                Alert.show("此副本还没开放");
                return;
            }

            windowIsRelevance = true;
            this.duplId = duplId;
            duplStruct = DuplMapData.instance.getDuplStruct(duplId);
            if (duplStruct == null)
            {
                Alert.show("不存在副本" + duplId);
                return;
            }
            proto.cs_info();
        }

        /** 接收 查询副本信息 */
        public function sc_duplInfo(count : int, isFree : Boolean, isPrePlay : Boolean) : void
        {
            this.isFree = isFree;
            this.count = count;
            this.isPrePlay = isPrePlay;
            if (duplId <= 0) return;

            if (windowEnter.visible == false && windowHook.visible == false)
            {
                windowEnter_open();
            }
            else if (windowHook.visible == true)
            {
                windowHook_updateNum();
            }
        }

        /** 主面板--打开 */
        public function windowEnter_open() : void
        {
            windowEnter.onClickCloseCall = windowEnter_close;
            windowEnter.title = duplStruct.name;
            windowEnter.setRemainNum(count, isFree);
            windowEnter.clearIcons();
            var openedMaxLayerId : int = DuplOpened.getOpenedMaxLayerId(duplId);
            for each (var layerStruct:LayerStruct in  duplStruct.layerDic)
            {
                var layerId : int = layerStruct.id;
                var duplMapId : int = DuplUtil.getDuplMapId(duplId, layerId);
                var iconMonster : MonsterStruct = layerStruct.getIconMonster();
                var name : String = iconMonster.name;
                var imageUrl : String = UrlUtils.getDungeonLayerIcon(duplMapId);
                var enable : Boolean = layerId <= openedMaxLayerId;

                var isOpenHook : Boolean = DuplOpened.isOpendHook;
                if (isOpenHook == true) isOpenHook = layerId < openedMaxLayerId;

                var icon : HeadIconEnter = windowEnter.getIconByIndex(layerId - 1);
                icon.setData(layerStruct.id, name, imageUrl, enable, isOpenHook);
                icon.onClickCall = windowEnter_onClickIcon;
                icon.onClickHookButtonCall = windowEnter_onClickHook;

                var tipStr : String = DuplMapData.instance.getLayerTip(duplMapId);
                if (tipStr && layerId <= openedMaxLayerId)
                {
                    ToolTipManager.instance.registerToolTip(icon.bg, ToolTip, tipStr);
                }
                else
                {
                    ToolTipManager.instance.destroyToolTip(icon.bg);
                }
            }
            windowEnter.visible = true;
            windowHook.visible = false;
            windowEnter_checkGuide();
            EnWalkManager.addCheckEnWalk(windowEnter_selfStartWalk);
        }

        /** 主面板--当自己玩家走路 */
        private function windowEnter_selfStartWalk(doWhat : int = 0) : Boolean
        {
            doWhat;
            windowEnter_close();
            return true;
        }

        /** 主面板--关闭 */
        public function windowEnter_close() : void
        {
            EnWalkManager.removeCheckEnWalk(windowEnter_selfStartWalk);
            windowEnter.visible = false;
        }

        /** 挂机面板 -- 打开 */
        public function windowHook_open() : void
        {
            windowHook.onClickCloseCall = windowHook_close;
            windowHook.startButton.addEventListener(MouseEvent.CLICK, windowHook_onClickStartButton);
            windowHook.stopButton.addEventListener(MouseEvent.CLICK, windowHook_onClickStopButton);
            windowHook.fastButton.addEventListener(MouseEvent.CLICK, windowHook_onClickFastButton);
            windowHook.visible = true;
            windowIsRelevanceByWalk = false;
            if (windowIsRelevance == true)
            {
                windowEnter_close();
            }
            windowHook.numTextInput.enabled = true;
            windowHook.timeLeftLabel.visible = false;
            windowHook.title = duplStruct.name.substr(0, 2) + '挂机';
            windowHook.setRemainNum(count, isFree);
            if (count == 0)
            {
                windowHook.buttonState_noNum();
            }
            else
            {
                windowHook.buttonState_default();
            }
            var icon : HeadIcon = windowHook.icon;
            var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
            var iconMonster : MonsterStruct = layerStruct.getIconMonster();
            var name : String = iconMonster.name;
            var imageUrl : String = UrlUtils.getDungeonLayerIcon(duplMapId);
            icon.setData(0, name, imageUrl);
            var tipStr : String = DuplMapData.instance.getLayerTip(duplMapId);
            if (tipStr)
            {
                ToolTipManager.instance.registerToolTip(icon.bg, ToolTip, tipStr);
            }
            else
            {
                ToolTipManager.instance.destroyToolTip(icon.bg);
            }
            windowHook.logBox. clearMsgs();
            windowHook.logBox.appendMsg_specification();
            windowHook.goodsBox.clear();

            EnWalkManager.addCheckEnWalk(windowHook_checkEnWalk);
        }

        private var windowHook_checkWalkSignal : Signal;

        /** 挂机面板 -- 关闭 */
        public function windowHook_close() : void
        {
            if (windowHook_checkEnClose() == false)
            {
                return;
            }
            EnWalkManager.removeCheckEnWalk(windowHook_checkEnWalk);
            windowHook.visible = false;
            windowHook.logBox. clearMsgs();
            windowHook.goodsBox.clear();
            if (windowIsRelevance == true && windowIsRelevanceByWalk == false)
            {
                windowEnter_open();
            }
            if (windowHook_checkWalkSignal)
            {
                windowHook_checkWalkSignal.dispatch();
                windowHook_checkWalkSignal = null;
            }
        }

        /** 挂机面板 -- 验证关闭 */
        public function windowHook_checkEnClose() : Boolean
        {
            if (windowHook_isStart == true)
            {
                StateManager.instance.checkMsg(6, [], windowHook_checkEnCloseButtonAlert);
                return false;
            }
            return true;
        }

        /** 挂机面板 -- 点击立即完成按钮对话框回调 */
        private function windowHook_checkEnCloseButtonAlert(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    windowHook_stopOfClose = true;
                    proto.cs_HookStop(duplMapId);
                    break;
                case Alert.CANCEL_EVENT :
                    windowHook_checkWalkSignal = null;
                    windowIsRelevanceByWalk = false;
                    break;
            }
            return true;
        }

        // =========================
        // 挂机面板
        // =========================
        /** 挂机面板 -- 是否开始 */
        private var windowHook_isStart : Boolean = false;
        /** 挂机面板 -- 是否加速 */
        private var windowHook_isFast : Boolean = false;
        /** 挂机面板 -- 是否发的加速协议 */
        private var windowHook_isSendFastProto : Boolean = false;
        /** 挂机面板 -- 设定次数 */
        private var windowHook_preStartCount : int = 0;
        private var windowHook_hookCount : int = 0;
        private var windowHook_monsterCount : int = 0;
        private  var windowHook_hookNum : int = 0;
        private var windowHook_monsterNum : int = 0;
        private var windowHook_timeleft : int = 0;
        /** 挂机面板 -- 是否是因为关闭停止 */
        private var windowHook_stopOfClose : Boolean = false;

        /** 挂机面板 -- 点击开始按钮 */
        private function windowHook_onClickStartButton(event : MouseEvent) : void
        {
            windowHook_isFast = false;
            windowHook_isSendFastProto = false;
            windowHook_preStartCount = count;
            windowHook_hookCount = windowHook.getNum();
            var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
            windowHook_monsterCount = layerStruct.monsterList.length;

            if (count <= 0)
            {
                StateManager.instance.checkMsg(5);
                return;
            }

            if (isFree == false)
            {
                var needGold : int = windowHook_hookCount * DuplPanelConfig.BUY_NUM_GOLD;
                if (isPrePlay == true) needGold -= DuplPanelConfig.BUY_NUM_GOLD;

                Logger.info("isPrePlay = " + isPrePlay + "  needGold =" + needGold);
                if (UserData.instance.gold < needGold && needGold > 0)
                {
                    StateManager.instance.checkMsg(4, [needGold]);
                    return;
                }

                if (UserData.instance.tryPutPack(DuplPanelConfig.HOOK_MIN_PACK_EMPTY) < 0)
                {
                    StateManager.instance.checkMsg(7, [DuplPanelConfig.HOOK_MIN_PACK_EMPTY]);
                    return;
                }

                if (needGold > 0)
                {
                    StateManager.instance.checkMsg(19, [windowHook_hookCount], windowHook_onClickStartNoFreeGoldAlert);
                    return;
                }
            }
            if (UserData.instance.tryPutPack(DuplPanelConfig.HOOK_MIN_PACK_EMPTY) < 0)
            {
                StateManager.instance.checkMsg(7, [DuplPanelConfig.HOOK_MIN_PACK_EMPTY]);
                return;
            }
            windowHook_csStart();
        }

        private function windowHook_onClickStartNoFreeGoldAlert(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    windowHook_csStart();
                    break;
            }
            return true;
        }

        /** 挂机面板 -- 点击开始按钮发送协议 */
        private function windowHook_csStart() : void
        {
            proto.cs_HookStart(duplMapId, windowHook_hookCount);
        }

        /** 挂机面板 -- 点击停止按钮 */
        private function windowHook_onClickStopButton(event : MouseEvent) : void
        {
            StateManager.instance.checkMsg(6, [], windowHook_onClickStopButtonAlert);
        }

        /** 挂机面板 -- 点击立即完成按钮对话框回调 */
        private function windowHook_onClickStopButtonAlert(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    windowHook_stopOfClose = false;
                    proto.cs_HookStop(duplMapId);
                    break;
            }
            return true;
        }

        /** 挂机面板 -- 点击立即完成按钮 */
        private function windowHook_onClickFastButton(event : MouseEvent) : void
        {
            var countleft : int = (windowHook_hookCount - windowHook_hookNum + 1);
            windowHook_fastNeedGold = DuplPanelConfig.HOOK_FAST_GOLD * countleft;
            StateManager.instance.checkMsg(3, [windowHook_fastNeedGold, countleft], windowHook_onClickFastButtonAlert);
        }

        private var windowHook_fastNeedGold : int = 0;

        /** 挂机面板 -- 点击立即完成按钮对话框回调 */
        private function windowHook_onClickFastButtonAlert(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    if (UserData.instance.gold < windowHook_fastNeedGold)
                    {
                        StateManager.instance.checkMsg(4, [windowHook_fastNeedGold]);
                        return false;
                    }
                    windowHook_isSendFastProto = true;
                    proto.cs_HookFastComplete();
                    break;
            }
            return true;
        }

        private function windowHook_updateNum() : void
        {
            windowHook.setRemainNum(count, isFree);
        }

        /** 挂机面板 -- 服务器反回挂机信息 */
        public function windowHook_scInfo(msg : SCAutoDungeon) : void
        {
            var exp : int = msg.exp;
            var items : Vector.<uint> = msg.items;
            var silver : int = setItems(items);

            var preHookNum : int;
            var isNeedHookNum : Boolean = false;

            // Alert.show(msg.result + "," + msg.countLeft + ", " + count);
            // 挂机结果  0-开始挂机 1-继续挂机 2-完成挂机 3-用户主动中断 4-背包不足停止 5-元宝不足停止
            switch(msg.result)
            {
                // 开始挂机
                case 0:
                    if (windowHook.visible == false)
                    {
                        duplMapId = msg.dungeonId;
                        duplId = DuplUtil.getDuplId(duplMapId);
                        layerId = DuplUtil.getLayerId(duplMapId);
                        duplStruct = DuplMapData.instance.getDuplStruct(duplId);
                        windowHook_open();
                        windowHook_hookCount = msg.countLeft;
                        var layerStruct : LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
                        windowHook_monsterCount = layerStruct.monsterList.length;
                    }
                    else
                    {
                        isPrePlay = true;
                    }
                    windowHook.logBox.clearMsgs();
                    windowHook.goodsBox.clear();
                    windowHook_isStart = true;
                    windowHook_hookNum = 1;
                    windowHook_monsterNum = msg.stage;
                    windowHook_timeleft = windowHook_hookCount;
                    isNeedHookNum = true;
                    windowHook.logBox.appendMsg_hookNuming(windowHook_hookNum, windowHook_monsterNum, isNeedHookNum);
                    windowHook.buttonState_start();
                    break;
                // 继续挂机
                case 1:
                    isPrePlay = false;
                    windowHook.logBox.appendMsg_hookNumWin(windowHook_hookNum, windowHook_monsterNum, exp, silver, items);
                    preHookNum = windowHook_hookNum;
                    windowHook_hookNum = windowHook_hookCount - msg.countLeft + 1;
                    if (preHookNum < windowHook_hookNum)
                    {
                        windowHook_monsterNum = 1;
                        isNeedHookNum = true;
                        count--;
                        // if (windowHook_monsterCount == 1) count--;
                    }
                    else
                    {
                        windowHook_monsterNum++;
                        isNeedHookNum = false;
                        // if (windowHook_monsterNum == windowHook_monsterCount)
                        // {
                        // count--;
                        // }
                    }
                    windowHook_timeleft = msg.countLeft;
                    windowHook.logBox.appendMsg_hookNuming(windowHook_hookNum, windowHook_monsterNum, isNeedHookNum);
                    if (windowHook_isSendFastProto == true && windowHook_isFast == false)
                    {
                        windowHook_isFast = true;
                        windowHook.buttonState_fast();
                    }
                    break;
                // 完成挂机
                case 2:
                    isPrePlay = false;
                    windowHook_isStart = false;
                    windowHook_isFast = false;
                    windowHook.logBox.appendMsg_hookNumWin(windowHook_hookNum, windowHook_monsterNum, exp, silver, items);
                    count--;
                    // if (windowHook_monsterCount == 1) count--;
                    preHookNum = windowHook_hookNum;
                    windowHook_hookNum = windowHook_hookCount;
                    windowHook_monsterNum = windowHook_hookCount;
                    windowHook_timeleft = 0;
                    windowHook.logBox.appendMsg_normalOverl();
                    windowHook.buttonState_default();
                    break;
                // 用户主动中断
                case 3:
                    if (windowHook_monsterCount != 1 && windowHook_monsterNum > 1)
                    {
                        count--;
                    }
                    windowHook_isStart = false;
                    windowHook_isFast = false;
                    windowHook.logBox.appendMsg_stop();
                    windowHook_timeleft = 0;
                    if (windowHook_stopOfClose == true)
                    {
                        windowHook_stopOfClose = false;
                        windowHook_close();
                    }
                    windowHook.buttonState_default();
                    break;
                // 背包不足停止
                case 4:
                    if (windowHook_monsterCount != 1 && windowHook_monsterNum > 1)
                    {
                        count--;
                    }
                    windowHook_isStart = false;
                    windowHook_isFast = false;
                    windowHook.logBox.appendMsg_packFull();
                    StateManager.instance.checkMsg(153);
                    windowHook_timeleft = 0;
                    windowHook.buttonState_default();
                    break;
                // 元宝不足停止
                case 5:
                    if (windowHook_monsterCount != 1 && windowHook_monsterNum > 1)
                    {
                        count--;
                    }
                    windowHook_isStart = false;
                    windowHook_isFast = false;
                    windowHook.logBox.appendMsg_goldOutof();
                    StateManager.instance.checkMsg(4);
                    windowHook_timeleft = 0;
                    windowHook.buttonState_default();
                    break;
            }

            windowHook.setNum(msg.countLeft);
            windowHook.setRemainNum(count, isFree, !windowHook_isStart);
            windowHook.setTimeleft(windowHook_timeleft);
            windowHook.numTextInput.enabled = !windowHook_isStart;
            windowHook.timeLeftLabel.visible = windowHook_isStart;
            if (count == 0 && isFree == true && windowHook_isStart == false && windowHook.visible == true)
            {
                proto.cs_info();
            }
        }

        private function windowHook_checkEnWalk(doWhat : int = 0) : Boolean
        {
            doWhat;
            if (windowHook_isStart == true)
            {
                windowHook_checkWalkSignal = EnWalkManager.continueWalk;
                windowIsRelevanceByWalk = true;
                windowHook_close();
                return false;
            }
            else
            {
                windowIsRelevanceByWalk = true;
                windowHook_close();
                return true;
            }
            return true;
        }

        private function setItems(items : Vector.<uint>) : int
        {
            var silver : int = 0;
            var length : int = items.length;
            for (var i : int = 0; i < length; i++)
            {
                var num : uint = items[i];
                var itemBindFlag : uint = num >> 31;
                var itemBind : Boolean = (itemBindFlag) ? true : false;
                var itemId : int = (num - (itemBindFlag << 31)) >> 16;
                var itemCount : int = num - ((itemBindFlag << 31) + (itemId << 16));
                windowHook.goodsBox.addItem(itemId, itemCount, itemBind);

                if (itemId == ID.SILVER)
                {
                    silver = itemCount;
                }
            }
            return silver;
        }

        // =========================
        // 主面板
        // =========================
        /** 主面板--点击图标 */
        public function windowEnter_onClickIcon(layerId : int) : void
        {
            this.layerId = layerId;
             if (DuplPanelQuest.instance.enFreeEnter(duplId, layerId))
            {
                windowEnter_onClickIconEnter();
                return;
            }
            
            if (count <= 0)
            {
                StateManager.instance.checkMsg(5);
                return;
            }

            if (isFree == false && isPrePlay == false)
            {
                var needGold : int = DuplPanelConfig.BUY_NUM_GOLD;
                if (UserData.instance.gold < needGold)
                {
                    StateManager.instance.checkMsg(4, [needGold]);
                    return;
                }
                if (needGold > 0)
                {
                    StateManager.instance.checkMsg(12, [needGold], windowEnter_onClickIconEnterNoFreeGoldAlert);
                    return;
                }
            }
            windowEnter_onClickIconEnter();
        }

        /** 挂机面板 -- 点击立即完成按钮对话框回调 */
        private function windowEnter_onClickIconEnterNoFreeGoldAlert(eventType : String) : Boolean
        {
            switch(eventType)
            {
                case Alert.OK_EVENT:
                    windowEnter_onClickIconEnter();
                    break;
            }
            return true;
        }
		
        private var cs_enterDupl_timer:uint;
        public function windowEnter_onClickIconEnter() : void
        {
            if(getTimer() - cs_enterDupl_timer < 2000)
            {
                return;
            }
            windowEnter_close();
            MapPreloadManager.instance.show();
            cs_enterDupl_timer = getTimer();
            this.duplMapId = DuplUtil.getDuplMapId(duplId, layerId);
            proto.cs_enterDupl(duplMapId);
        }

        /** 主面板--点击挂机 */
        public function windowEnter_onClickHook(layerId : int) : void
        {
            this.layerId = layerId;
            this.duplMapId = DuplUtil.getDuplMapId(duplId, layerId);
            windowHook_open();
        }

        /** 主面板--检查引导 */
        public function windowEnter_checkGuide() : void
        {
            if (duplPanelQuest.hasCurrentDuplGuide(duplId) == false)
            {
                windowEnter_removeGuide();
                return;
            }

            if ((duplPanelQuest.guideType & DuplPanelQuest.DEFEAT_BOSS) ==  DuplPanelQuest.DEFEAT_BOSS)
            {
                var openMaxLayerId : int = DuplOpened.getOpenedMaxLayerId(duplId);
                var guideLayerId : int = duplPanelQuest.layerId;
                if (openMaxLayerId == -1)
                {
                    GuideMange.getInstance().moveTo(-100, 215, "灭魂出 鬼神诛\n此副本还没开放", windowEnter);
                }

                var layerId : int = Math.min(openMaxLayerId, guideLayerId);
                var icon : HeadIconEnter = windowEnter.getIconById(layerId);
                var point : Point = new Point(icon.x, icon.y);
                point.y += icon.height / 2;
                point = windowEnter.localToGlobal(point);
                point = windowEnter.globalToLocal(point);
                point.x -= 150;
                var tipStr : String = guideLayerId == layerId ? "击杀任务目标" : "点击进入副本";
                GuideMange.getInstance().moveTo(point.x, point.y, tipStr, windowEnter);
            }
            else
            {
                windowEnter_removeGuide();
            }
        }

        public function windowEnter_removeGuide() : void
        {
            var displayObject : DisplayObject = windowEnter.getChildByName("guideArrows");
            if (displayObject) displayObject.parent.removeChild(displayObject);
        }

        /** 挂机面板--检查引导 */
        public function windowHook_checkGuide() : void
        {
            if (duplPanelQuest.hasCurrentDuplGuide(duplId) == false) return;
        }
    }
}
class Singleton
{
}