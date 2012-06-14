package game.module.daily
{
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.manager.VersionManager;

	/**
	 * @author yangyiqiang
	 */
	public class VoCopy
	{
		public var id : int;

		public var name : String;

		public var level : int;

		public var dropString : String;

		public function pares(xml : XML) : void
		{
			id = xml.@id;
			name = xml.@name;
			dropString = xml.children();
			level = xml.@level;
		}

		public function getIcoUrl() : String
		{
			return VersionManager.instance.getUrl("assets/ico/daily/copy" + id + ".png");
		}

		public function execute() : void
		{
			MenuManager.getInstance().closeMenuView(MenuType.DAILY);
		}
	}
}
