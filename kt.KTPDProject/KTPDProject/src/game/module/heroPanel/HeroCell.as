package game.module.heroPanel
{
	import com.commUI.tooltip.HeroTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.utils.FilterUtils;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import game.core.hero.VoHero;
	import gameui.cell.GCell;
	import gameui.controls.GImage;
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.manager.GToolTipManager;
	import net.AssetData;
	import net.RESManager;





	/**
	 * @author yangyiqiang
	 */
	public class HeroCell extends GComponent
	{
		private var _selected : Boolean = false;

		public function HeroCell()
		{
			_base = new GComponentData();
			_base.width = 53;
			_base.height = 53;

			super(_base);
			initView();
		}

		private var _heroImg : GImage;

		private function initView() : void
		{
			var bg : MovieClip = RESManager.getMC(new AssetData("IconBottom"));
			if (bg)
				addChild(bg);
			var data : GImageData = new GImageData();
			data.iocData.align = new GAlign(0, 0);
			// data.x = 5;
			// data.y = 5;
			// data.align = new GAlign(-1,-1,-1,-1,0,0);
			_heroImg = new GImage(data);
			addChild(_heroImg);
			// GLayout.layout(_heroImg);
			var out : MovieClip = RESManager.getMC(new AssetData("IconBox"));
			if (out)
				addChild(out);
			addEventListener(MouseEvent.CLICK, onSelected);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}

		protected function onSelected(event : MouseEvent) : void
		{
			selected = true;
			if (_selected) dispatchEvent(new Event(GCell.SINGLE_CLICK, true));
			if (!vo)
			{
				this.filters = [];
			}
		}

		private function onRollOver(event : MouseEvent) : void
		{
			if (!vo)
			{
				this.filters = [];
			}
			else
			{
				this.filters = [FilterUtils.selectFilter];
				_toolTip.source = _vo;
			}
		}

		private function onRollOut(event : MouseEvent) : void
		{
			if (!vo)
			{
				this.filters = [];
			}
			else
			{
				if (_selected)
					this.filters = [FilterUtils.selectFilter];
				else
					this.filters = [];
			}
		}

		public function set selected(value : Boolean) : void
		{
			if (_selected == value) return;
			_selected = value;
			if (_selected)
				this.filters = [FilterUtils.selectFilter];
			else
				this.filters = [];
		}

		private var _vo : VoHero;

		public function set vo(value : VoHero) : void
		{
			_vo = value;
			if (_vo)
			{
				_heroImg.url = _vo.heroImage;
				_toolTip = ToolTipManager.instance.getToolTip(HeroTip);
				GToolTipManager.registerToolTip(this);
			}
			else
			{
				// TODO: remove tooltip
				if (_heroImg)
					_heroImg.clearUp();
			}
		}

		public function get vo() : VoHero
		{
			return _vo;
		}
	}
}
