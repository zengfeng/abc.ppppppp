package game.module.duplMap
{
    import flash.utils.Dictionary;
    import game.core.user.UserData;
    import game.manager.SignalBusManager;
    import game.module.quest.QuestManager;


    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
     */
    public class DuplOpened
    {
        /** key=duplId, val=layerId*/
        private static var _dic : Dictionary;

        public static function get dic() : Dictionary
        {
            if (_dic == null)
            {
                _dic = new Dictionary();
                var length : int = UserData.instance.dungeonOpened.length;
				var duplId : int;
				var layerId : int;
                for (var i : int = 0; i < length; i++)
                {
                    var duplMapId : int = UserData.instance.dungeonOpened[i];
					if(duplMapId >= 100)
					{
	                    duplId = DuplUtil.getDuplId(duplMapId);
	                    layerId = DuplUtil.getLayerId(duplMapId);
	                    if (_dic[duplId] == null || _dic[duplId] < layerId)
	                    {
	                        _dic[duplId] = layerId;
	                    }
					}
					else if(duplMapId >= 10 && duplMapId < 100)
					{
						duplId = Math.floor(duplMapId / 10) * 10;
	                    layerId = duplMapId % 10;
	                    if (_dic[duplId] == null || _dic[duplId] < layerId)
	                    {
	                        _dic[duplId] = layerId;
	                    }
					}
                }
            }
            return _dic;
        }

        public static function setOpenedDuplMapId(duplMapId : int) : void
        {
			var duplId : int;
			var layerId : int;
			var dic:Dictionary = DuplOpened.dic;
			if(duplMapId >= 100)
			{
	            duplId = DuplUtil.getDuplId(duplMapId);
	            layerId = DuplUtil.getLayerId(duplMapId);
	            if (dic[duplId] == null || dic[duplId] < layerId)
	            {
	                dic[duplId] = layerId;
	            }
			}
			else if(duplMapId >= 10 && duplMapId < 100)
			{
				duplId = Math.floor(duplMapId / 10) * 10;
	            layerId = duplMapId % 10;
	            if (dic[duplId] == null || dic[duplId] < layerId)
	            {
	             	dic[duplId] = layerId;
	            }
			}
            SignalBusManager.duplOpened.dispatch(duplMapId);
        }

        public static function isPassLayer(duplId : int, layerId : int) : Boolean
        {
            return dic[duplId] != null ? layerId <= dic[duplId] : false;
        }

        public static function isPassDuplMapId(duplMapId : int) : Boolean
        {
			var duplId : int;
			var layerId : int;
			if(duplMapId >= 100)
			{
	            duplId = DuplUtil.getDuplId(duplMapId);
	            layerId = DuplUtil.getLayerId(duplMapId);
			}
			else if(duplMapId >= 10 && duplMapId < 100)
			{
				duplId = Math.floor(duplMapId / 10) * 10;
	            layerId = duplMapId % 10;	
			}
            return dic[duplId] != null ? layerId <= dic[duplId] : false;
        }
		
		

        public static function isOpenDuplMapId(duplMapId : int) : Boolean
        {
			var duplId : int;
			var layerId : int;
			if(duplMapId >= 100)
			{
	            duplId = DuplUtil.getDuplId(duplMapId);
	            layerId = DuplUtil.getLayerId(duplMapId);
			}
			else if(duplMapId >= 10 && duplMapId < 100)
			{
				duplId = Math.floor(duplMapId / 10) * 10;
	            layerId = duplMapId % 10;	
			}
            return dic[duplId] != null ? layerId <= dic[duplId]+1 : false;
        }

        public static function getOpenedMaxLayerId(duplId : int) : int
        {
            return dic[duplId] != null ? dic[duplId] + 1 : -1;
        }

        public static function isOpened(duplId : int) : Boolean
        {
            return dic[duplId] != null;
        }

        public static function isOpenedLayer(duplId : int, layerId : int) : Boolean
        {
            if (dic[duplId] == null) return false;
            return layerId <= dic[duplId] + 1;
        }

        public static function isOpenedBydDuplMapId(duplMapId : int) : Boolean
        {
			var duplId : int;
			var layerId : int;
			if(duplMapId >= 100)
			{
	            duplId = DuplUtil.getDuplId(duplMapId);
	            layerId = DuplUtil.getLayerId(duplMapId);
			}
			else if(duplMapId >= 10 && duplMapId < 100)
			{
				duplId = Math.floor(duplMapId / 10) * 10;
	            layerId = duplMapId % 10;	
			}
            return isOpenedLayer(duplId, layerId);
        }

        public static function get isOpendHook() : Boolean
        {
            return QuestManager.getInstance().isSubmit(101019);
        }
    }
}
