package game.module.duplMap {
	import game.core.user.UserData;

	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
	 */
	public class DuplUtil {
		public static function getDuplMapId(duplId : int, layerId : int) : int {
			return duplId + layerId;
		}

		public static function getDuplId(duplMapId : int) : int {
			return Math.floor(duplMapId / 100) * 100;
		}

		public static function getLayerId(duplMapId : int) : int {
			return duplMapId % 100;
		}

		public static function getParentMapId(duplMapId : int) : int {
			return Math.floor(duplMapId / 100);
		}

		public static function getInMapId(parentMapId : int) : int {
			return parentMapId * 100 + 1;
		}

		public static function getInMapIdByDuplMapId(duplMapId : int) : int {
			return getParentMapId(duplMapId) * 100 + 1;
		}

		public static function getDemonBossId(duplId : int, layerId : int) : int {
			var id : int = duplId / 10 + layerId / 2;
			return id;
		}

		public static function getDemonBossIdByDuplMapId(duplMapId : int) : int {
			var duplId : int = getDuplId(duplMapId);
			var layerId : int = getLayerId(duplMapId);
			var id : int = duplId / 10 + layerId / 2;
			return id;
		}

		public static function get hasEnoughPack() : Boolean {
			if (UserData.instance.tryPutPack(DuplConfig.MIN_PACK_EMPTY) <= 0) return false;
			return true;
		}
	}
}
