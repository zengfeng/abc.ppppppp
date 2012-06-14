package game.module.sutra {
	import game.config.StaticConfig;
	import game.core.hero.VoHero;
	import game.core.item.sutra.Sutra;
	import game.core.user.UserData;
	import game.definition.UI;

	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.manager.UIManager;

	import net.AssetData;
	import net.LibData;
	import net.RESManager;

	import com.commUI.tooltip.SutraStepTip;
	import com.commUI.tooltip.ToolTipManager;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;

	/**
	 * @author Lv
	 */
	public class SutraImg extends GComponent {
		private var img:GImage;
		private var sutraStep:Sutra;
		private var weapMC:MovieClip;
		public function SutraImg() {
			_base = new GComponentData();
			initData();
			super(_base);
			initView();
			initEvent();
		}

		private function initData() : void {
			_base.width =240;
			_base.height = 422;
		}

		private function initEvent() : void {
			this.addEventListener(MouseEvent.ROLL_OVER, onover);
			this.addEventListener(MouseEvent.ROLL_OUT, onOut);
		}

		private function onOut(event : MouseEvent) : void {
			img.filters = [];
		}

		private function onover(event : MouseEvent) : void {
			img.filters = [new GlowFilter(0xFFF000)];
		}

		private function initView() : void {
			addBG();
		}
		private var iconMc:Sprite;
		private var tipsText:GLabel;
		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData("Gossip"));
			bg.scaleX = bg.scaleY = 1.27;
			bg.x = (240-bg.width)/2;
			bg.alpha = 0.2;
			bg.y = 111;
			addChild(bg);
			
			iconMc = UIManager.getUI(new AssetData(UI.ICON_HINT));
			iconMc.x = 10;
			iconMc.y = 3;
			addChild(iconMc);
			var data1:GLabelData = new GLabelData();
			data1.textColor = 0x000000;
			data1.textFieldFilters = [];
			data1.text = "提升法宝阶数获得附加属性";
			data1.width = 200;
			data1.x = iconMc.x + iconMc.width +2;
			data1.y = 3;
			tipsText = new GLabel(data1);
			addChild(tipsText);
			
			var data:GImageData = new GImageData();
			data.width=this.width;
			data.height=this.height;
			data.iocData.align=new GAlign(-1,-1,-1,-1,0);
			img = new GImage(data);
			addChild(img);
			
		//	setWeap();
			
			
		}
		//更改法宝图片
		public function changeIMG(hero:VoHero):void{
			img.clearUp();
			sutraStep = hero.sutra;
			img.url = sutraStep.imgLargeUrl;
			if(sutraStep == null)
				ToolTipManager.instance.destroyToolTip(this);
			else
				ToolTipManager.instance.registerToolTip(this, SutraStepTip);
			var level:int = UserData.instance.myHero.level;
			if(level>59){
				iconMc.visible = false;
				tipsText.visible = false;
			}
		}
		
		override public function get source() : * {
			return this.sutraStep;
		}
		
		public function setWeap():void{
			RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/weapMC/weap1.swf", "weap1"), initDieFrame);
		}

		private function initDieFrame() : void {
			weapMC = RESManager.getMC(new AssetData("xzvcb","weap1"));
			weapMC.x = 5;
			weapMC.y = 12;
			//weapMC.gotoAndPlay(2);
			//this.addChild(weapMC);
		}
		public function upLevel():void{
//			weapMC.gotoAndPlay("levelup");
		}
	}
}
