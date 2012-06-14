package game.module.quest.animation {
	import game.config.StaticConfig;
	import game.core.user.UserData;
	import game.manager.RSSManager;
	import game.module.quest.VoNpc;

	/**
	 * @author yangyiqiang
	 */
	public class Action
	{
		public var id : int;

		/*
		 * type       动作分类  1:对话，2:人物移动 3：模型转身 4: 模型攻击 5：死亡消失 6:星宿冒金光特效 7：星宿所代表的星宿名和神性文字从avatar上浮现 
		8:星宿归位，任务人物消失化为金光升空的动画 9：从天而降 10：模型释放技能特效 11：后退 12：屏幕抖动
		13：地图上出现物品avatar 14：引入过场动画
		 */
		public var type : int;

		/* 
		 * 描述 如果是对话，则为对话内容
		 * [x,y] 移动到指定点
		 */
		public var describe : String;

		/** direction  1:左边 2：右边 */
		public var direction : int = 1;

		/* 执行者 */
		public var targets : Array = [];

		public var target : int;

		public var completeType : Number = 0;

		public function parse(xml : XML) : void
		{
			id = xml.@id;
			type = xml.@type;
			describe = xml.@describe;
			targets = String(xml.@target).split("|");
			target = targets[0];
			completeType = xml.@completeType;
			direction = xml.@direction;
		}

		private var _vo :VoNpc;

		public function get helfUrl() : String
		{	//4007自己的影子
			if (target == 0||target==4007)
			{
				return StaticConfig.cdnRoot + "assets/avatar/halfBody/" + UserData.instance.myHero.id + ".png";
			}
			_vo = RSSManager.getInstance().getNpcById(target);
			if (!_vo) return "";
			return StaticConfig.cdnRoot + "assets/avatar/halfBody/" + _vo.halfId + ".png";
		}

		public function get targetName() : String
		{
			if (target == 0)
			{
				return UserData.instance.playerName;
			}
			if (!_vo) _vo = RSSManager.getInstance().getNpcById(target);
			if (!_vo) return "";
			return _vo.name;
		}
	}
}
