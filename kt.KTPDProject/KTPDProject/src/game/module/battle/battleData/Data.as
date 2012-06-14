package game.module.battle.battleData
{
	public class Data
	{
		public  var x:uint = 0;
		public  var y:uint = 0;            //沙盘坐标点
		public  var factor:Number = 0.0;   //对该位置效果系数
		public  var skilltype:uint = 0;    //效果类型
		
		public function Data(p:uint = 0, t:uint = 0, f:Number = 0, s:uint = 0)
		{
			x = p;
			y = t;
			factor = f;
			skilltype = s;
		}
		public function clone():Data
		{
			var tmp:Data = new Data();
			tmp.x = x;
			tmp.y = y;
			tmp.factor = factor;
			tmp.skilltype = skilltype;
			return tmp;
		}
	}
}