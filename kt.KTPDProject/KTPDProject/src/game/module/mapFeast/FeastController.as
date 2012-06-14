package game.module.mapFeast
{
	import game.core.user.ExperienceConfig;
	import game.core.user.StateManager;
	import game.core.user.StateType;
	import game.core.user.UserData;
	import game.manager.ViewManager;
	import game.module.map.BarrierOpened;
	import game.module.map.CurrentMapData;
	import game.module.map.MapController;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.AnimalType;
	import game.module.map.animal.CoupleAnimal;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animalManagers.PlayerManager;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.utils.MapPosition;
	import game.module.map.utils.MapUtil;
	import game.module.map.utils.PlayerModelUtil;
	import game.module.mapFeast.element.CoupleStruct;
	import game.module.mapFeast.ui.FeastUI;
	import game.module.mapFeast.ui.UIFeastMatch;
	import game.module.mapFeast.ui.UIFeastSearch;
	import game.module.mapFeast.ui.UIFeastStart;
	import game.module.mapFeast.ui.UIFeastTimerPanel;
	import game.module.userBuffStatus.Buff;
	import game.module.userBuffStatus.BuffStatusManager;

	import gameui.data.GButtonData;
	import gameui.data.GPanelData;
	import gameui.manager.UIManager;

	import log4a.Logger;

	import net.AssetData;

	import com.commUI.alert.Alert;
	import com.commUI.button.ExitButton;
	import com.commUI.tips.PlayerTip;
	import com.utils.ColorUtils;
	import com.utils.FilterUtils;
	import com.utils.StringUtils;
	import com.utils.UIUtil;

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;









	/**
	 * @author 1
	 */
	public class FeastController {
		
		//离开派对
		public static const FEAST_LEAVE:int = 0 ;
		//离开派对弹筐中
		public static const FEAST_PRELEAVE:int = 1 ;
		//参加派对
		public static const FEAST_ENTER:int = 2 ;
		//点击开始派对后,等待匹配
		public static const FEAST_BEGIN:int = 3 ;	
		//匹配成功，派对进行中
		public static const FEAST_MATCH:int = 4 ;
		
		public static const FEAST_STATE_DEFAULT:int = -1 ;
		
		private var _feastStatus:int = 0 ;
		
		public var hasBegin:Boolean = false ;
		
		private var _lx:uint ; 
		private var _ly:uint ;
		
		private var _uiList:Vector.<DisplayObject> = new Vector.<DisplayObject>() ;
		private var _currentUI:DisplayObject = null ;
//		private var _cancelUI:GButton = null ;
		private var _feastMap:Dictionary = new Dictionary() ;
		
		private var _feastId:uint = 0 ;
		public var selfPartner:uint ;
		
		public var _timePanel:UIFeastTimerPanel ;

		public var mateName:String ;
		public var mateId:int ;
		public var mateColor:int ;
		private var _mateText:TextField ;
		public var selfAvatar:uint = 0xFFFF ;
		
		public function get feastStatus():int
		{
			return _feastStatus ;
		}

		public function FeastController( single: Singleton ){
			single ;
			initUI();
		}
		
		public function playerSingle( struct:PlayerStruct ):void
		{
			removeCouple( struct.id );
			if( struct.id == UserData.instance.playerId )
			{
				//自己
				animalManger.selfPlayer.show();
				control.enMouseMove = true ;
			}
			else 
			{
				if( animalManger.getPlayer(struct.id) )
					return ;
				MapSystem.addPlayer(struct);
			}
		}
		
		public function playerMatch( pstruct:PlayerStruct ):void
		{
			var anim:CoupleAnimal ;
			var struct:CoupleStruct = new CoupleStruct();
			var panim:PlayerAnimal = animalManger.getPlayer( pstruct.id );
			
			matchOnline( pstruct.id );
			if( _feastMap.hasOwnProperty( pstruct.id ) )
			{
				return ;
			}
			
			if( panim != null )
			{
				struct.x = panim.x ;
				struct.y = panim.y ;
			}
			else 
			{
				struct.x = pstruct.x ;
				struct.y = pstruct.y ;
			}
			struct.id = _feastId ++ ;
			struct.coupleId = pstruct.model - PlayerModelUtil.FEAST_MATCH_MIN + 1 ;
			
			Logger.debug(  "master : " +  pstruct.name +  ";  coupleX : " + struct.x + "; coupleY : " + struct.y );
			
			if( pstruct.id == UserData.instance.playerId )
			{
				animalManger.selfPlayer.hide() ;
				control.enMouseMove = false ;
				anim = animalManger.addAnimal(struct) as CoupleAnimal ;
				_feastMap[pstruct.id] = anim ;
				MapPosition.instance.center();
				//
				if( mateId != 0 )
				{
					addMatchText(anim);
				}
			}
			else 
			{
				if( animalManger.getPlayer(pstruct.id) != null )
					MapSystem.removePlayer(pstruct.id);
				anim = animalManger.addAnimal(struct) as CoupleAnimal;
				_feastMap[pstruct.id] = anim ;
			}
		}
		
		public function playerPartner( struct:PlayerStruct ):void
		{
			//该货是打酱油的
			//如果已经在跳舞了，删除之
			removeCouple(struct.id);

			if( struct.id == UserData.instance.playerId )
			{
				animalManger.selfPlayer.hide() ;
				control.enMouseMove = false ;
				if( mateId != 0 && _feastMap.hasOwnProperty(mateId) )
				{
					var anim1:CoupleAnimal = _feastMap[mateId] as CoupleAnimal;
					addMatchText( anim1 ) ;
				}
			}
			else 
			{
				if( animalManger.getPlayer(struct.id) != null )
					MapSystem.removePlayer(struct.id);
			}
		}
		
		public function matchOnline( player:uint ):void
		{
			if( player == UserData.instance.playerId )
			{
				//自己
				animalManger.selfPlayer.hide();
				control.enMouseMove = false ;
			}
			else 
			{
				if( animalManger.getPlayer(player) != null )
					MapSystem.removePlayer(player);
			}
		}
		
		public function changeMaster( pre:uint , post:uint ):void
		{
			if( ! _feastMap.hasOwnProperty(pre) ) return ;
			var anim:CoupleAnimal ; 
			//删除接收人的avatar
			if( post == UserData.instance.playerId )
			{
				animalManger.selfPlayer.hide() ;
				control.enMouseMove = false ;
			}
			else 
			{
				if( animalManger.getPlayer(post) != null )
					MapSystem.removePlayer(post);

			}
			
			removeCouple(post);
			Logger.debug(  pre.toString() + "----->" + post );
			
			//将派对master转换到另一个人身上
			anim = _feastMap[pre]; 
			delete _feastMap[pre];
			_feastMap[post] = anim ;
		}
		
		public function feastDismiss( pre:uint ):void
		{
			//删除动画 
			if( _feastMap.hasOwnProperty(pre) )
			{
				var anim:CoupleAnimal = _feastMap[pre] as CoupleAnimal ;
				delete _feastMap[pre];
				animalManger.removeAnimal(anim.id, AnimalType.COUPLE);
			}
			
			//添加自己的avatar
			if( pre == UserData.instance.playerId )
			{
				animalManger.selfPlayer.show() ;
				control.enMouseMove = false ;
			}
			else 
			{
				var struct:PlayerStruct = PlayerManager.instance.getPlayer(pre);
				if( struct != null )
				{
					if( animalManger.getPlayer(pre) == null )
						MapSystem.addPlayer(struct);
				}
			}
		}


		public function moved():void{
			
			if( !MapUtil.isMainMap() || hasBegin )
				return ;
			if( _feastStatus > 1 )
			{
				if( checkArea( animalManger.selfPlayer.x , animalManger.selfPlayer.y ) )
				{
					_lx = animalManger.selfPlayer.x ;
					_ly = animalManger.selfPlayer.y ;
				}
				else 
				{
					//弹筐
					_feastStatus = 1 ;
				}
			}
		}
		
		public function set feastStatus( stat:int ):void
		{
			var temp:DisplayObject = _currentUI ;
			if( _feastStatus == stat )
			{
				return ;
			}

			//离开
			if( stat == 1 )
			{
				_feastStatus = stat ;
				return ;
			}

			if( _feastStatus > 0 && stat == 0 )
			{
//				if( ViewManager.instance.uiContainer.contains(_cancelUI) )
//					ViewManager.instance.uiContainer.removeChild(_cancelUI);
				
				ExitButton.instance.setVisible(false, null);
				
				if( ViewManager.instance.uiContainer.contains(_timePanel) )
					ViewManager.instance.uiContainer.removeChild(_timePanel);
					
				StateManager.instance.changeState( StateType.FEASTING , false );
				
			}
			else if( _feastStatus == 0 && stat > 0 )
			{
				ExitButton.instance.setVisible(true, onClickLeave);
				if( !ViewManager.instance.uiContainer.contains(_timePanel) )
					ViewManager.instance.uiContainer.addChild(_timePanel);
					
				StateManager.instance.changeState( StateType.FEASTING , true );
			}	
			
			if( _feastStatus == 1 )
			{
				if( stat == 0 && _currentUI != null )
				{
					ViewManager.instance.uiContainer.removeChild( _currentUI );
					( _currentUI as FeastUI ).onDetach();
					_currentUI = null ;
				}
			}
			else 
			{
				if( _feastStatus > 1 )
				{
					ViewManager.instance.uiContainer.removeChild( _uiList[_feastStatus - 2 ] );
					( _currentUI as FeastUI ).onDetach();
					
					_currentUI = null ;
				}
				
				if( stat > 1 )
				{
					ViewManager.instance.uiContainer.addChild( _uiList[ stat - 2 ] );
					_currentUI = _uiList[stat - 2 ];
					( _currentUI as FeastUI ).onAttach();
					
					layout();
				}
			}
			
			if( _feastStatus == FEAST_MATCH  )
			{
				//之前的状态是配对中
				removeMatchText();
				mateId = 0 ;
				mateName = null ;
				mateColor = 0 ;
			}
			
			if( stat == FEAST_MATCH )
			{
				addMatchText();
			}
			
			
			_feastStatus = stat ;
			ViewManager.refreshShowState();
			
			if( (temp != null) != (_currentUI != null) )
			{
				if( temp != null )
					ViewManager.removeStageResizeCallFun(layout);
				else 
					ViewManager.addStageResizeCallFun(layout);
			}			
		}
		
		public function checkArea( x:uint , y:uint ):Boolean
		{
			return x > FeastConfig.AREA_LEFT && x < FeastConfig.AREA_RIGHT && y > FeastConfig.AREA_TOP && y < FeastConfig.AREA_BOTTOM ;
		}
		
		
		public function set timeLeft(time:uint):void
		{
			_timePanel.timeLeft = time ;
		}
		
		public function removeMatchText():void
		{
			if( _mateText.parent != null )
				_mateText.parent.removeChild(_mateText);
		}
		
		public function setFeastStatus( stat:uint , tim:uint = 0 , timtotal:uint = 0 ) : void
		{
			selfAvatar = stat & 0xF ;
			var b1:Buff = BuffStatusManager.instance.getBuff(200+selfAvatar);
			var rep:Array = [ ["__EXP__",updBufferExp ]];
			b1.extendReplace(rep);
			BuffStatusManager.instance.updateBuffTime(200+selfAvatar, timtotal);
			
			if( stat > 0x1F  )
			{
				BuffStatusManager.instance.updateBuffTime( 210 , tim );
			}

			else if( _feastStatus == 4 && ( stat >> 4 ) != 2 )
			{
				BuffStatusManager.instance.updateBuffTime( 210 , 0 );
				if( CurrentMapData.instance.selfPlayerStruct.model != 0 )
					StateManager.instance.checkMsg(26,[mateName]);
			}
			
			
			if( stat < 0x10 )
				(_uiList[0] as UIFeastStart ).cooldown =  tim ;
			else if( stat > 0x1F )
				(_uiList[2] as UIFeastMatch ).timeLeft =  tim ;
			
			this.timeLeft = timtotal ;
			this.feastStatus = ( stat >> 4 ) + 2 ;
		}
		
		public function updBufferExp():String
		{
			var exp:Number = ExperienceConfig.getPracticeExperience(UserData.instance.level) * 6 ;
			return exp.toString() ;
		}
				
		public function addMatchText(anim:CoupleAnimal = null):void
		{
			if( anim == null )
			{
				if( _feastMap.hasOwnProperty( UserData.instance.playerId ) )
				{
					anim = _feastMap[UserData.instance.playerId] as CoupleAnimal ;
				}
				else if( _feastMap.hasOwnProperty( mateId ) )
				{
					anim = _feastMap[mateId] as CoupleAnimal ;
				}
			}

			if( anim != null && !anim.avatar.contains(_mateText) )
			{
				anim.avatar.addChild( _mateText );
				_mateText.x = - 90 ;
				_mateText.y = - 150 ;
				_mateText.htmlText = "与玩家"+ StringUtils.addEvent( StringUtils.addLine(StringUtils.addColor(mateName,ColorUtils.TEXTCOLOR[mateColor+1])) , "to") + "</a>" +"派对中....." ;
				_mateText.addEventListener(MouseEvent.CLICK, onClickText);
			}
		}
		
		private var _mapController:MapController ;
		
		private var animalManger:AnimalManager = AnimalManager.instance ;
		
		private var currData:CurrentMapData = CurrentMapData.instance ;
				
		private function get control():MapController
		{
			if( _mapController == null )
				_mapController = MapController.instance;
			return _mapController;
		}
		
		public static function get instance():FeastController{
			if( _instance == null )
				_instance = new FeastController(new Singleton());
			return _instance ;
		}

		private function initUI() : void {
			
			var startdata:GPanelData = new GPanelData();
			var enterUi:UIFeastStart = new UIFeastStart(startdata);
			enterUi.addEventListener(MouseEvent.CLICK, onClickQueue);
			enterUi.tabEnabled = false ;
			_uiList.push(enterUi);
			
			var sdata:GPanelData = new GPanelData();
			var searchui:UIFeastSearch = new UIFeastSearch(sdata);
			_uiList.push(searchui);
			
			var pandata:GPanelData = new GPanelData();
			var matchui:UIFeastMatch = new UIFeastMatch(pandata);
			_uiList.push(matchui);

			var udata:GButtonData = new GButtonData() ;
			udata.upAsset = new AssetData(FeastConfig.LEAVE_ASSET) ;
			udata.downAsset = new AssetData(FeastConfig.LEAVE_ASSET) ;
			udata.overAsset = new AssetData(FeastConfig.LEAVE_ASSET) ;
			udata.width = 91 ;
			udata.height = 53 ;
			//test ui ;
			_timePanel = new UIFeastTimerPanel();
			_timePanel.tabEnabled = false ;
//			
			_mateText = new TextField();
			_mateText.width = 180 ;
			var tf:TextFormat = new TextFormat() ;
			tf.color = 0xFFFFFF ;
			tf.size = 14 ;
			tf.font = "黑体" ;
			tf.align = TextFormatAlign.LEFT ;
			_mateText.defaultTextFormat = tf ;
			_mateText.selectable = false ;
			_mateText.addEventListener(TextEvent.LINK, onClickMate);
			_mateText.antiAliasType = AntiAliasType.NORMAL ;
			_mateText.filters = [FilterUtils.defaultTextEdgeFilter] ;
		}
	
		
		private function layout( s:Stage = null , w:Number = 0 , h:Number = 0  ):void{
			
			s;
			w;
			h;
			var stage:Stage = UIManager.stage ;
			if( _currentUI != null ){
				UIUtil.alignStageHCenter(_currentUI);
				_currentUI.y = 28.5 ;
			}
			
			if( _timePanel != null ){
				UIUtil.alignStageHCenter(_timePanel);
				_timePanel.y = 7.55 ;
			}
		}
		
		public function setup():void
		{
		}
		
		public function openPathPass():void
		{
			BarrierOpened.setState(FeastConfig.FEAST_AREA_COLOR, true);
		}
		
		public function feastBegin():void
		{
			hasBegin = true ;
		}
		
		public function feastEnd():void
		{
			hasBegin = false ;
			feastStatus = 0 ;
			BuffStatusManager.instance.updateBuffTime(200+selfAvatar, 0);
			BuffStatusManager.instance.updateBuffTime(210 , 0 );
			selfAvatar = 0xFFFF ;
		}
		
		private static var _instance:FeastController ;
		
		public function playerLeave(id:int):void
		{
			/** 如果是自己就关闭面板 */			if( id == UserData.instance.playerId )
			{
				feastStatus = 0 ;
				
				BuffStatusManager.instance.updateBuffTime(200+selfAvatar, 0);
				selfAvatar = 0xFFFF ;
				
				BuffStatusManager.instance.updateBuffTime(210, 0);
			}
		}
		
		public function playerEnter(id:int):void
		{
			/**如果是自己就打开面板*/
			if( id == UserData.instance.playerId )
			{
				feastStatus = 2 ;
			}
		}
		
		public function onClickLeave(evt:Event = null):void
		{
			var alert:Alert ;
			if( _feastStatus == FEAST_MATCH )
				alert = StateManager.instance.checkMsg(29,[mateName],onAlert);
			else 
				alert = StateManager.instance.checkMsg(28,null,onAlert);
			alert.modal = true ;
			alert.show();
			
		}
		
		public function onAlert(evt:String):Boolean
		{
			if( evt == Alert.CANCEL_EVENT )
			{
//				var self:SelfPlayerStruct = currData.selfPlayerStruct ;
//				if( !checkArea( self.x , self.y ) )
//				{
//					self.x = _lx ;
//					self.y = _ly ;
//					control.transport(self);
//				}
			}
			else if( evt == Alert.OK_EVENT )
			{
				FeastProto.instance.sendFeastLeave() ;
			}
			return true ;
		}
		
		public function onClickMate(evt:Event):void
		{
			if( mateId != 0 )
				PlayerTip.show( mateId , mateName );
		}
		
		public function onClickQueue( evt:Event ):void
		{
			if( ( _uiList[0] as UIFeastStart ).cooldown == 0 )
			{
				FeastProto.instance.sendFeastQueue();
			}	
		}
		
		public function onClickText(evt:Event):void
		{
			evt.stopPropagation();
		}
		
		
		public function removeCouple( id:uint ):void
		{
			if( _feastMap.hasOwnProperty( id ) )
			{
				//
				var anim:CoupleAnimal = _feastMap[id];
				if( anim.avatar.contains(_mateText) )
					anim.avatar.removeChild(_mateText);
				delete _feastMap[id];
				animalManger.removeAnimal( anim.id , AnimalType.COUPLE);
			}

		}
	}
}
class Singleton{
}