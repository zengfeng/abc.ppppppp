package game.module.battle
{
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import game.config.StaticConfig;
	import game.manager.RSSManager;
	import game.manager.VersionManager;
	import game.manager.ViewManager;
	import game.module.battle.view.BTSystem;
	import game.net.core.Common;
	import game.net.data.StoC.PropertyB;
	import game.net.data.StoC.SCBattleInfo;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.manager.UIManager;
	import net.LibData;
	import net.RESLoader;
	import net.RESManager;
	import net.SWFLoader;
	import project.Game;





	[ SWF ( frameRate="60" , backgroundColor=0x000000,width="1680" , height="1000" ) ]
	public class PlayerMain extends Game
	{
		
		override protected function initGame() : void
		{
		}
		
		private function initializeStage() : void
		{
			flash.system.Security.allowDomain("*");
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
		}
		
		private var _url:String;
		/** 初始化配置文件 **/
		private function initConfig() : void
		{
			UIManager.setRoot(this);
			ViewManager.preStageWH.x = stage.stageWidth;
			ViewManager.preStageWH.y = stage.stageHeight;
			ViewManager.instance.initializeViewsDebug();
			StaticConfig.initConfig(this.loaderInfo.parameters);
			ViewManager.instance.setRightMenu();
			_url=this.loaderInfo.parameters["url"];
		}
		
		private function completeHandler(event : Event) : void
		{
			_res.removeEventListener(Event.COMPLETE, completeHandler);
			RSSManager.getInstance().parseConfig(RESManager.getByteArray("config.kt"),1);
			ViewManager.instance.initializeViews();
			getBTDataFromUrl("");
		}
		
		private function initCommon():void
		{
			_res.add(new RESLoader(new LibData(VersionManager.instance.getUrl("config/config.kt"), "config.kt")));
			_res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + "assets/ui/Numbers.swf", "Numbers")));
			_res.add(new SWFLoader(new LibData(VersionManager.instance.getUrl("assets/swf/ui.swf"), "ui")));
			_res.addEventListener(Event.COMPLETE, completeHandler);
			_res.startLoad();
			Common.getInstance().loadPanel.show();
			var bcData : GComponentData = new GComponentData();
			bcData.parent = UIManager.root;
			var bc : GComponent = new GComponent(bcData);
			bc.mouseEnabled = false;
			BTSystem.INSTANCE().setContainer(bc);
			BTSystem.INSTANCE().setBattleModel(1);
		}
		
		public function getBTDataFromUrl(str:String):void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, parseBTData);
			
			var requestHeader:URLRequestHeader = new URLRequestHeader("Content-type","application/octet-stream");
			var request:URLRequest = new URLRequest("D:/server/replay/0/0/2.dat");
			request.method = flash.net.URLRequestMethod.POST;
			request.requestHeaders.push(requestHeader);
			urlLoader.load(request);
		}
		
		public function parseBTData(evt:Event):void
		{
			new BattleInterface();
			var dataBuf:ByteArray = evt.target.data as ByteArray;
			if(dataBuf.readByte() == 1)
				dataBuf.endian = "littleEndian";
			else
				dataBuf.endian = "bigEndian";
			
			dataBuf.readByte();
			var binfo:SCBattleInfo = new SCBattleInfo();
			binfo.randomseed = dataBuf.readUnsignedInt();
			binfo.overtype = dataBuf.readUnsignedInt();
			var i:int;
			var objNum:uint = dataBuf.readByte();
			for(i = 0; i < objNum; ++i)
			{
				var pb:PropertyB = new PropertyB();
				pb.id = dataBuf.readShort();
				pb.ftype = dataBuf.readByte();
				pb.weaponid = dataBuf.readShort();
				pb.skillid = dataBuf.readShort();
				pb.fname = dataBuf.readUTF();
				pb.side = dataBuf.readByte();
				pb.pos = dataBuf.readByte();
				pb.hp = dataBuf.readUnsignedInt();
				pb.hpnow = dataBuf.readUnsignedInt();
				pb.attack = dataBuf.readUnsignedInt();
				pb.spelldmg = dataBuf.readUnsignedInt();
				pb.defend = dataBuf.readUnsignedInt();
				pb.hitrate = dataBuf.readDouble();
				pb.dodge = dataBuf.readDouble();
				pb.speed = dataBuf.readShort();
				pb.crit = dataBuf.readDouble();
				pb.pierce = dataBuf.readDouble();
				pb.counter = dataBuf.readDouble();
				pb.countermul = dataBuf.readDouble();
				pb.critmul = dataBuf.readDouble();
				pb.piercedef = dataBuf.readDouble();
				pb.spellmul = dataBuf.readDouble();
				pb.gaugemax = dataBuf.readShort();
				pb.gaugeinit = dataBuf.readShort();
				pb.gaugeuse = dataBuf.readShort();
				pb.formationid = dataBuf.readUnsignedInt();
				binfo.vecpropertyb.push(pb);
			}
			Common.game_server.sendCCMessage(0x66,binfo);
			
		}
		
		public function PlayerMain()
		{
			initializeStage();
			initConfig();
			RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/swf/loading.swf", "loading"), initCommon);
			super();
		}
	}
}