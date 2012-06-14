package game.module.searchTreasure {
	import flash.display.Sprite;
	import game.module.bossWar.BossBloodVaulItem;
	import gameui.containers.GPanel;
	import gameui.controls.GLabel;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.skin.SkinStyle;
	import net.AssetData;

	/**
	 * @author Lv
	 */
	public class FamilyPlayerList extends GPanel {
		private var myPlayerToBossHarm:GLabel;
		private var ChallengeLastTimer:GLabel;
		private var rankingVaulItemList:Vector.<BossBloodVaulItem> = new Vector.<BossBloodVaulItem>();
		private var listSp:Sprite;
		private var bossBloodTotal:Number;
		
		public function FamilyPlayerList() {
			_data = new GPanelData();
			initData();
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void {
			_data.width = 290;
			_data.height = 300;
			_data.bgAsset=new AssetData(SkinStyle.emptySkin);   //取消背景
		}

		private function initEvent() : void {
		}

		private function initView() : void {
//			bossBloodTotal = ProxyBossWar.bossBloodTotal;
			addPanel();
			//addRankPanel();
		}
		/**
		 * 玩家对boss的伤害排行榜   前10名
		 */
		public function addRankPanel() : void {
			removeList();
//			var playerNameVec:Vector.<StrING> = BOSSWARCONTROL.JOINBOSSWARPLAYERNAME;
//			VAR PLAYERCOLORVEC:VECTOR.<UINT> = BOSSWARCONTROL.JOINBOSSWARPLAYERCOLOR;
//			VAR PLAYERBLOODVEC:VECTOR.<UInt> = BossWarControl.joinBossWarPlayerBlood;
//			var max:int = playerNameVec.length;
//			var totalBlood:int = ProxyBossWar.bossBloodTotal;
//			if(max == 0)return;
//			for(var i:int = 0; i < max ; i++){
//				var color:uint = playerColorVec[i];
//				var name:String = playerNameVec[i];
//				var harm:int = playerBloodVec[i];
//				rankingVaulItemList[i].alpha = 1;
//				rankingVaulItemList[i].setPlayerName(i+1, name, harm,totalBlood);
//				rankingVaulItemList[i].setTextColor(color);
//			}
			
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
			data.text = "你对BOSS造成0(0%)的伤害";
			data.width = 280;
			myPlayerToBossHarm = new GLabel(data);
			addChild(myPlayerToBossHarm);
			data.clone();
			data.text = "挑战BOSS剩余时间：";
			data.y = 280;
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
		 * 我的boss造成的伤害
		 * harm:伤害值
		 */
		public function myHeroBloodToBoss():void{
//			var harm:uint = BossWarControl.mypalyeToBossHarm;
//            bossBloodTotal = ProxyBossWar.bossBloodTotal;
//            if(harm ==0)
//            	myPlayerToBossHarm.text = "你对BOSS造成0(0%)的伤害";
//           else
//				myPlayerToBossHarm.text = "你对BOSS造成"+harm+"("+(Math.round((harm/bossBloodTotal)*10000))/100+"%"+")"+"的伤害";
			
			
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
//			SecondsTimer.addFunction(refershTimer);				//倒计时控制
		}
		
		private function refershTimer() : void {
//			ChallengeLastTimer.text = TimeUtil.secondsToTime(timer);				//获取显示时间 格式：00:00:00
//			if(timer == 0){
//				SecondsTimer.removeFunction(refershTimer);
//				return;
//			}
//			timer--;
		}
		
		override public function hide():void{
			super.hide();
		}
	}
}