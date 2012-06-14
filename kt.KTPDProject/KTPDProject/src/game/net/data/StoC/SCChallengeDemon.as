package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x89
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCChallengeDemon extends com.protobuf.Message {
		 /**
		  *@demonId   demonId
		  **/
		public var demonId:uint;

		 /**
		  *@result   result
		  **/
		public var result:Boolean;

		 /**
		  *@counted   counted
		  **/
		public var counted:Boolean;

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var demonId$count:uint = 0;
			var result$count:uint = 0;
			var counted$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (demonId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCChallengeDemon.demonId cannot be set twice.');
					}
					++demonId$count;
					demonId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (result$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCChallengeDemon.result cannot be set twice.');
					}
					++result$count;
					result = com.protobuf.ReadUtils.read$TYPE_BOOL(input);
					break;
				case 3:
					if (counted$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCChallengeDemon.counted cannot be set twice.');
					}
					++counted$count;
					counted = com.protobuf.ReadUtils.read$TYPE_BOOL(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
