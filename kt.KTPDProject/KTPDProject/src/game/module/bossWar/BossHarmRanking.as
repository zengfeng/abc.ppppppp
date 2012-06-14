package game.module.bossWar {
	import framerate.SecondsTimer;

	import gameui.controls.GLabel;
	import gameui.core.GComponent;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.manager.UIManager;

	import com.utils.TimeUtil;

	import flash.display.Sprite;

	/**
	 * @author Lv
	 */
	public class BossHarmRanking extends GComponent {
		
		private var myPlayerToBossHarm:GLabel;
		private var ChallengeLastTimer:GLabel;
		private var rankingVaulItemList:Vector.<BossBloodVaulItem> = new Vector.<BossBloodVaulItem>();
		private var listSp:Sprite;
		private var bossBloodTotal:Number;
		
		public function BossHarmRanking() {
			_base = new GPanelData();
			initData();
			super(_base);
			initView();
			initEvent();
		}

		private function initData() : void {
			_base.width = 290;
			_base.height = 180;
//			_base.bgAsset=new AssetData(SkinStyle.emptySkin);   //取消背景
		}

		private function initEvent() : void {
		}

		private function initView() : void {
//			bossBloodTotal = ProxyBossWar.bossBloodTotal;
			addPanel();
			//addRankPanel();
		}
		/**
		 * 《玩家对boss的伤害排行榜   前10名》
		 * NameVec:玩家名字
		 * ColorVec:玩家颜色
		 * BloodVec:玩家对boss的伤害总值
		 * totalBlood:boss的总血量
		 */
		public function addRankPanel(NameVec:Vector.<String>,ColorVec:Vector.<uint>,BloodVec:Vector.<uint>,totalBlood:uint) : void {
			removeList();
			var max:int = NameVec.length;
			if(max == 0)return;
			if(max>5)max = 5;
			for(var i:int = 0; i < max ; i++){
				var color:uint = ColorVec[i];
				var name:String = NameVec[i];
				var harm:int = BloodVec[i];
				rankingVaulItemList[i].alpha = 1;
				rankingVaulItemList[i].setPlayerName(i+1, name, harm,totalBlood);
				rankingVaulItemList[i].setTextColor(color);
			}
			
		}

		public function removeList() : void {
			for(var i:int = 0; i< rankingVaulItemList.length; i++){
				rankingVaulItemList[i].alpha = 0;
			}
		}

		private function addPanel() : void {
			var data:GLabelData = new GLabelData();
			data.textColor = 0xFFF600;
			data.textFormat.size = 14;
			data.textFieldFilters = UIManager.getEdgeFilters(0x000000, 1,17);
			data.text = "你对BOSS造成0(0%)的伤害";
			data.width = 280;
			myPlayerToBossHarm = new GLabel(data);
			addChild(myPlayerToBossHarm);
			data.clone();
			data.text = "挑战BOSS剩余时间：";
			data.y = 160;
			data.textColor = 0xFFFFFF;
			var text:GLabel = new GLabel(data);
			addChild(text);
			data.text = "00:00:00";
			data.x = text.x + text.width;
			ChallengeLastTimer = new GLabel(data);
			addChild(ChallengeLastTimer);
			
			listSp = new Sprite();
			listSp.y = myPlayerToBossHarm.height + 2;
			addChild(listSp);
			
			for(var i:int = 0; i < 10 ; i++){
				var item:BossBloodVaulItem = new BossBloodVaulItem();
				item.y = (i * item.height) + 8;
				rankingVaulItemList.push(item);
				item.alpha = 0;
				listSp.addChild(item);
			}
		}
		/**
		 * 《我的boss造成的伤害》
		 * harm:伤害值
		 * total:boss总血量
		 */
		public function myHeroBloodToBoss(harm:uint,total:uint):void{
            bossBloodTotal = total;
            if(harm ==0)
            	myPlayerToBossHarm.text = "你对BOSS造成0(0%)的伤害";
           else
				myPlayerToBossHarm.text = "你对BOSS造成"+harm+"("+(Math.round((harm/bossBloodTotal)*10000))/100+"%"+")"+"的伤害";
			
			
		}
        //清空
        public function clearnMyHeroBlood():void{
            myPlayerToBossHarm.text = "你对BOSS造成0(0%)的伤害";
        }
		private var timer:int = 180;
		/**
		 * 设置挑战BOSS的剩余时间  ---秒
		 */
		public function setChallageLastTimer(s:int):void{
			timer = s;
			SecondsTimer.addFunction(refershTimer);				//倒计时控制
		}
		
		private function refershTimer() : void {
			ChallengeLastTimer.text = TimeUtil.secondsToTime(timer);				//获取显示时间 格式：00:00:00
			if(timer == 0){
				SecondsTimer.removeFunction(refershTimer);
				return;
			}
			timer--;
		}
		
		override public function hide():void{
			super.hide();
		}
	}
}
