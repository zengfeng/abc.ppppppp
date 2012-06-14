package game.module.quest {
	import game.manager.VersionManager;

	import flash.events.EventDispatcher;

	/**
	 * @author yangyiqiang
	 */
	public class VoBase extends EventDispatcher {
		public var id : int;
		public var name : String;
		public var headImg : int;
		public var avatarId : int;
		public function get avatarUrl() : String {
			return "";
		}

		public function get helfIocUrl() : String {
			return VersionManager.instance.getUrl("assets/ico/halfBody/" + headImg + ".png");
		}
	}
}
