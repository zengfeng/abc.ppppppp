package game.module.tasteTea
{
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.module.guild.GuildManager;

	/**
	 * @author Lv
	 */
	public class TasteTeaControl {
		
		private static var _instance :TasteTeaControl;
		
		public function TasteTeaControl(control:Control):void{
			control;
		}
		public static function get instance():TasteTeaControl{
			if(_instance == null){
				_instance = new TasteTeaControl(new Control());
			}
			return _instance;
		}
		
		private var teaUI:TastePanel;
		public function setupUI():void{
			//判断家族等级不够
			if(!teaUI){
				
				teaUI = new TastePanel();
				MenuManager.getInstance().getMenuButton(MenuType.TASTTEA).target=teaUI;
			}
			MenuManager.getInstance().changMenu(MenuType.TASTTEA);
			var num:int = GuildManager.instance.actiondata[2].personalremain;
			if(num == 0){
				enableTastTeaBtn();
			}
		}
		//品茶按钮不可以用
		public function enableTastTeaBtn():void{
			teaUI.EnableTastTea();
		}
	}
}
class Control{}
