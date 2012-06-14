package game.core.avatar
{
	import com.utils.UrlUtils;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import game.manager.RSSManager;
	import game.module.quest.VoBase;
	import game.module.quest.VoNpc;
	import log4a.Logger;
	import net.LibData;
	import net.RESManager;





	/**
	 * @author yangyiqiang
	 */
	public class PerformerAvatar extends AvatarThumb
	{
		public function PerformerAvatar()
		{
			super();
		}

		private var _npcVo :VoNpc;

		public function setId(value : int) : void
		{
			_npcVo = RSSManager.getInstance().getNpcById(value);
			if (!_npcVo)
			{
				Logger.debug("PerformerAvatar中value= " + value + " 的npc或者怪物没找到!");
				return;
			}
			checkStyle();
			updateDisplays();
		}

		override protected function change(type : int = 1) : void
		{
		}

		override protected function addShodow() : void
		{
		}

		private var _isMc : Boolean = false;

		override public function setAction(value : int, loop : int = 0, index : int = 0, arr : Array = null) : void
		{
			if (_isMc)
			{
				if (_mc)
					_mc.gotoAndPlay(1);
				return;
			}
			super.setAction(value, _isOne ? 1 : loop, index, arr);
		}

		public function changeAction() : void
		{
			if (!_npcVo || !(_npcVo is VoNpc)) return;
			if (!this.avatarBd) return;
			if (this.avatarBd.getAvatarFrame(AvatarNpc.NPC_STAND) && this.avatarBd.getAvatarFrame(AvatarNpc.NPC_ACTION) == null) return;
			if (_action == AvatarNpc.NPC_ACTION) return;
			if (!AvatarManager.instance.getAvatarFrame(_uuid, _action)) return;
			this.setAction(AvatarNpc.NPC_ACTION, 1, 0);
			this.player.addEventListener(Event.COMPLETE, onCompletechange);
		}

		private function onCompletechange(event : Event) : void
		{
			this.player.removeEventListener(Event.COMPLETE, onCompletechange);
			this.setAction(AvatarNpc.NPC_STAND, 0);
		}

		private var _seat : AvatarThumb;

		override public  function addSeat(id : int) : void
		{
			if (!_seat)
			{
				_seat = AvatarManager.instance.getAvatar(id, AvatarType.NPC_TYPE);
			}
			_seat.avatarBd.addEventListener(Event.COMPLETE, onComplete);
			addChild(_seat);
			player.y = _seat.avatarBd.topY - 10;
			player.x = -10;
			addChild(player);
			updateDisplays();
		}

		private function onComplete(event : Event) : void
		{
			_seat.avatarBd.removeEventListener(Event.COMPLETE, onComplete);
			player.y = _seat.avatarBd.topY;
			updateDisplays();
		}

		override public  function removeSeat() : void
		{
			updateDisplays();
		}

		override protected function updateDisplays() : void
		{
			if (!_avatarBd) return;
			_lastY = _avatarBd.topY + 10;
			if (_seat) _lastY = _lastY + _seat.avatarBd.topY;
			if (_progressBar)
			{
				_progressBar.x = -33;
				_progressBar.y = _lastY;
				_lastY -= 20;
			}
			_nameBitMap.x = _avatarBd.topX;
			_nameBitMap.y = _lastY;
			_lastY -= 20;
			if (_clanBitMap)
			{
				_clanBitMap.x = _avatarBd.topX;
				_clanBitMap.y = _lastY;
				_lastY -= 20;
			}
			if (_stateObj)
			{
				_stateObj.x = -_stateObj.width / 2;
				_stateObj.y = _lastY ;
				_lastY -= 20;
			}
		}

		private var _mc : MovieClip;

		private var _isOne : Boolean = false;

		private function checkStyle() : void
		{
			_isOne = false;
			if (_npcVo is VoNpc)
			{
				setName(_npcVo.name);
				switch((_npcVo as VoNpc).type)
				{
					case 3:
						setName("");
						break;
					case 4:
						setName("");
						_mc = RESManager.getLoader(String(_uuid)) ? RESManager.getLoader(String(_uuid)).getContent() as MovieClip : null;
						if (!_mc)
						{
							RESManager.instance.load(new LibData(UrlUtils.getAvatar(_uuid), String(_uuid)), onComplete2);
							return;
						}
						this.addChild(_mc);
						_mc.scaleX = _npcVo.flipH ? -1 : 1;
						player.hide();
						this.scaleX = 1;
						this.scaleY = 1;
						_isMc = true;
						return;
					case 5:
						setName("");
						_isOne = true;
						break;
				}
				player.flipH = _npcVo.flipH;
				initAvatar(_npcVo.avatarId, AvatarType.NPC_TYPE);
				this.scaleX = 1;
				this.scaleY = 1;
				return;
			}
			else
			{
				initAvatar(_npcVo.avatarId, AvatarType.MONSTER_TYPE);
				this.scaleX = 0.8;
				this.scaleY = 0.8;
			}
			setName(_npcVo.name);
		}

		private function onComplete2() : void
		{
			_mc = RESManager.getLoader(String(_uuid)).getContent() as MovieClip;
			this.addChild(_mc);
			_mc.scaleX = _npcVo.flipH ? -1 : 1;
			player.hide();
			this.scaleX = 1;
			this.scaleY = 1;
			_isMc = true;
			// if (!_mc) return;
			// _mc.gotoAndPlay(1);
			// this.addChild(_mc);
		}

		override protected function onMouseClick(event : MouseEvent) : void
		{
		}

		override internal function reset() : void
		{
			super.reset();
			this.scaleX = 1;
			this.scaleY = 1;
			_isMc = false;
		}

		private function toDirection(angle : Number, isRun : Boolean = false) : void
		{
			if (angle < 0)
			{
				angle += 360;
			}
			if (angle >= 337.5 || angle < 22.5)
			{
				_direction = 3;
				player.flipH = false;
			}
			else if (angle >= 22.5 && angle < 67.5)
			{
				_direction = 2;
				player.flipH = false;
			}
			else if (angle >= 67.5 && angle < 112.5)
			{
				_direction = 1;
				player.flipH = false;
			}
			else if (angle >= 112.5 && angle < 157.5)
			{
				_direction = 2;
				player.flipH = true;
			}
			else if (angle >= 157.5 && angle < 202.5)
			{
				_direction = 3;
				player.flipH = true;
			}
			else if (angle >= 202.5 && angle < 247.5)
			{
				_direction = 4;
				player.flipH = true;
			}
			else if (angle >= 247.5 && angle < 292.5)
			{
				_direction = 5;
				player.flipH = false;
			}
			else if (angle >= 292.5 && angle < 337.5)
			{
				_direction = 4;
				player.flipH = false;
			}
			if (_seat)
			{
				_seat.player.flipH = player.scaleX == -1 ? true : false;
				_seat.setAction(_direction);
				setAction(_direction);
			}
			else
			{
				setAction(isRun ? (_direction + 5) : _direction);
			}
		}

		private var _direction : int = 0;

		override public function run(goX : int, goY : int, targetX : int, targetY : int) : void
		{
			var x_distance : Number = goX - targetX;
			var y_distance : Number = goY - targetY;

			var angle : Number = Math.atan2(y_distance, x_distance) * 180 / Math.PI;
			toDirection(angle, true);
		}

		override public function standDirection(targetX : int, targetY : int, x : int = 0, y : int = 0) : void
		{
			if (x == 0 && y == 0)
			{
				x = this.x;
				y = this.y;
			}
			var x_distance : Number = targetX - x;
			var y_distance : Number = targetY - y;

			var angle : Number = Math.atan2(y_distance, x_distance) * 180 / Math.PI;
			toDirection(angle);
		}
	}
}
