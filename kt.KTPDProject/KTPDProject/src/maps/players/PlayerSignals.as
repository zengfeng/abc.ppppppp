package maps.players {
	import maps.elements.structs.PlayerStruct;

	import com.signalbus.Signal;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-23
     */
    public class PlayerSignals
    {
        /** 玩家获得最新信息等待安装  */
        public static const PLAYER_GET_NEWEST_INFO_WAIT_INSTALL: Signal = new Signal(PlayerStruct);
        /** 玩家安装完成  */
        public static const PLAYER_INSTALLED : Signal = new Signal(PlayerStruct);
		/** 自己玩家等待安装 */
        public static const SELF_PLAYER_GET_NEWEST_INFO_WAIT_INSTALL: Signal = new Signal(PlayerStruct);
		/** 自己玩家安装完成 */
        public static const SELF_PLAYER_INSTALLED: Signal = new Signal(PlayerStruct);
		
		
        // =================
        // 模式
        // =================
        /** 龟仙拜佛进入 args=[playerId, quality] */
        public static const MODEL_CONVOY_IN : Signal = new Signal(uint, uint);
        /** 龟仙拜佛退出 args=[playerId] */
        public static const MODEL_CONVOY_OUT : Signal = new Signal(uint);
        /** 龟仙拜佛速度改变 args=[playerId, quality] */
        public static const MODEL_CONVOY_SPEED : Signal = new Signal(uint, uint);
        // -----------------------------
        /** 钓鱼进入 args=[playerId] */
        public static const MODEL_FISHING_IN : Signal = new Signal(uint);
        /** 钓鱼退出 args=[playerId] */
        public static const MODEL_FISHING_OUT : Signal = new Signal(uint);
        // -----------------------------
        /** 打座进入 args=[playerId] */
        public static const MODEL_SITDOWN_IN : Signal = new Signal(uint);
        /** 打座退出 args=[playerId] */
        public static const MODEL_SITDOWN_OUT : Signal = new Signal(uint);
        // -----------------------------
        /** 派对进入 args=[playerId, status] */
        public static const MODEL_FEAST_IN : Signal = new Signal(uint, uint);
        /** 派对退出 args=[playerId] */
        public static const MODEL_FEAST_OUT : Signal = new Signal(uint);
        /** 派对状态改变 args=[playerId, state] */
        public static const MODEL_FEAST_STATE : Signal = new Signal(uint, uint);
        // =================
        // 换装
        // =================
        /**  换衣服 args=[playerId, clothId] */
        public static const CLOTH : Signal = new Signal(uint, int);
        /**  换坐骑 args=[playerId, rideId] */
        public static const RIDE : Signal = new Signal(uint, int);
        /**  潜力改变 args=[playerId, potential] */
        public static const POTENTIAL : Signal = new Signal(uint, int);
    }
}
