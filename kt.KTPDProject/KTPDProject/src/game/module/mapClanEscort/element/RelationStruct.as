package game.module.mapClanEscort.element
{
    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-27   ����8:37:57 
     */
    public class RelationStruct
    {
        public var playerId:int;
        public var drayId:int = -1;
        function RelationStruct(playerId:int, drayId:int):void
        {
            this.playerId = playerId;
            this.drayId = drayId;
        }
    }
}
