package game.module.map.animalManagers
{
	import flash.utils.Dictionary;
	import game.core.user.UserData;
	import game.module.map.CurrentMapData;
	import game.module.map.MapSystem;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.utils.MapUtil;
	import game.module.map.utils.PlayerModelUtil;
	import game.module.mapConvoy.ConvoyController;
	import game.module.mapFeast.FeastController;
	import game.module.mapFishing.FishingController;
	import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
	import game.net.data.StoC.SCAvatarInfoChange;
	import game.net.data.StoC.SCMultiAvatarInfoChange;
	import game.net.data.StoC.SCMultiAvatarInfoChange.AvatarInfoChange;


	/**
	 * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-12   ����8:30:02 
	 */
	public class GlobalPlayerManager
	{
		public function GlobalPlayerManager(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : GlobalPlayerManager;

		/** 获取单例对像 */
		static public function get instance() : GlobalPlayerManager
		{
			if (_instance == null)
			{
				_instance = new GlobalPlayerManager(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 玩家字典,存入PlayerStruct以playerId为键值 */
		protected var playerDic : Dictionary = new Dictionary();

		/** 自己玩家ID */
		public function get selfPlayerId() : int
		{
			return UserData.instance.playerId;
		}

		public function get selfPlayer() : SelfPlayerStruct
		{
			return CurrentMapData.instance.selfPlayerStruct;
		}

		/** 加入玩家 */
		public function addPlayer(playerStruct : PlayerStruct) : PlayerStruct
		{
			if (playerStruct == null) return null;
			if (playerDic[playerStruct.id] == null)
			{
				playerDic[playerStruct.id] = playerStruct;
			}
			else if (playerDic[playerStruct.id] != playerStruct)
			{
				var oldPlayerStruct : PlayerStruct = playerDic[playerStruct.id];
				oldPlayerStruct.mirror(playerStruct);
				playerStruct = oldPlayerStruct;
			}
			return playerStruct;
		}

		/** 移除玩家 */
		public function removePlayer(playerId : uint) : PlayerStruct
		{
			var playerStruct : PlayerStruct = playerDic[playerId];
			delete playerDic[playerId];
			return playerStruct;
		}

		/** 获取玩家 */
		public function getPlayer(playerId : uint) : PlayerStruct
		{
			if (playerId == selfPlayerId) return CurrentMapData.instance.selfPlayerStruct;
			return playerDic[playerId];
		}

		/** 玩家Avatar信息 */
		public function playerAvatarInfo(msg : PlayerAvatar) : void
		{
			var playerStruct : PlayerStruct = getPlayer(msg.id);
			if (playerStruct == null) return;
			// var preModel : int = playerStruct.model;
			playerStruct.mergeSCAvatarInfo(msg);
			if ( enterModel(playerStruct) )
			{
				if ( updateCloth(playerStruct) )
				{
					MapSystem.initPlayerAvatar(playerStruct);
				}
			}
			// MapSystem.initPlayerAvatar(playerStruct);
			// palyerUpdateModel(msg.model, preModel, playerStruct);
		}

		/** 玩家avatar信息改变 */
		public function playerAvatarInfoChange(msg : SCAvatarInfoChange) : void
		{
			var playerStruct : PlayerStruct = getPlayer(msg.id);
			if (playerStruct == null) return;
			// 玩家model有变化
			var precloth : int = playerStruct.cloth ;
			var premodel : int = playerStruct.model ;
			var update : Boolean = true ;
			playerStruct.mergeSCAvatarInfoChange(msg);

			if ( playerStruct.model != premodel )
			{
				leaveModel(playerStruct, premodel);
				update = enterModel(playerStruct);
			}

			if (update)
			{
				if ( precloth != playerStruct.cloth || premodel != playerStruct.model )
				{
					// 各模块cloth改变的特殊操作
					update = updateCloth(playerStruct);
					if ( update )
					{
						MapSystem.updateAvatar(playerStruct.id);
					}
				}
			}

			// var preModel : int = playerStruct.model;
			// playerStruct.mergeSCAvatarInfoChange(msg);
			// MapSystem.updateAvatar(msg);
			//			
			//
//			 if (msg.hasModel)
//			 {
//			 palyerUpdateModel(msg.model, preModel, playerStruct);
//			 }
		}

		/** 玩家动物安装更新AVATAR */
		public function playerAnimalInstall(playerId : int) : void
		{
			var playerStruct : PlayerStruct = getPlayer(playerId);
			if (playerStruct == null) return;
			// palyerUpdateModel(playerStruct.model,0, playerStruct);
			
			if ( PlayerModelUtil.isFishing(playerStruct.model) )
			{
				FishingController.instance.checkPlayer(playerStruct);
			}
		}

		// public function palyerUpdateModel(model : int, preModel : int, playerStruct : PlayerStruct) : void
		// {
		// if (playerStruct == null) return;
		//            //  如果进入主城市
		// if (MapUtil.isMainMap() == true)
		// {
		// if(PlayerModelUtil.isNormal(model) && model == preModel) return;
		//                //  正常
		// if (PlayerModelUtil.isNormal(model) == true)
		// {
		//                    //  如果之前是龟拜
		// if (PlayerModelUtil.isConvory(preModel) == true)
		// {
		// convoyController.checkPlayer(playerStruct);
		// }
		//                    //  如果之前是钓鱼
		// else if (PlayerModelUtil.isFishing(preModel) == true)
		// {
		// FishingController.instance.checkPlayer(playerStruct);
		// }
		// }
		//                //  龟拜
		// else if (PlayerModelUtil.isConvory(model) == true)
		// {
		// convoyController.checkPlayer(playerStruct);
		// }
		//                //  钓鱼
		// else if (PlayerModelUtil.isFishing(model) == true)
		// {
		// FishingController.instance.checkPlayer(playerStruct);
		// }
		//
		//				//  加入宴会
		// if( PlayerModelUtil.isFeastState(model) && !PlayerModelUtil.isFeastState(preModel) )
		// {
		// FeastController.instance.playerEnter(playerStruct.id);
		// }
		//				//  离开宴会
		// else if( !PlayerModelUtil.isFeastState(model) && PlayerModelUtil.isFeastState(preModel) )
		// {
		// FeastController.instance.playerLeave(playerStruct.id);
		// if( PlayerManager.instance.getPlayer(playerStruct.id) != null || playerStruct.id == UserData.instance.playerId )
		// FeastController.instance.playerSingle(playerStruct);
		// }
		//
		// if( PlayerModelUtil.isFeastSingle(model) )
		// {
		//					//  有玩家变成single,销毁feast,创建player
		// FeastController.instance.playerSingle(playerStruct);
		// return ;
		// }
		//				//  上线，或者交割的情况下不调用playerMatch
		// if( !PlayerModelUtil.isFeastPartner(preModel) && PlayerModelUtil.isFeastMatch(model) )
		// {
		//					//  玩家变成配对状态
		// FeastController.instance.playerMatch(playerStruct,model);
		// return ;
		// }
		//
		// if( PlayerModelUtil.isFeastPartner(model) )
		// {
		// FeastController.instance.playerPartner(playerStruct);
		// return ;
		// }
		//
		// //  /** 从宴会中离开 */
		// //  if( PlayerModelUtil.isFeastSingle(preModel) )
		// //  {
		// //  FeastController.instance.playerLeave( playerStruct.id );
		// //  }
		// //
		// //  /** 加入宴会 */
		// //  if( PlayerModelUtil.isFeast(model) )
		// //  {
		// //  FeastController.instance.playerEnter( playerStruct.id );
		// //  }
		//
		//
		//
		// }
		// }
		public function prePlayerInteract(msg : SCMultiAvatarInfoChange) : Boolean
		{
			switch( msg.reason )
			{
				case 1:
					// 成功配对
					{
						if ( msg.changes.length != 2 )
							break ;
						if ( msg.changes[0].id == UserData.instance.playerId )
							FeastController.instance.selfPartner = msg.changes[1].id ;
						else if ( msg.changes[1].id == UserData.instance.playerId )
							FeastController.instance.selfPartner = msg.changes[0].id ;
					}
					break ;
				case 2:
					{
						if ( msg.changes.length != 2 )
							break ;
						if ( PlayerModelUtil.isFeastMatch(msg.changes[0].model) )
							FeastController.instance.changeMaster(msg.changes[1].id, msg.changes[0].id);
						else if ( PlayerModelUtil.isFeastMatch(msg.changes[1].model) )
							FeastController.instance.changeMaster(msg.changes[0].id, msg.changes[1].id);
						return false ;
					}
					break ;
				default:
					break ;
			}
			return true ;
		}

		public function postPlayerInteract(msg : SCMultiAvatarInfoChange) : void
		{
		}

		public function leaveModel(struct : PlayerStruct, preModel : int) : void
		{
			if ( PlayerModelUtil.isFeastMatchMember(preModel) && !PlayerModelUtil.isFeastMatchMember(struct.model) )
			{
				FeastController.instance.playerSingle(struct);
			}

			if( PlayerModelUtil.isFeastState(preModel) && !PlayerModelUtil.isFeastState(struct.model) )
			{
				FeastController.instance.playerLeave(struct.id);
			}
			// 如果之前是龟拜
			if (PlayerModelUtil.isConvory(preModel) && !PlayerModelUtil.isConvory(struct.model))
			{
				convoyController.checkPlayer(struct);
			}
			// 如果之前是钓鱼
			else if (PlayerModelUtil.isFishing(preModel) && !PlayerModelUtil.isFishing(struct.model))
			{
				FishingController.instance.checkPlayer(struct);
			}
		}

		public function updateCloth(struct : PlayerStruct) : Boolean
		{
			return true ;
		}

		public function getAvatarCloth(struct : PlayerStruct) : int
		{
			return struct.cloth ;
		}

		// 初始化其他玩家的avatar
		public function enterModel(struct : PlayerStruct) : Boolean
		{
			if ( MapUtil.isFeastMap() )
			{
				// model是在派对配对中
				if ( PlayerModelUtil.isFeastMatch(struct.model) )
				{
					FeastController.instance.playerMatch(struct);
					return false ;
				}
				if ( PlayerModelUtil.isFeastPartner(struct.model) )
				{
					FeastController.instance.playerPartner(struct);
					return false ;
				}
			}
			else if( MapUtil.isMainMap() )
			{
				if ( PlayerModelUtil.isConvory(struct.model) )
				{
					convoyController.checkPlayer(struct);
				}
				if ( PlayerModelUtil.isFishing(struct.model) )
				{
					FishingController.instance.checkPlayer(struct);
				}
			}
			return true ;
		}

		public function multipleAvatarInfoChange(msg : SCMultiAvatarInfoChange) : void
		{
			var struct : PlayerStruct ;
			var precloth : int ;
			var premodel : int ;
			var cloth : int ;
			if ( !prePlayerInteract(msg) )
				return  ;
			for each ( var chg:AvatarInfoChange in msg.changes )
			{
				struct = getPlayer(chg.id);
				if ( struct == null ) continue ;

				// 玩家model有变化
				precloth = struct.cloth ;
				premodel = struct.model ;
				var update : Boolean = true ;
				cloth = 0 ;
				struct.mergeAvatarInfoChange(chg);

				if ( struct.model != premodel )
				{
					leaveModel(struct, premodel);
					update = enterModel(struct);
				}

				if (update )
				{
					if ( precloth != struct.cloth || premodel != struct.model )
					{
						// 各模块cloth改变的特殊操作
						update = updateCloth(struct);
						if ( update )
						{
							MapSystem.updateAvatar(struct.id);
						}
					}
				}
			}
			postPlayerInteract(msg);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 龟仙拜佛控制器 */
		private var convoyController : ConvoyController = ConvoyController.instance;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
	}
}
class Singleton
{
}
