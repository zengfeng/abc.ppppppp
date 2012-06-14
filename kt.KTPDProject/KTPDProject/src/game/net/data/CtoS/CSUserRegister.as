package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x01
	 **/
	import com.protobuf.*;
	public dynamic final class CSUserRegister extends com.protobuf.Message {
		 /**
		  *@id   id
		  **/
		public var id:String;

		 /**
		  *@isMale   isMale
		  **/
		public var isMale:Boolean;

		 /**
		  *@job   job
		  **/
		public var job:uint;

		 /**
		  *@name   name
		  **/
		public var name:String;

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.LENGTH_DELIMITED, 1);
			com.protobuf.WriteUtils.write$TYPE_STRING(output, id);
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 2);
			com.protobuf.WriteUtils.write$TYPE_BOOL(output, isMale);
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 3);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, job);
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.LENGTH_DELIMITED, 4);
			com.protobuf.WriteUtils.write$TYPE_STRING(output, name);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
