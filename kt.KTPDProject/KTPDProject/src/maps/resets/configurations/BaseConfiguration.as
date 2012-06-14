package maps.resets.configurations
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class BaseConfiguration
    {
        public var mapId : int;
        public var selfX : int;
        public var selfY : int;
        public var npcList : Vector.<uint>;
        public var playerList : Vector.<uint>;

        public function destory() : void
        {
            mapId = NaN;
            selfX = NaN;
            selfY = NaN;
            if (npcList)
            {
                while (npcList.length > 0)
                {
                    npcList.pop();
                }
            }

            if (playerList)
            {
                while (playerList.length > 0)
                {
                    playerList.pop();
                }
            }
        }
    }
}
