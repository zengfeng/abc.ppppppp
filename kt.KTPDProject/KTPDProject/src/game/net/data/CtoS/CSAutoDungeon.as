package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x82
	 **/
	import com.protobuf.*;
	public dynamic final class CSAutoDungeon extends com.protobuf.Message {
		 /**
		  *@dungeonId   dungeonId
		  **/
		public var dungeonId:uint;

		 /**
		  *@start   start
		  **/
		public var start:Boolean;

		 /**
		  *@count   count
		  **/
		public var count:uint;

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 1);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, dungeonId);
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 2);
			com.protobuf.WriteUtils.write$TYPE_BOOL(output, start);
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 3);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, count);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
