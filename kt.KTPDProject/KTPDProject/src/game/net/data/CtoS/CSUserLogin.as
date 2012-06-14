package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x02
	 **/
	import com.protobuf.*;
	public dynamic final class CSUserLogin extends com.protobuf.Message {
		 /**
		  *@id   id
		  **/
		public var id:String;

		 /**
		  *@key   key
		  **/
		private var key$field:String;

		public function removeKey():void {
			key$field = null;
		}

		public function get hasKey():Boolean {
			return key$field != null;
		}

		public function set key(value:String):void {
			key$field = value;
		}

		public function get key():String {
			return key$field;
		}

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.LENGTH_DELIMITED, 1);
			com.protobuf.WriteUtils.write$TYPE_STRING(output, id);
			if (hasKey) {
				com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.LENGTH_DELIMITED, 2);
				com.protobuf.WriteUtils.write$TYPE_STRING(output, key$field);
			}
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
