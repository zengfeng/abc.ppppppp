package game.module.map.utils
{
	import game.module.map.animal.AnimalManager;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-16 ����12:07:45
     */
    public class PlayerModelUtil
    {
        /** 最小龟拜值 */
        public static const MIN_CONVORY:int = 1;
        /** 最大龟拜值 */
        public static const MAX_CONVORY:int = 10;
        /** 钓鱼 */
        public static const FISHING:int = 11;
        /** 修炼 */
        public static const PRACTICE:int = 20;
		/** 派对变身1 */
		public static const FEAST_MIN:int = 30;
		/** 派对变身6 */
		public static const FEAST_MAX:int = 35;
		/** 派对合体1 */
		public static const FEAST_MATCH_MIN:int = 40 ;
		/** 派对合体3 */
		public static const FEAST_MATCH_MAX:int = 42 ;
		/** 派对舞伴 */
		public static const FEAST_PARTNER:int = 45 ;
		
//		public static const feastArr:Array = [21,23,25,22,24,26];
		public static const feastArr:Array = [21,22];
        
        
		public static function isPractice(model:int):Boolean
		{
			return model == PRACTICE;
		}

		public static function isFeastSingle(model:int):Boolean
		{
			return model >= FEAST_MIN && model <= FEAST_MAX ;
		}
		
		public static function isFeastMatch(model:int):Boolean
		{
			return model >= FEAST_MATCH_MIN && model  <= FEAST_MATCH_MAX ;
		}
		
		public static function isFeastState(model:int):Boolean
		{
			return model >= FEAST_MIN && model <= FEAST_PARTNER ;
		}
		
		public static function isFeastMatchMember(model:int):Boolean
		{
			return model >= FEAST_MATCH_MIN && model <= FEAST_PARTNER ;
		}
		
		public static function feastSide( model:int ):Boolean
		{
			return model <= ( FEAST_MAX + FEAST_MIN ) / 2 ;
		}
		
		public static function isFeastPartner(model:int):Boolean
		{
			return model == FEAST_PARTNER ;
		}
		
        public static function isNormal(model:int):Boolean
        {
            return model == 0;
        }
        
        public static function isConvory(model:int):Boolean
        {
            return model >= MIN_CONVORY && model <= MAX_CONVORY;
        }
		
        public static function isFishing(model:int):Boolean
        {
            return model == FISHING;
        }
        
		public static function getAvatarCloth( model:int , cloth:int ):int
		{
			if( isFeastSingle(model) )
			{
				return feastArr[model-FEAST_MIN] as int ;
			}
			
			return cloth ;
		}
		
        
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private static var _animalManager:AnimalManager;
        private static function get animalManager():AnimalManager
        {
            if(_animalManager == null)
            {
                _animalManager = AnimalManager.instance;
            }
            return _animalManager;
        }
        
    }
}
