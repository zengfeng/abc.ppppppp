package game.module.map.playerVisible
{
    import com.utils.dataStruct.LinkNode;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animal.SelfPlayerAnimal;


    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-13   ����6:20:39 
     */
    public class PlayerVisibleLinkNode extends LinkNode
    {
        public function PlayerVisibleLinkNode()
        {
        }

        private static function get selfPlayerAnimal() : SelfPlayerAnimal
        {
            return AnimalManager.instance.selfPlayer;
        }
        

        override public function compare(node : LinkNode) : int
        {
            var a : PlayerAnimal = data as PlayerAnimal;
            var b : PlayerAnimal = node.data as PlayerAnimal;
            var selfPlayer : SelfPlayerAnimal = selfPlayerAnimal;
            var showRadius:int = PlayerTolimitManager.showRadius;

            var distanceA : Number = (a.x - selfPlayer.x) * (a.x - selfPlayer.x) + (a.y - selfPlayer.y) * (a.y - selfPlayer.y);
            var distanceB : Number = (b.x - selfPlayer.x) * (b.x - selfPlayer.x) + (b.y - selfPlayer.y) * (b.y - selfPlayer.y);
//			//trace("PlayerTolimitManager.playerNum = " + PlayerTolimitManager.playerNum);
//            //trace("PlayerTolimitManager.maxPlayerNum = " + PlayerTolimitManager.maxPlayerNum);
            if (distanceA >= showRadius)
            {
                a.visible = false;
//                if(PlayerTolimitManager.playerNum >= PlayerTolimitManager.maxPlayerNum) a.visible = false;
            }
            else
            {
//                a.visible = true;
                if(PlayerTolimitManager.playerNum < PlayerTolimitManager.maxPlayerNum) a.visible = true;
            }

            if (distanceB >= showRadius)
            {
                b.visible = false;
//                if(PlayerTolimitManager.playerNum >= PlayerTolimitManager.maxPlayerNum) b.visible = false;
            }
            else
            {
//                b.visible = true;
                if(PlayerTolimitManager.playerNum < PlayerTolimitManager.maxPlayerNum) b.visible = true;
            }

            if (distanceA < distanceB)
            {
                return -1;
            }
            else if (distanceA > distanceB)
            {
                return 1;
            }

            return 0;
        }
    }
}
