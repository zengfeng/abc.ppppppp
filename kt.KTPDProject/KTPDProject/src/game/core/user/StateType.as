package game.core.user
{
	/**
	 * @author yangyiqiang
	 */
	public class StateType
	{
		/*
		 * 人物状态 value < 0xffff
		 */
		/** 原地打坐 */
		public static const PRACTICE_STATE : uint = 0x02;

		/** 人物移动 */
		public static const MOVE_STATE : uint = 0x04;

		/*
		 * 战斗
		 */
		public static const BATTLE : uint = 0x05;
		
		/**  自动寻路 */
		public static const AUTO_RUN: uint = 0x06;

		/** 人物站立*/
		public static const NO_STATE : uint = 0;
		

		/**
		 * 场景状态 value > 0xffff
		 */
		/** 主城打坐 */
		public static const PRACTICE : uint = 0xffff1;

		/** 副本 */
		public static const DUNGEON : uint = 0xffff2;

		/** 自动副本 */
		public static const AUTO_DUNGEON : uint = 0xffff3;

		/** 任务对话中 */
		public static const QUEST_DIALOG : uint = 0xffff4;

		/** 国战中 */
		public static const GROUP_BATTLE : uint = 0xffff5;

		/** BOSS战中 */
		public static const BOSS_BATTLE : uint = 0xffff6;

		/** 剧情动画中 */
		public static const ANIMATION : uint = 0xffff7;
		
		/** 欢乐派对中 */
		public static const FEASTING : uint = 0xffff8;
		
		
	}
}
