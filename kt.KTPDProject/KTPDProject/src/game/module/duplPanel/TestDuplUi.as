package game.module.duplPanel
{
	import com.commUI.button.KTButtonData;
	import com.utils.UICreateUtils;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import game.definition.ID;
	import game.module.duplMap.DuplMapController;
	import game.module.duplMap.DuplOpened;
	import game.module.duplPanel.view.WindowEnter;
	import game.module.duplPanel.view.WindowHook;
	import gameui.controls.GButton;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;
	import utils.GStringUtil;






    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestDuplUi extends Sprite
    {
        public function TestDuplUi()
        {
            initView();
        }

        /** 单例对像 */
        private static var _instance : TestDuplUi;

        /** 获取单例对像 */
        public static function get instance() : TestDuplUi
        {
            if (_instance == null)
            {
                _instance = new TestDuplUi();
            }
            return _instance;
        }

        private function initView() : void
        {
            windowEnter = WindowEnter.instance;
            windowHook = WindowHook.instance;
            // windowHook.visible = true;
            var buttonData : GButtonData;
            var button : GButton;

            buttonData = new GButtonData();
            buttonData.labelData.text = "副本进入面板";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, enterPanel);

            buttonData = new GButtonData();
            buttonData.labelData.text = "副本挂机面板";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, hookPanel);

            buttonData = new GButtonData();
            buttonData.labelData.text = "添加消息";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, appendMsg);

            buttonData = new GButtonData();
            buttonData.labelData.text = "清空消息";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, clearMsg);

            buttonData = new GButtonData();
            buttonData.labelData.text = "开放";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, opened);

            button = UICreateUtils.createGButton("Jian");
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, fish);
            button = UICreateUtils.createGButton("paly");
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, paly);
            button = UICreateUtils.createGButton("paly2");
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, paly2);

            for (var i : int = 0; i < numChildren; i++)
            {
                var dis : DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }
            // MapNameMovieClip.instance.show();

            x = 500;
            y = 50;

            initMsgs();
        }

        private function paly2(event : MouseEvent) : void
        {
            DuplMapController.instance.getRewardView.setGoodsIdList( DuplMapController.instance.getRewardView.goodsIdList);
            DuplMapController.instance.getRewardView.play();
        }

        private function paly(event : MouseEvent) : void
        {
            var items:Vector.<uint> = new Vector.<uint>();
            items.push((ID.ENHANCE_STONE_1 << 16) + 5);
            items.push((ID.ENHANCE_STONE_1<< 16 )+ 5);
            items.push((ID.PRIMARY_BAIT<< 16) + 5);
            items.push((ID.XIANG_LU_1<< 16) + 5);
            items.push((ID.XIANG_LU_4<< 16 )+ 5);
			DuplMapController.instance.getRewardView.monsterPostion = new Point(DuplMapController.instance.getRewardView.width / 2, -100);
            DuplMapController.instance.getRewardView.setItems(items);
            DuplMapController.instance.getRewardView.show();
            DuplMapController.instance.getRewardView.play();
        }

        private function fish(event : MouseEvent) : void
        {
			var i:uint = 0;
			var ui:Sprite;
			
			//trace("Test ui start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				ui = UIManager.getUI(new AssetData(SkinStyle.emptySkin));
			}
			//trace("Test ui end: " + getTimer());
			
			//trace("Test aslib start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				ui = UIManager.getUI(new AssetData(SkinStyle.emptySkin, AssetData.AS_LIB));
			}
			//trace("Test aslib end: " + getTimer());
			
			//trace("Text GButton 1 start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				ui = UICreateUtils.createGButton("测试", 50, 22, 545, 1, KTButtonData.SMALL_BUTTON);
			}
			//trace("Text GButton 1 end: " + getTimer());	
			
			//trace("Text GButton 2 start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				ui = new GButton(UICreateUtils.buttonDataSmall);
			}
			//trace("Text GButton 2 end: " + getTimer());	
			
			//trace("Text GButton 3 start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				ui = createGButton(null, 50, 22, 545, 1);
			}
			//trace("Text GButton 3 end: " + getTimer());	
			
			//trace("Text GButtonData 1 start: " + getTimer());
			var data:GComponentData;
            for (i = 0; i< 1000; i++)
			{
				data = new GButtonData();
			}
			//trace("Text GButtonData 1 end: " + getTimer());
			
			var tf:TextField = new TextField();
			//trace("TextField Test 1 start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				tf.text = "测试";
			}
			//trace("TextField Test 1 end: " + getTimer());
			
			//trace("TextField Test 2 start: " + getTimer());
            for (i = 0; i< 1000; i++)
			{
				tf.text = GStringUtil.truncateToFit("测试", 4);
			}
			//trace("TextField Test 2 end: " + getTimer());	
			
			
			
        }
		
		public function createGButton(text : String = null, width : int = 0, height : int = 0, x : int = 0, y : int = 0) : GButton
		{
			var data : GButtonData = new GButtonData();
			if (width) data.width = width;
			if (height) data.height = height;
			data.x = x;
			data.y = y;

			var button : GButton = new GButton(data);
//			if (text)
//				button.text = text;
			button.mouseChildren = false;
			return button;
		}

        private function opened(event : MouseEvent) : void
        {
            DuplOpened.setOpenedDuplMapId(205);
        }

        public var msgList : Vector.<String> = new Vector.<String>();

        public function initMsgs() : void
        {
            var str : String ;
            str = "菲律宾战舰和反潜机赶往黄岩岛海域";
            msgList.push(str);
            str = "中俄军演将实弹对抗 舰艇今日向公众开放 高清图";
            msgList.push(str);
            str = "[海上阅兵式周四下午举行 专家称联演包括高保密性项目]";
            msgList.push(str);
            str = "温家宝在德国演讲 冰岛外长称其从政是学界损失 专题";
            msgList.push(str);
            str = "福建警方被疑错抓海南女大学生且将错就错";
            msgList.push(str);
            str = "朝鲜军方发通告称将对李明博政府开启特别行动";
            msgList.push(str);
            str = "国际油价持续下跌 国内成品油价5月或迎年内首降";
            msgList.push(str);
            str = "郑州市区内所有报刊亭被指属于违建(组图)";
            msgList.push(str);
        }

        private var ii : int = 0;

        private function appendMsg(event : MouseEvent) : void
        {
//            windowHook.logBox.textArea.removeLastLine(1);
            for (var i : int = 0; i < 10; i++)
            {
                ii++;
                var index : int = Math.floor(Math.random() * msgList.length);
                var str : String = ii + "." + msgList[index];
                windowHook.logBox.textArea.appendMsg(str);
            }
        }

        private function clearMsg(event : MouseEvent) : void
        {
            windowHook.logBox.clearMsgs();
        }

        public var windowHook : WindowHook;

        private function hookPanel(event : MouseEvent) : void
        {
            windowHook.visible = !windowHook.visible;
        }

        public var windowEnter : WindowEnter;

        private function enterPanel(event : Event) : void
        {
            windowEnter.visible = !windowEnter.visible;
        }
    }
}
