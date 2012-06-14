package game.core.avatar {
	import game.core.user.UserData;
	import game.module.bossWar.BossWarSystem;
	import game.module.map.MapSystem;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * @author yangyiqiang
	 */
	public class AvatarPlayer extends AvatarThumb {
		/**					|
		 * 					5
		 * 					|
		 * ------------------------------------
		 * 				   /|\2
		 * 				  / 1 \
		 */
		private var _direction : int = 1;

		private function toDirection(angle : Number, isRun : Boolean = false) : void {
			if (_model == 0)
				changeModel(AvatarType.PLAYER_RUN);
			if (angle < 0) {
				angle += 360;
			}
			if (angle >= 337.5 || angle < 22.5) {
				_direction = 3;
				player.flipH = false;
			} else if (angle >= 22.5 && angle < 67.5) {
				_direction = 2;
				player.flipH = false;
			} else if (angle >= 67.5 && angle < 112.5) {
				_direction = 1;
				player.flipH = false;
			} else if (angle >= 112.5 && angle < 157.5) {
				_direction = 2;
				player.flipH = true;
			} else if (angle >= 157.5 && angle < 202.5) {
				_direction = 3;
				player.flipH = true;
			} else if (angle >= 202.5 && angle < 247.5) {
				_direction = 4;
				player.flipH = true;
			} else if (angle >= 247.5 && angle < 292.5) {
				_direction = 5;
				player.flipH = false;
			} else if (angle >= 292.5 && angle < 337.5) {
				_direction = 4;
				player.flipH = false;
			}
			if (_seat) {
				_seat.player.flipH = player.scaleX == -1 ? true : false;
				_seat.setAction(_direction);
				setAction(_direction);
			} else {
				setAction(isRun ? (_direction + 5) : _direction);
			}
		}

		override public function run(goX : int, goY : int, targetX : int, targetY : int) : void {
			var x_distance : Number = goX - targetX;
			var y_distance : Number = goY - targetY;

			var angle : Number = Math.atan2(y_distance, x_distance) * 180 / Math.PI;
			toDirection(angle, true);
		}

		override public function standDirection(targetX : int, targetY : int, x : int = 0, y : int = 0) : void {
			if (x == 0 && y == 0) {
				x = this.x;
				y = this.y;
			}
			var x_distance : Number = targetX - x;
			var y_distance : Number = targetY - y;

			var angle : Number = Math.atan2(y_distance, x_distance) * 180 / Math.PI;
			toDirection(angle);
		}

		override protected function changeType(value : int) : Boolean {
			if (super.changeType(value)) {
				if (value == 0) {
					this.scaleX = 1;
					this.scaleY = 1;
				} else {
					this.scaleX = 0.9;
					this.scaleY = 0.9;
				}
				return true;
			}
			return false;
		}

		override protected function updateDisplays() : void {
			if (!_avatarBd) return;
			if (_action == AvatarManager.PRACTICE) {
				_nameBitMap.x = _avatarBd.topX;
				return;
			}
			_lastY = _avatarBd.topY + 10;
			if (_seat) _lastY = _lastY + _seat.avatarBd.topY;
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

		private var _seat : AvatarSeat;

		override public function addSeat(seatId : int) : void {
			if (_seat) AvatarManager.instance.removeAvatar(_seat);
			_seat = AvatarManager.instance.getAvatar(seatId, AvatarType.SEAT_TYPE) as AvatarSeat;
			_seat.avatarBd.addEventListener(Event.COMPLETE, onComplete);
			addChild(_seat);
			player.y = _seat.avatarBd.topY;
			super.addChild(player);
			updateDisplays();
		}

		private function onComplete(event : Event) : void {
			if (_seat) {
				_seat.avatarBd.removeEventListener(Event.COMPLETE, onComplete);
				player.y = _seat.avatarBd.topY;
			}
			updateDisplays();
		}

		override public function removeSeat() : void {
			if (_seat) {
				AvatarManager.instance.removeAvatar(_seat);
				if (_seat.parent) _seat.parent.removeChild(_seat);
			}
			_seat = null;
			player.x = 0;
			player.y = 0;
			updateDisplays();
		}

		/** 站立 */
		override  public function stand() : void {
			if (_model != AvatarType.CHANGE_AVATAR)
				changeModel(AvatarType.PLAYER_RUN);
			setAction(_direction);
		}

		override public function setAction(value : int, loop : int = 0, index : int = -1, arr : Array = null) : void {
			if (value == AvatarManager.PRACTICE&&_avatarBd) {
				_nameBitMap.y = Math.abs(_avatarBd.topY) / 4 * -3 + 10;
			} else if (_action == AvatarManager.PRACTICE) {
				super.setAction(value, loop, index, arr);
				updateDisplays();
				return;
			}
			super.setAction(value, loop, index, arr);
		}

		override protected function onMouseClick(event : MouseEvent) : void {
			if (MapSystem.enSelectOtherPlayer == false) return;
			if (_name == UserData.instance.playerName || BossWarSystem.isJoin)
				return;
			if (player.getBitMap().bitmapData && player.getBitMap().bitmapData.hitTest(new Point(player.getBitMap().x, player.getBitMap().y), 255, AvatarManager.hitTest, new Point(event.localX, event.localY))) {
				super.onMouseClick(event);
				dispatchEvent(new Event("clickPlayer", true));
				event.stopPropagation();
			}
		}

		override protected function addShodow() : void {
			super.addShodow();
			_shodow.scaleX = 0.5;
			_shodow.scaleY = 0.5;
			_shodow.x = -29;
			_shodow.y = -12;
		}

		override protected function change(type : int = 1) : void {
			super.change(type);
			if (type == 0) {
				_shodow.scaleX = 1;
				_shodow.scaleY = 1;
				_shodow.x = -_shodow.width ;
				_shodow.y = -_shodow.height ;
			} else {
				_shodow.scaleX = 0.5;
				_shodow.scaleY = 0.5;
				_shodow.x = -29;
				_shodow.y = -12;
			}
		}

		private var _recoverList : Array = [];

		override public function addChild(obj : DisplayObject) : DisplayObject {
			_recoverList.push(obj);
			return super.addChild(obj);
		}

		override public function addChildAt(obj : DisplayObject, index : int) : DisplayObject {
			_recoverList.push(obj);
			return super.addChildAt(obj, index);
		}

		override internal function reset() : void {
			super.reset();
			for each (var obj:DisplayObject in _recoverList) {
				if (obj && obj.parent) obj.parent.removeChild(obj);
			}
			_recoverList = [];
		}

		public function AvatarPlayer() {
			super();
		}
	}
}
