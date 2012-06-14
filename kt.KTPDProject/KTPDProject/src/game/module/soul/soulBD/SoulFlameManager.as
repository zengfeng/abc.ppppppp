package game.module.soul.soulBD
{
	import bd.BDData;
	import bd.BDUnit;

	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;

	import com.utils.UrlUtils;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/**
	 * @author jian
	 */
	public class SoulFlameManager
	{
		// ===============================================================
		// Singleton
		// ===============================================================
		private static var __instance:SoulFlameManager;
		
		public static function get instance ():SoulFlameManager
		{
			if (!__instance)
				__instance = new SoulFlameManager();
			return __instance;
		}
		
		public function SoulFlameManager()
		{
			if (__instance)
				throw (Error("Singleton Error"));
			
			initiate();
		}
		
		// ===============================================================
		// Attribute
		// ===============================================================
		private var _flameBDs:Dictionary;
		
		// ===============================================================
		// Method
		// ===============================================================
		private function initiate ():void
		{
			_flameBDs = new Dictionary();
			parseFlameBD();
		}
		
		
		private function parseFlameBD ():void
		{
			var i:int= 0;
			var j:int =0;
			var loader:SWFLoader = RESManager.getLoader("soul_flame");
			if(!loader)return;
			
			var _source : BitmapData = new(loader.getClass("source")) as BitmapData;
			if (!_source) return;
			var text : String = (loader.getMovieClip("text")).getChildAt(0)["text"];
			var _xml : XML = new XML(text);
		
			var bottomX:Number = Number(_xml.attribute("bottomX"));
			var bottomY:Number = Number(_xml.attribute("bottomY"));
			for each (var xml:XML in _xml["frame"])
			{
				j = 0;
				var frames : Vector.<BDUnit > = new Vector.<BDUnit >;
				for each (var frame:XML in xml["item"])
				{
					var unit : BDUnit = new BDUnit();
					var rect : Rectangle = new Rectangle(frame. @ x,frame. @ y,frame. @ w,frame. @ h);
					var bds : BitmapData = new BitmapData(rect.width,rect.height,true,0);
					bds.copyPixels(_source,rect,new Point());
					unit.offset = new Point(int(frame.@offsetX) + bottomX,int(frame.@offsetY) + bottomY);
					unit.bds = bds;
					frames.push(unit);
					j++;
				}
				
				var flameID : uint = Number(String(xml.@name));
				addFlameBD(frames,flameID);
				
				i++;
			}
		}
		
		private function addFlameBD (frames:Vector.<BDUnit>, flameID:uint):void
		{
			_flameBDs[flameID] = new BDData(frames);
		}
		
		public function getFlameBD (flameID:uint):BDData
		{
			return _flameBDs[flameID];
		}
	}
}
