package game.net.data.StoC {
	/**
	 * Server to Client 协议号0xD2
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCConvoyInfoRes extends com.protobuf.Message {
		 /**
		  *@playerId   playerId
		  **/
		public var playerId:uint;

		 /**
		  *@quality   quality
		  **/
		public var quality:uint;

		 /**
		  *@robHonor   robHonor
		  **/
		public var robHonor:uint;

		 /**
		  *@robSilver   robSilver
		  **/
		public var robSilver:uint;

		 /**
		  *@beRobNum   beRobNum
		  **/
		public var beRobNum:uint;

		 /**
		  *@robNum   robNum
		  **/
		private var robNum$field:uint;

		private var hasField$0:uint = 0;

		public function removeRobNum():void {
			hasField$0 &= 0xfffffffe;
			robNum$field = new uint();
		}

		public function get hasRobNum():Boolean {
			return (hasField$0 & 0x1) != 0;
		}

		public function set robNum(value:uint):void {
			hasField$0 |= 0x1;
			robNum$field = value;
		}

		public function get robNum():uint {
			return robNum$field;
		}

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var playerId$count:uint = 0;
			var quality$count:uint = 0;
			var robHonor$count:uint = 0;
			var robSilver$count:uint = 0;
			var beRobNum$count:uint = 0;
			var robNum$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (playerId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCConvoyInfoRes.playerId cannot be set twice.');
					}
					++playerId$count;
					playerId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (quality$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCConvoyInfoRes.quality cannot be set twice.');
					}
					++quality$count;
					quality = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 3:
					if (robHonor$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCConvoyInfoRes.robHonor cannot be set twice.');
					}
					++robHonor$count;
					robHonor = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 4:
					if (robSilver$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCConvoyInfoRes.robSilver cannot be set twice.');
					}
					++robSilver$count;
					robSilver = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 5:
					if (beRobNum$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCConvoyInfoRes.beRobNum cannot be set twice.');
					}
					++beRobNum$count;
					beRobNum = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 6:
					if (robNum$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCConvoyInfoRes.robNum cannot be set twice.');
					}
					++robNum$count;
					robNum = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
