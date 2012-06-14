package game.net.data.StoC {
	/**
	 * Server to Client 协议号0xC3
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCGroupBattlePlayerUpdate extends com.protobuf.Message {
		 /**
		  *@playerId   playerId
		  **/
		public var playerId:uint;

		 /**
		  *@group   group
		  **/
		public var group:uint;

		 /**
		  *@playerSatus   playerSatus
		  **/
		public var playerSatus:uint;

		 /**
		  *@time   time
		  **/
		public var time:uint;

		 /**
		  *@playerId2   playerId2
		  **/
		private var playerId2$field:uint;

		private var hasField$0:uint = 0;

		public function removePlayerId2():void {
			hasField$0 &= 0xfffffffe;
			playerId2$field = new uint();
		}

		public function get hasPlayerId2():Boolean {
			return (hasField$0 & 0x1) != 0;
		}

		public function set playerId2(value:uint):void {
			hasField$0 |= 0x1;
			playerId2$field = value;
		}

		public function get playerId2():uint {
			return playerId2$field;
		}

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var playerId$count:uint = 0;
			var group$count:uint = 0;
			var playerSatus$count:uint = 0;
			var time$count:uint = 0;
			var playerId2$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (playerId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGroupBattlePlayerUpdate.playerId cannot be set twice.');
					}
					++playerId$count;
					playerId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (group$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGroupBattlePlayerUpdate.group cannot be set twice.');
					}
					++group$count;
					group = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 3:
					if (playerSatus$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGroupBattlePlayerUpdate.playerSatus cannot be set twice.');
					}
					++playerSatus$count;
					playerSatus = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 4:
					if (time$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGroupBattlePlayerUpdate.time cannot be set twice.');
					}
					++time$count;
					time = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 5:
					if (playerId2$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGroupBattlePlayerUpdate.playerId2 cannot be set twice.');
					}
					++playerId2$count;
					playerId2 = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
