package game.module.sutra
{
	import game.core.hero.HeroManager;
	import game.core.hero.VoHero;
	import game.core.item.sutra.Sutra;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.core.menu.VoMenuButton;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.manager.SignalBusManager;
	import game.manager.ViewManager;
	import game.module.quest.guide.GuideMange;
	import game.net.core.Common;
	import game.net.data.StoC.SCHeroEnhance;

	import gameui.core.GAlign;
	import gameui.data.GTitleWindowData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import net.AssetData;
	import net.RESManager;

	import com.commUI.GCommonWindow;
	import com.commUI.herotab.HeroTabList;
	import com.utils.UICreateUtils;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;





	/**
	 * @author Lv
	 */
	public class SutraView extends GCommonWindow {
		private var herolist:HeroTabList;
		private var heroID:int= -1;
		private var heroSutra:Sutra;
		
		private var sutraIMG:SutraImg;
		private var sutraSubmit:SutraSubmitPanel;
		
		public function SutraView() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}
		
		override protected function initData() : void {
			_data.width = 575;
			_data.height = 437;
			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;	
			super.initData();	
		}

		private function initEvents() : void {
			herolist.selectionModel.addEventListener(Event.CHANGE, onSelectCell);
			Common.game_server.addCallback(0x15, sCHeroEnhance);
			Common.game_server.addCallback(0xFFF1, cCUserDataChangeUp);
			SignalBusManager.sutraPanelSelectHero.add(onExternalSelectHero);
		}
		
		private function removeEvent():void{
			Common.game_server.removeCallback(0x15, sCHeroEnhance);
			Common.game_server.removeCallback(0xFFF1, cCUserDataChangeUp);
			SignalBusManager.sutraPanelSelectHero.remove(onExternalSelectHero);
		}

		private function onExternalSelectHero(heroId:uint) : void
		{
			herolist.selectHero(heroId);
		}


		private function cCUserDataChangeUp(...arg) : void {
			SutraContral.instance.refreshSubmit(heroID);
		}
		
		private function onSelectCell(event :Event) : void {
			heroID = (herolist.selection as VoHero).id;
			SutraContral.instance.refreshSubmit(heroID);
		}
		private var effectsWord:MovieClip;
		private function sCHeroEnhance(e:SCHeroEnhance) : void {
			
			var hero:VoHero = HeroManager.instance.getTeamHeroById(e.id);
			var sutra:Sutra = hero.sutra;
			var oldLevel:int = sutra.step;
			sutra.nowSumbitRate = e.progress;
			sutra.step = e.wpLevel;
			if(hero){
				heroID = e.id;
				SutraContral.instance.refreshSubmit(hero.id);
			}
			if(oldLevel < e.wpLevel){
				GuideMange.getInstance().checkGuideByMenuid(MenuType.SUTRA);
				StateManager.instance.checkMsg(177, [hero.sutra.name,e.wpLevel]);
				StateManager.instance.checkMsg(179, [hero.sutra.stepProp.act_add+hero.sutra.prop.act_add]);
				StateManager.instance.checkMsg(295, [hero.sutra.stepProp.strength+hero.sutra.prop.strength]);
				StateManager.instance.checkMsg(296, [hero.sutra.stepProp.quick+hero.sutra.prop.quick]);
				StateManager.instance.checkMsg(297, [hero.sutra.stepProp.physique+hero.sutra.prop.physique]);
				effectsWord = RESManager.getMC(new AssetData("orderUpSuccess", "commonAction"));
				if(effectsWord == null)deleteMC();
				effectsWord.x = 226;
				effectsWord.y = 188;
				_contentPanel.addChild(effectsWord);
				effectsWord.gotoAndPlay(2);
				setTimeout(deleteMC, 900);
			}
		}
		private function deleteMC():void{
			if(effectsWord != null)
				_contentPanel.removeChild(effectsWord);
		}
		override protected function onClickClose(event : MouseEvent) : void
		{
			GuideMange.getInstance().checkGuideByMenuid(MenuType.SUTRA);
			if (this.source is VoMenuButton)
			{
				MenuManager.getInstance().closeMenuView((this.source as VoMenuButton).id);
			}
			else
			{
				super.onClickClose(event);
			}
		}
		
		override protected function initViews() : void
		{
			title = "法宝";	
			addBG();
			addpanel();	
			super.initViews();
		}

		private function addpanel() : void {
			heroID = UserData.instance.myHero.id;
			
			heroSutra = UserData.instance.myHero.sutra;
//			var goodsID:int = UserData.instance.myHero.sutra;
			herolist = new HeroTabList(UICreateUtils.heroListDataLeft);
			herolist.x = 5;
			herolist.y = 0;
			_contentPanel.addChild(herolist);
			herolist.selectHero(heroID);
			
			
			sutraIMG = SutraContral.instance.sutraImg();
			sutraIMG.x = 80;
			sutraIMG.y = 4;
			_contentPanel.addChild(sutraIMG);
			
			sutraSubmit = SutraContral.instance.sutraSubmit();
			sutraSubmit.y = 4;
			sutraSubmit.x = 324;
			_contentPanel.addChild(sutraSubmit);
			
			SutraContral.instance.refreshSubmit(heroID);
			
		}

		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData(UI.TRADE_BACKGROUND_BIG));
			bg.x = 76;
			bg.y = 0;
			bg.width = 488;
			bg.height = 430;
			_contentPanel.addChild(bg);
		}
		
		override public function show():void
		{
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2,-1,(UIManager.stage.stageHeight - this.height) / 2,-1);
			GLayout.layout(this);
			super.show();
			SutraContral.instance.refreInputText();
			initEvents();
		}
		override public function hide():void
		{
			GuideMange.getInstance().checkGuideByMenuid(MenuType.SUTRA);
			removeEvent();
			super.hide();
		}
	}
}
