package game.module.wordDonate {
	import com.greensock.layout.AlignMode;
	import com.utils.StringUtils;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import game.definition.UI;
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
	public class ContributionItem extends GPanel {
		private var titleArr:Array = ["排名","名字","等级","本周贡献"];
		public var nameStr:GLabel;
		public var rankStr:GLabel;
		private var levelStr:GLabel;
		private var contributionStr:GLabel;
		private var bg:Sprite;
		public function ContributionItem() {
			_data = new GPanelData();
			initData();
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void {
			_data.width = 298;
			_data.height = 24;
			_data.bgAsset=new AssetData(SkinStyle.emptySkin);   //取消背景
		}

		private function initEvent() : void {
		}

		private function initView() : void {
			addBG();
			addPanel();
		}

		private function addBG() : void {
			bg = UIManager.getUI(new AssetData(UI.COMPETE_BACKGROUND));
			bg.width = 298;
			bg.height = 24;
			_content.addChild(bg);
		}
		//获取title标题
		public function getTitle():void{
			rankStr.text = titleArr[0];
			nameStr.text = titleArr[1];
			levelStr.text = titleArr[2];
			contributionStr.text = titleArr[3];
			rankStr.textColor = nameStr.textColor = levelStr.textColor = contributionStr.textColor = 0xFFFFFF;
		}
		/**
		 * bgColor:背景颜色转变
		 */
		public function setBgAlpha(bgColor:Boolean = true):void{
			
			if(bgColor){
				bg.alpha = 0.5;
			}
		}
		public var rank:int = 1;
		public var playerID:int ;
		/**
		 * 《设置具体数值》
		 * rank:玩家排名
		 * name:玩家名称
		 * level:玩家等级
		 * contr:玩家本周贡献
		 * bgColor:背景颜色转变
		 * id:玩家id
		 * color:颜色值
		 */
		public function setContent(rank1:uint,name:String,level:uint,contr:uint,id:int,color:uint):void{
			rankStr.text = String(rank1);
			nameStr.text = name;
			levelStr.text = String(level);
			contributionStr.text = String(contr) + " 个";
			rank = rank1;
			playerID = id;
			nameStr.text = StringUtils.addColorById(String(nameStr.text), (color + 1));
		}
		public var color:uint;
		/**
		 * 《设置颜色》
		 * color:颜色值
		 */
		public function setNameColor(color:uint):void{
			color = color;
			StringUtils.addColorById(nameStr.text, (color + 1));
		}
		/**
		 * 《设置背景》
		 * change:背景的颜色
		 * bgFilter:背景描边
		 */
		public function setBackGround(changeBG:Boolean = true,bgFilter:Boolean = false):void{
			if(changeBG)
				bg.alpha = 0.5;
			bg.filters = [];
			if(bgFilter){
				bg.filters = [new GlowFilter(0xFFF000)];
			}
		}

		private function addPanel() : void {
			var data:GLabelData = new  GLabelData();
			data.textFormat = new TextFormat("12",null,0x000000,null,null,null,null,null,AlignMode.CENTER);
			data.width = 38;
			data.text = "1";
			rankStr = new GLabel(data);
			_content.addChild(rankStr);
			data.clone();
			data.text = "name";
			data.width = 122;
			data.x = 38;
			nameStr = new GLabel(data);
			_content.addChild(nameStr);
			data.clone();
			data.text = "21";
			data.width = 57;
			data.x = 160;
			levelStr = new GLabel(data);
			_content.addChild(levelStr);
			data.clone();
			data.text = "本周贡献";
			data.width = 86;
			data.x = 217;
			contributionStr = new GLabel(data);
			_content.addChild(contributionStr);
		}
	}
}
