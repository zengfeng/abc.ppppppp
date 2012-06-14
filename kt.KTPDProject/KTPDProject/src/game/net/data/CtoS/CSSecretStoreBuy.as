package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x1CA
	 **/
	import com.protobuf.*;
	public dynamic final class CSSecretStoreBuy extends com.protobuf.Message {
		 /**
		  *@itemPos   itemPos
		  **/
		public var itemPos:uint;

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 1);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, itemPos);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
