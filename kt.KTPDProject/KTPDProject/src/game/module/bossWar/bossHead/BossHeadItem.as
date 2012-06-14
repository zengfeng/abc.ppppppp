package game.module.bossWar.bossHead {
	import com.utils.UrlUtils;
	import flash.display.Sprite;
	import game.definition.UI;
	import gameui.controls.GImage;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.manager.UIManager;
	import net.AssetData;

	/**
	 * @author Lv
	 */
	public class BossHeadItem extends GComponent {
		private var imgUrl:String ;
		private var bossIMG:GImage;
		public function BossHeadItem() {
			_base = new GComponentData();
            initData();
            super(_base);
            initView();
            initEvent();
		}

		private function initData() : void {
			_base.width = 93;
            _base.height = 92;
		}

		private function initEvent() : void {
		}

		private function initView() : void {
			setBgToStage();
			setImgToStage();
//			refreshBossIMG("");
		}
		
		public function refreshBossIMG(id:int):void{
//			imgUrl = path;
			bossIMG.url = UrlUtils.getBossHeadIcon(id);
      //	bossIMG.url = imgUrl;
		}

		private function setImgToStage() : void {
			var data:GImageData = new GImageData();
			data.width = 121;
			data.height = 175;
			data.x = -13-(93/2);
			data.y = -46-(92/2);
			bossIMG = new GImage(data);
			this.addChild(bossIMG);
		}
		
		private function setBgToStage() : void {
			var bg1:Sprite = UIManager.getUI(new AssetData(UI.HEAD_ICON_BACKGROUND));
			this.addChild(bg1);
		}
	}
}
