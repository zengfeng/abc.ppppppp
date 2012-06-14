package
{
	import game.config.StaticConfig;
	import game.manager.CommonMessageManage;
	import game.manager.ViewManager;
	import game.module.map.BarrierOpened;
	import game.module.map.GateOpened;
	import game.module.map.NpcSignals;
	import game.net.core.Common;

	import gameui.manager.UIManager;

	import maps.auxiliarys.MapStage;

	import net.LibData;
	import net.RESManager;

	import com.commUI.LoginPanel;
	import com.sociodox.theminer.TheMiner;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.ui.Keyboard;

	[ SWF ( frameRate="60" , backgroundColor=0x000000,width="1680" , height="1000" ) ]
	public class Client extends Sprite
	{
		public function Client()
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			initConfig();
		}

		private function onKeyDown(event : KeyboardEvent) : void
		{
			switch(event.keyCode)
			{
				case Keyboard.F1:
					NpcSignals.aiStart.dispatch(4111);
					break;
				case Keyboard.F2:
					NpcSignals.aiStop.dispatch(4111);
					break;
				case Keyboard.F3:
					NpcSignals.remove.dispatch(4111);
					break;
				case Keyboard.F4:
					NpcSignals.add.dispatch(4111);
					break;
				case Keyboard.T:
					// NpcSignals.transportSelfPlayerToNpc.dispatch(4111);
//					MapSystem.mapTo.toDuplNpc(202);
//					MapSystem.mapTo.toDuplNpc(201);
//					MapSystem.mapTo.toMap(2, 1888, 896);
//					MapSystem.mapTo.toMap(1, 2640, 1808);
					break;
				case Keyboard.G:
					isGate = !isGate;
					break;
				case Keyboard.B:
					isBarrier = !isBarrier;
					break;
				case Keyboard.O:
					isOpen = !isOpen;
					break;
			}

			if (event.keyCode >= Keyboard.NUMBER_0 && event.keyCode <= Keyboard.NUMBER_9)
			{
				var num : int = parseInt(String.fromCharCode(event.keyCode));
				if (isGate)
				{
					GateOpened.setState(num, isOpen);
				}

				if (isBarrier)
				{
					BarrierOpened.setState(num, isOpen);
				}
			}
		}

		private var isOpen : Boolean;
		private var isGate : Boolean;
		private var isBarrier : Boolean;

		private function init() : void
		{
			UIManager.setStage(this.stage);
			UIManager.setRoot(this);
			MapStage.startup(UIManager.stage);
			initializeStage(UIManager.stage);
			initContainer();
		}

		private function initializeStage(stage : Stage) : void
		{
			flash.system.Security.allowDomain("*");
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			initView();
		}

		private function initView() : void
		{
			ViewManager.preStageWH.x = stage.stageWidth;
			ViewManager.preStageWH.y = stage.stageHeight;
			ViewManager.instance.initializeViewsDebug();
			ViewManager.instance.setRightMenu();
			addChild(new TheMiner());
		}

		/** 初始化配置文件 **/
		private function initConfig() : void
		{
			switch(StaticConfig.initConfig(this.loaderInfo.parameters))
			{
				case StaticConfig.ISDEBUGE:
					UIManager.appDomain = ApplicationDomain.currentDomain;
					init();
					_loginPanel = new LoginPanel(this, startLoad);
					_loginPanel.show();
					break;
				case StaticConfig.NODEBUGE:
					UIManager.appDomain = ApplicationDomain.currentDomain;
					init();
					startLoad();
					break;
				case StaticConfig.RELEASE:
					break;
			}
		}

		public function initMessage() : void
		{
			UIManager.setStage(this.stage);
			UIManager.setRoot(this);
			initView();
			MapStage.startup(UIManager.stage);
			UIManager.appDomain = ApplicationDomain.currentDomain;
			CommonMessageManage.instance.init();
			initContainer();
		}

		private var _loginPanel : LoginPanel;

		private function startLoad() : void
		{
			RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/swf/loading.swf", "loading"), initCommon);
		}

		private function initCommon() : void
		{
			CommonMessageManage.instance.init();
			Common.getInstance().init(StaticConfig.serversString, StaticConfig.userId, StaticConfig.key);
		}

		// 容器初始化
		private function initContainer() : void
		{
			ViewManager.instance.initializeContainers();
		}
	}
}