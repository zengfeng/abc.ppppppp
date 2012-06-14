package test {
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import game.config.StaticConfig;
	import net.LibData;
	import net.RESManager;



	/**
	 * @author yangyiqiang
	 */
	public class TestLoader extends Sprite {
		private var _list : Array = ["67112865", "67112866", "67112867", "67112868", "67113014", "67113015", "67113016", "67113017", "67113018", "67113019", "67113020", "67113021", "67112866", "67112866", "67112866"];
		private var _timer:uint;
		public function TestLoader() {
			_timer=getTimer();
			for (var i : int = 0;i < _list.length;i++)
				RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/avatar/" + _list[i] + ".swf"), onComplete);
			//trace(String(getTimer()-_timer));
		}

		private function onComplete() : void {
//			for (var i : int = 0;i < _list.length;i++)
//				RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/avatar/" + _list[i] + ".swf"), onComplete);
		}
	}
}
