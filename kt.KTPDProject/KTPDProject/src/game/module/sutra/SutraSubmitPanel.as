package game.module.sutra
{
	import com.commUI.button.KTButtonData;
	import com.commUI.icon.ItemIcon;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.utils.StringUtils;
	import com.utils.UICreateUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import game.core.hero.VoHero;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.core.item.sutra.Sutra;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.net.core.Common;
	import game.net.data.CtoC.CCPackChange;
	import game.net.data.CtoS.CSHeroEnhance;
	import gameui.containers.GPanel;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.controls.GMagicLable;
	import gameui.controls.GProgressBar;
	import gameui.controls.GTextInput;
	import gameui.data.GButtonData;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.data.GProgressBarData;
	import gameui.data.GTextInputData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;





	/**
	 * @author Lv
	 */
	public class SutraSubmitPanel extends GPanel {
		private var sutraName : GLabel;
		private var sutraLevel : GLabel;
		private var heroName : GLabel;
		private var sutraExplain : GLabel;
		private var materialScale : TextField;
		private var expPro : GProgressBar;
		private var submitMaterial : GTextInput;
		private var submitBtn : GButton;
		private var submIcon : ItemIcon;
		private var voHero : VoHero;
		private var submitNum : int;
		private var sutalTotal : int;
		private var relic : Item ;
		private var levelLimit:GLabel;

		public function SutraSubmitPanel() {
			_data = new GPanelData();
			initData();
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void {
			_data.width = 236;
			_data.height = 422;
			_data.bgAsset = new AssetData(SkinStyle.emptySkin);
			// 取消背景
		}

		private function initEvent() : void {
			submitBtn.addEventListener(MouseEvent.MOUSE_DOWN, onSubmit);
			submitMaterial.addEventListener(FocusEvent.FOCUS_IN, onfoucsIN);
			submitMaterial.addEventListener(Event.CHANGE, oncheng);
		}

		private function onfoucsIN(event : FocusEvent) : void {
		}

		private function oncheng(event : Event) : void {
			var putinto : int = int(submitMaterial.text);
			var nowGoods : int = relic.nums;
			var value : int = sutalTotal - voHero.sutra.nowSumbitRate;
			if (putinto > value) {
				if (value > nowGoods)
					submitMaterial.text = String(nowGoods);
				else
					submitMaterial.text = String(value);
			} else {
				if (putinto > nowGoods)
					submitMaterial.text = String(nowGoods);
				else
					submitMaterial.text = String(putinto);
			}
			if(nowGoods != 0){
				if(int(submitMaterial.text) ==0){
					submitMaterial.text = "1";
				}
			}
			submitNum = int(submitMaterial.text);
		}

		private function initView() : void {
			addBG();
			addPanel();
		}
		private var goodID : int;
		private var oldSubmit:int = 0;
		private var oldTotal:int = 0;
		private var nowSutra:Sutra;
		private var nowStep:int= 0;
		// 刷新面板
		public function refreshPanel(sutra : Sutra, hero : VoHero) : void {
			voHero = hero;
			refreshText(sutra);
			refreshExp(voHero,sutra);
			refreshTextInput(voHero);
			refreshSubmitBtn(sutra);
			updateItemIcon();
			updateLevel();
			
			if((nowSutra == null) || (nowSutra != sutra)||(nowStep == sutra.step))
				changeSutra(sutra);
			else
				addToAdditional(sutra);
			nowSutra = sutra;
			nowStep = sutra.step;
		}

		private function refreshSubmitBtn(sutra:Sutra) : void {
			var myHeroLevel:int = UserData.instance.myHero.level;
			var limit:int =  StateManager.sutraStepOnLineDic[myHeroLevel];
			if((limit<sutra.step)||(limit == sutra.step)){
				submitBtn.visible = false;
				levelLimit.visible = true;
				var upLevel:int = StateManager.levelStepOnLineDic[limit+10];
				levelLimit.text = "下一阶提升需要主将到达"+StringUtils.addColor(String(upLevel),"#BD0000")+"级";
				levelLimit.x = (236 - levelLimit.width)/2;
			}else{
				submitBtn.visible = true;
				levelLimit.visible = false;
				submitBtn.x = (236 - submitBtn.width)/2;
			}
		}

		private function refreshTextInput(hero : VoHero) : void {
			var nowGoods : int;
			 nowGoods = relic.nums;
			var value : int = sutalTotal - hero.sutra.nowSumbitRate;
			oldSubmit = hero.sutra.nowSumbitRate;
			hero.sutra.story;
			oldTotal = sutalTotal;
			if (nowGoods > value)
				submitMaterial.text = String(value);
			else
				submitMaterial.text = String(nowGoods);
			submitNum = int(submitMaterial.text);
		}
		//打开面板刷新输入框
		public function refreshInputOnce():void{
			refreshTextInput(voHero);
		}

		private function refreshExp(hero : VoHero, sutra : Sutra) : void {
			var sutarObj : Object;
			sutarObj = hero.getSutraIDandNum(sutra.step);
			if (sutarObj == null) return;
			goodID = sutarObj["id"];
			sutalTotal = sutarObj["Num"];
			updateItemIcon();
			expPro.value = hero.sutra.nowSumbitRate / sutalTotal * 100;
			materialScale.text = hero.sutra.nowSumbitRate + "/" + sutalTotal;
		}

		private function refreshText(sutra : Sutra) : void {
			sutraName.text = StringUtils.addBold(sutra.name);
			sutraLevel.x = sutraName.x + sutraName.width;
			sutraLevel.visible = true;
			if(sutra.step == 0)
				sutraLevel.visible = false;
			else
				sutraLevel.text = StringUtils.addBold("  "+String(sutra.step) + "阶");
			sutraExplain.text = StringUtils.addSize(StringUtils.addBold("法宝技能："),14) + sutra.skill ;
			sutraSkillTips(sutra);
		}

		private function sutraSkillTips(sutra : Sutra) : void {
			var str:String = "";
			str +=  "技能："+sutra.skill+" \r";
			str += sutra.story;
			ToolTipManager.instance.registerToolTip(sutraExplain,ToolTip,str);
		}

		private function onSubmit(event : MouseEvent) : void {
//			SutraContral.instance.weapLevelUp();
//			return;
			submitBtn.mouseEnabled = false;
			setTimeout(deleteMC, 1000);
			var nowGoods : int = relic.nums;
			if(nowGoods == 0)
				StateManager.instance.checkMsg(178);
			var cmd : CSHeroEnhance = new CSHeroEnhance();
			cmd.id = voHero.id;
			cmd.count = submitNum;
			Common.game_server.sendMessage(0x15, cmd);
		}
		
		private function deleteMC():void{
			submitBtn.mouseEnabled = true;;
		}

		private function addPanel() : void {
			var data : GLabelData = new GLabelData();
			data.textFormat.size = 14;
			data.textColor = 0xDE5522;
			data.textFieldFilters = [];
			data.text = "九齿钉耙";
			data.x = 5;
			data.y = 21;
			data.width = 120;
			sutraName = new GLabel(data);
			_content.addChild(sutraName);
			data.clone();
			data.text = "  3阶";
			data.x = sutraName.width;
			sutraLevel = new GLabel(data);
			_content.addChild(sutraLevel);
			data.clone();
			data.text = StringUtils.addSize(StringUtils.addBold("所属名仙："),14);
			data.width = 220;
			data.x = 5 ;
			data.y = 52;
			heroName = new GLabel(data);
			_content.addChild(heroName);
			data.clone();
			data.x = 5;
			data.y = 80;
			data.width = 240;
			data.text =  StringUtils.addSize(StringUtils.addBold("法宝技能："),14);
			sutraExplain = new GLabel(data);
			_content.addChild(sutraExplain);
			data.clone();
			
			data.text = StringUtils.addSize(StringUtils.addBold("法宝属性："),14);
			data.y = 108;
			data.x = 5;
			var tex3:GLabel = new GLabel(data);
			_content.addChild(tex3);
			
			data.clone();
			data.text = "炼化材料：";
			data.y = 245;
			data.x = 0;
			var tex4 : GLabel = new GLabel(data);
			_content.addChild(tex4);
			data.clone();
			data.x = 27;
			data.y = 373;
			levelLimit = new GLabel(data);
			_content.addChild(levelLimit);

			var dataExp : GProgressBarData = new GProgressBarData();
			dataExp.trackAsset = new AssetData("ProgressBar_SU_Bg");
			dataExp.barAsset = new AssetData("ProgressBar_SU_HP");
			dataExp.height = 13;
			dataExp.width = 231;
			dataExp.x = 0;
			dataExp.y = 264;
			dataExp.paddingX = 3;
			dataExp.paddingY = 3;
			dataExp.padding = 3;
			expPro = new GProgressBar(dataExp);
			_content.addChild(expPro);
			expPro.value = 100 / 100 * 100;
			materialScale = UICreateUtils.createTextField(null, "0/20",236, 0,0,260, new TextFormat(null,null,0xFFFFFF,null,null,null,null,null,TextFormatAlign.CENTER));
			_content.addChild(materialScale);
			materialScale.filters = UIManager.getEdgeFilters(0x000000,0.7);
			
			var textData : GTextInputData = new GTextInputData();
			textData.width = 70;
			textData.height = 22;
			textData.x = 104;
			textData.y = 305;
			submitMaterial = new GTextInput(textData);
			_content.addChild(submitMaterial);
			var databtn : GButtonData = new KTButtonData();
			databtn.labelData.text = "提交";
			databtn.x = 79;
			databtn.y = 372;
			submitBtn = new GButton(databtn);
			_content.addChild(submitBtn);
			addItional();
		}
		private var act:GMagicLable;
		private var strength:GMagicLable;
		private var quick:GMagicLable;
		private var physique:GMagicLable;
		private var addTxt1:GLabel;
		private var addTxt2:GLabel;
		private var addTxt3:GLabel;
		private var addTxt4:GLabel;
		private function addItional() : void {
			var data:GLabelData = new GLabelData();
			data.textColor = 0x2F1F00;
			data.textFieldFilters = [];
			data.text = "攻击：";
			data.x = 25;
			data.y = 135;
			addTxt1 = new GLabel(data);
			_content.addChild(addTxt1);
			data.clone();
			data.x = addTxt1.x + addTxt1.width + 2;
			data.text = "0";
			act = new GMagicLable(data);
			_content.addChild(act);
			data.clone();
			data.text = "力量：";
			data.x = 25;
			data.y = addTxt1.y + addTxt1.height + 2;
			addTxt2 = new GLabel(data);
			_content.addChild(addTxt2);
			data.clone();
			data.text = "0";
			data.x = addTxt2.x + addTxt2.width + 2;
			strength = new GMagicLable(data);
			_content.addChild(strength);
			data.clone();
			data.text = "敏捷：";
			data.y = addTxt2.y + addTxt2.height + 2;
			data.x = 25;
			addTxt3 = new GLabel(data);
			_content.addChild(addTxt3);
			data.clone();
			data.x = addTxt3.x + addTxt3.width + 2;
			data.text = "0";
			quick = new GMagicLable(data);
			_content.addChild(quick);
			data.clone();
			data.text = "体魄：";
			data.y = addTxt3.y + addTxt3.height + 2;
			data.x = 25;
			addTxt4 = new GLabel(data);
			_content.addChild(addTxt4);
			data.clone();
			data.x = addTxt4.x + addTxt4.width + 2;
			data.text = "0";
			physique = new GMagicLable(data);
			_content.addChild(physique);
			
		}

		private function addBG() : void {
			var bg : Sprite = UIManager.getUI(new AssetData("TitalLine"));
			bg.y = 42;
			_content.addChild(bg);

			var bg2 : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
			bg2.width = 231;
			bg2.height = 72;
			bg2.y = 280;
			_content.addChild(bg2);
			submIcon = UICreateUtils.createItemIcon({x:104, y:271, showBg:true, showBorder:true, showNums:true, showToolTip:true});
			submIcon.x = 51;
			submIcon.y = 291;
			_content.addChild(submIcon);
		}

		private function updateItemIcon() : void {
			relic = ItemManager.instance.getPileItem(goodID);
			submIcon.source = relic;
		}

		private function updateLevel() : void {
			heroName.text = StringUtils.addSize(StringUtils.addBold("所属名仙："),14) + voHero.htmlName + "  " + voHero.htmlLevel + StringUtils.addColorById("级", voHero.color);
		}

		override protected function onShow() : void {
			super.onShow();
			updateItemIcon();
			updateLevel();
			Common.game_server.addCallback(0xFFF2, onPackChange);
		}

		override protected function onHide() : void {
			Common.game_server.removeCallback(0xFFF2, onPackChange);
			super.onHide();
		}

		private function onPackChange(msg : CCPackChange) : void {
			if (msg.topType | Item.JEWEL) {
				updateItemIcon();
			}
		}
		
		private function changeSutra(sutra:Sutra):void{
			if(sutra.step == 0){
				resetVaule(sutra);
				return;
			}
			var sutraStep : Sutra = sutra;
			act.text = String(sutraStep.stepProp.act_add+sutraStep.prop.act_add);
			strength.text = String(sutraStep.stepProp.strength+sutraStep.prop.strength);
			quick.text = String(sutraStep.stepProp.quick+sutraStep.prop.quick);
			physique.text = String(sutraStep.stepProp.physique+sutraStep.prop.physique);
			
			act.num = Number(sutraStep.stepProp.act_add+sutraStep.prop.act_add);
			strength.num = Number(sutraStep.stepProp.strength+sutraStep.prop.strength);
			quick.num = Number(sutraStep.stepProp.quick+sutraStep.prop.quick);
			physique.num = Number(sutraStep.stepProp.physique+sutraStep.prop.physique);
		}
		
		private function addToAdditional(sutra : Sutra) : void {
			if(sutra.step == 0){
				resetVaule(sutra);
				return;
			}
			var sutraStep : Sutra = sutra;
			act.setMagicText(String(sutraStep.stepProp.act_add+sutraStep.prop.act_add), sutraStep.stepProp.act_add+sutraStep.prop.act_add);
			strength.setMagicText(String(sutraStep.stepProp.strength+sutraStep.prop.strength), sutraStep.stepProp.strength+sutraStep.prop.strength);
			quick.setMagicText(String(sutraStep.stepProp.quick+sutraStep.prop.quick), sutraStep.stepProp.quick+sutraStep.prop.quick);
			physique.setMagicText(String(sutraStep.stepProp.physique+sutraStep.prop.physique), sutraStep.stepProp.physique+sutraStep.prop.physique);
		}

		private function resetVaule(sutra:Sutra) : void {
			act.text = String(sutra.prop.act_add);
			strength.text = String(sutra.prop.strength);
			quick.text = String(sutra.prop.quick);
			physique.text = String(sutra.prop.physique);
		}
	}
}
