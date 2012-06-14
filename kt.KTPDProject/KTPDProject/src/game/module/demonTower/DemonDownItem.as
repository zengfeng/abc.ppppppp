package game.module.demonTower {
	import com.greensock.layout.AlignMode;
	import com.utils.UrlUtils;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import game.module.duplMap.DuplOpened;
	import game.module.duplMap.DuplUtil;
	import game.module.map.animalstruct.MonsterStruct;
	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.manager.UIManager;
	import net.AssetData;
	import net.RESManager;





	/**
	 * @author Lv
	 */
	public class DemonDownItem extends GComponent {
		private var background:MovieClip;
		private var signSP:Sprite;
		private var signLockSp:Sprite;
		private var monsterImg:GImage;
		private var monsterName:GLabel;
		private var lockStatus:Boolean;
		private var monster:MonsterStruct;
		public function DemonDownItem() {
			_base = new GComponentData();
            initData();
            super(_base);
            initView();
            initEvent();
		}

		private function initData() : void {
			_base.width = 133;
            _base.height = 44;
		}

		private function initEvent() : void {
		}

		private function initView() : void {
			setBgToStage();
			setsignSPToStage();
			setLockToStage();
			setMonsterImgToStage();
			setMonsterNameToStage();
			maskMonster();
		}
		
		public function refreshData(monster1:MonsterStruct):void{
			this.monster = monster1;
			var demonBossId:int = DuplUtil.getDemonBossIdByDuplMapId(monster.mapId);
			var isPass:Boolean = DuplOpened.isOpenDuplMapId(demonBossId);
			if(!isPass){
				noImg();
				return;
			}
			else{
				haveImg();
			}
			
			refreshMonsterImg(monster.mapId);
			refreshMonsterName(monster.name);
		}
		
		public function refreshOpen():void{
			refreshData(getMonster);
		}

		private function haveImg() : void {
			signSP.visible = false;
			monsterImg.visible = true;
			monsterName.visible = true;
		}

		private function noImg() : void {
			signSP.visible = true;
			monsterImg.visible = false;
			monsterName.visible = false;
		}

		private function refreshMonsterName(newName:String) : void {
			monsterName.text = newName;
		}

		private function refreshMonsterImg(duplMapId:int) : void {
			monsterImg.url =  UrlUtils.getDungeonLayerIcon(duplMapId);;
		}
		
		public function mouseDown():void{
			background.gotoAndStop(2);
		}
		
		public function mouseUp():void{
			background.gotoAndStop(1);
		}
		
		private function maskMonster():void{
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x55555);
			mask.graphics.drawRect(0, -120, 121, 161);
			mask.graphics.endFill();
			this.addChild(mask);
			monsterImg.mask = mask;
			mask.mouseChildren = false;
			mask.mouseEnabled=false;
		}

		private function setMonsterNameToStage() : void {
			var data:GLabelData = new GLabelData();
			data.text = "变异树妖";
			data.width = 133;
			data.y = 20;
			data.textFormat = new TextFormat(null,14,0xFFFFFF,null,null,null,null,null,AlignMode.RIGHT);
			monsterName = new GLabel(data);
			this.addChild(monsterName);
		}

		private function setMonsterImgToStage() : void {
			var data:GImageData = new GImageData();
			data.width = 121;
			data.height = 184;
			data.x = 0;
			data.y = -120;
			monsterImg = new GImage(data);
			this.addChild(monsterImg);
			monsterImg.mouseChildren = false;
			monsterImg.mouseEnabled=false;
		}

		private function setLockToStage() : void {
			signLockSp = UIManager.getUI(new AssetData("Locking"));
			signLockSp.x = 121;
			signLockSp.y = -6;
			signLockSp.scaleX = signLockSp.scaleY = 0.8;
			signLockSp.filters = [new GlowFilter(0xFFFFCC)];
			signLockSp.visible = false;
			this.addChild(signLockSp);
		}

		private function setsignSPToStage() : void {
			signSP = UIManager.getUI(new AssetData("QuestionMark"));
			signSP.x = 57;
			signSP.y = 6;
			signSP.visible = false;
			this.addChild(signSP); 
		}

		private function setBgToStage() : void {
			background = RESManager.getMC(new AssetData("demonBG"));
			this.addChild(background);
		}

		public function get getLockStatus() : Boolean {
			return lockStatus;
		}

		public function set setLockStatus(lockStatus : Boolean) : void {
			signLockSp.visible = lockStatus;
			this.lockStatus = lockStatus;
		}

		public function get getMonsterName() : GLabel {
			return monsterName;
		}

		public function get getMonster() : MonsterStruct {
			return monster;
		}
	}
}
