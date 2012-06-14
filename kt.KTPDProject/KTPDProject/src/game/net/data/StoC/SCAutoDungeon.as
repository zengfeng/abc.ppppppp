package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x82
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCAutoDungeon extends com.protobuf.Message {
		 /**
		  *@dungeonId   dungeonId
		  **/
		public var dungeonId:uint;

		 /**
		  *@countLeft   countLeft
		  **/
		public var countLeft:uint;

		 /**
		  *@stage   stage
		  **/
		public var stage:uint;

		 /**
		  *@result   result
		  **/
		public var result:uint;

		 /**
		  *@items   items
		  **/
		public var items:Vector.<uint> = new Vector.<uint>();

		 /**
		  *@exp   exp
		  **/
		private var exp$field:uint;

		private var hasField$0:uint = 0;

		public function removeExp():void {
			hasField$0 &= 0xfffffffe;
			exp$field = new uint();
		}

		public function get hasExp():Boolean {
			return (hasField$0 & 0x1) != 0;
		}

		public function set exp(value:uint):void {
			hasField$0 |= 0x1;
			exp$field = value;
		}

		public function get exp():uint {
			return exp$field;
		}

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var dungeonId$count:uint = 0;
			var countLeft$count:uint = 0;
			var stage$count:uint = 0;
			var result$count:uint = 0;
			items = new Vector.<uint>();

			var exp$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (dungeonId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCAutoDungeon.dungeonId cannot be set twice.');
					}
					++dungeonId$count;
					dungeonId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (countLeft$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCAutoDungeon.countLeft cannot be set twice.');
					}
					++countLeft$count;
					countLeft = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 3:
					if (stage$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCAutoDungeon.stage cannot be set twice.');
					}
					++stage$count;
					stage = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 4:
					if (result$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCAutoDungeon.result cannot be set twice.');
					}
					++result$count;
					result = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 5:
					if ((tag & 7) == com.protobuf.WireType.LENGTH_DELIMITED) {
						com.protobuf.ReadUtils.readPackedRepeated(input, com.protobuf.ReadUtils.read$TYPE_UINT32, items);
						break;
					}
					items.push(com.protobuf.ReadUtils.read$TYPE_UINT32(input));
					break;
				case 6:
					if (exp$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCAutoDungeon.exp cannot be set twice.');
					}
					++exp$count;
					exp = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
