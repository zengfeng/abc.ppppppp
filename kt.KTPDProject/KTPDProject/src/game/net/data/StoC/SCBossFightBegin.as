package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x2E0
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCBossFightBegin extends com.protobuf.Message {
		 /**
		  *@flag   flag
		  **/
		public var flag:uint;

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var flag$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (flag$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCBossFightBegin.flag cannot be set twice.');
					}
					++flag$count;
					flag = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
