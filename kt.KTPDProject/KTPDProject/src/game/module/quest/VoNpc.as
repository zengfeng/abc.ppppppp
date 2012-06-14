package game.module.quest {
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarType;
	import game.manager.VersionManager;

	import log4a.Logger;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author yangyiqiang
	 */
	public final class VoNpc extends VoBase {
		/**
		 *  类型 
		 *  1:普通类型
		 *  2:不显示名字及avatar
		 *  3:不显示名字
		 */
		public var type : int;
		public var mapId : int;
		public var x : int;
		public var y : int;
		/** halfId 半身像ID **/
		public var halfId : int;
		public var flipH : Boolean = false;
		public var isHit : Boolean = false;
		public var hasAvatar : Boolean = false;
		public var defaultDialog : String = "默认对话!";
		private var counter : int = 0;

		public function get helfUrl() : String {
			return VersionManager.instance.getUrl("assets/avatar/halfBody/" + halfId + ".png");
		}

		override public function get avatarUrl() : String {
			return id < 4000 ? VersionManager.instance.getUrl("assets/avatar/" + AvatarManager.instance.getUUId(avatarId, AvatarType.NPC_TYPE) + ".swf") : VersionManager.instance.getUrl("assets/avatar/" + AvatarManager.instance.getUUId(avatarId, AvatarType.MONSTER_TYPE) + ".swf");
		}

		public function parse(arr : Array) : void {
			if (!arr) return;
			id = arr[counter++];
			name = arr.length > counter ? arr[counter++] : "";
			type = arr.length > counter ? arr[counter++] : 0;
			headImg = arr.length > counter ? arr[counter++] : 0;
			mapId = arr.length > counter ? arr[counter++] : 0;
			avatarId = arr.length > counter ? arr[counter++] : 0;
			avatarId = avatarId <= 0 ? id : avatarId;
			halfId = arr.length > counter ? arr[counter++] : 10;
			defaultDialog = arr.length > counter ? arr[counter++] : "";
			flipH = arr.length > counter ? (int(arr[counter++]) == 1 ? true : false) : false;
			counter += 3;
			isHit = arr.length > counter ? (int(arr[counter++]) == 1 ? true : false) : false;
			hasAvatar = arr.length > counter ? (int(arr[counter++]) == 1 ? true : false) : false;
		}

		private var _stateDic : Dictionary;
		private var _questState : int = 0;

		public function setQuestState(questId : int, state : int = 0) : void {
			if (!_stateDic) _stateDic = new Dictionary();
			_stateDic[questId] = state;
			reset();
		}

		/**
		 * 0:NOTHING
		 * 1:CAN_ACCEPT
		 */
		public function get questState() : int {
			return _questState;
		}

		public function reset() : void {
			if (!_stateDic) return;
			var num : int;
			for each (var state:int in _stateDic) {
				num += state;
			}
			_questState = num > 0 ? 1 : 0;
			dispatchEvent(new Event("refresh"));
			Logger.info("id===>" + id, "_questState===>" + _questState);
		}
	}
}
