package game.module.userBuffStatus.ui
{
	import com.utils.FilterUtils;
	import game.module.userBuffStatus.Buff;
	import gameui.controls.GImage;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GImageData;
	import gameui.data.GToolTipData;



	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-1 ����2:15:32
	 */
	public class BuffIcon extends GComponent
	{
		public var buff : Buff;
		private var img : GImage;
		private var _buffStatusContainer : BuffStatusContainer;

		public function BuffIcon(buff : Buff)
		{
			_base = new GComponentData();
			_base.width = 25;
			_base.height = 25;
			_base.toolTipData = new GToolTipData();
			super(_base);
			this.buff = buff;
			initViews();
		}

		/** 初始化视图 */
		public function initViews() : void
		{
			var imageData : GImageData = new GImageData();
			imageData.width = 25;
			imageData.height = 25;
			img = new GImage(imageData);
			img.url = buff.url;
			addChild(img);
		}

		/** TIP */
		public function set tip(value : String) : void
		{
			toolTip.source = value;
		}

		/** 时间 */
		public function set time(value : int) : void
		{
			if (value <= 3 && value > 0)
			{
				FilterUtils.addGlow(this);
			}
			else
			{
				FilterUtils.removeGlow(this);
			}
		}

		private function get buffStatusContainer() : BuffStatusContainer
		{
			if (_buffStatusContainer == null)
			{
				_buffStatusContainer = BuffStatusContainer.instance;
			}
			return _buffStatusContainer;
		}

		override public function show() : void
		{
			if (isClearImg == true)
			{
				img.url = buff.url;
				isClearImg = false;
				addChild(img);
				buffStatusContainer.addIcon(this);
			}
		}

		public var isClearImg : Boolean = true;

		override public function hide() : void
		{
			buffStatusContainer.removeIcon(this);
			img.clearUp();
			isClearImg = true;
		}
	}
}
