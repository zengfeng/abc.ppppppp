package game.module.groupBattle.ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import game.module.groupBattle.GBPlayerStatus;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-17 ����10:29:26
	 */
	public class UiPlayerStatusIcon extends Sprite
	{
		private var _status : int = GBPlayerStatus.UNKNOW;
		private var bitmap : Bitmap = new Bitmap();

		public function UiPlayerStatusIcon()
		{
			status = GBPlayerStatus.UNKNOW;
			addChild(bitmap);
		}

		public function get status() : int
		{
			return _status;
		}

		public function set status(status : int) : void
		{
			_status = status;
			bitmap.y = 0;
			switch(_status)
			{
				case GBPlayerStatus.WAIT:
					bitmap.bitmapData = GBPlayerStatus.waitIcon;
					break;
				case GBPlayerStatus.REST:
					bitmap.bitmapData = GBPlayerStatus.restIcon;
					bitmap.y = -2;
					break;
				case GBPlayerStatus.VS:
					bitmap.bitmapData = GBPlayerStatus.vsIcon;
					break;
				case GBPlayerStatus.DIE:
					bitmap.bitmapData = GBPlayerStatus.dieIcon;
					break;
				// 移动状态
				case GBPlayerStatus.MOVE:
					bitmap.bitmapData = null;
					break;
				default:
					bitmap.bitmapData = null;
					break;
			}
			// bitmap.scaleX = bitmap.scaleY = 0.5;
		}
	}
}
