package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x84
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCOpenDungeon extends com.protobuf.Message {
		 /**
		  *@dungeonId   dungeonId
		  **/
		public var dungeonId:uint;

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var dungeonId$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 2:
					if (dungeonId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCOpenDungeon.dungeonId cannot be set twice.');
					}
					++dungeonId$count;
					dungeonId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
