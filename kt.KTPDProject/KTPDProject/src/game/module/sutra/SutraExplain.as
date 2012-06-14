package game.module.sutra
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import game.core.item.sutra.Sutra;
	import gameui.containers.GPanel;
	import gameui.controls.GLabel;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;




	/**
	 * @author 1
	 */
	public class SutraExplain extends GPanel {
		private var goodsItem:Sutra;
		private var goodsLegend:GLabel;
		private var goodsExplain:TextField;
		/**
		 * id:法宝id
		 */
		public function SutraExplain(id:Sutra) {
			_data = new GPanelData();
			initData();
			goodsItem = id;
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void {
			_data.width =203;
			_data.height = 357;
			_data.bgAsset=new AssetData(SkinStyle.emptySkin);   //取消背景
		}

		private function initEvent() : void {
		}

		private function initView() : void {
			addBG();
			addPanel();
		}
		//物品id
		public function refreshSutraExplain(sutra:Sutra):void
		{
//			goodsID = id;
//			goodsItem = ManagePack.getItemFromConfig(goodsID) as VoItem;
//			var sutra:Sutra = ItemManager.instance.get(goodsID) 
			var str:String;
			if(sutra.story)
				str = sutra.story;
			else
				str = "未加载";
			goodsExplain.text = str;
		}

		private function addPanel() : void {
//			goodsItem = ManagePack.getItemFromConfig(goodsID) as VoItem;
			var data:GLabelData = new GLabelData();
			data.text = "法宝传说";
			data.textFormat.size = 14;
			data.textColor = 0x000000;
			data.textFormat.bold = true;
			data.filters = [];
			data.textFieldFilters = [];
			data.x = 70;
			data.y = 7;
			goodsLegend = new GLabel(data);
			_content.addChild(goodsLegend);
			
			var format:TextFormat = new TextFormat();
          	 format.font = "Verdana";
            format.color = 0x000000;
            format.size = 12;
			format.leading = 4;
			goodsExplain = new TextField();
			goodsExplain.width = 186;
			goodsExplain.height = 312;
			goodsExplain.defaultTextFormat = format;
			goodsExplain.wordWrap = true;
			goodsExplain.x = 10;
			goodsExplain.y = 40;
			if(goodsItem.story)
				goodsExplain.text = goodsItem.story;
			else
				goodsExplain.text = "未加载";
			_content.addChild(goodsExplain);
			
			
		}

		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData("sutra_Explain"));
			_content.addChild(bg);
		}
	}
}
