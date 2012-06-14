package game.module.duplMap.ui
{
	import com.commUI.icon.ItemIcon;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.utils.UICreateUtils;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.manager.ViewManager;
	import game.module.duplMap.DuplConfig;
	import game.module.duplMap.DuplProto;
	import game.module.duplMap.DuplUtil;
	import gameui.controls.GButton;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;
	import gameui.manager.UIManager;
	import net.AssetData;





    public class DuplMapGetReward extends GComponent
    {
        protected var _getCompleteCallFun : Vector.<Function> = new Vector.<Function>();
        /** 背景 */
        public var bg : DisplayObject;
        /** 全部拾取按钮 */
        public var getAllButton : GButton;
        /** 怪物位置 */
        public var monsterPostion : Point = new Point();
        public var itemWidth : uint = 48;
        public var itemHeight : uint = 48;
        public var gap : uint = 5;
        public var itemList : Vector.<VoParabolicItem> = new Vector.<VoParabolicItem>();
        public var itemCount : uint;
        public var itemGetCount : uint = 0;
        public var NAME : String = "DungeonGetReward";

        public function DuplMapGetReward()
        {
            this.name = NAME;
            _base = new GComponentData();
            _base.width = 430;
            _base.height = 100;
            _base.parent = ViewManager.instance.uiContainer;
            super(_base);
            stageResize();
            initViews();
            initEvent();
        }

        public function stageResize(stage : Stage = null, preStageWidth : Number = 0, preStageHeight : Number = 0) : void
        {
            this.x = (ViewManager.instance.uiContainer.stage.stageWidth - _base.width) / 2;
            this.y = (ViewManager.instance.uiContainer.stage.stageHeight - _base.height) / 2 + 100;
        }

        public function initViews() : void
        {
            bg = UIManager.getUI(new AssetData(UI.ICON_LIST_BACKGROUND));
            bg.height = 55;
            bg.x = 0;
            bg.y = 0;
            addChild(bg);
            var buttonData : GButtonData = new GButtonData();
            buttonData.width = 114;
            buttonData.height = 33;
            buttonData.x = (this.width - buttonData.width) / 2;
            buttonData.y = this.height - buttonData.height;
            buttonData.labelData.text = "全部拾取";
            getAllButton = new GButton(buttonData);
            addChild(getAllButton);
            visible = false;
        }

        public function initEvent() : void
        {
        }

        public function setMonsterGlobalPostion(point : Point) : void
        {
            monsterPostion = this.globalToLocal(point);
            monsterPostion.x -= itemWidth / 2;
            monsterPostion.y -= itemHeight;
        }

        public function setItems(items : Vector.<uint>) : void
        {
            var goodsIdList : Vector.<VoDuplGoods> = new Vector.<VoDuplGoods>();

            var length : int = items.length;
            for (var i : int = 0; i < length; i++)
            {
                var num : uint = items[i];
                var bindingFlag : uint = num >> 31;
                var voDungeonGoods : VoDuplGoods = new VoDuplGoods();
                voDungeonGoods.binding = (bindingFlag) ? true : false;
                voDungeonGoods.id = (num - (bindingFlag << 31)) >> 16;
                voDungeonGoods.count = num - ((bindingFlag << 31) + (voDungeonGoods.id << 16));
                goodsIdList.push(voDungeonGoods);
            }
            setGoodsIdList(goodsIdList);
            this.goodsIdList = goodsIdList;
        }

        public var goodsIdList : Vector.<VoDuplGoods>;

        public function setGoodsIdList(goodsIdList : Vector.<VoDuplGoods>) : void
        {
            if (goodsIdList == null || goodsIdList.length == 0) getAllButton.addEventListener(MouseEvent.CLICK, getAllButton_clickHandler);
            // goodsIdList.push(new VoDungeonGoods(2,0));
            // goodsIdList.push(new VoDungeonGoods(3,1));
            // goodsIdList.push(new VoDungeonGoods(4,2));
            // goodsIdList.push(new VoDungeonGoods(4,3));
            this.visible = false;
            this.alpha = 1;
            bg.visible = false;
            getAllButton.visible = false;
            bg.alpha = 0;
            getAllButton.alpha = 0;

            var voParabolicItem : VoParabolicItem;
            while (itemList.length > 0)
            {
                voParabolicItem = itemList.shift();
                if (voParabolicItem.displayObject && voParabolicItem.displayObject.parent) voParabolicItem.displayObject.parent.removeChild(voParabolicItem.displayObject);
            }

            itemCount = goodsIdList.length;
            for (var i : int = 0; i < itemCount; i++)
            {
                var voItem : Item = ItemManager.instance.newItem(goodsIdList[i].id);
                // if(voItem) voItem = voItem.clone();
                // if(voItem == null) voItem = new VoItem();
                voItem.nums = goodsIdList[i].count;
                voItem.binding = goodsIdList[i].binding;
                var itemIcon : ItemIcon = UICreateUtils.createItemIcon({showBg:true, showBorder:true, showToolTip:true, showNums:true, showBinding:true});
                itemIcon.source = voItem;
                voParabolicItem = new VoParabolicItem();
                voParabolicItem.displayObject = itemIcon;
                voParabolicItem.startPoint.x = monsterPostion.x;
                voParabolicItem.startPoint.y = monsterPostion.y;
                var endPostion : Point = getItemEndPostion(i, itemCount);
                voParabolicItem.endPoint.x = endPostion.x;
                voParabolicItem.endPoint.y = endPostion.y;
                itemIcon.scaleX = itemIcon.scaleY = 0.3;
                itemIcon.alpha = 0.3;
                addChild(itemIcon);
                itemList.push(voParabolicItem);
            }
        }

        public function play() : void
        {
            if (itemList == null || itemList.length == 0) getAllButton.addEventListener(MouseEvent.CLICK, getAllButton_clickHandler);
            this.visible = true;
            bg.visible = true;
            getAllButton.visible = true;

            this.alpha = 1;
            TweenLite.to(bg, 1, {alpha:1});
            TweenLite.to(getAllButton, 1, {alpha:1});

            var thruY : int = monsterPostion.y - 80;

            var voParabolicItem : VoParabolicItem;
            var a:Number = 0.3 / itemList.length;
            for (var i : int = 0; i < itemList.length; i++)
            {
                voParabolicItem = itemList[i];
                var thruX : int = monsterPostion.x + (voParabolicItem.endPoint.x-monsterPostion.x ) * 2;
                voParabolicItem.displayObject.x = monsterPostion.x;
                voParabolicItem.displayObject.y = monsterPostion.y;
                TweenMax.to(voParabolicItem.displayObject, 1- i * a, {delay:i * a, alpha:1, scaleX:1, scaleY:1, ease:Linear.easeInOut, bezier:[{x:thruX, y:thruY}, {x:voParabolicItem.endPoint.x, y:voParabolicItem.endPoint.y}]});
            }

            setTimeout(itemGetAllComplete, 1000);

            // for (var i : int = 0; i < itemList.length; i++)
            // {
            // var parabolic : Parabolic = new Parabolic();
            // parabolic.displayObject = itemList[i].displayObject;
            //				//  parabolic.startPoint = itemList[i].startPoint;
            // parabolic.startPoint = monsterPostion;
            // parabolic.displayObject.x = monsterPostion.x;
            // parabolic.displayObject.y = monsterPostion.y;
            // parabolic.endPoint = itemList[i].endPoint;
            // parabolic.playCompleteCallFun = itemGetCompleteCallFun;
            // setTimeout(parabolic.play, (200 * Math.round(Math.random() * 4)));
            // }
        }

        public function itemGetCompleteCallFun(parabolic : Parabolic) : void
        {
            parabolic;
            itemGetCount++;
            if (itemGetCount >= itemCount)
            {
                itemGetAllComplete();
            }
        }

        public function itemGetAllComplete() : void
        {
            getAllButton.addEventListener(MouseEvent.CLICK, getAllButton_clickHandler);
        }

        private function getAllButton_clickHandler(event : MouseEvent) : void
        {
            if (DuplUtil.hasEnoughPack == false) return;
            if (itemList.length == 0)
            {
                close();
                return;
            }
            DuplProto.instance.cs_getAward();
            // close();
        }

        public function checkPack() : Boolean
        {
            if (UserData.instance.tryPutPacMsg153(DuplConfig.MIN_PACK_EMPTY) <= 0) return false;
            return true;
        }

        public function close() : void
        {
            getAllButton.removeEventListener(MouseEvent.CLICK, getAllButton_clickHandler);
            for (var i : int = 0; i < _getCompleteCallFun.length; i++)
            {
                _getCompleteCallFun[i]();
            }
            TweenLite.to(this, 1, {alpha:0});
            setTimeout(hide, 1000);
        }

        public function getItemEndPostion(index : int, count : int) : Point
        {
            var countIsEven : Boolean = count % 2 == 0;
            var postion : Point = new Point();
            postion.y = 0;
            // 共有偶数个
            if (countIsEven == true)
            {
                if (index % 2 == 0)
                {
                    postion.x = this.width / 2 - (itemWidth + gap) * Math.floor(index / 2) + gap * 0.5 - (itemWidth + gap);
                }
                else
                {
                    postion.x = this.width / 2 + (itemWidth + gap) * Math.floor(index / 2) - gap * 0.5 ;
                }
            }
            else
            {
                if (index == 0)
                {
                    postion.x = (this.width - itemWidth) / 2;
                }
                else if (index % 2 == 0)
                {
                    postion.x = (this.width - itemWidth) / 2 - (itemWidth + gap) * Math.ceil(index / 2);
                }
                else
                {
                    postion.x = (this.width - itemWidth) / 2 + (itemWidth + gap) * Math.ceil(index / 2);
                }
            }
            return postion;
        }

        override public function show() : void
        {
            ViewManager.addStageResizeCallFun(stageResize);
            bg.width = itemList.length * (itemWidth + gap);
            bg.x = (_base.width - bg.width - gap) / 2 ;
            this.visible = false;
            bg.visible = false;
            getAllButton.visible = false;
            bg.alpha = 0;
            getAllButton.alpha = 0;

            if (_base.parent && _base.parent.getChildByName(NAME)) _base.parent.removeChild(_base.parent.getChildByName(NAME));
            super.show();
            play();
        }

        override public function hide() : void
        {
            ViewManager.removeStageResizeCallFun(stageResize);
            this.visible = false;
            bg.visible = false;
            getAllButton.visible = false;
            bg.alpha = 0;
            getAllButton.alpha = 0;
            super.hide();
        }

        public function addGetCompleteCallFun(fun : Function) : void
        {
            if (fun == null) return;
            var index : int = _getCompleteCallFun.indexOf(fun);
            if (index == -1)
            {
                _getCompleteCallFun.push(fun);
            }
        }

        public function removeGetCompleteCallFun(fun : Function) : void
        {
            if (fun == null) return;
            var index : int = _getCompleteCallFun.indexOf(fun);
            if (index != -1)
            {
                _getCompleteCallFun.splice(index, 1);
            }
        }

        public function clear() : void
        {
            while (_getCompleteCallFun.length > 0)
            {
                _getCompleteCallFun.shift();
            }

            while (itemList.length > 0)
            {
                var voGoodsItem : VoParabolicItem = itemList.shift();
                if (voGoodsItem.displayObject && voGoodsItem.displayObject.parent) voGoodsItem.displayObject.parent.removeChild(voGoodsItem.displayObject);
            }

            hide();
        }
    }
}