package game.module.role
{
	import gameui.manager.UIManager;
	/**
	 * @author yang
	 */
	public class RoleSystem {
		private static var createRole : CreateRole;

		/** 创建角色  */
		public static function  initCreateRole() : void {
			createRole = new CreateRole(null);
			UIManager.root.addChild(createRole);
		}
	}
}
