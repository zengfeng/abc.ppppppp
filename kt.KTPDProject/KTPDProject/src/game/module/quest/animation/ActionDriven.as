package game.module.quest.animation
{
	import com.greensock.TweenLite;
	import com.utils.FilterUtils;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarThumb;
	import game.core.user.StateManager;
	import game.core.user.StateType;
	import game.manager.MouseManager;
	import game.manager.RSSManager;
	import game.manager.ViewManager;
	import game.module.battle.view.BTSystem;
	import game.module.map.MapSystem;
	import game.module.mapStory.StoryController;
	import game.net.core.Common;
	import game.net.data.CtoS.CSPlotEnd;
	import gameui.controls.BDPlayer;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;
	import gameui.data.GLabelData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;
	import gameui.skin.ASSkin;
	import log4a.Logger;
	import net.AssetData;
	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;






	/**
	 * @author yangyiqiang
	 */
	public class ActionDriven
	{
		<!-- 
			所有标点请用英文半角
			id  对应的任务编号
			name 任务名
			mapid 地图编号
			mapx  中心点X,Y
			player 玩家列表  1,100,100|  用|区分player     用,区分坐标   
			npc    npc列表
			
			action
			target   动作的执行者  数值与上面player或npc对应 0,代表玩家avatar
			direction  1:左边 2：右边
			type       动作分类  1:对话，2:人物原地出现 3：模型转身 4: 模型攻击 5：死亡消失 6:冒金光特效 7：文字或物品从avatar上浮现 
			                     8:星宿归位，任务人物消失化为金光升空的动画 9：从天而降 10：模型释放技能特效 11：后退 12：屏幕抖动
								 14：引入过场动画  15: 模型无痕迹消失 16: 烟雾逃遁 17：星宿归位 18:黑屏之后文字 describe 为要显示的内容  19:模型闪避
								 20：模型无痕迹出现  21：被攻击受创 22：打坐姿势出现 23：白色雾气环绕 24：融入体内  25：压黑底显示文字（有确定）
								 26: 走路  27：切换动作  28:模型skill攻击  29：骑坐骑移动  31:被攻击后闪避（describe里填写相对便宜位置，填的是距离X,Y的正负值） 
								 32:不断缩小至消失   34:NPC发光  36：从消失不断放大  37：模型使用第二套动作
								 35: 2个模型绑定 describe里，若target在上层，则填0,ID 若target在下层，则填1,ID describe里填 0，33【NPCid】，x，y【X,Y为相对坐标】
								
			describe 动作描述
			1:对话，对话内容
			2:移动, 目标点坐标
			3:转身,	当前面向的坐标
			completeType  动作完成类型
			0: 点击完成   其它表示延时 -->;
		public static const DIALOGUE : int = 1;

		public static const MOVE : int = 2;

		public static const AVATAR_TUN : int = 3;

		public static const AVATAR_ATTACK : int = 4;

		public static const AVATAR_DIE : int = 5;

		public static const SCREEN_WIDTH : int = 1280;

		public static const SCREEN_HEIGHT : int = 700;

		private static var _instance : ActionDriven;

		public function ActionDriven()
		{
			if (_instance)
			{
				throw Error("单类，不能多次初始化!");
			}
		}

		private var _currentAction : Animation;

		public function getNextAction() : Action
		{
			return _currentAction.getNextAction();
		}

		public static function instance() : ActionDriven
		{
			if (_instance == null)
			{
				_instance = new ActionDriven();
			}
			return _instance;
		}

		private var _dic : Dictionary = new Dictionary(true);

		/** 初始化xml */
		public function initXml(xml : XML) : void
		{
			if (!xml) return;
			var anim : Animation;
			for each (var item:XML in xml.children())
			{
				anim = new Animation();
				anim.parse(item);
				_dic[anim.id] = anim;
			}
			RSSManager.getInstance().deleteData("questAnimation");
		}

		private var _panel : DialoguePanel;

		public function playAnimation(id : int) : Animation
		{
			_currentAction = _dic[id];
			if (_currentAction)
			{
				StateManager.instance.changeState(StateType.ANIMATION, true, startAnimation, null, waitFor, [id]);
			}
			else
			{
				Logger.error("找不到 id= " + id + " 的剧情动画");
			}
			return _currentAction;
		}

		private var _key : String;

		private var _isEnd : Boolean = true;

		private function startAnimation() : void
		{
			_isEnd = false;
			if (_currentAction.getAssets().length > 0)
			{
				for each (var url:String in _currentAction.getAssets())
				{
					_key = url;
					RESManager.instance.add(new SWFLoader(new LibData(url, _key)));
				}
				Common.getInstance().moduleLoader.model = RESManager.instance.model;
				RESManager.instance.addEventListener(Event.COMPLETE, loadComplete);
				RESManager.instance.startLoad();
				Common.getInstance().moduleLoader.startShow("加载剧情动画资源中...");
			}
			else
			{
				initAnimation();
			}
			MouseManager.cursor = MouseCursor.ARROW;
		}

		private function waitFor(id : int) : void
		{
			BTSystem.INSTANCE().addClickEndCall({fun:playAnimation, arg:[id]});
		}

		private function loadComplete(event : Event) : void
		{
			RESManager.instance.removeEventListener(Event.COMPLETE, loadComplete);
			initAnimation();
			Common.getInstance().moduleLoader.hide();
		}

		public function endAnimation() : void
		{
			_isEnd = true;
			removeMode();
			UIManager.stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
			ViewManager.instance.getContainer(ViewManager.MAP_CONTAINER).mask = null;
			ViewManager.removeStageResizeCallFun(onResize);
			StoryController.instance.self.avatar.removeSeat();
			StoryController.instance.quit();
			_panel.hide();
			TweenLite.to(ViewManager.instance.uiContainer, 2, {alpha:1});
			TweenLite.to(ViewManager.instance.getContainer(ViewManager.AUTO_CONTAINER), 2, {alpha:1});
			var cmd : CSPlotEnd = new CSPlotEnd();
			cmd.plotId = _currentAction.id;
			Common.game_server.sendMessage(0x39, cmd);
			StateManager.instance.changeState(StateType.ANIMATION, false);
			// addActionSkin();
			MapSystem.zoomRestore();
			if (_backSkin && _backSkin.parent) _backSkin.parent.removeChild(_backSkin);
			setTimeout(runEndClickCall, 2000);
			MouseManager.cursor = MouseCursor.ARROW;
		}

		private  var _clickEndCallList : Vector.<Object> = new Vector.<Object>();

		/*
		 * ActionDriver.instance.addClickEndCall({fun:QuestUtil.questAction, arg:[temp.id]});
		 */
		public  function addClickEndCall(obj : Object) : void
		{
			if (obj == null || !obj["fun"] ) return;
			var index : int = _clickEndCallList.indexOf(obj);
			if (index == -1)
				_clickEndCallList.push(obj);
		}

		public  function removeClickEndCall(obj : Object) : void
		{
			var index : int = _clickEndCallList.indexOf(obj);
			if (index != -1)
				_clickEndCallList.splice(index, 1);
		}

		private  function runEndClickCall() : void
		{
			if (_clickEndCallList.length <= 0) return;
			for (var i : int = 0; i < _clickEndCallList.length; i++)
			{
				var fun : Object = _clickEndCallList[i];
				if (!fun["fun"]) continue;
				(fun["fun"] as Function).apply(null, fun["arg"]);
			}
			_clickEndCallList = new Vector.<Object>();
		}

		public function initAnimation() : void
		{
			addMode();
			_currentAction.reset();
			TweenLite.to(ViewManager.instance.uiContainer, 1, {alpha:0});
			TweenLite.to(ViewManager.instance.getContainer(ViewManager.AUTO_CONTAINER), 1, {alpha:0});
			UIManager.stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			if (!_panel)
				_panel = new DialoguePanel();
			ViewManager.addStageResizeCallFun(onResize);
			// addActionSkin();
			initMapElement();
			MapSystem.zoomUp();
			// TweenLite.to(ViewManager.instance.getContainer(ViewManager.MAP_CONTAINER), 2, {scaleX:1.1, scaleY:1.1});
			addBackSkin();
			executeAction();
		}

		public function get isInQuestAction() : Boolean
		{
			return !_isEnd;
		}

		private function onResize(...args) : void
		{
			GLayout.layout(_panel, new GAlign(-1, -1, -1, 0, 0));
			addBackSkin();
			if (_modalSkin)
			{
				_modalSkin.width = UIManager.stage.stageWidth;
				_modalSkin.height = UIManager.stage.stageHeight;
			}
		}

		private function onMouseClick(event : MouseEvent) : void
		{
			if (!_action) return;
			if (_action.type == 1)
			{
				if (_panel.showAll())
				{
					executeAction();
					return;
				}
			}
			else if (_action.type == 25) // 点击获得
			{
				removeSkin();
				executeAction();
			}
		}

		private var _diePlay : BDPlayer;

		private var avatar : AvatarThumb;

		private var _temp : Array;

		private var _tempMc : MovieClip;

		private var _skin : Sprite;

		private var _action : Action;

		private function executeAction() : void
		{
			if (_isEnd) return;
			_action = getNextAction();
			if (!_action)
			{
				endAnimation();
				return;
			}
			_panel.hide();
			switch(_action.type)
			{
				case 1:
					_panel.data = _action;
					break;
				case 2:
					showNpc(true, true);
					break;
				case 3:
					_temp = _action.describe.split(",");
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					if (!avatar) break;
					avatar.standDirection(_temp[0], _temp[1]);
					break;
				case 4:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_temp = _action.describe.split(",");
					TweenLite.to(avatar, 0.3, {x:int(_temp[0]), y:int(_temp[1]), onComplete:fightStepA, onCompleteParams:[avatar, avatar.x, avatar.y, AvatarManager.ATTACK], overwrite:0});
					break;
				case 10:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_temp = _action.describe.split(",");
					TweenLite.to(avatar, 0.3, {x:int(_temp[0]), y:int(_temp[1]), onComplete:fightStepA, onCompleteParams:[avatar, avatar.x, avatar.y, AvatarManager.MAGIC_ATTACK], overwrite:0});
					break;
				case 5:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_diePlay = new BDPlayer(new GComponentData());
					_diePlay.setBDData(AvatarManager.instance.getDie());
					avatar.addChild(_diePlay);
					avatar.hideName();
					_diePlay.addEventListener(Event.COMPLETE, dieComplete);
					TweenLite.to(avatar.player, 0.6, {alpha:0, overwrite:0});
					_diePlay.play(30);
					break;
				case 6:
					_tempMc = RESManager.getMC(new AssetData("bottomAction", _key));
					if (!_tempMc) break;
					_tempMc.gotoAndStop(0);
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_tempMc.x = -_tempMc.width / 2 ;
					_tempMc.y = -_tempMc.height + 30;
					avatar.addChildAt(_tempMc, 0);
					_tempMc.gotoAndPlay(0);
					break;
				case 7:
					var tempMc2 : MovieClip = RESManager.getMC(new AssetData("nameAction", _key));
					if (!tempMc2) break;
					tempMc2.x = -tempMc2.width / 2;
					avatar.addChild(tempMc2);
					break;
				case 8:
					var tempMc3 : MovieClip = RESManager.getMC(new AssetData("upAction", _key));
					if (!tempMc3) break;
					tempMc3.gotoAndStop(0);
					tempMc3.x = -tempMc3.width / 2;
					tempMc3.y = -tempMc3.height / 2;
					avatar.addChild(tempMc3);
					tempMc3.gotoAndPlay(0);
					break;
				case 11:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					avatar.setAction(AvatarManager.HURT);
					break;
				case 12:
					MapSystem.shake();
					break;
				case 15:
					StoryController.instance.removeNpc(_action.target);
					break;
				case 16:
					StoryController.instance.removeNpc(_action.target);
					break;
				case 18:
					addSkin(_action.describe);
					break;
				case 20:
					showNpc();
					break;
				case 22:
					showNpc();
					StoryController.instance.self.avatar.setAction(AvatarManager.PRACTICE);
					break;
				case 25:
					addSkin(_action.describe, 0);
					break;
				case 26:
					showNpc(false);
					break;
				case 27:
					ActionUtil.changeAvatarState(_action);
					break;
				case 28:
					var avatar : AvatarThumb = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_temp = _action.describe.split(",");
					if (_temp.length < 2)
					{
						_temp = [avatar.x, avatar.y];
					}
					TweenLite.to(avatar, 0.3, {x:int(_temp[0]), y:int(_temp[1]), onComplete:fightStepA, onCompleteParams:[avatar, avatar.x, avatar.y, AvatarManager.MAGIC_ATTACK], overwrite:0});
					break;
				case 29:
					StoryController.instance.self.avatar.addSeat(25);
					break;
				case 31:
					BTSystem.INSTANCE().initAssets();
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_temp = _action.describe.split(",");
					if (_temp.length < 2) _temp = [-30, -30];
					// if (avatar is PerformerAvatar)
					// {
					avatar.showEfft();
					TweenLite.to(avatar, 0.2, {x:avatar.x + Number(_temp[0]), y:avatar.y + Number(_temp[1]), overwrite:0});
					TweenLite.to(avatar, 0.2, {delay:0.2, x:avatar.x, y:avatar.y, overwrite:0});
					// }
					break;
				case 32:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					avatar.alpha = 1;
					avatar.scaleX = 1;
					avatar.scaleY = 1;
					_temp = _action.describe.split(",");
					TweenLite.to(avatar, _action.completeType, {scaleX:0.1, scaleY:0.1, alpha:0, x:int(_temp[0]), y:int(_temp[1]), onComplete:runEnd, overwrite:0});
					return;
				case 33:
					_temp = _action.describe.split("|");
					var arr : Array = String(_temp[1]).split(",");
					addSkin("", 3);
					endAnimation();
					MapSystem.mapTo.toMap(_temp[0], arr[0], arr[1], true);
					break;
				case 34:
					var defaultGlowFilter : GlowFilter = FilterUtils.defaultGlowFilter;
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					avatar.filters = [defaultGlowFilter];
					avatar.alpha = 1;
					TweenLite.to(defaultGlowFilter, 1, {alpha:1, blurX:20, blurY:20, overwrite:0});
					break;
				case 35:
					// 0,npcid     1,npcid
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_temp = _action.describe.split(",");
					var avatar2 : AvatarThumb = _temp[1] == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_temp[1]).avatar;
					avatar2.x = _temp[3];
					avatar2.y = _temp[4];
					if (_temp[0] == 0)
						avatar.addChildAt(avatar2, 0);
					else
					{
						avatar.addChild(avatar2);
					}
					break;
				case 36:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					_temp = _action.describe.split("|");
					var arr3 : Array = String(_temp[0]).split(",");
					var arr4 : Array = String(_temp[1]).split(",");
					avatar.alpha = 0;
					avatar.scaleX = 0.1;
					avatar.scaleY = 0.1;
					StoryController.instance.npcMoveTo(_action.target, arr3[0], arr3[1], true);
					TweenLite.to(avatar, _action.completeType, {scaleX:1, scaleY:1, alpha:1, x:int(arr4[0]), y:int(arr4[1]), onComplete:runEnd, overwrite:0});
					break;
				case 37:
					avatar = _action.target == 0 ? StoryController.instance.self.avatar : StoryController.instance.getNpc(_action.target).avatar;
					avatar["changeAction"]();
					break;
			}
			//trace("action.type===>" + _action.type + " action.completeType===>" + _action.completeType);
			if (_action.completeType > 0)
				setTimeout(executeAction, _action.completeType * 1000);
		}

		private function runEnd() : void
		{
			executeAction();
		}

		private function showNpc(flashStep : Boolean = true, playShowAction : Boolean = false) : void
		{
			var arr : Array ;
			var total : Array = _action.describe.split("|");
			if (total.length > 1)
			{
				_temp = _action.describe.split("|");
				var max : int = total.length;
				for (var i : int = 0;i < max;i++)
				{
					arr = (_temp[i] as String).split(",");
					StoryController.instance.getNpc(_action.targets[i]).avatar.setAction(1);
					StoryController.instance.npcMoveTo(_action.targets[i], arr[0], arr[1], flashStep);
					if (playShowAction) StoryController.instance.getNpc(_action.targets[i]).avatar.playShowAction();
				}
				return;
			}
			arr = _action.describe.split(",");
			if (arr.length < 2) return;
			if (_action.target == 0)
			{
				StoryController.instance.selfMoveTo(arr[0], arr[1], flashStep);
				if (playShowAction) StoryController.instance.selfPlayer.avatar.playShowAction();
			}
			else
			{
				StoryController.instance.getNpc(_action.target).avatar.setAction(1);
				StoryController.instance.npcMoveTo(_action.target, arr[0], arr[1], flashStep);
				if (playShowAction) StoryController.instance.getNpc(_action.target).avatar.playShowAction();
			}
		}

		private var _tempArray : Array;

		private function fightStepA(avatar : AvatarThumb, oldX : int, oldY : int, type : int) : void
		{
			_tempArray = [avatar, oldX, oldY];
			avatar.setAction(type, 1);
			avatar.player.addEventListener(Event.COMPLETE, fightStepB);
		}

		private function fightStepB(event : Event) : void
		{
			var avatar : AvatarThumb = event.target["parent"] as AvatarThumb;
			if (!avatar) return;
			avatar.player.removeEventListener(Event.COMPLETE, fightStepB);
			avatar.setAction(AvatarManager.BT_STAND);
			TweenLite.to(_tempArray[0], 0.3, {x:int(_tempArray[1]), y:int(_tempArray[2]), overwrite:0});
		}

		private function dieComplete(event : Event) : void
		{
			_diePlay.stop();
			_diePlay.removeEventListener(Event.COMPLETE, dieComplete);
			if (avatar)
				avatar.hide();
		}

		private var _backSkin : Sprite;

		private function addBackSkin() : void
		{
			if (!_backSkin)
				_backSkin = new Sprite();
			_backSkin.graphics.clear();
			var fillType : String = GradientType.LINEAR;

			var colors : Array = [0xffff88, 0xffff00];
			var alphas : Array = [1, 1];
			var ratios : Array = [0x00, 0xff];
			var matr : Matrix = new Matrix();
			matr.createGradientBox(20, 20, 0, 0, 0);
			_backSkin.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr);
			_backSkin.graphics.drawRect(0, 0, UIManager.stage.stageWidth, 1);
			with(_backSkin.graphics)
			{
				beginFill(0x000000, 0.8);
				drawRect(0, 1, UIManager.stage.stageWidth, 140);
				endFill();
			}
			_backSkin.y = UIManager.stage.stageHeight - _backSkin.height;
			if (!UIManager.root.contains(_backSkin))
				UIManager.root.addChild(_backSkin);
		}

		private var _lable : GLabel;

		private var _button : GButton;

		private function addSkin(str : String, type : int = 1) : void
		{
			if (!_skin)
			{
				_skin = ASSkin.blackSkin;
				var data : GLabelData = new GLabelData();
				data.textFormat = UIManager.getTextFormat(20);
				data.width = 500;
				_lable = new GLabel(data);
			}
			_skin.x = 0;
			_skin.y = 0;
			_skin.mouseChildren = false;
			_skin.mouseEnabled = false;
			_skin.alpha = 0;
			_lable.htmlText = str;
			_skin.width = UIManager.stage.stageWidth;
			_skin.height = UIManager.stage.stageHeight;
			_lable.x = (_skin.width - _lable.width) / 2;
			_lable.y = (_skin.height - _lable.height) / 2;
			UIManager.root.addChild(_skin);
			UIManager.root.addChild(_lable);
			if (type == 0)
			{
				var gbutton : GButtonData = new GButtonData();
				_button = new GButton(gbutton);
				_button.text = "确定";
				_button.x = (_skin.width - _button.width) / 2;
				_button.y = (_skin.height - _button.height) / 2;
				UIManager.root.addChild(_button);
			}
			else if (type == 1)
			{
				TweenLite.to(_skin, 1, {alpha:1, overwrite:0});
				TweenLite.to(_lable, 1, {alpha:1, overwrite:0});
				TweenLite.to(_skin, 1, {delay:_action ? _action.completeType : 1, alpha:0, onComplete:removeSkin, overwrite:0});
				TweenLite.to(_lable, 1, {delay:_action ? _action.completeType : 1, alpha:0, overwrite:0});
			}
			else
			{
				_skin.alpha = 1;
				TweenLite.to(_skin, 1, {delay:1, alpha:0, onComplete:removeSkin, overwrite:0});
			}
		}

		private function removeSkin() : void
		{
			if (_lable && UIManager.root.contains(_lable))
				UIManager.root.removeChild(_lable);
			if (UIManager.root.contains(_skin))
				UIManager.root.removeChild(_skin);
			if (_button && UIManager.root.contains(_button))
				UIManager.root.removeChild(_button);
		}

		private  var _modalSkin : Sprite = ASSkin.emptySkin;

		private  function addMode() : Sprite
		{
			if (!_modalSkin)
				_modalSkin = ASSkin.emptySkin;
			_modalSkin.width = UIManager.stage.stageWidth;
			_modalSkin.height = UIManager.stage.stageHeight;
			if (!_modalSkin.parent) UIManager.root.addChild(_modalSkin);
			return _modalSkin;
		}

		private  function removeMode() : Sprite
		{
			if (_modalSkin && _modalSkin.parent)
			{
				_modalSkin.parent.removeChild(_modalSkin);
			}
			return _modalSkin;
		}

		private function initMapElement() : void
		{
			StoryController.instance.setup(_currentAction.mapId, _currentAction.mapX, _currentAction.mapY);
			for each (var obj:Object in _currentAction.performerDic)
			{
				if (obj["id"] == 0)
				{
					StoryController.instance.addSelf(obj["x"], obj["y"]);
					continue;
				}
				StoryController.instance.addNpc(obj["id"], obj["x"], obj["y"]).avatar;
//				var avatar : AvatarThumb = StoryController.instance.addNpc(obj["id"], obj["x"], obj["y"]).avatar;
//				if (obj["x"] == -1 && obj["y"] == -1)
//					avatar.stop();
			}
		}
	}
}
