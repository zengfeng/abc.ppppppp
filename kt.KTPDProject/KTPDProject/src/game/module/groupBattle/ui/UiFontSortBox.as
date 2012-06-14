package game.module.groupBattle.ui
{
    import gameui.core.GComponent;
    import gameui.core.GComponentData;
    import gameui.manager.UIManager;

    import net.AssetData;

    import flash.display.Sprite;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-18 ����10:46:41
     * 前三名
     */
    public class UiFontSortBox extends GComponent
    {
        /** 背景 */
        private var bg : Sprite;
        /** 第一名 */
        private var aItem : Item;
        /** 第二名 */
        private var bItem : Item;
        /** 第三名 */
        private var cItem : Item;

        public function UiFontSortBox()
        {
            _base = new GComponentData();
            _base.width = 230;
            _base.height = 100;
            super(_base);

            initViews();

            setPalyer(1, "大海明月", "#FFFF00", 60);
            setPalyer(2, "人众人", "#00FF00", 5);
            setPalyer(3, "浏览", "#0daaDD", 3);
        }

        /** 初始化视图 */
        protected function initViews() : void
        {
            // 背景
            bg = UIManager.getUI(new AssetData("GroupBattleBoxBg"));
            bg.width = _base.width;
            bg.height = _base.height;
//            addChild(bg);

            // 第一名
            var item : Item;
            item = new Item();
            item.x = 15;
            item.y = 20;
            item.setNo(1);
            item.setPlayerName(null);
            addChild(item);
            aItem = item;
            // 第二名
            item = new Item();
            item.x = 15;
            item.y = 45;
            item.setNo(2);
            item.setPlayerName(null);
            addChild(item);
            bItem = item;
            // 第三名
            item = new Item();
            item.x = 15;
            item.y = 70;
            item.setNo(3);
            item.setPlayerName(null);
            addChild(item);
            cItem = item;
        }

        public function setPalyer(noId : int, playerName : String, colorStr : String = "#FF00000", killCout : int = 0) : void
        {
            var item : Item;
            switch(noId)
            {
                case 1:
                    item = aItem;
                    break;
                case 2:
                    item = bItem;
                    break;
                case 3:
                    item = cItem;
                    break;
                default:
                    item = aItem;
                    break;
            }

            if (!playerName)
            {
                item.setPlayerName(null);
            }
            else
            {
                item.setPlayerName(playerName, colorStr);
                item.setKillCout(killCout);
            }
        }
    }
}
import gameui.manager.UIManager;
import gameui.core.GComponent;
import gameui.core.GComponentData;

import com.utils.FilterUtils;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
class Item extends GComponent
{
    /** 排名编号 */
    private var noTF : TextField;
    /** 玩家名称 */
    private var palyerNameTF : TextField;
    /** 连杀数量 */
    private var killCountTF : TextField;

    function Item(width : int = 250, height : int = 26)
    {
        _base = new GComponentData();
        _base.width = width;
        _base.height = height;
        super(_base);
        // 初始化视图
        initViews();
        this.filters = [FilterUtils.defaultTextEdgeFilter];
    }

    /** 初始化视图 */
    private function initViews() : void
    {
        // 排名编号
        var textFormat : TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0xFFFFFF;
        textFormat.bold = true;
        textFormat.align = TextFormatAlign.LEFT;
        textFormat.letterSpacing = 2;
        textFormat.font = UIManager.defaultFont;
        var tempTF : TextField = new TextField();
        tempTF.selectable = false;
        tempTF.defaultTextFormat = textFormat;
        tempTF.width = 60;
        tempTF.height = 26;
        tempTF.x = 5;
        tempTF.y = 0;
        tempTF.text = "第1名：";
        addChild(tempTF);
        noTF = tempTF;
        // 玩家名称
        textFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0xFFFFFF;
        textFormat.bold = false;
        textFormat.align = TextFormatAlign.LEFT;
        textFormat.letterSpacing = 2;
        textFormat.font = UIManager.defaultFont;
        tempTF = new TextField();
        tempTF.selectable = false;
        tempTF.defaultTextFormat = textFormat;
        tempTF.width = 80;
        tempTF.height = 26;
        tempTF.x = noTF.width + noTF.x + 5;
        tempTF.y = 0;
        tempTF.text = "大海明月";
        addChild(tempTF);
        palyerNameTF = tempTF;
        // 连杀数量
        textFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0xFFFFFF;
        textFormat.bold = true;
        textFormat.align = TextFormatAlign.RIGHT;
        textFormat.letterSpacing = 2;
        textFormat.font = UIManager.defaultFont;
        tempTF = new TextField();
        tempTF.selectable = false;
        tempTF.defaultTextFormat = textFormat;
        tempTF.width = 80;
        tempTF.height = 26;
        tempTF.x = palyerNameTF.width + palyerNameTF.x - 20;
        tempTF.y = 0;
        tempTF.text = "99连杀";
        addChild(tempTF);
        killCountTF = tempTF;
    }

    /** 设置编号 */
    public function setNo(value : int) : void
    {
        noTF.text = "第 " + value + " 名：";
    }

    /** 设置玩家名称 */
    public function setPlayerName(playerName : String, colorStr : String = "#FF0000") : void
    {
        if (playerName == null || playerName == "")
        {
            visible = false;
            return;
        }
        else
        {
            visible = true;
        }
        palyerNameTF.htmlText = "<font color='" + colorStr + "'>" + playerName + "</font>";
    }

    /** 设置连杀数 */
    public function setKillCout(value : int) : void
    {
        killCountTF.text = value + "连杀";
    }
}
