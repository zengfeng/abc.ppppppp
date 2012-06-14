package game.module.artifact
{
	import com.utils.ColorUtils;
	import com.utils.StringUtils;
	import log4a.Logger;

	import flash.display.Bitmap;
	/**
	 * @author yangyiqiang
	 */
	public class ArtifactManage
	{
		private var _list : Vector.<VoArtifact> = new Vector.<VoArtifact>(20);

		public var numVec : Vector.<Bitmap> = new Vector.<Bitmap>();

		private static var _instance : ArtifactManage;

		/**
		 * 已经铸魂的次数  
		 */
		public var caseCount : int;

		/**
		 * 已经挑战的次数  
		 */
		public var battleCount : int;

		/**
		 * 铸魂的最高 次数  
		 */
		public var caseMax : int;

		public var result : int;

		public var critNum : int;
		
		public var lastExp:int;
		
		public var isBusy:Boolean=false;

		public static const FREE_BATTLE : int = 20;

		public static const FREE_CAST : int = 12;
		
		public function getCritNumString():String
		{
			if(critNum==0)return "";
			var num:int=0;
			if(caseCount>FREE_CAST)num=lastExp+1000;
			else num=lastExp+1000;
			return "连暴"+StringUtils.addColor(String(critNum),ColorUtils.HIGHLIGHT)+"次,下次暴击获得"+StringUtils.addColor(String(num),ColorUtils.HIGHLIGHT)+"经验";
		}

		public function ArtifactManage()
		{
			if (_instance)
				throw Error("ArtifactManage 是单类，不能多次初始化!");
		}

		public static function instance() : ArtifactManage
		{
			if (_instance == null)
				_instance = new ArtifactManage();
			return _instance;
		}

		public function initVo(vo : VoArtifact) : void
		{
			_list[vo.id - 1] = vo;
		}

		public function getVo(id : int) : VoArtifact
		{
			if(id>=20||id<=0){
				Logger.error("找不到ID="+id+" 的神器！");
				return null;
			}
			return _list[id - 1];
		}
		
		public function getVos():Vector.<VoArtifact>
		{
			return _list;
		}
	}
}
