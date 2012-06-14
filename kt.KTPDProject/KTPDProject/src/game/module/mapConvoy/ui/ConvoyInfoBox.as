package game.module.mapConvoy.ui
{
    import com.commUI.icon.ItemIcon;
    import com.utils.ColorUtils;
    import com.utils.UICreateUtils;
    import com.utils.UIUtil;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFormatAlign;
    import game.core.item.Item;
    import game.core.item.ItemManager;
    import game.module.mapConvoy.ConvoyConfig;
    import gameui.controls.GButton;
    import gameui.controls.GLabel;
    import gameui.controls.GToolTip;
    import gameui.core.GComponent;
    import gameui.core.GComponentData;
    import gameui.data.GButtonData;
    import gameui.data.GLabelData;
    import gameui.data.GToolTipData;
    import gameui.manager.UIManager;
    import net.AssetData;





    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-14 ����7:13:02
     */
    public class ConvoyInfoBox extends GComponent
    {
        public function ConvoyInfoBox(singleton:Singleton)
        {
			singleton;
            _base = new GComponentData();
			_base.parent = UIUtil.stage;
            _base.width = 240;
            _base.height = 85;
            super(_base);
            initViews();
        }

		/** 单例对像 */
		private static var _instance : ConvoyInfoBox;

		/** 获取单例对像 */
		static public function get instance() : ConvoyInfoBox {
			if (_instance == null) {
				_instance = new ConvoyInfoBox(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //

		public var itemIcon : ItemIcon;
		public var itemNameLabel:GLabel;
		/** 奖励 */
		public var rewardLabel:GLabel;
		/** 进程 */
		public var processLabel:GLabel;
		/** 加速按钮 */
		public var fastForwardButton:GButton;
		/** 立即完成按钮 */
		public var immediatelyButton:GButton;
        private function initViews() : void
        {
			//背景
			var sprite:Sprite = UIManager.getUI(new AssetData("Bg_Darkblue"));
			sprite.width = _base.width;
			sprite.height = _base.height;
			addChild(sprite);
			//香炉物品图
			itemIcon = UICreateUtils.createItemIcon({showBg:true, showBorder:true, showToolTip:true});
			var item : Item = ItemManager.instance.getPileItem(ConvoyConfig.xiangLuGoodsDic[ConvoyConfig.XIANG_LU_4]);
			itemIcon.source = item;
			itemIcon.x = 10;
			itemIcon.y = 5;
			addChild(itemIcon);
			var labelData : GLabelData = new GLabelData();
			labelData.text = item.name;
			labelData.textColor = ColorUtils.TEXTCOLOROX[item.color];
			labelData.width = itemIcon.width;
			labelData.textFormat.align = TextFormatAlign.CENTER;
			labelData.x = itemIcon.x;
			labelData.y = itemIcon.height + 5;
			labelData.textFieldFilters = [];
			var label : GLabel = new GLabel(labelData);
			addChild(label);
			itemNameLabel = label;
			
			//运香炉获得：
			label = UICreateUtils.createGLabel({width:90, height:20,text:"运香炉获得：", x:80, y: 15});
			addChild(label);
			// 
			sprite = UIManager.getUI(new AssetData("MoneyIcon_Silver"));
			sprite.x = 150;
			sprite.y = 18;
			addChild(sprite);
			// 
			label = UICreateUtils.createGLabel({width:90, height:20,text:"99999999", x:165, y: 15});
			addChild(label);
			rewardLabel = label;
			//参拜进程：
			label = UICreateUtils.createGLabel({width:75, height:20,text:"参拜进程：", x:80, y: 35});
			addChild(label);
			// 
			label = UICreateUtils.createGLabel({width:90, height:20,text:"1/4", x:138, y: 35});
			addChild(label);
			processLabel = label;
			//剩余时间：
			label = UICreateUtils.createGLabel({width:75, height:20,text:"剩余时间：", x:80, y: 55});
			addChild(label);
			// 
			label = UICreateUtils.createGLabel({width:90, height:20,text:"32:15", x:138, y: 55});
			addChild(label);
			//FastForwardIcon ImmediatelyIcon
			
			// 加速按钮
			var button:GButton = UICreateUtils.createGButton("", 25, 22, 190, 55);
            button.toolTip = new GToolTip(new GToolTipData());
            button.toolTip.source = "加速";
            button.addEventListener(MouseEvent.CLICK, fastForwardButtonOnClick);
            addChild(button);
			fastForwardButton = button;

            var buttonIcon : Sprite = UIManager.getUI(new AssetData("FastForwardIcon"));
            buttonIcon.x = (button.width - buttonIcon.width) / 2;
            buttonIcon.y = (button.height - buttonIcon.height) / 2;
            button.addChild(buttonIcon);
			
			// 立即完成按钮
			button = UICreateUtils.createGButton("", 25, 22, 230, 55);
            button.toolTip = new GToolTip(new GToolTipData());
            button.toolTip.source = "立即完成";
            button.addEventListener(MouseEvent.CLICK, immediatelyButtonOnClick);
            addChild(button);
			immediatelyButton = button;

            buttonIcon = UIManager.getUI(new AssetData("ImmediatelyIcon"));
            buttonIcon.x = (button.width - buttonIcon.width) / 2;
            buttonIcon.y = (button.height - buttonIcon.height) / 2;
            button.addChild(buttonIcon);
			
			
        }

        private function immediatelyButtonOnClick(event : MouseEvent) : void
        {
        }

        private function fastForwardButtonOnClick(event : MouseEvent) : void
        {
        }
		
		
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		override protected function layout():void
		{
			x = 5;
			y = 103;
		}
		
		override public function show() : void {
			layout();
			super.show();
//			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		override public function hide() : void {
//			stage.removeEventListener(Event.RESIZE, onStageResize);
			super.hide();
		}

		private function onStageResize(event : Event) : void {
			layout();
		}

		override public function get stage() : Stage {
			return UIUtil.stage;
		}
    }
}
class Singleton
{
	
}