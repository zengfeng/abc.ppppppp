package game.core.avatar {
	import com.greensock.TweenLite;
	import com.utils.CallFunStruct;
	import com.utils.StringUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	import game.module.battle.view.BTSystem;
	import game.module.map.MapSystem;

	import gameui.controls.GProgressBar;
	import gameui.core.GComponentData;
	import gameui.data.GProgressBarData;
	import gameui.data.GToolTipData;
	import gameui.manager.UIManager;

	import net.AssetData;

	/**
	 * @author yangyiqiang
	 */
	public class AvatarThumb extends AbstractAvatar {
		protected var _stateObj : DisplayObject;
		protected var _progressBar : GProgressBar;
		protected var _nameBitMap : Bitmap;
		protected var _clanBitMap : Bitmap;
		protected var _lastY : Number;

		override protected function updateDisplays() : void {
			if (!_avatarBd) return;
			_lastY = _avatarBd.topY + 10;
			if (_progressBar) {
				_progressBar.x = -33;
				_progressBar.y = _lastY;
				_lastY -= 20;
			}
			_nameBitMap.x = _avatarBd.topX;
			_nameBitMap.y = _lastY;
			_lastY -= 20;
			if (_clanBitMap) {
				_clanBitMap.x = _avatarBd.topX;
				_clanBitMap.y = _lastY;
				_lastY -= 20;
			}
			if (_stateObj) {
				_stateObj.x = -_stateObj.width / 2;
				_stateObj.y = _lastY ;
				_lastY -= 20;
			}
		}

		protected var _name : String;
		private var nameText : TextField;

		public function setName(name : String, color : String = "#ffee00") : void {
			createText();
			nameText.htmlText = StringUtils.addColor(name, color);
			var bitMapData : BitmapData = new BitmapData(120, 40, true, 0);
			bitMapData.draw(nameText);
			if (_nameBitMap.bitmapData) _nameBitMap.bitmapData.dispose();
			_nameBitMap.bitmapData = bitMapData;
			_nameBitMap.smoothing = true;
			_name = name;
			updateDisplays();
		}
		
		
		private function createText() : void {
			if (!nameText) {
				nameText = new TextField();
				nameText.width = 120;
				nameText.autoSize = TextFieldAutoSize.CENTER;
				nameText.defaultTextFormat = UIManager.getTextFormat(13);
				nameText.filters = UIManager.getEdgeFilters(0x111111, 0.8, 17);
			}
		}

		public function setClanName(name : String, color : String = "#ffee00") : void {
			if (name == "") {
				if (_clanBitMap) {
					if (_clanBitMap.bitmapData) _clanBitMap.bitmapData.dispose();
					removeChild(_clanBitMap);
				}
				_clanBitMap = null;
			} else {
				createText();
				nameText.htmlText = StringUtils.addColor(name, color);
				var bitMapData : BitmapData = new BitmapData(100, 40, true, 0);
				bitMapData.draw(nameText);
				if (!_clanBitMap) _clanBitMap = new Bitmap();
				if (_clanBitMap.bitmapData) _clanBitMap.bitmapData.dispose();
				_clanBitMap.bitmapData = bitMapData;
				addChild(_clanBitMap);
			}
			updateDisplays();
		}

		public function addProgressBar() : void {
			if (_progressBar)
				_progressBar.value = 100;
			else {
				var data : GProgressBarData = new GProgressBarData();
				data.x = -33;
				data.y = 70;
				data.max = 100;
				data.value = 100;
				data.trackAsset = new AssetData("ProgressBar_BT_HP_Bg");
				data.barAsset = new AssetData("ProgressBar_BT_HP");
				data.toolTipData = new GToolTipData();
				data.paddingX = data.paddingY = data.padding = 1;
				_progressBar = new GProgressBar(data);
				_progressBar.setSize(75, 6);
				addChild(_progressBar);
			}
			updateDisplays();
		}

		public function getProgressBar() : GProgressBar {
			return _progressBar;
		}

		// 显示血条bar的百分比
		public function showHPBar(pV : uint) : void {
			if (!_progressBar) return;
			_progressBar.value = pV;
		}

		public function addStateObj(obj : DisplayObject) : void {
			if (_stateObj && this.contains(_stateObj)) {
				this.removeChild(_stateObj);
				_stateObj.x = _stateObj.y = 0;
			}
			_stateObj = obj;
			if (!_stateObj) return;
			this.addChild(_stateObj);
			if (obj.x == 0 && obj.y == 0) {
				updateDisplays();
				return;
			}
			obj.x = -obj.width / 2;
			obj.y = avatarBd.topY;
		}

		public function standDirection(targetX : int, targetY : int, x : int = 0, y : int = 0) : void {
		}

		public function run(goX : int, goY : int, targetX : int, targetY : int) : void {
		}

		public function addSeat(seatId : int) : void {
		}

		public function removeSeat() : void {
		}

		/** 站立 */
		public function stand() : void {
			if (changeType(AvatarType.PLAYER_RUN))
				setAction(1);
		}

		/** 打坐 */
		public function sitdown() : void {
			if (changeType(AvatarType.PLAYER_RUN))
				setAction(AvatarManager.PRACTICE);
		}

		/** 正面准备战斗(战斗站立) */
		public function fontReadyBattle() : void {
			if (changeType(AvatarType.PLAYER_BATT_FRONT)) {
				this.player.flipH = false;
				setAction(AvatarManager.BT_STAND);
			}
		}

		/** 背面准备战斗(战斗站立) */
		public function backReadyBattle() : void {
			if (changeType(AvatarType.PLAYER_BATT_BACK)) {
				this.player.flipH = false;
				setAction(AvatarManager.BT_STAND);
			}
		}

		/** 正面物理攻击 */
		public function fontAttack(loop : int = 0) : void {
			if (changeType(AvatarType.PLAYER_BATT_FRONT)) {
				this.player.flipH = false;
				setAction(AvatarManager.ATTACK, loop, 0);
				if (loop > 0) {
					player.addEventListener(Event.COMPLETE, battComplete);
				}
			}
		}

		/** 背面物理攻击 */
		public function backAttack(loop : int = 0) : void {
			if (changeType(AvatarType.PLAYER_BATT_BACK)) {
				this.player.flipH = false;
				setAction(AvatarManager.ATTACK, loop, 0);
				if (loop > 0) {
					player.addEventListener(Event.COMPLETE, battComplete);
				}
			}
		}

		/** 正面技能攻击 */
		public function fontSkillAttack(loop : int = 0) : void {
			if (changeType(AvatarType.PLAYER_BATT_FRONT)) {
				this.player.flipH = false;
				setAction(AvatarManager.MAGIC_ATTACK, loop, 0);
				if (loop > 0) {
					player.addEventListener(Event.COMPLETE, battComplete);
				}
			}
		}

		/** 背面技能攻击 */
		public function backSkillAttack(loop : int = 0) : void {
			if (changeType(AvatarType.PLAYER_BATT_BACK)) {
				this.player.flipH = false;
				setAction(AvatarManager.MAGIC_ATTACK, loop, 0);
				if (loop > 0) {
					player.addEventListener(Event.COMPLETE, battComplete);
				}
			}
		}

		/** 正面被攻击 */
		public function fontHit(loop : int = 0) : void {
			if (changeType(AvatarType.PLAYER_BATT_FRONT)) {
				this.player.flipH = false;
				setAction(AvatarManager.HURT, loop, 0);
				if (loop > 0) {
					player.addEventListener(Event.COMPLETE, battComplete);
				}
			}
		}

		/** 背面被攻击 */
		public function backHit(loop : int = 0) : void {
			if (changeType(AvatarType.PLAYER_BATT_BACK)) {
				this.player.flipH = false;
				setAction(AvatarManager.HURT, loop, 0);
				if (loop > 0) {
					player.addEventListener(Event.COMPLETE, battComplete);
				}
			}
		}

		private function battComplete(event : Event) : void {
			setAction(AvatarManager.BT_STAND);
		}

		/** 点击回调方法列表 */
		private var clickCallList : Vector.<CallFunStruct> = new Vector.<CallFunStruct>();

		/** 添加点击回调 */
		public function addClickCall(callFunStruct : CallFunStruct) : void {
			if (callFunStruct == null && callFunStruct.fun != null) return;
			var index : int = clickCallList.indexOf(callFunStruct);
			if (index == -1) {
				clickCallList.push(callFunStruct);
			}
		}

		/** 移除点击回调 */
		public function removeClickCall(callFunStruct : CallFunStruct) : void {
			if (callFunStruct == null) return;
			var index : int = clickCallList.indexOf(callFunStruct);
			if (index != -1) {
				clickCallList.splice(index, 1);
			}
		}

		/** 清理点击回调 */
		public function clearClickCallList() : void {
			while (clickCallList.length) {
				clickCallList.shift();
			}
		}

		/** 运行点击回调 */
		public function runClickCall() : void {
			for (var i : int = 0; i < clickCallList.length; i++) {
				var callFunStruct : CallFunStruct = clickCallList[i];
				callFunStruct.fun.apply(null, callFunStruct.args);
			}
		}

		public function die() : void {
		}

		public function getAction() : int {
			return _action;
		}

		protected function onMouseClick(event : MouseEvent) : void {
			if (this.parent && this.parent.name == "ElementLayer") {
				if (MapSystem.enMouseClickMovePlayer == false) return;
				MapSystem.mapTo.toAvatarPosition(x, y, runClickCall);
				if (event) event.stopPropagation();
			}
		}

		public function mouseClickAction() : void {
			onMouseClick(null);
		}

		public function showName() : void {
			_nameBitMap.visible = true;
		}

		public function hideName() : void {
			_nameBitMap.visible = false;
		}

		// 设置普通效果,攻击方
		public function showEfft(effectID : uint = 1003) : void {
			if (effectID == BTSystem.ID_Shanbi) {
				var Shanbi : MovieClip = new BTSystem.Effect_Shanbi as MovieClip;
				Shanbi.gotoAndStop(1);
				Shanbi.x = avatarBd.topX - 30;
				Shanbi.y = avatarBd.topY - 50;
				this.addChild(Shanbi);
				Shanbi.gotoAndPlay(1);
				TweenLite.to(Shanbi, 0, {delay:2, onComplete:showEffectComplete_func, onCompleteParams:[this, Shanbi], overwrite:0});
			}
		}

		private function showEffectComplete_func(av : AvatarThumb, mc : MovieClip) : void {
			if (av.contains(mc))
				av.removeChild(mc);
		}

		override protected function onHide() : void {
			super.onHide();
			this.removeEventListener(MouseEvent.CLICK, onMouseClick);
		}

		override protected function onShow() : void {
			super.onShow();
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			updateDisplays();
		}

		override protected function create() : void {
			super.create();
			_nameBitMap = new Bitmap();
			super.addChild(_nameBitMap);
		}

		override internal function reset() : void {
			super.reset();
			if (_nameBitMap)
				_nameBitMap.visible = true;
			clearClickCallList();
			addStateObj(null);
			setClanName("");
			showName();
			this.name = "";
		}

		public function AvatarThumb() {
			_base = new GComponentData();
			_base.toolTipData = new GToolTipData();
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			super();
		}
	}
}
