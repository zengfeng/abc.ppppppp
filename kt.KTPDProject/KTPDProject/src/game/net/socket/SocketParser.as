package game.net.socket {
	import com.protobuf.Message;
	import flash.utils.ByteArray;

	/**
	 * @author yangyiqiang
	 */
	internal final class SocketParser{
		
		public function readObject(style : int) : void {
			switch(style) {
			}
		}

		public static function writeObject(outBuffer : ByteArray,msgCmd:uint, obj : Object) : void {
			if (!outBuffer) return;
			var style : int = getStyle(obj);
			outBuffer.writeShort(msgCmd);
			switch(style) {
				case 1:
				try{
					Message(obj)?Message(obj).writeTo(outBuffer):0;
					break;
				}catch (e : Error){
				}
				break;
			}
		}

		private static function getStyle(obj : Object) : int {
			if(obj==null)return 0;
			if (obj is Message) {
				return 1;
			}else if(obj is int){
				return 2;
			}else if(obj is String){
				return 3;
			}
			return 0;
		}
	}
}
