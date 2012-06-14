package game.core.avatar {
	import core.IDispose;

	import gameui.controls.BDPlayer;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;

	import utils.ObjectPool;

	import flash.display.Bitmap;
	import flash.events.Event;

	/**
	 * @author yangyiqiang
	 */
	public class AbstractAvatar extends GComponent implements IDispose {
		protected var _uuid : int;
		protected var _id : int;
		protected var _cloth : int;
		protected var _type : int;
		protected var _model : uint = 0;
		protected var _action : int = 1;
		protected var _avatarBd : AvatarBD;
		protected var _player : BDPlayer;
		protected var _shodow : Bitmap;

		private function setUUID(value : int) : void {
			if (_uuid == value) return;
			_uuid = value;
			if (_avatarBd) _avatarBd.release();
			_avatarBd = AvatarManager.instance.getAvatarBD(_uuid);
			this.player.setBDData(_avatarBd.bds);
			_avatarBd.addEventListener(Event.COMPLETE, initComplete);
			setAction(_action);
			updateDisplays();
		}

		// loop:0 循环播放  n:播放n遍
		public function setAction(value : int, loop : int = 0, index : int = -1, arr : Array = null) : void {
			if (value <= 0 || value > 22 || !_player) return;
			_action = value;
			var unit : AvatarUnit = AvatarManager.instance.getAvatarFrame(_uuid, _action);
			if (unit == null) {
				_player.play(80, arr, loop, index);
				if (_player.total < 2) change(0);
				else change();
				return;
			}
			_player.play(unit.timer, arr == null ? unit.avatars : arr, loop, index);
			change();
		}

		protected function changeType(type : int) :Boolean {
			_type = type == -1 ? _type : type;
			if (_model) return false;
			setUUID(AvatarManager.instance.getUUId(_id, _type, _cloth));
			return true;
		}

		public function changeCloth(cloth : int, id : int = -1, type : int = -1) : void {
			_cloth = cloth;
			_id = id == -1 ? _id : id;
			_type = type == -1 ? _type : type;
			if (_model) return;
			setUUID(AvatarManager.instance.getUUId(_id, _type, _cloth));
		}

		public function initAvatar(id : int, type : int = 0, cloth : int = 0) : void {
			_cloth = cloth;
			_id = id;
			_type = type;
			if (_model) return;
			setUUID(AvatarManager.instance.getUUId(_id, _type, _cloth));
		}
		
		public function initUUID(uuid:int):void
		{
			_cloth = (uuid&0xf00000)>>20;
			_id =uuid&0xfffff; 
			_type = (uuid&0xff000000)>>20;
			if (_model) return;
			setUUID(uuid);
		}

		// value=0 退出当前model状态
		public function changeModel(value : int = 0) : void {
			_model = value;
			if (_model == 0)
				setUUID(AvatarManager.instance.getUUId(_id, _type, _cloth));
			else
				setUUID(AvatarManager.instance.getUUId(_model, AvatarType.CHANGE_AVATAR));
		}

		public function playShowAction() : void {
		}

		public function get uuid() : int {
			return _uuid;
		}

		public function get player() : BDPlayer {
			return _player;
		}

		public function get avatarBd() : AvatarBD {
			return _avatarBd;
		}

		protected function initComplete(event : Event) : void {
			setAction(_action);
			if (_avatarBd)
				_avatarBd.removeEventListener(Event.COMPLETE, initComplete);
			updateDisplays();
			playShowAction();
			change();
		}

		protected function updateDisplays() : void {
		}

		protected function addShodow() : void {
			if (!_shodow) {
				_shodow = new Bitmap();
				_shodow.bitmapData = AvatarManager.instance.getShodow();
			}
			_shodow.x = -_shodow.width / 2;
			_shodow.y = -_shodow.height / 2;
			super.addChild(_shodow);
		}

		protected function change(type : int = 1) : void {
			if (type == 0) {
				if (_shodow.bitmapData == AvatarManager.instance.getCommonAvatar()) return;
				_shodow.bitmapData = AvatarManager.instance.getCommonAvatar();
				_shodow.x = -_shodow.width ;
				_shodow.y = -_shodow.height ;
			} else {
				if (_shodow.bitmapData == AvatarManager.instance.getShodow()) return;
				_shodow.bitmapData = AvatarManager.instance.getShodow();
				_shodow.x = -_shodow.width / 2;
				_shodow.y = -_shodow.height / 2;
			}
		}

		public function showShodow() : void {
			if (_shodow)
				_shodow.visible = true;
		}

		public function hideShodow() : void {
			if (_shodow)
				_shodow.visible = false;
		}

		override protected function create() : void {
			addShodow();
			var data : GComponentData = new GComponentData();
			_player = new BDPlayer(data);
			super.addChild(_player);
		}

		private function pause() : void {
			if (_player)
				_player.stop();
		}

		private  function resume() : void {
			setAction(_action);
		}

		override public function set visible(value : Boolean) : void {
			if (value) resume();
			else pause();
			super.visible = value;
		}

		override protected function onShow() : void {
			super.onShow();
			playShowAction();
		}

		override protected function onHide() : void {
			super.onHide();
		}

		internal function reset() : void {
			_player.frame = 0;
			this.scaleX = 1;
			this.scaleY = 1;
			this.alpha = 1;
			this.visible = true;
			this.filters = [];
			_id = 0;
			_cloth = 0;
			_type = 0;
			_model = 0;
			_action = 0;
		}

		/** 回收，放入ObjectPool */
		internal function callback() : void {
			reset();
			if (this.avatarBd) {
				this.avatarBd.release();
				_avatarBd = null;
			}
			ObjectPool.disposeObject(this);
		}

		public function dispose() : void {
			_player.dispose();
		}

		public function AbstractAvatar() {
			_base = new GComponentData();
			super(_base);
			this.cacheAsBitmap = true;
		}
	}
}
