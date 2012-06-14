package game.module.quest {
	import framerate.SecondsTimer;

	import game.config.StaticConfig;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.definition.ID;
	import game.definition.UI;
	import game.manager.SignalBusManager;
	import game.manager.ViewManager;
	import game.net.core.Common;
	import game.net.data.CtoC.CCPackChange;
	import game.net.data.StoC.SCLoopQuestDataRes;
	import game.net.data.StoC.SCLoopQuestSubmitRes;

	import gameui.controls.GButton;
	import gameui.controls.GImage;
	import gameui.core.GAlign;
	import gameui.data.GImageData;
	import gameui.data.GTitleWindowData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import net.AssetData;
	import net.RESManager;

	import com.commUI.GCommonWindow;
	import com.commUI.button.GItemRadioButton;
	import com.utils.StringUtils;
	import com.utils.TextFormatUtils;
	import com.utils.TimeUtil;
	import com.utils.UICreateUtils;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * @author yangyiqiang
	 */
	public class DailyQuestPanel extends GCommonWindow {
		private static const ITEM_NUMS:int=4;

		private static const IDS:Array=[ID.NORMAL_DAILY, ID.PRIMARY_DAILY, ID.MEDIUM_DAILY, ID.SENIOR_DAILY];

		private var _startButton:GButton;

		private var _GItemRadioButtones:Array;

		private var _bgSkin:Sprite;

//		private var _group : GToggleGroup;

		private var _remainText:TextField;
		private var _timeText:TextField;

		private var _dataContainer:GTitleWindowData;

		private var _frameBg:Sprite;

		private var _nextTime:uint;

		private var _questIds:Array=[];
		private var _questClicks:Array=[];
		private var _questQuality:Array=[];

		public var msg:SCLoopQuestDataRes=null;

		public function DailyQuestPanel() {
			_dataContainer=new GTitleWindowData();
			_dataContainer.width=496;
			_dataContainer.height=303;
			_dataContainer.parent=ViewManager.instance.uiContainer;
			_dataContainer.align=new GAlign(-1, -1, -1, -1, 1, 1);
			super(_dataContainer);
			Common.game_server.addCallback(0xD7, loopQuestDataRes);
			Common.game_server.addCallback(0xD8,updateMsg);
			Common.game_server.sendMessage(0xD7);
		}

		private function updateMsg(p_msg:SCLoopQuestSubmitRes):void{
			var idx:uint=_questIds[p_msg.preQuestId];
			msg.quality[idx]=255;
			msg.questId[idx]=p_msg.questId;
			msg.leftNum=p_msg.leftNum;
		}
		
		private function getHeadIcon(id:uint):Sprite {
			var data:GImageData=new GImageData();
			data.iocData.align=new GAlign(-1, -1, -1, -1, 0);
			var img:GImage=new GImage(data);
			img.url=StaticConfig.cdnRoot + "assets/ico/halfBody/" + id + ".png";
			return img;
		}

		private function loopQuestDataRes(p_msg:SCLoopQuestDataRes):void {
			msg=p_msg;
			SignalBusManager.questPanelAcceptMissionUpdate.add(updateAcceptMissionPanel);
			SignalBusManager.questPanelEndMissionUpdate.add(updateEndMissionPanel);
			SignalBusManager.questPanelSubmitMissionUpdate.add(updateSubmitMissionPanel);
			if (MenuManager.getInstance().getMenuState(MenuType.DAILY_QUEST) == true) {
				updateThisPanelContainer();
			}
		}

		private function updateThisPanelContainer():void {
			var upperLimited:String="";
			_nextTime=msg.nextTime;
			_timeText.htmlText="距离下次发布悬赏令的时间：" + StringUtils.addColor(TimeUtil.toHHMMSS(_nextTime), "#FF3300");
			SecondsTimer.addFunction(countDown);
			_remainText.htmlText="当前已累积" + StringUtils.addColor(msg.leftNum.toString() + "/" + msg.maxNum.toString(), "#FF3300") + "张悬赏令" + StringUtils.addColor(upperLimited, "#FF3300") + "（下次发布" + StringUtils.addColor(msg.nextNum.toString(), "#FF3300") + "张）";
			//			if (msg.leftNum >= msg.maxNum) {
			//				upperLimited="(累积已达上限)";
			//			}
			_questIds=[]; //存储ID
			_questClicks=[]; //存储被点击对象

			for (var i:uint=0; i < msg.questId.length; i++) {
				var wanted:Sprite=new Sprite();
				var wantedBitmap:Bitmap=new Bitmap(RESManager.getBitmapData(new AssetData(UI.QUEST_NONE_BMP)));
				var wantedTitle:Bitmap=new Bitmap(RESManager.getBitmapData(new AssetData(UI.QUEST_WANTED_BMP, "embedFont")));
				var explainText:TextField=new TextField();

				var headMask:Sprite=new Sprite();
				headMask.graphics.beginFill(0x000000);
				headMask.graphics.drawRect(0, 0, 110, 110);
				headMask.graphics.endFill();

				var headIcon:Sprite;

				explainText.setTextFormat(UIManager.getTextFormat());
				wanted.name="wanted" + msg.questId[i];
				explainText.name="explain" + msg.questId[i];

				_questIds.push(msg.questId[i]);
				_questQuality.push(msg.quality[i]);
				_questClicks.push(wanted);

				addChild(wanted);
				wanted.addChild(wantedBitmap);

				wanted.addChild(wantedTitle);
				wanted.addChild(explainText);

				wantedTitle.x=(wanted.width - wantedTitle.width) / 2;
				wantedTitle.y=8;

				wanted.x=26 + (wanted.width + 10) * i;
				wanted.y=_frameBg.y + (_frameBg.height - wanted.height) / 2;

				var shadowF:DropShadowFilter=new DropShadowFilter();
				shadowF.alpha=0.3;
				wanted.filters=[shadowF];
				//				var clickText:TextField=UICreateUtils.createTextField("点击接取");

				explainText.wordWrap=true;
				explainText.mouseEnabled=false;
				explainText.selectable=false;
				explainText.autoSize=TextFieldAutoSize.LEFT;
				var voQuest:VoQuest;
				var missionPickMC:MovieClip;
				var missionTypeBmp:Bitmap;

				var treasureBody:Bitmap;
				var treasureCover:Bitmap;
				var treasureShine:MovieClip;

				if (msg.questId[i] > 0) {
					voQuest=QuestManager.getInstance().search(msg.questId[i]);

					if (voQuest.state == 2) {
						if (voQuest.isCompleted == true) {
							alreadyCompleted(i);
						} else {
							alreadyGet();
						}
					} else {
						clickGetMession();
					}
				} else {
					nonePublish();
				}

				wanted.addEventListener(MouseEvent.MOUSE_OVER, getMissionMouse);
				wanted.addEventListener(MouseEvent.MOUSE_OUT, getMissionMouse);


				function clickGetMession():void {
					explainText.htmlText=StringUtils.addColor("点击接取", "#FF3300");
					var tf:flash.text.TextFormat=new flash.text.TextFormat();
					tf.bold=true;
					tf.size=14;
					explainText.setTextFormat(tf);
					explainText.x=36;
					explainText.y=166;
					positionHeadIcon();
					wanted.addEventListener(MouseEvent.CLICK, getMission);
				}

				function nonePublish():void {
					explainText.htmlText=StringUtils.addColor("未发布", "#2F1F00");
					var tf:flash.text.TextFormat=new flash.text.TextFormat();
					tf.bold=true;
					tf.size=14;
					explainText.setTextFormat(tf);
					explainText.x=44;
					explainText.y=166;
				}

				function alreadyGet():void {
					explainText.htmlText=voQuest.parseQuestDesc();
					missionPickMC=RESManager.getMC(new AssetData(UI.QUEST_ALREADYPICK_MC, "embedFont"));
					missionPickMC.mouseEnabled=false;
					missionPickMC.mouseChildren=false;
					missionPickMC.gotoAndStop(missionPickMC.totalFrames);
					missionPickMC.x=90;
					missionPickMC.y=13;
					missionTypeBmp=new Bitmap(RESManager.getBitmapData(new AssetData(getMissionType(voQuest.base.getCompleteTry()))));
					missionTypeBmp.x=5;
					missionTypeBmp.y=156;
					explainText.x=24;
					explainText.y=153;
					positionHeadIcon();
					wanted.addChild(missionTypeBmp);
					wanted.addChild(missionPickMC);
					wanted.addEventListener(MouseEvent.CLICK, actionQuest);
				}

				function positionHeadIcon():void {
					headIcon=getHeadIcon(voQuest.base.headId);
					wanted.addChild(headIcon);
					headIcon.x=70;
					headIcon.y=-15;
					wanted.addChild(headMask);
					headIcon.mask=headMask;
					headMask.x=13;
					headMask.y=40;
				}

				function alreadyCompleted(idx:uint):void {
					explainText.htmlText=voQuest.parseQuestDesc();
					//				missionPickMC=RESManager.getMC(new AssetData(UI.QUEST_COMPLETED_MC, "embedFont"));
					//				missionPickMC.mouseEnabled=false;
					//				missionPickMC.mouseChildren=false;
					//				missionPickMC.gotoAndStop(missionPickMC.totalFrames);
					//				missionPickMC.x=wanted.width - 80;
					//				missionPickMC.y=13;
					//					missionTypeBmp=new Bitmap(RESManager.getBitmapData(new AssetData(getMissionType(voQuest.base.getCompleteTry()))));
					//					wanted.addChild(missionTypeBmp);
					//					missionTypeBmp.x=5;
					//					missionTypeBmp.y=156;

					explainText.htmlText=StringUtils.addColor("领取奖励", "#FF3300");
					var tf:flash.text.TextFormat=new flash.text.TextFormat();
					tf.bold=true;
					tf.size=14;
					explainText.setTextFormat(tf);
					explainText.x=36;
					explainText.y=166;

					switch (_questQuality[idx]) {
						case 0:
							treasureBodyType=UI.QUEST_WHITETREASUREBODY_BMP;
							treasureCoverType=UI.QUEST_WHITETREASURECLOSE_BMP;
							break;
						case 1:
							treasureBodyType=UI.QUEST_GREENTREASUREBODY_BMP;
							treasureCoverType=UI.QUEST_GREENTREASURECLOSE_BMP;
							break;
						case 2:
							treasureBodyType=UI.QUEST_BLUETREASUREBODY_BMP;
							treasureCoverType=UI.QUEST_BLUETREASURECLOSE_BMP;
							break;
						case 3:
							treasureBodyType=UI.QUEST_PURPLETREASUREBODY_BMP;
							treasureCoverType=UI.QUEST_PURPLETREASURECLOSE_BMP;
							break;
					}

					treasureBody=new Bitmap(RESManager.getBitmapData(new AssetData(treasureBodyType)));
					treasureBody.name="treasureBody";
					wanted.addChild(treasureBody);
					treasureBody.x=12;
					treasureBody.y=40;

					var treasureBodyType:String;
					var treasureCoverType:String;
					treasureCover=new Bitmap(RESManager.getBitmapData(new AssetData(treasureCoverType)));
					treasureCover.name="treasureCover";
					wanted.addChildAt(treasureCover, wanted.getChildIndex(treasureBody) + 1);
					treasureCover.x=treasureBody.x;
					treasureCover.y=treasureBody.y;

					treasureShine=RESManager.getMC(new AssetData(UI.QUEST_SHINE_MC));
					treasureShine.name="treasureShine";
					wanted.addChildAt(treasureShine, wanted.getChildIndex(treasureCover) + 1);
					treasureShine.x=0;
					treasureShine.y=0;

					
					
//					wanted.addChild(missionPickMC);
//					wanted.addEventListener(MouseEvent.MOUSE_OVER, getTreasure);
//					wanted.addEventListener(MouseEvent.MOUSE_OUT, getTreasure);
					
					
					coverInterval=setInterval(shakeCover,(1000/stage.frameRate)*2,treasureCover,12,40);
					
					wanted.addEventListener(MouseEvent.MOUSE_DOWN, getTreasure);
					
					
				}
			}

		}


		private function actionQuest(e:MouseEvent):void {
			var clickWanted:Sprite=e.currentTarget as Sprite;
			var questID:uint=_questIds[_questClicks.indexOf(clickWanted)];
			MenuManager.getInstance().closeMenuView(MenuType.DAILY_QUEST);
			QuestUtil.questAction(questID);
		}

		private function updateSubmitMissionPanel(id:uint):void {
//			MenuManager.getInstance().closeMenuView(MenuType.DAILY_QUEST);
			var voQuest:VoQuest=QuestManager.getInstance().search(id);
			QuestDisplayManager.getInstance().isShowing(voQuest);
			QuestDisplayManager.getInstance().closeMainQuest();
			Common.game_server.sendMessage(0xD7);
		}

		private function updateEndMissionPanel(id:uint):void {
			if (MenuManager.getInstance().getMenuState(MenuType.DAILY_QUEST) == true) {
				var voQuest:VoQuest=QuestManager.getInstance().search(id);
				var wanted:Sprite=getChildByName("wanted" + id.toString()) as Sprite;
				var explainText:TextField=wanted.getChildByName("explain" + id.toString()) as TextField;
				explainText.htmlText=voQuest.parseQuestDesc();
//			var missionStateMC:MovieClip=wanted.getChildByName("missionState_" + id.toString()) as MovieClip;
//			missionStateMC.gotoAndStop(1);
//			missionStateMC=RESManager.getMC(new AssetData(UI.QUEST_COMPLETED_MC, "embedFont"));
				wanted.removeEventListener(MouseEvent.CLICK, actionQuest);
				wanted.addEventListener(MouseEvent.CLICK, getTreasure);
			} else {
				MenuManager.getInstance().openMenuView(MenuType.DAILY_QUEST);
			}
		}

		private function shakeCover(cover:Bitmap,x:int,y:int):void{
			if(coverSeed==0){
				coverSeed=1;
				cover.x=x-0.5;
			}else{
				coverSeed=0;
				cover.x=x+0.5;
			}
		}
		
		private var coverInterval:int=-1;
		private var coverSeed:uint=0;
		private var coverCount:uint=0;
		
		private function getTreasure(e:MouseEvent):void {
			var wanted:Sprite=e.currentTarget as Sprite;
			var cover:Bitmap=wanted.getChildByName("treasureCover") as Bitmap;
			switch (e.type) {
				case MouseEvent.MOUSE_OVER:
					//播放盖子抖动动画
//					coverInterval=setInterval(shakeCover,(1000/stage.frameRate)*2,cover,12,40);
					break;
				case MouseEvent.MOUSE_OUT:
					cover.x=12;
					cover.y=40;
					clearInterval(coverInterval);
					coverInterval=-1;
					break;
				case MouseEvent.MOUSE_DOWN:
					var body:Bitmap=wanted.getChildByName("treasureBody") as Bitmap;
					var shine:MovieClip=wanted.getChildByName("treasureShine") as MovieClip;
					var idx:uint=_questClicks.indexOf(wanted);
					var treasureCoverType:String;
					switch (_questQuality[idx]) {
						case 0:
							treasureCoverType=UI.QUEST_WHITETREASUREOPEN_BMP;
							break;
						case 1:
							treasureCoverType=UI.QUEST_GREENTREASUREOPEN_BMP;
							break;
						case 2:
							treasureCoverType=UI.QUEST_BLUETREASUREOPEN_BMP;
							break;
						case 3:
							treasureCoverType=UI.QUEST_PURPLETREASUREOPEN_BMP;
							break;
					}
					cover.bitmapData=RESManager.getBitmapData(new AssetData(treasureCoverType));
					wanted.addChildAt(cover, wanted.getChildIndex(body));
					shine.gotoAndPlay(1);
					wanted.removeEventListener(MouseEvent.MOUSE_DOWN, getTreasure);
					cover.x=12;
					cover.y=40;
					clearInterval(coverInterval);
					coverInterval=-1;
					
//					QuestUtil.sendTaskOperateReq(_questIds[idx], QuestUtil.SUBMIT);
					break;
			}
		}

		private function updateAcceptMissionPanel(id:uint, quality:uint):void {
			var voQuest:VoQuest=QuestManager.getInstance().search(id);
			var wanted:Sprite=this.getChildByName("wanted" + id) as Sprite;
			var explainText:TextField=wanted.getChildByName("explain" + id) as TextField;
			_questQuality[_questIds.indexOf(id)]=quality;
			explainText.htmlText=voQuest.parseQuestDesc();
			var missionPickMC:MovieClip=RESManager.getMC(new AssetData(UI.QUEST_ALREADYPICK_MC, "embedFont"));
			missionPickMC.name="missionState_" + id;
			wanted.addChild(missionPickMC);
			missionPickMC.mouseEnabled=false;
			missionPickMC.mouseChildren=false;
			missionPickMC.x=90;
			missionPickMC.y=13;
			var missionTypeBmp:Bitmap=new Bitmap();
			missionTypeBmp=new Bitmap(RESManager.getBitmapData(new AssetData(getMissionType(voQuest.base.getCompleteTry()))));
			wanted.addChild(missionTypeBmp);
			missionTypeBmp.x=5;
			missionTypeBmp.y=156;
			explainText.x=24;
			explainText.y=153;
			missionPickMC.gotoAndPlay(2);

			wanted.removeEventListener(MouseEvent.CLICK, getMission);
			wanted.addEventListener(MouseEvent.CLICK, actionQuest);
		}

		private function getMissionMouse(e:MouseEvent):void {
			var shadowF:DropShadowFilter=new DropShadowFilter();
			shadowF.alpha=0.3;
			var growF:GlowFilter=new GlowFilter(0xffffff, 0.5, 10, 10);
			var targetMc:Sprite=e.currentTarget as Sprite;
			var targetBitmap:Bitmap=targetMc.getChildAt(0) as Bitmap;
			if (e.type == MouseEvent.MOUSE_OVER) {
				targetMc.filters=[shadowF, growF];
				targetBitmap.bitmapData.colorTransform(new Rectangle(0, 0, targetBitmap.width, targetBitmap.height), new ColorTransform(1, 1, 1, 1, targetBitmap.transform.colorTransform.redMultiplier + 20, targetBitmap.transform.colorTransform.greenMultiplier + 20, targetBitmap.transform.colorTransform.blueMultiplier + 20));
			} else if (e.type == MouseEvent.MOUSE_OUT) {
				targetMc.filters=[shadowF];
				targetBitmap.bitmapData.colorTransform(new Rectangle(0, 0, targetBitmap.width, targetBitmap.height), new ColorTransform(1, 1, 1, 1, targetBitmap.transform.colorTransform.redMultiplier - 20, targetBitmap.transform.colorTransform.greenMultiplier - 20, targetBitmap.transform.colorTransform.blueMultiplier - 20));
			}
		}

		private function getMissionType(id:uint):String {
			var rt:String;
			switch (id) {
				case 1:
					rt=UI.QUEST_DIALOGUE_BMP;
					break;
				case 2:
					rt=UI.QUEST_FIGHT_BMP;
					break;
				case 3:
					rt=UI.QUEST_FIGHT_BMP;
					break;
				case 4:
					rt=UI.QUEST_PICK_BMP;
					break;
				case 5:
					rt=UI.QUEST_PICK_BMP;
					break;
				case 6:
					rt=UI.QUEST_PICK_BMP;
					break;
				case 7:
					rt=UI.QUEST_DIALOGUE_BMP;
					break;
				case 8:
					rt=UI.QUEST_DIALOGUE_BMP;
					break;
				case 9:
					rt=UI.QUEST_EXPLORE_BMP;
					break;
				case 10:
					rt=UI.QUEST_DIALOGUE_BMP;
					break;
			}
			return rt;
		}

		private function getMission(e:Event):void {
			var target:Sprite=e.currentTarget as Sprite;
			var dailyPanelSub:DailyQuestPanelSub=new DailyQuestPanelSub();
			dailyPanelSub.targetQuestId=_questIds[_questClicks.indexOf(target)];
			dailyPanelSub.show();
		}

		private function countDown():void {
			_nextTime-=1
			if (_nextTime <= 0) {
				SecondsTimer.removeFunction(countDown);
				Common.game_server.sendMessage(0xD7);
			}
			_timeText.htmlText="距离下次发布悬赏令的时间: " + StringUtils.addColor(TimeUtil.toHHMMSS(_nextTime), "#FF3300");
		}

		override protected function create():void {
			super.create();
			this.title="悬榜令";
			addBackground();
//			addGItemRadioButtones();
			addHint();
			addRemainText();
//			addButtons();
		}

		private function addBackground():void {
			_bgSkin=UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND));
			_bgSkin.x=5;
			_bgSkin.y=0;
			_bgSkin.width=_dataContainer.width - 15;
			_bgSkin.height=_dataContainer.height - 5;
			_contentPanel.addChild(_bgSkin);

			_frameBg=UIManager.getUI(new AssetData(UI.PACK_BACKGROUND));

			_frameBg.width=_bgSkin.width - 20;
			_frameBg.height=227;
			_frameBg.x=_bgSkin.x + 10;
			_frameBg.y=34;
			addChild(_frameBg);

		}

		private function addHint():void {
			_timeText=UICreateUtils.createTextField("距离下次发布悬赏令的时间：", null, _frameBg.width, 20, 142, 10, TextFormatUtils.panelContent);
			_timeText.htmlText="距离下次发布悬赏令的时间：" + StringUtils.addColor("1:15:30", "#FF3300");
			addChild(_timeText);
		}

		private function addRemainText():void {
			_remainText=UICreateUtils.createTextField("当前已累积", null, _frameBg.width, 20, _frameBg.x + 10, _bgSkin.height - 26, TextFormatUtils.panelContent);
			_remainText.htmlText="当前已累积 " + StringUtils.addColor(" 0/0 ", "#FF3300") + " 张悬赏榜 " + StringUtils.addColor("累积已达上限", "#FF3300");
			addChild(_remainText);
		}

		private function addButtons():void {
			_startButton=UICreateUtils.createGButton("确定", 0, 0, 129, 155);
			addChild(_startButton);
		}

		private function addGItemRadioButtones():void {

		/*			_GItemRadioButtones = [];
					_group = new GToggleGroup();
					for (var i : uint = 0;i < ITEM_NUMS;i++)
					{
						var item : GItemRadioButton = new GItemRadioButton(i == 0);
						item.x = 27 + 77 * i;
						item.y = 40;
						item.group = _group;
						_GItemRadioButtones.push(item);
						addChild(item);
					}
					_group.selectionModel.index = 0;
		*/


		}

		// ------------------------------------------------
		// 更新
		// ------------------------------------------------
		private function updateBaits():void {
			for (var i:uint=0; i < ITEM_NUMS; i++) {
				(_GItemRadioButtones[i] as GItemRadioButton).source=ItemManager.instance.getPileItem(IDS[i]);
			}
		}

		private var _arr:Array=[1, 2, 4, 8];

		private function selection_changeHandler(event:Event):void {
//			var index : int = _group.selectionModel.index;
//			_remainText.htmlText = "可获得经验" + StringUtils.addColor(String(ExperienceConfig.getPracticeExperience(UserData.instance.level) * 60 * _arr[index]), "#FF3300");
		}

		// -----------------------------------------------
		// 交互
		// -----------------------------------------------
		override protected function onShow():void {
			super.onShow();
			clearInterval(coverInterval);
			coverInterval=-1;

//			_startButton.addEventListener(MouseEvent.CLICK, startButton_clickHandler);
//			Common.game_server.addCallback(0xfff2, onPackChange);
			GLayout.layout(this);
//			_group.selectionModel.addEventListener(Event.CHANGE, selection_changeHandler);
//			updateBaits();
//			var img:GImage=new GImage(new GImageData());
//			addChild(img);
//			img.url=StaticConfig.cdnRoot+"";
//			RESManager.getMC(new AssetData(UI.BUTTON_BOXTAB_DISABLED,"embedFont");
			if (msg != null) {
				updateThisPanelContainer();
			}
		}

		override protected function onHide():void {
			super.onHide();
//			_startButton.removeEventListener(MouseEvent.CLICK, startButton_clickHandler);
//			Common.game_server.removeCallback(0xfff2, onPackChange);
//			_group.selectionModel.removeEventListener(Event.CHANGE, selection_changeHandler);
			SecondsTimer.removeFunction(countDown);
			for (var i:uint=0; i < _questIds.length; i++) {
				if (getChildByName("wanted" + _questIds[i]) != null) {
					removeChild(getChildByName("wanted" + _questIds[i]));
				}
			}

		}

		private function startButton_clickHandler(event:Event):void {
		/*			var index : int = _group.selectionModel.index;

					var good : Item = (_GItemRadioButtones[index] as GItemRadioButton).source;
					var order : VoOrder;
					var quest:VoQuest=QuestManager.getInstance().findCurrentDailyQuest();
					if (good.nums > 0 || index == 0)
					{
						QuestManager.getInstance().resetQuestState(quest.id, QuestManager.UNDONE);
						quest.resetReqStep();
						QuestUtil.sendTaskOperateReq(quest.id,1,index);
						hide();
					}
					else
					{
						order = new VoOrder();
						order.id = good.id;
						order.count = 1;
						MultiQuickShop.showOrder([order], null, null, this);
					}
		*/
		}

		// 0xfff2
		private function onPackChange(msg:CCPackChange):void {
			if (msg.topType == Item.EXPEND)
				updateBaits();
		}

	}
}
