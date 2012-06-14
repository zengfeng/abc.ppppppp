package game.module.map
{
	import com.signalbus.Signal;
	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-9
	// ============================
	public class NpcSignals
	{
		/** args=[npcId] */
		public static const aiStart:Signal = new Signal(int);
		/** args=[npcId] */
		public static const aiStop:Signal = new Signal(int);
		/** args=[npcId] */
		public static const aiHit:Signal = new Signal(int);
		/** args=[npcId] */
		public static const add:Signal = new Signal(int);
		/** args=[npcId] */
		public static const remove:Signal = new Signal(int);
		public static const gotoNextAI:Signal = new Signal();
		public static const aiComplete:Signal = new Signal();
	}
}
