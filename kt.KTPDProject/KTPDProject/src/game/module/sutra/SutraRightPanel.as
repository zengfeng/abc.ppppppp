package game.module.sutra
{
	import game.core.hero.HeroManager;
	import game.core.hero.VoHero;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.core.item.sutra.Sutra;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.module.shop.staticValue.ShopStaticValue;
	import game.net.core.Common;
	import game.net.data.CtoS.CSHeroEnhance;
	import game.net.data.StoC.SCHeroEnhance;

	import gameui.containers.GPanel;
	import gameui.controls.GButton;
	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.controls.GProgressBar;
	import gameui.core.ScaleMode;
	import gameui.data.GButtonData;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.data.GProgressBarData;
	import gameui.data.GToolTipData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;

	import net.AssetData;

	import com.commUI.icon.ItemIcon;
	import com.protobuf.Message;
	import com.utils.StringUtils;
	import com.utils.UICreateUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;





	/**
	 * @author Lv
	 */
	public class SutraRightPanel extends GPanel
	{
		private var submitBtn : GButton;
		private var textInput : TextField;
		private var img : ItemIcon;
		private var weaponName : GLabel;
		private var attackDis : GLabel;
		private var sutrSkil : GLabel;
		private var stepLeft : GLabel;
		private var stepRight : GLabel;
		private var submitNowDay : GLabel;
		private var expMax : GLabel;
		private var expLest : GLabel;
		private var expPro : GProgressBar;
		private var weaponImg : GImage;
		private var selectHeorID : int;
		private var hero : VoHero;
		private var itemGoods : Sutra;
		private var needLevelStr : GLabel;
		private var nowDaySumbit : int = 50;
		private var imgCornerNUM : GLabel;
		private var heroName : GLabel;
		private var sutraTotalValue : int;
		private var textInputNull : int = 1;

		/**
		 * id :所选英雄ID
		 */
		public function SutraRightPanel(id : int)
		{
			_data = new GPanelData();
			initData();
			selectHeorID = id;
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void
		{
			_data.width = 350;
			_data.height = 357;
			_data.bgAsset = new AssetData(SkinStyle.emptySkin);
			// 取消背景
		}

		private function initEvent() : void
		{
			textInput.addEventListener(FocusEvent.FOCUS_OUT, listenerFocus);
			textInput.addEventListener(KeyboardEvent.KEY_UP, ontextInput);
			textInput.addEventListener(MouseEvent.MOUSE_DOWN, onfoucsIN);
			textInput.addEventListener(Event.CHANGE, oncheng);
			submitBtn.addEventListener(MouseEvent.MOUSE_DOWN, onSubmit);
			Common.game_server.addCallback(0x15, sCHeroEnhance);
			Common.game_server.addCallback(0xfff2, itemChange);
			Common.game_server.addCallback(0xfff1, itemChangUp);
			// 升级
		}

		private function remvoeEvent() : void
		{
			Common.game_server.removeCallback(0x15, sCHeroEnhance);
			Common.game_server.removeCallback(0xfff2, itemChange);
			Common.game_server.removeCallback(0xfff1, itemChangUp);
		}

		// 级别刷新
		private function itemChangUp(e : Message) : void
		{
			sutraStep(hero.sutra.step);
		}

		// 物品刷新
		private function itemChange(e : Message) : void
		{
			sutraStep(hero.sutra.step);
		}

		// 获取提交进度
		private function sCHeroEnhance(e : SCHeroEnhance) : void
		{
			hero.sutra.step = e.wpLevel;
			stepLeft.text = e.wpLevel + "阶";
			stepRight.text = e.wpLevel + 1 + "阶";
			hero.sutra.nowDoaySumbit = e.todayCount;
			hero.sutra.nowSumbitRate = e.progress;
			sutraStep(hero.sutra.step);
		}

		// 提交进度成功
		private function onSubmit(event : MouseEvent) : void
		{
			if (textInputNull == 2)
			{
				textInputNull = 1;
				return;
			}
			var cmd : CSHeroEnhance = new CSHeroEnhance();
			cmd.id = hero.id;
			cmd.count = int(textInput.text);
			Common.game_server.sendMessage(0x15, cmd);
		}

		private function ontextInput(e : KeyboardEvent) : void
		{
			if (textInput.text == "")
				textInputNull = 2;
			else
				textInputNull = 1;
		}

		private function oncheng(event : Event) : void
		{
			var textInt : Number = Number(TextField(event.target).text);
			var sumNUM : int = sutraTotalValue - hero.sutra.nowSumbitRate;
			var total : int;
			if (nowDaySumbit > sumNUM)
				total = sumNUM;
			else
				total = nowDaySumbit;
			if (textInput.text != "")
				textInput.text = String(textInt);
			if (textInt > total)
			{
				textInput.text = String(total);
			}
		}

		private function onfoucsIN(event : MouseEvent) : void
		{
			textInput.setSelection(0, 70);
		}

		private function listenerFocus(event : FocusEvent) : void
		{
			var sumNUM : int = sutraTotalValue - hero.sutra.nowSumbitRate;
			var total : int;
			if (textInput.text == "" || textInput.text == "0" || int(textInput.text) == 0)
			{
				if (nowDaySumbit > sumNUM)
					total = sumNUM;
				else
					total = nowDaySumbit;
				textInput.text = String(total);
			}
		}

		private function initView() : void
		{
			addBG();
			hero = HeroManager.instance.getTeamHeroById(selectHeorID);
			itemGoods = hero.sutra;
			addPanel();
		}

		public function refreshPanel(sutra : Sutra) : void
		{
			// hero = UserData.instance.getHeroById(id);
			// itemGoods = ManagePack.getItemFromConfig(hero.sutra) as VoItem;
			// if(itemGoods == null)return;
			sutrSkil.text = sutra.skill;
			attackDis.text = sutra.range;
			weaponImg.source = itemGoods.imgLargeUrl;
			sutraStep(hero.sutra.step);
		}

		private function addPanel() : void
		{
			var data : GLabelData = new GLabelData();
			if (itemGoods != null)
				data.text = itemGoods.name + "    " + hero.sutra.step + "阶";
			else
				data.text = "未加载";
			data.width = 135;
			data.textFormat.size = 14;
			data.textFormat.bold = true;
			data.textFieldFilters = [];
			data.textColor = 0x000000;
			data.x = 11;
			data.y = 7;
			weaponName = new GLabel(data);
			_content.addChild(weaponName);
			data.clone();
			data.text = hero.sutra.step + "阶 →";
			data.textFormat.size = 14;
			data.textFormat.bold = true;
			data.x = 138;
			data.y = 177 + 29;
			stepLeft = new GLabel(data);
			_content.addChild(stepLeft);
			data.clone();
			data.text = hero.sutra.step + 1 + "阶";
			data.x = stepLeft.x + stepLeft.width;
			stepRight = new GLabel(data);
			_content.addChild(stepRight);
			data.clone();
			data.text = "所属名仙：";
			data.x = 13;
			data.y = 29;
			data.textFormat.size = 12;
			data.filters = [];
			data.textFieldFilters = [];
			data.textFormat.bold = false;
			var text : GLabel = new GLabel(data);
			_content.addChild(text);
			data.clone();
			if (hero._name)
				data.text = hero._name + "  " + hero.level;
			else
				data.text = "未加载";
			data.x = text.x + text.width;
			data.textColor = 0x3882D4;
			heroName = new GLabel(data);
			_content.addChild(heroName);
			data.clone();
			data.text = "攻击距离：";
			data.textColor = 0x000000;
			data.y = text.y + text.height + 2;
			data.x = 13;
			var text1 : GLabel = new GLabel(data);
			_content.addChild(text1);
			data.clone();
			if (itemGoods.range)
				data.text = itemGoods.range;
			else
				data.text = "未加载";
			data.x = text1.x + text1.width;
			attackDis = new GLabel(data);
			_content.addChild(attackDis);
			data.clone();
			data.text = "法宝技能：";
			data.y = text1.y + text1.height + 2;
			data.x = text1.x;
			var text2 : GLabel = new GLabel(data);
			_content.addChild(text2);
			data.clone();
			data.text = "倒打一耙";
			if (itemGoods.skill)
				data.text = itemGoods.skill;
			else
				data.text = "未加载";
			data.x = text2.x + text2.width;
			sutrSkil = new GLabel(data);
			_content.addChild(sutrSkil);
			data.clone();
			data.text = "需要名仙等级达到XXX";
			data.x = 118;
			data.y = 225;
			data.width = 300;
			needLevelStr = new GLabel(data);
			_content.addChild(needLevelStr);
			needLevelStr.visible = false;
			data.clone();
			data.text = "今天提交上限: " + nowDaySumbit + "个";
			data.x = 240;
			data.y = 250;
			data.width = 130;
			submitNowDay = new GLabel(data);
			// _content.addChild(submitNowDay);							// 今日提交上线保留
			data.clone();
			data.text = "00";
			data.textColor = 0xFFFFFF;
			data.x = 152 + 15 ;
			data.y = 197 + 29;
			expLest = new GLabel(data);
			data.clone();
			data.text = "/00";
			data.x = expLest.x + expLest.width;
			expMax = new GLabel(data);
			data.clone();
			data.textFormat.size = 10;
			data.text = "0";
			data.x = 125;
			data.y = 262 + 31;
			imgCornerNUM = new GLabel(data);

			var bgText : Sprite = UIManager.getUI(new AssetData("sutraTextInput"));
			bgText.x = 150;
			bgText.y = 248 + 31;
			bgText.width = 70;
			bgText.height = 22;
			_content.addChild(bgText);
			textInput = new TextField();
			textInput.type = TextFieldType.INPUT;
			textInput.restrict = "0-9";
			textInput.x = 153;
			textInput.y = 248 + 33;
			textInput.width = 70;
			textInput.height = 22;
			textInput.text = "1";
			_content.addChild(textInput);

			var dataBtn : GButtonData = new GButtonData();
			dataBtn.labelData.text = "提交";
			dataBtn.x = 135;
			dataBtn.y = 314 + 13;
			submitBtn = new GButton(dataBtn);
			_content.addChild(submitBtn);

			var dataExp : GProgressBarData = new GProgressBarData();
			dataExp.trackAsset = new AssetData("BossBloodPro_bg");
			dataExp.barAsset = new AssetData("sutraExp");
			dataExp.toolTipData = new GToolTipData();
			dataExp.height = 15;
			dataExp.width = 150;
			dataExp.x = 108;
			dataExp.y = 197 + 29;
			dataExp.paddingX = 2;
			dataExp.paddingY = 1;
			dataExp.padding = 29.3;
			expPro = new GProgressBar(dataExp);
			_content.addChild(expPro);
			_content.addChild(expMax);
			_content.addChild(expLest);

			var box1 : Sprite = UIManager.getUI(new AssetData("ItemBack"));
			box1.width = box1.height = 36.7;
			box1.x = 104;
			box1.y = 240 + 31;
			// _content.addChild(box1);

			var dataImg : GImageData = new GImageData();
			dataImg.iocData.width = 33;
			dataImg.iocData.height = 33;
			dataImg.iocData.scaleMode = ScaleMode.SCALE9GRID;
			// dataImg.toolTipData = new GToolTipData();
			dataImg.x = 104;
			dataImg.y = 240 + 31;
			dataImg.width = dataImg.width = 36.7;
			// img = new GImage(dataImg);
			// img.filters = [new GlowFilter(0xFFF000)];
			// _content.addChild(img);

			img = UICreateUtils.createItemIcon({x:104, y:271, showBg:true, showBorder:true, showNums:true, showToolTip:true});
			_content.addChild(img);

			var box2 : Sprite = UIManager.getUI(new AssetData("ItemBorder"));
			box2.width = box2.height = 36.7;
			box2.x = 104;
			box2.y = 240 + 31;
			// _content.addChild(box2);

			var imgdata : GImageData = new GImageData();
			imgdata.x = 168;
			imgdata.y = 110;
			weaponImg = new GImage(imgdata);
			_content.addChild(weaponImg);

			// _content.addChild(imgCornerNUM);
			var text5 : TextField = new TextField();
			text5.textColor = 0xFF6633;
			text5.x = 295;
			text5.y = 295;
			text5.width = 60;
			text5.height = 20;
			text5.antiAliasType = AntiAliasType.NORMAL;
			_content.addChild(text5);
			text5.htmlText = StringUtils.addLine("声望兑换");
			text5.addEventListener(MouseEvent.MOUSE_DOWN, onchangehonour);

			sutraStep(hero.sutra.step);
		}

		private function onchangehonour(event : MouseEvent) : void
		{
			if (UserData.instance.myHero.level < 20 || MenuManager.getInstance().getMenuState(MenuType.SHOP)) return;
			ShopStaticValue.goToAndStopLabel = 2;
			MenuManager.getInstance().openMenuView(MenuType.SHOP);
		}

		private var stepIndex : int;
		private var contrStep : int = 10;

		/**
		 * 通过法宝阶数获取天才地宝的图片 和 天才地宝需要提交的个数
		 * step：法宝的阶数    
		 */
		private function sutraStep(step : int) : void
		{
			var level : int = hero.level;
			var sutra:Sutra = hero.sutra;

			// ---------------------------------------------------------------------------------
			var goodsID : int;
			if (hero._name)
				heroName.text = hero._name + "  " + hero.level;
			else
				heroName.text = "未加载";
			needLevelStr.x = 118;
			// ------------------------------------------------------------------------------------
			StateManager.sutraStepOnLineDic[level];
			/*stepIndex = StateManager.sutraStepOnLineDic[level];
			if(stepIndex == 0 && level<StateManager.levelStepOnLineDic[10]){
			goodsID = hero.stepRelicLevel10;
			sutraTotalValue = hero.stepRelicLevel10_Num;
			changeValue(goodsID);
			showPanel();
			needLevelStr.visible = true;
			submitBtn.enabled = false;
			needLevelStr.text = "需要名仙等级达到 "+StringUtils.addColor(String(StateManager.levelStepOnLineDic[10]),"#FF0000")+" 级";
			}else{
				
			goodsID = hero.stepRelicLevel10;
			sutraTotalValue = hero.stepRelicLevel10_Num;
			changeValue(goodsID);
			if(stepIndex != contrStep){
			contrStep = stepIndex;
			showPanel();
			needLevelStr.visible = true;
			submitBtn.enabled = false;
			needLevelStr.text = "需要名仙等级达到 "+ StringUtils.addColor(String(StateManager.levelStepOnLineDic[contrStep]),"#FF0000")+" 级";
			return;
			}else{
			hidePanel();
			needLevelStr.visible = false;
			}
			}*/
			if (level < 50)
			{
				goodsID = sutra.stepRelicLevel10;
				sutraTotalValue = sutra.stepRelicLevel10_Num;
				changeValue(goodsID);
				showPanel();
				needLevelStr.visible = true;
				submitBtn.enabled = false;
				needLevelStr.text = "需要名仙等级达到" + StringUtils.addColor(" 50 ", "#FF0000") + "级";
			}
			else if ((50 < level || level == 50) && (level < 60))
			{
				goodsID = sutra.stepRelicLevel10;
				sutraTotalValue = sutra.stepRelicLevel10_Num;
				changeValue(goodsID);
				if (step >= 10)
				{
					showPanel();
					needLevelStr.visible = true;
					submitBtn.enabled = false;
					needLevelStr.text = "需要名仙等级达到" + StringUtils.addColor(" 60 ", "#FF0000") + "级";
					return;
				}
				else
				{
					hidePanel();
					needLevelStr.visible = false;
				}
			}
			else if ((60 < level || level == 60) && (level < 80))
			{
				if (step >= 10)
				{
					sutraTotalValue = sutra.stepRelicLevel20_Num;
					goodsID = sutra.stepRelicLevel20;
				}
				else
				{
					sutraTotalValue = sutra.stepRelicLevel10_Num;
					goodsID = sutra.stepRelicLevel10;
				}
				changeValue(goodsID);
				if (step >= 20)
				{
					showPanel();
					needLevelStr.visible = true;
					submitBtn.enabled = false;
					needLevelStr.text = "需要名仙等级达到" + StringUtils.addColor(" 80 ", "#FF0000") + "级";
					return;
				}
				else
				{
					hidePanel();
					needLevelStr.visible = false;
				}
			}
			else if (80 < level || level == 80)
			{
				if (step >= 20)
				{
					goodsID = sutra.stepRelicLevel30;
					sutraTotalValue = sutra.stepRelicLevel30_Num;
				}
				else if (step >= 10)
				{
					sutraTotalValue = sutra.stepRelicLevel20_Num;
					goodsID = sutra.stepRelicLevel20;
				}
				else
				{
					sutraTotalValue = sutra.stepRelicLevel10_Num;
					goodsID = sutra.stepRelicLevel10;
				}

				changeValue(goodsID);
				if (step >= 30)
				{
					showPanel();
					needLevelStr.visible = true;
					submitBtn.enabled = false;
					stepLeft.visible = false;
					stepRight.visible = false;
					needLevelStr.text = "已满阶";
					needLevelStr.x = 158;
					return;
					return;
				}
				else
				{
					hidePanel();
					needLevelStr.visible = false;
				}
			}
		}

		private function changeValue(goodsID : int) : void
		{
			// if(ManagePack.getItemFromConfig(suratID))
			var sutra:Sutra = hero.sutra;
			weaponImg.url = sutra.imgLargeUrl;

			var relic : Item = ItemManager.instance.getPileItem(goodsID);
			img.source = relic;

			var index : int = sutra.sutraNowSumbitRate;
			if (index > sutraTotalValue) index = sutraTotalValue;
			expLest.text = String(index);
			expMax.text = "/" + sutraTotalValue;
			// nowDaySumbit = ManagePack.getItemNum(goodsID,0);
			expPro.value = sutra.sutraNowSumbitRate / sutraTotalValue * 100;
			var num1 : int = nowDaySumbit - sutra.sutraNowDoaySumbit;
			var num2 : int = sutraTotalValue - sutra.sutraNowSumbitRate;
			if (num1 < 0) num1 = 0;
			if (num2 < 0) num2 = 0;
			submitNowDay.text = "今天提交上限: " + String(num1) + "个";
			// var totalCorner:int = ManagePack.getItemNum(goodsID,0);
			// if(totalCorner>99)
			// imgCornerNUM.text = "99+";
			// else
			// imgCornerNUM.text = String(totalCorner);
			if (relic.nums == 0)
				submitBtn.enabled = false;
			else
				submitBtn.enabled = true;
			if (sutra.step == 0)
			{
				if (itemGoods)
					weaponName.text = itemGoods.name;
				else
					weaponName.text = "未加载";
			}
			else
			{
				if (itemGoods)
					weaponName.text = itemGoods.name + "    " + sutra.step + "阶";
				else
					weaponName.text = "未加载";
			}
			stepLeft.text = sutra.step + "阶 → ";
			stepRight.text = sutra.nextStep + "阶";
			stepLeft.visible = true;
			stepRight.visible = true;
			stepRight.x = stepLeft.x + stepLeft.width;

			var sumNUM : int = sutraTotalValue - sutra.nowSumbitRate;
			var total : int;
			if (sumNUM > nowDaySumbit)
				total = nowDaySumbit;
			else
				total = sumNUM;
			if (total == 0) total = 1;
			textInput.text = String(total);
		}

		private function addBG() : void
		{
			var bg : Sprite = UIManager.getUI(new AssetData("Sutra_bg"));
			_content.addChild(bg);
		}

		private function showPanel() : void
		{
			expPro.visible = false;
			expMax.visible = false;
			expLest.visible = false;
			needLevelStr.visible = false;
		}

		private function hidePanel() : void
		{
			expPro.visible = true;
			expMax.visible = true;
			expLest.visible = true;
			needLevelStr.visible = true;
		}

		override public function hide() : void
		{
			remvoeEvent();
			super.hide();
		}
	}
}
