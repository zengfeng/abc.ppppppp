package game.module.demonTower {
	import com.commUI.tooltip.ToolTipManager;
	import com.greensock.layout.AlignMode;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import game.module.demonTower.demonTips.DemonUpTips;
	import game.module.duplMap.data.DuplStruct;
	import gameui.controls.GLabel;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GLabelData;
	import net.AssetData;
	import net.RESManager;

	/**
	 * @author Lv
	 */
	public class DemonUpItem extends GComponent {
		private var copyEnterLevel:GLabel;
		private var background:MovieClip;
		private var dupls:DuplStruct;
		public function DemonUpItem() {
			_base = new GComponentData();
            initData();
            super(_base);
            initView();
            initEvent();
		}

		private function initData() : void {
			_base.width = 90;
            _base.height = 38;
		}

		private function initEvent() : void {
		}

		private function initView() : void {
			setBackground();
	//--------------------------------------
			setText();
		}
		
		public function refreshDemonUp(item:DuplStruct):void{
			dupls = item;
			copyEnterLevel.text = dupls.name;
			ToolTipManager.instance.registerToolTip(this, DemonUpTips);
		}

		public function selectFalse():void{
			background.gotoAndStop(1);
		}
		
		public function selectTrue():void{
			background.gotoAndStop(2);
		}

		private function setText() : void {
			var data:GLabelData = new GLabelData();
			data.text = "深渊树洞";
			data.textColor = 0x2F1F00;
			data.width = 90;
			data.y = 8;
			data.textFormat = new TextFormat(null,14,null,null,null,null,null,null,AlignMode.CENTER);
			data.textFieldFilters = [];
			copyEnterLevel = new GLabel(data);
			this.addChild(copyEnterLevel);
		}

		private function setBackground() : void {
			background = RESManager.getMC(new AssetData("demonHoleBG"));
			background.x = 5;
			background.y = 2;
			this.addChild(background);
		}
		
		override public function get source() : * {
			return this.getDupls;
		}

		public function get getDupls() : DuplStruct {
			return dupls;
		}
	}
}
