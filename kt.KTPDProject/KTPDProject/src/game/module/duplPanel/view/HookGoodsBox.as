package game.module.duplPanel.view
{
	import com.commUI.button.KTButtonData;
	import com.commUI.icon.ItemIcon;
	import com.greensock.TweenLite;
	import com.utils.UICreateUtils;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import gameui.controls.GButton;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;




	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-13
	 */
	public class HookGoodsBox extends GComponent
	{
		private const BUTTON_WIDTH : int = 14;
		private const BUTTON_HEIGHT : int = 21;
		private const ITEM_WIDTH : int = 46;
		private const ITEM_HEIGHT : int = 46;
		private const ITEM_Y : int = 0;
		private const GAP : int = 7;
		private var BODY_WIDTH : int = 505;
		private var BODY_HEIGHT : int = 46;
		private var ITEM_ONCE_PAGE_RANK_COUNT : int = 5;
		/** 正文容器 */
		private var bodyContainer : Sprite;
		private var bodyScrollRect : Rectangle;
		private var leftButton : GButton;
		private var rightButton : GButton;
		private var testPageSprict:Sprite;

		public function HookGoodsBox(width : int = 310, height : int = 48)
		{
			_base = new GComponentData();
			_base.width = width;
			_base.height = height;
//			BODY_WIDTH = width - BUTTON_WIDTH * 2 - GAP * 3;
			BODY_WIDTH = (ITEM_WIDTH + GAP) * ITEM_ONCE_PAGE_RANK_COUNT - GAP ;
			BODY_HEIGHT = height;
//			ITEM_ONCE_PAGE_RANK_COUNT = Math.floor((BODY_WIDTH + GAP) / (ITEM_WIDTH + GAP)) ;
			bodyScrollRect = new Rectangle(0, 0, BODY_WIDTH + 2, BODY_HEIGHT);
			super(_base);

			initViews();
//			create_testPageSprict();
		}

		public function initViews() : void
		{
			var buttonData : GButtonData;
			var button : GButton;
			buttonData = new KTButtonData(KTButtonData.PAGE_LEFT_BUTTON);
			button = new GButton(buttonData);
			button.x = 0;
			button.y = (_base.height - BUTTON_HEIGHT) >> 1;
			addChild(button);
			leftButton = button;

			buttonData = new KTButtonData(KTButtonData.PAGE_RIGHT_BUTTON);
			button = new GButton(buttonData);
			button.x = _base.width - BUTTON_WIDTH;
			button.y = leftButton.y;
			addChild(button);
			rightButton = button;

			bodyContainer = new Sprite();
			bodyContainer.x = (_base.width - BODY_WIDTH) / 2;
			bodyContainer.y = ( _base.height - ITEM_HEIGHT) / 2;
			addChildAt(bodyContainer, 0);
			bodyContainer.scrollRect = bodyScrollRect;
			leftButton.addEventListener(MouseEvent.CLICK, onClickLeftButton);
			rightButton.addEventListener(MouseEvent.CLICK, onClickRightButton);

			initItems();
			clear();
			
//			testWH();
//			testItem();
		}


		
		//==================
		// Item区块
		//==================
		private var itemIndex : int = 0;

		public function initItems() : void
		{
			var itemIcon : ItemIcon;
			for (var i : int = 0; i < ITEM_ONCE_PAGE_RANK_COUNT; i++)
			{
				itemIcon = UICreateUtils.createItemIcon({showBg:true, showBorder:true, showToolTip:true, showNums:true,showBinding:true});
				itemIcon.x = i * (ITEM_WIDTH + GAP);
				itemIcon.y = ITEM_Y;
				bodyContainer.addChild(itemIcon);
			}
		}

		public function clear() : void
		{
			var itemIcon : ItemIcon;
			while (bodyContainer.numChildren > ITEM_ONCE_PAGE_RANK_COUNT)
			{
				itemIcon = bodyContainer.getChildAt(bodyContainer.numChildren - 1) as ItemIcon;
				bodyContainer.removeChild(itemIcon);
				itemIcon.source = null;
			}

			for (var i : int = 0; i < bodyContainer.numChildren; i++)
			{
				itemIcon = bodyContainer.getChildAt(i) as ItemIcon;
				itemIcon.source = null;
			}
			itemIndex = 0;
			setPagePostion(0);
		}

		public function addItem(id : int, num : int, binding:Boolean) : void
		{
			var itemIcon : ItemIcon;
			if (itemIndex < ITEM_ONCE_PAGE_RANK_COUNT)
			{
				itemIcon = bodyContainer.getChildAt(itemIndex) as ItemIcon;
			}
			else
			{
				itemIcon = UICreateUtils.createItemIcon({showBg:true, showBorder:true, showToolTip:true, showNums:true,showBinding:true});
				itemIcon.x = bodyContainer.numChildren * (ITEM_WIDTH + GAP);
				itemIcon.y = ITEM_Y;
				bodyContainer.addChild(itemIcon);
			}

			var item : Item = ItemManager.instance.newItem(id);
			if (item)
			{
				item.nums = num;
				item.binding = binding;
			}
			itemIcon.source = item;
			itemIndex++;
			setMaxPagePosition();
		}
		
		//==================
		// 滚屏区块
		//==================
		 /** 获取最小滚屏位置 */
        public function getPageMin() : int
        {
            return 0;
        }

        /** 获取最小滚屏位置 */
        public function getPageMax() : int
        {
			var val:Number = bodyContainer.numChildren * (ITEM_WIDTH + GAP) - BODY_WIDTH - GAP;
            return val > 0 ? val : 0;
        }
		
		private function onClickLeftButton(event : MouseEvent) : void
		{
            var value : Number = bodyScrollRect.x - BODY_WIDTH - GAP;
            setPagePostion(value);
		}
		
		private function onClickRightButton(event : MouseEvent) : void
		{
            var value : Number = bodyScrollRect.x + BODY_WIDTH + GAP;
            setPagePostion(value);
		}
		
		private function onScrollUpdate():void
		{
			bodyContainer.scrollRect = bodyScrollRect;
//			testPageSprict.x = bodyScrollRect.x + 25;
		}
		
		public function setMaxPagePosition():void
		{
			setPagePostion(getPageMax());
		}
		
		/** 设置滚屏位置 */
        public function setPagePostion(value : int) : void
        {
			//trace("value= " + value);
			  if (value <= getPageMin())
            {
                value = getPageMin();
                leftButton.enabled = false;
            }

            if (value >= getPageMax())
            {
                value = getPageMax();
                rightButton.enabled = false;
            }

            TweenLite.to(bodyScrollRect, 0.5, {x:value, onUpdate:onScrollUpdate});
			//trace("value: " + value);

            if (bodyContainer.numChildren <= ITEM_ONCE_PAGE_RANK_COUNT)
            {
                leftButton.enabled = false;
                rightButton.enabled = false;
            }
            else
            {
                if (value > getPageMin())
                {
                    leftButton.enabled = true;
                }

                if (value < getPageMax())
                {
                    rightButton.enabled = true;
                }
            }
		}
		
		
		
		public function create_testPageSprict():void
		{
			testPageSprict = new Sprite();
			testPageSprict.x = bodyContainer.x;
			var g:Graphics = testPageSprict.graphics;
			g.beginFill(0x00FF00, 0.3);
			g.drawRect(0, 0, BODY_WIDTH, BODY_HEIGHT);
			g.endFill();
			addChildAt(testPageSprict, 0);
		}
		
		public function testItem() : void
		{
			for (var i : int = 0; i < 13;i++)
			{
				var id : int = 9000 + Math.round(Math.random() * 50);
				var num : int = Math.random() * 100;
				addItem(id, num, false);
			}
		}

		public function testWH() : void
		{
			var g : Graphics = bodyContainer.graphics;
			g.beginFill(0xFF0000, 0.1);
			g.drawRect(0, 0, BODY_WIDTH, BODY_HEIGHT);
			g.endFill();
		}
	}
}
