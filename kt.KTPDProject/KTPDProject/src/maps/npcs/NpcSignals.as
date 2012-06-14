package maps.npcs
{
    import com.signalbus.Signal;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class NpcSignals
    {
        /** 添加 */
        public static const ADD : Signal = new Signal(uint);
        /** 移除 */
        public static const REMOVE : Signal = new Signal(uint);
        /** 移除所有 */
        public static const REMOVE_ALL:Signal = new Signal();
        /** 安装完成 */
        public static const INSTALLED : Signal = new Signal(uint);
        /** 停止安装 */
        public static const STOP_INSTALL : Signal = new Signal();
        /** 开始安装 */
        public static const START_INSTALL : Signal = new Signal();
    }
}
