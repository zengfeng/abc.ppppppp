package game.module.wordDonate {
	import com.commUI.GCommonWindow;
	import com.commUI.pager.Pager;
	import com.commUI.pager.PagerCell;
	import com.commUI.tips.PlayerTip;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.greensock.layout.AlignMode;
	import com.utils.StringUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.manager.ViewManager;
	import game.module.wordDonate.donateManage.DonateRewardManager;
	import game.net.core.Common;
	import game.net.data.CtoS.CSDonateList;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.data.GLabelData;
	import gameui.data.GTitleWindowData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;


	/**
	 * @author Lv
	 */
	public class ContributionList extends GCommonWindow {
		private var myRank:GLabel;
		private var thisWeek:GLabel;
		private var page:Pager;
		private var listItem:Vector.<ContributionItem> = new Vector.<ContributionItem>();
		public function ContributionList() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}
		
		override protected function initData() : void {
			_data.width = 322;
			_data.height = 345;
			_data.parent = ViewManager.instance.uiContainer;
			_data.panelData.bgAsset = new AssetData(SkinStyle.emptySkin);
			_data.allowDrag = true;	
			super.initData();	
		}

		private function initEvents() : void {
			page.addEventListener(Event.CHANGE, onGetList);
		}
		
		override protected function onClickClose(event : MouseEvent) : void
        {
			MenuManager.getInstance().changMenu(MenuType.DONATECONTRIBUTION);
        }
		private var nowPage:int = 1;
		private function onGetList(event : Event) : void {
			var totalPage:int;
			if(DonateProxy.contributionNum!=0)
				totalPage = Math.ceil(DonateProxy.contributionNum/10);
			else
				totalPage = 1;
			nowPage = page.model.page;
			page.setPage(nowPage,totalPage);
			var cmd:CSDonateList = new CSDonateList();
			cmd.page = nowPage;
			Common.game_server.sendMessage(0x103,cmd);
			var arr:Array = page.labelList;
			var w:int;
			for each(var txt0:PagerCell in arr){
				w += txt0.width;
			}
			w = w + (arr.length-1)*2;
			page.x = (this.width - w) / 2;
		}
		
		override protected function initViews() : void
		{
			title = "贡献排行榜";	
			super.initViews();
			addBG();
			addPanel();
		}

		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND));
			bg.x = 5;
			bg.y = 3;
			bg.width = 307;
			bg.height = 337;
			_contentPanel.addChild(bg);
		}
		
		public function setList():void{
			clearnItem();
			if(DonateProxy.nowWeekRank == 0)
				myRank.text = "我的排名：未入围";
			else
				myRank.text = "我的排名：" +String(DonateProxy.nowWeekRank);
			thisWeek.text = "本周贡献：" + String(DonateProxy.nowWeekContributionVaule) + " 个";
			var list:Vector.<Object> = DonateProxy.contributionRank;
			if(list.length>10)return;
			for(var i:int = 0 ; i<list.length; i++){
				var obj:Object = list[i];
				var id:int = obj["id"];
				var name:String = obj["name"];
				var level:int = obj["level"];
				var contr:uint = obj["vaule"];
				var color:uint = obj["color"];
				var rank:int = 10*(nowPage-1) + (i+1);
				listItem[i].setContent(rank, name, level, contr,id,color);
				listItem[i].visible = true;
				if(id == UserData.instance.playerId){
					listItem[i].setBackGround(false,true);
				}
				var maxRank:int = DonateRewardManager.saveDonateRewardMaxRank;
				var str:String = "";
				if(rank < maxRank)
					str = DonateRewardManager.saveDonateRewardDic[rank];
				else
					str = DonateRewardManager.saveDonateRewardDic[maxRank];
				str = str.split("：")[1];
				str = "<font color='#FFF000'>第"+rank+"名奖励:</font>" + str.split("、")[0] + "\n" + str.split("、")[1];
				str = StringUtils.addSize(StringUtils.addBold(StringUtils.addColorById(name, (color + 1))),14)+"\n"+str+"\n"+"<font color='#999999'>在下周一00:00结算时，按排名获得 </font>";
				ToolTipManager.instance.registerToolTip(listItem[i].nameStr, ToolTip, str);
			}
		}
		
		private function clearnItem():void{
			for each(var item:ContributionItem in listItem){
				item.visible = false;
			}
		}

		private function addPanel() : void {
			var data:GLabelData = new GLabelData();
			data.text = "我的排名：";
			data.x = 20;
			data.y = 10;
			data.width = 141;
			data.textFormat = new TextFormat(null,null,null,null,null,null,null,null,AlignMode.CENTER);
			data.textFieldFilters = [];
			data.textColor = 0x000000;
			data.textFormat.size = 12;
			myRank = new GLabel(data);
			_contentPanel.addChild(myRank);
			data.clone();
			data.text = "本周贡献：";
			data.x = 161 ;
			data.width = 141;
			data.textFormat = new TextFormat(null,null,null,null,null,null,null,null,AlignMode.CENTER);
			thisWeek = new GLabel(data);
			_contentPanel.addChild(thisWeek);
			
			var totalPage:int;
			if(DonateProxy.contributionNum!=0)
				totalPage = Math.ceil(DonateProxy.contributionNum/10);
			else
				totalPage = 1;
			page = new Pager(5,true);
			page.setPage(nowPage, totalPage);
			page.y = 312;
			var arr:Array = page.labelList;
			var w:int;
			for each(var txt0:PagerCell in arr){
				w += txt0.width;
			}
			w = w + (arr.length-1)*2;
			page.x = (this.width -  w) / 2;
			_contentPanel.addChild(page);
			
			var title:ContributionItem = new ContributionItem();
			title.getTitle();
			title.x = 9;
			title.y = 39;
			_contentPanel.addChild(title);
			var item:ContributionItem;
			var isTrue:Boolean = true;
			for(var i:int =0; i<10; i++){
				item = new ContributionItem();
				item.x = 9;
				item.y = 64 + (item.height+1)*i;
				if(i == 1||i==3||i==5||i==7||i==9)
					isTrue = true;
				else
					isTrue = false;
				item.setBgAlpha(isTrue);
				listItem.push(item);
				_contentPanel.addChild(item);
				item.visible = false;
				item.addEventListener(MouseEvent.CLICK, ondown);
			}
		}

		private function ondown(event : MouseEvent) : void {
			var item:ContributionItem = event.currentTarget as ContributionItem;
			var id:int = item.playerID;
			var name:String = item.nameStr.text;
			PlayerTip.show(id,name,[PlayerTip.NAME_SHISPER,PlayerTip.NAME_TRADE,PlayerTip.NAME_ADD_FRIEND,PlayerTip.NAME_INVITE_CLAN,PlayerTip.NAME_COPY_PLAYER_NAME,PlayerTip.NAME_LOOK_INFO,PlayerTip.NAME_MOVE_TO_BACKLIST]);
		}

		override public function hide():void{
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2,-1,(UIManager.stage.stageHeight - this.height) / 2,-1);
			super.hide();
		}
		override public function show():void{
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2,-1,(UIManager.stage.stageHeight - this.height) / 2,-1);
			super.show();
		}
	}
}
