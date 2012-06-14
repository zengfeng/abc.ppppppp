package
{
	import game.config.StaticConfig;
	import game.module.role.RoleSystem;
	import game.net.core.Common;
	import game.net.core.RequestData;
	import game.net.data.StoC.SCUserLogin;

	import gameui.manager.UIManager;

	import net.AssetData;
	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.ApplicationDomain;

	public class Main extends Sprite
	{
		public function Main()
		{
			initializeStage(this.stage);
			UIManager.setStage(this.stage);
			UIManager.setRoot(this);
			initConfig();
		}

		private function initializeStage(stage : Stage) : void
		{
			flash.system.Security.allowDomain("*");
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_mc=new swfClass();
			_mc.x=stage.stageWidth/2;
			_mc.y=stage.stageHeight/2;
			addChild(_mc);
		}

		
		[Embed(source='../assets/ui/mc.swf')]	

		private var swfClass:Class;
		private var _mc:MovieClip;
		private function initConfig() : void
		{
			StaticConfig.initConfig(this.loaderInfo.parameters);
			startLoad();
		}

		private function startLoad() : void
		{
			RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/swf/loading.swf", "loading"), initCommon);
		}

		private function initCommon() : void
		{
			UIManager.appDomain=ApplicationDomain.currentDomain;
			Common.game_server.addCallback(0x02, loginCallBack);
			Common.getInstance().init(StaticConfig.serversString, StaticConfig.userId, StaticConfig.key);
		}
		
		private var _mssage:SCUserLogin;
		/**
		 * 登录返回
		 */
		private function loginCallBack(message : SCUserLogin) : void
		{
			_mssage=message;
			switch(message.result)
			{
				case 0:
					/** 登录成功 **/
					RESManager.instance.add(new SWFLoader(new LibData((StaticConfig.cdnRoot=="../"?"":StaticConfig.cdnRoot)+"Client.swf", "client", true, false)));
					RESManager.instance.addEventListener(Event.COMPLETE, loadComplete);
					RESManager.instance.startLoad();
					Common.getInstance().loadPanel.startShow(false);
					Common.game_server.removeCallback(0x02, loginCallBack);
					break;
				case 1:
					/** 新用户 **/
					RoleSystem.initCreateRole();
					break;
			}
		}

		private function loadComplete(event : Event) : void
		{
			if(_mc){
				_mc.stop();
				this.removeChild(_mc);
			}
			RESManager.instance.removeEventListener(Event.COMPLETE, loadComplete);
			this.parent.removeChild(this);
			var cls : Class = RESManager.getClass(new AssetData("Client", "client"));
			var game : * = new cls();
			UIManager.stage.addChild(game);
			game["initMessage"]();
			Common.game_server.executeCallback(new RequestData(0x02, _mssage));
		}
	}
}
