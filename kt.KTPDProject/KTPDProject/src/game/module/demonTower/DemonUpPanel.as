package game.module.demonTower
{
	import com.commUI.button.KTButtonData;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import game.core.user.UserData;
	import game.module.duplMap.DuplMapData;
	import game.module.duplMap.data.DuplStruct;
	import gameui.controls.GButton;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;




	/**
	 * @author Lv
	 */
	public class DemonUpPanel extends GComponent {
		private var leftBtn:GButton;
		private var rightBtn:GButton;
		private var itemVec:Vector.<DemonUpItem> = new Vector.<DemonUpItem>();
		private var openitem:int = 0;
		public function DemonUpPanel() {
			_base = new GComponentData();
            initData();
            super(_base);
            initView();
            initEvent();
		}

		private function initData() : void {
			_base.width = 415;
            _base.height = 52;
		}

		private function initEvent() : void {
			leftBtn.addEventListener(MouseEvent.CLICK, onleftBtn);
			rightBtn.addEventListener(MouseEvent.CLICK, onrightBtn);
		}

		private function initView() : void {
			setBG();
			setButtonToStage();
			setMask();
			//refreshData();
		}
		
		public function refreshData():void{
			var myLevel:int = UserData.instance.myHero.level;
			var duplstVec:Vector.<DuplStruct> = DuplMapData.instance.getLevelDownDuplStructList(myLevel);
			if(duplstVec.length==0)return;
			loaderItem(duplstVec);
		}

		private function onrightBtn(event : MouseEvent) : void {
			var index:int = panelSp.width - 370 - 7;
			if(panelSp.x < -index )return;
			TweenLite.to(panelSp,0.3,{x:panelSp.x - 93});
			rightBtn.enabled = false;
			setTimeout(BtnRelive, 400);
		}

		private function onleftBtn(event : MouseEvent) : void {
			if(panelSp.x > -1 )return;
			TweenLite.to(panelSp,0.3,{x:panelSp.x + 93});
			leftBtn.enabled = false;
			setTimeout(BtnRelive, 400);
		}
		
		private function BtnRelive():void{
			rightBtn.enabled = true;
			leftBtn.enabled = true;
		}
		
		private var panelSp:Sprite;
		private function setMask():void{
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x555555);
			sp.graphics.drawRect(23, 7, 370, 38);
			sp.graphics.endFill();
			this.addChild(sp);
			
			panelSp = new Sprite();
			this.addChild(panelSp);
			panelSp.mask = sp;
		}

		private function loaderItem(itemlisVec:Vector.<DuplStruct>) : void {
			if(itemVec.length>0)clearnItem();
			var item:DemonUpItem;
			var max:int = itemlisVec.length;
			var gap:int = 3;
			for(var i:int = 0; i< max;i++){
				item = new DemonUpItem();
				item.x = 23+(item.width + gap)*i;
				item.y = 7;
				item.selectFalse();
				panelSp.addChild(item);
				item.refreshDemonUp(itemlisVec[i]);
				itemVec.push(item);
				item.name = "x_" + i;
				item.addEventListener(MouseEvent.CLICK, onclick);
				item.addEventListener(MouseEvent.ROLL_OVER, onOver);
				item.addEventListener(MouseEvent.ROLL_OUT, onOut);
				
			}
			if(max>4){
				showBtn();
			}else{
				hidBtn();
			}
		}
		private var currentlyStruct:DuplStruct;
		public function starInto() : void {
			closeAllItem();
			mouseDownIndex = openitem;
			var item:DemonUpItem = itemVec[openitem];
			item.selectTrue();
			currentlyStruct = item.getDupls;
			var structID:int = currentlyStruct.id / 10 + 1;
			DemonProxy.nowlayerNumbeer = structID;
			DemonProxy.openDown = true;
			DemonProxy.instance.checkManage(structID);
		}
		
		public function OpenDownPenl():void{
			DemonContral.instance.changeLayerBoss(currentlyStruct);
		}

		private function hidBtn() : void {
			leftBtn.visible = false;
			rightBtn.visible = false;
		}

		private function showBtn() : void {
			leftBtn.visible = true;
			rightBtn.visible = true;
		}

		private function clearnItem() : void {
			while(itemVec.length>0){
				panelSp.removeChild(itemVec[0]);
				itemVec.splice(0, 1);
			}
		}
		private var rollIndex:Number = -1;
		private var rollItem:DemonUpItem;
		private function onOut(event : MouseEvent) : void {
			if(rollIndex == mouseDownIndex)return;
			rollItem.selectFalse();
		}

		private function onOver(event : MouseEvent) : void {
			rollIndex = int(event.currentTarget.name.split("_")[1]);
			if(rollIndex == mouseDownIndex)return;
			rollItem = event.currentTarget as DemonUpItem;
			rollItem.selectTrue();
		}
		private var mouseDownIndex:Number = -2;
		private function onclick(event : MouseEvent) : void {
			var index:int = int(event.currentTarget.name.split("_")[1]);
			if(mouseDownIndex == index)return;
			closeAllItem();
			mouseDownIndex = index;
			openitem = index;
			var item:DemonUpItem = event.currentTarget as DemonUpItem;
			item.selectTrue();
			currentlyStruct = item.getDupls;
			var structID:int = currentlyStruct.id / 10 + 1;
			DemonProxy.nowlayerNumbeer = structID;
			DemonProxy.openDown = true;
			DemonProxy.instance.checkManage(structID);
		}

		private function closeAllItem() : void {
			for each(var item:DemonUpItem in itemVec){
				item.selectFalse();
			}
		}

		private function setButtonToStage() : void {
			var data:GButtonData = new KTButtonData(5);
			leftBtn = new GButton(data);
			leftBtn.x = 6;
			leftBtn.y = 15;
			this.addChild(leftBtn);
			var data1:GButtonData = new KTButtonData(6);
			rightBtn = new GButton(data1);
			rightBtn.x = 396;
			rightBtn.y = 15;
			this.addChild(rightBtn);
		}

		private function setBG() : void {
		}
	}
}
