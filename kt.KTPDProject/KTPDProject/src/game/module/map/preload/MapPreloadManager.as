package game.module.map.preload
{
	import game.module.map.MapSingles;
	import game.manager.SignalBusManager;
	import game.module.map.MapSystem;
	import game.module.map.Path;
	import game.net.core.Common;

	import com.commUI.CommonLoading;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-6
	 */
	public class MapPreloadManager
	{
		function MapPreloadManager(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : MapPreloadManager;

		/** 获取单例对像 */
		static public function get instance() : MapPreloadManager
		{
			if (_instance == null)
			{
				_instance = new MapPreloadManager(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 加载UI */
		private var _loaderPanel : CommonLoading;

		private function get loaderPanel() : CommonLoading
		{
			if (_loaderPanel == null)
			{
				_loaderPanel = Common.getInstance().loadPanel;
			}
			return _loaderPanel;
		}

		/** 显示  */
		public function show() : void
		{
			isShow = true;
			clearTimeout(closeLoadUITimer);
			clearTimeout(setupProgressTimer_60);
			clearTimeout(setupProgressTimer_70);
			clearTimeout(setupProgressTimer_80);
			clearTimeout(setupProgressTimer_90);
			clearTimeout(setupProgressTimer_100);
			loaderPanel.isLoadMapProgress = true;
			loaderPanel.isSetupMapProgress = false;
			loaderPanel.open();
			// loaderPanel.setShow();
			// loaderPanel.startShow();
		}

		public function setLoadMapProgress(progress : int) : void
		{
			if (isShow == false) return;
			loaderPanel.loadMapProgress(progress);
			if (progress >= 100)
			{
				loaderPanel.isLoadMapProgress = false;
				loaderPanel.isSetupMapProgress = true;
				loaderPanel.setupMapProgress(1);
				Path.signalWriteProgress.add(setSetupMapProgress);
				Path.signalWriteComplete.add(setSetupMapCompelete);
			}
		}

		private function setSetupMapProgress(value : Number, total : Number) : void
		{
			loaderPanel.setupMapProgress((value / total) * 50);
		}

		private function setSetupMapCompelete() : void
		{
			loaderPanel.setupMapProgress(50);
			setupProgressTimer_60 = setTimeout(loaderPanel.setupMapProgress, 200, 60);
			setupProgressTimer_70 = setTimeout(loaderPanel.setupMapProgress, 400, 70);
			setupProgressTimer_80 = setTimeout(loaderPanel.setupMapProgress, 600, 80);
			setupProgressTimer_90 = setTimeout(loaderPanel.setupMapProgress, 800, 90);
			setupProgressTimer_100 = setTimeout(loaderPanel.setupMapProgress, 1200, 100);
			closeLoadUI();
		}

		private var isShow : Boolean = true;
		private var closeLoadUITimer : uint;
		private var setupProgressTimer_60 : uint;
		private var setupProgressTimer_70 : uint;
		private var setupProgressTimer_80 : uint;
		private var setupProgressTimer_90 : uint;
		private var setupProgressTimer_100 : uint;

		/** 关闭加载界面 */
		public function closeLoadUI() : void
		{
			if (isShow == false) return;
			isShow = false;
			Path.signalWriteProgress.remove(setSetupMapProgress);
			Path.signalWriteComplete.remove(setSetupMapCompelete);
			closeLoadUITimer = setTimeout(delayClose, 1200);
		}

		private function delayClose() : void
		{
			MapSystem.mapTo.checkArrive();
			loaderPanel.hide();
			loaderPanel.isLoadMapProgress = false;
			loaderPanel.isSetupMapProgress = false;
			SignalBusManager.setupMapComplete.dispatch();
			MapSingles.setupMapComplete.dispatch();
		}
	}
}
class Singleton
{
}