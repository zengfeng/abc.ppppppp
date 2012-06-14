package maps.elements.core.pools
{
    import maps.elements.core.PlayerElement;
    import maps.elements.structs.PlayerStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class PlayerElementPool
    {
        /** 单例对像 */
        private static var _instance : PlayerElementPool;

        /** 获取单例对像 */
        static public function get instance() : PlayerElementPool
        {
            if (_instance == null)
            {
                _instance = new PlayerElementPool(new Singleton());
            }
            return _instance;
        }

        private const MAX_COUNT : int = 150;
        public var list : Vector.<PlayerElement> = new Vector.<PlayerElement>();

        function PlayerElementPool(singleton : Singleton)
        {
        }

        public function getObject(playerStruct : PlayerStruct) : PlayerElement
        {
            if (list.length > 0)
            {
                var playerElement : PlayerElement = list.pop();
                playerElement.reset(playerStruct);
                return playerElement;
            }
            return new PlayerElement(playerStruct);
        }

        public function destoryObject(playerElement : PlayerElement) : void
        {
            if (playerElement == null) return;
            if (list.indexOf(playerElement) != -1) return;
            playerElement.destory();
            if (list.length < MAX_COUNT) list.push(playerElement);
        }
    }
}
class Singleton
{
}