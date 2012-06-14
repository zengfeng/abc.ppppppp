package game.module.rewardPackage
{
	import game.module.notification.ActionIcoMenu;
	import game.module.notification.ICOMenuManager;
	import game.module.notification.VoICOButton;
	import game.net.core.Common;
	import game.net.data.CtoS.CSGiftList;
	import game.net.data.CtoS.CSGiftTake;

	import flash.utils.Dictionary;
	/**
	 * @author zheng
	 */
	  
	  
	 
	public class GiftPackageManage
	{
		
	  /**********************************************************
	  * 定义
	  ********************************************************/
		private static var _instance : GiftPackageManage;
		
		private var _iocDic : Dictionary = new Dictionary();
		
	    private var _menu : ActionIcoMenu;
		
	    private var _giftList:Vector.<VoPackReward>=new Vector.<VoPackReward>();
		
		public function GiftPackageManage() : void
		{
			if (_instance)
			{
				throw Error("GiftPackageManage 是单类，不能多次初始化!");
			}		
			
			initiate();
		}
		
		public static function get instance() : GiftPackageManage
		{
			if (_instance == null)
			{
				_instance = new GiftPackageManage();
			}
			return _instance;
		}
		
		private function initiate() : void
		{
		//	Common.game_server.addCallback(0x70, updateGiftPanel);   //礼包列表
		//	Common.game_server.addCallback(0x72, ontest);   //礼包数量更新
		}
			   
		public static function sendResGift(id : int) : void
		{
			var cmd : CSGiftTake = new CSGiftTake();
		//	cmd.type = type;
		//	cmd.id = 0<<16|id;
		    cmd.id =id;
			Common.game_server.sendMessage(0x71, cmd);
		}
	   
	   private function getInfoByID(id:int):VoICOButton
	   {
		   var vo:VoICOButton;
	       vo=ICOMenuManager.getInstance().getIcoVo(id);
		   return vo;
	   }
	   
	   public function sendReqListMsg():void
	   {
		 var cmd:CSGiftList=new CSGiftList();
		 Common.game_server.sendMessage(0x70, cmd);
	   }
		
	}
}
