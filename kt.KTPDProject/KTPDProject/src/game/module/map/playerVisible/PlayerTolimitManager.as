package game.module.map.playerVisible
{
    import com.utils.dataStruct.LinkList;
    import com.utils.dataStruct.LinkNode;
    import flash.utils.getTimer;
    import game.module.map.animal.PlayerAnimal;


    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-13   ����6:21:50 
     * 玩家显示上限管理
     */
    public class PlayerTolimitManager
    {
        function PlayerTolimitManager():void
        {
            linkList = new LinkList();
        }
        /** 单例对像 */
        private static var _instance : PlayerTolimitManager;

        /** 获取单例对像 */
        static public function get instance() : PlayerTolimitManager
        {
            if (_instance == null)
            {
                _instance = new PlayerTolimitManager();
            }
            return _instance;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var linkList:LinkList;
        public var enable:Boolean = false;
        public static var showRadius:int = 160000;
        public static var playerNum:int = 0;
        public static var maxPlayerNum:int = 50;
        
        public function clear():void
        {
            linkList.clear();
            playerNum = 0;
        }
        private var runTime:Number = 0;
        public function run():void
        {
            if(getTimer() - runTime < 500)
            {
                return;
            }
            runTime = getTimer();
            var i:int = 0;
            var count:int =  maxPlayerNum + 20;
            if(count > linkList.length) count = linkList.length;
            if(count < 1) return;
            var node:LinkNode = linkList.headNode;
            var a : PlayerAnimal = node.data as PlayerAnimal;
            a.visible = true;
            if(node == null) return;
            var nextNode:LinkNode = node.nextNode;
            while(i < count && nextNode)
            {
                i++;
                linkList.sortUpdate(nextNode);
                nextNode = nextNode.nextNode;
            }
        }
        
    }
}
