package game.module.map
{
	import com.signalbus.Signal;
	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-13
	// ============================
	public class MapSingles
	{
		public static const sendLeaveDuplMap:Signal = new Signal();
		public static const setupMapComplete:Signal = new Signal();
	}
}
