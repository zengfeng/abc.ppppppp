package maps.elements
{
	import flash.display.DisplayObject;

	import com.signalbus.Signal;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
	 */
	public class ElementSignals
	{
		/** 添加到ElementLayer，args=[Avatar, childIndex] */
		public static const ADD_TO_LAYER : Signal = new Signal(DisplayObject, uint);
		/** 移除从ElementLayer  */
		public static const REMOVE_FROM_LAYER : Signal = new Signal(DisplayObject);
		/** 深度改变 args=[Avatar, childIndex] */
		public static const DEPTH_CHANGE : Signal = new Signal(DisplayObject, uint);
	}
}
