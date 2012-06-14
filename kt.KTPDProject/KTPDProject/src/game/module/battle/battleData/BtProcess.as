package game.module.battle.battleData
{
	public final class BtProcess
	{
		public static var data:Vector.<BtProcess> = new Vector.<BtProcess>();
		public static var selfList:Vector.<FighterInfo>;
		public static var enemyList:Vector.<FighterInfo>;
		
		
		//可能需要标志
		
		//攻击信息
		public var oneAtkInfo:BtOneAtk;
		
		//被攻击者列表
		public var defendList:Array = [];
		
		//状态改变列表
		public var SChangeList:Array = [];
		
		//被帮助者列表
		public var rescuedList:Array = [];
		
		//被帮助者状态改变
		public var resuedSChangeList:Array = [];
		
		
		public  function BtProcess()
		{
			
		}
		
		public function clone():BtProcess
		{
			var i:int = 0;
			var btpr:BtProcess = new BtProcess();
			if(this.oneAtkInfo != null)
				btpr.oneAtkInfo = this.oneAtkInfo.clone();
			for(i = 0; i < defendList.length; ++i)
			{
				btpr.defendList.push(this.defendList[i].clone() as BtDefend);
			}
			
			for(i = 0 ; i < SChangeList.length; ++i)
			{
				btpr.SChangeList.push(this.SChangeList[i].clone() as BtStatus);
			}
			
			for(i = 0; i < rescuedList.length; ++i)
			{
				btpr.rescuedList.push(this.rescuedList[i].clone() as BtDefend);
			}
			
			for(i = 0; i < resuedSChangeList.length; ++i)
			{
				btpr.resuedSChangeList.push(this.resuedSChangeList[i].clone() as BtStatus);
			}
			return btpr;
		}
	}
}