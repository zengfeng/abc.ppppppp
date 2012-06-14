package game.module.map.loding
{
    import com.commUI.CommonLoading;
    import flash.events.KeyboardEvent;
    import flash.events.Event;
    import com.utils.UIUtil;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-14
     */
    public class TestLoaderPanel extends Sprite
    {
        public function TestLoaderPanel()
        {
            initView();
        }
        
        /** 单例对像 */
        private static var _instance : TestLoaderPanel;

        /** 获取单例对像 */
        public static function get instance() : TestLoaderPanel
        {
            if (_instance == null)
            {
                _instance = new TestLoaderPanel();
            }
            return _instance;
        }
         private function initView():void
        {
            var buttonData:GButtonData;
            var button:GButton;
            
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "load显示";
            button = new GButton(buttonData);
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, showLoaderPanel);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "load隐藏";
            button = new GButton(buttonData);
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, hideLoaderPanel);
            UIUtil.stage.addEventListener(KeyboardEvent.KEY_DOWN, hideLoaderPanel);
            
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, hideLoaderPanel);
            UIUtil.stage.addEventListener(KeyboardEvent.KEY_DOWN, hideLoaderPanel);
            
            
            for(var i:int = 0; i <numChildren; i++)
            {
                var dis:DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }
           
            x = 500;
            y = 250;
            
        }

        private function hideLoaderPanel(event : Event = null) : void
        {
//            CommonLoading.instance.close();
        }

        private function showLoaderPanel(event : MouseEvent) : void
        {
//            CommonLoading.instance.open();
//            CommonLoading.instance.updateProgress("正在安装地图中....", 50);
        }
    }
}
