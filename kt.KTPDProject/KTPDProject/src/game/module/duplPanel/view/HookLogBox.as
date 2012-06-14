package game.module.duplPanel.view
{
    import com.commUI.TextArea;
    import com.utils.PotentialColorUtils;
    import com.utils.StringUtils;
    import flash.display.Graphics;
    import game.core.item.Item;
    import game.core.item.ItemManager;
    import game.definition.ID;
    import game.module.duplPanel.DuplPanelConfig;
    import gameui.core.GComponent;
    import gameui.core.GComponentData;






    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-13
     */
    public class HookLogBox extends GComponent
    {
        public var textArea : TextArea;

        public function HookLogBox(width : int, height : int)
        {
            _base = new GComponentData();
            _base.width = width;
            _base.height = height;
            super(_base);
            initViews();
            // testWH();
        }

        private function initViews() : void
        {
            textArea = new TextArea(_base.width, _base.height, 0x2F1F00, false, 15, 200);
            textArea.tf.selectable = false;
            textArea.x = 0;
            textArea.y = 0;
            addChild(textArea);
        }

        /** 清空 */
        public function clearMsgs() : void
        {
            textArea.clearMsgs();
        }

        /** 说明书 */
        public function appendMsg_specification() : void
        {
            textArea.appendMsg(DuplPanelConfig.LOG_SPECIFICATION);
        }

        /** 包裹不足 */
        public function appendMsg_start() : void
        {
            textArea.appendMsg(DuplPanelConfig.LOG_START);
        }

        /** 包裹不足 */
        public function appendMsg_packFull() : void
        {
            textArea.appendMsg(DuplPanelConfig.LOG_PACK_FULL);
        }

        /** 元宝不足 */
        public function appendMsg_goldOutof() : void
        {
            textArea.appendMsg(DuplPanelConfig.LOG_GOLD_OUTOF);
        }

        /** 正常完成 */
        public function appendMsg_normalOverl() : void
        {
            textArea.appendMsg(DuplPanelConfig.LOG_NORMAL_OVER);
        }

        /** 正常完成 */
        public function appendMsg_stop() : void
        {
            textArea.appendMsg(DuplPanelConfig.LOG_STOP);
        }

        /** 第几次挂机中 */
        public function appendMsg_hookNuming(hookNum : int, monsterNum : int, isNeedHookNum : Boolean) : void
        {
            var str : String = "";
            if (isNeedHookNum == true)
            {
                str = DuplPanelConfig.LOG_HOOK_NUM.replace(/__NUM__/i, hookNum);
                textArea.appendMsg(str);
            }
            str = DuplPanelConfig.LOG_MONSTER_BATTLEING.replace(/__NUM__/i, monsterNum);
            textArea.appendMsg(str);
        }

        /** 第几次挂机胜利 */
        public function appendMsg_hookNumWin(hookNum : int, monsterNum : int, exp : Number, silver : Number, items : Vector.<uint>) : void
        {
            textArea.removeLastLine(1);
            var str : String = "";
            // str += DuplPanelConfig.LOG_HOOK_NUM.replace(/__NUM__/i, hookNum);
            str = DuplPanelConfig.LOG_MONSTER_WIN.replace(/__NUM__/i, monsterNum);
            textArea.appendMsg(str);
            str = "";
            str += DuplPanelConfig.LOG_AWARD_EXP.replace(/__EXP__/i, exp);
            if(silver > 0) str += DuplPanelConfig.LOG_AWARD_SILVER.replace(/__SILVER__/i, silver);
            var itemsStr : String = "  ";
            var itemLength : int = items.length;
            for (var i : int = 0; i < itemLength; i++)
            {
                var num : uint = items[i];
                var itemBindFlag : uint = num >> 31;
                var itemBind : Boolean = (itemBindFlag) ? true : false;
                var itemId : int = (num - (itemBindFlag << 31)) >> 16;
                var itemCount : int = num - ((itemBindFlag << 31) + (itemId << 16));

                if (itemId == ID.SILVER) continue;

                var voItem : Item = ItemManager.instance.newItem(itemId);
                var name : String = voItem ? voItem.name : "未知物品";
                var colorString : String = PotentialColorUtils.getColorOfStr(voItem.color);
                itemsStr += "<font color='" + colorString + "'>[" + name + "]</font>×" + itemCount + "  ";
            }
            str += itemsStr;
            textArea.appendMsg(str);
            textArea.appendMsg("  ");
        }

        public function testWH() : void
        {
            var g : Graphics = this.graphics;
            g.beginFill(0xFF0000, 0.1);
            g.drawRect(0, 0, _base.width, _base.height);
            g.endFill();
        }
    }
}
