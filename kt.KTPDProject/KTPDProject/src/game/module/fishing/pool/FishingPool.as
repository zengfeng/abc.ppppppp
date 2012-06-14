package game.module.fishing.pool
{
	import com.shortybmc.CSV;
	import flash.utils.Dictionary;
	import game.manager.RSSManager;
	import log4a.Logger;
	import utils.DictionaryUtil;




	/**
	 * @author jian
	 */
	public class FishingPool
	{
		// ===============================================================
		// 钓鱼池，用于管理其他钓鱼玩家的Avatar，
		// 保证最多显示N个玩家的Avatar
		// 玩家钓鱼位置：(C + D) % N
		// N：鱼池座位个数，NUM_CHAIRS
		// C：前一玩家的位置，(FIRST_POSITION)
		// D：当前位置增量，为一质数，与服务器约定，(DELTA_POSITION)
		// ===============================================================
		// ===============================================================
		// 单例
		// ===============================================================
		private static var __instance : FishingPool;

		public static function get instance() : FishingPool
		{
			if (!__instance)
				__instance = new FishingPool();

			return __instance;
		}

		public function FishingPool()
		{
			if (__instance)
				throw(Error("单例错误！"));

			initiate();
		}

		// ===============================================================
		// 属性
		// ===============================================================
		private var _chairs : Dictionary /* of FishingChairVO */;
		private var _index : uint = 0;

		// ===============================================================
		// 方法
		// ===============================================================
		private function initiate() : void
		{
			initiateChairs();
		}

		private function initiateChairs() : void
		{
			_chairs = new Dictionary();

			for each (var arr:Array in (RSSManager.getInstance().getData("fish_point", RSSManager.TYPE_CSV) as CSV).getData())
			{
				var chair : FishingChairVO = new FishingChairVO();
				chair.id = arr[0];
				chair.x = arr[1];
				chair.y = arr[2];
				chair.position = arr[3];

				_chairs[chair.x + "_" + chair.y] = chair;
			}

			RSSManager.getInstance().deleteData("fish_point", RSSManager.TYPE_CSV);
		}

		// public function takeChair(playerId : uint, onKicked : Function) : FishingChairVO
		// {
		// var chair : FishingChairVO = _chairs[_index];
		// _index++;
		//
		// if (chair.taken && chair.onKicked && !chair.onKicked())
		// {
		// return takeChair(playerId, onKicked);
		// }
		//
		// chair.taken = true;
		// chair.playerId = playerId;
		// chair.onKicked = onKicked;
		//
		// return chair.clone();
		// }
		public function returnChair(vo : FishingChairVO, playerId : uint) : void
		{
			var chair : FishingChairVO = _chairs[vo.x + "_" + vo.y];
			var index : int = -1;

			for each (var player:Object in chair.players)
			{
				if (player["id"] == playerId)
				{
					index++;
					break;
				}
				index++;
			}

			if (index < 0)
			{
				Logger.error("鱼塘returnChair错误，玩家" + playerId + "位置" + vo.x + " " + vo.y);
				return;
			}

			if (index == chair.players.length - 1 && index > 0)
			{
				chair.players[index - 1]["onSit"]();
			}

			chair.players.splice(index, 1);
		}

		public function takeChair(playerId : uint, onStand : Function, onSit : Function, x : int, y : int) : FishingChairVO
		{
			var chair : FishingChairVO = _chairs[x + "_" + y];
			if (!chair)
			{
				Logger.error("钓鱼，服务器发来错误钓鱼地点" + x + " " + y);
				return DictionaryUtil.getValues(_chairs)[0].clone();
			}
				
			var vo : FishingChairVO = chair.clone();
			
			var me : Object = {id:playerId, onStand:onStand, onSit:onSit};

			if (chair.players.length > 0)
			{
				var owner : Object = chair.players[chair.players.length - 1];

				if (owner["onStand"]())
				{
					chair.players.push(me);
					vo.usage = "sit";
				}
				else
				{
					chair.players[chair.players.length - 1] = me;
					chair.players.push(owner);
					vo.usage = "stand";
				}
			}
			else
			{
				chair.players.push(me);
				vo.usage = "sit";
			}

			return vo;
		}
	}
}
