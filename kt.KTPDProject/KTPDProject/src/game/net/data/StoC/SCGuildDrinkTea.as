package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x2D1
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCGuildDrinkTea extends com.protobuf.Message {
		 /**
		  *@sel   sel
		  **/
		public var sel:uint;

		 /**
		  *@tim   tim
		  **/
		private var tim$field:uint;

		private var hasField$0:uint = 0;

		public function removeTim():void {
			hasField$0 &= 0xfffffffe;
			tim$field = new uint();
		}

		public function get hasTim():Boolean {
			return (hasField$0 & 0x1) != 0;
		}

		public function set tim(value:uint):void {
			hasField$0 |= 0x1;
			tim$field = value;
		}

		public function get tim():uint {
			return tim$field;
		}

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var sel$count:uint = 0;
			var tim$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (sel$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGuildDrinkTea.sel cannot be set twice.');
					}
					++sel$count;
					sel = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (tim$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGuildDrinkTea.tim cannot be set twice.');
					}
					++tim$count;
					tim = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
