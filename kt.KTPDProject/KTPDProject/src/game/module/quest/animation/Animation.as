package game.module.quest.animation {

	/**
	 * @author yangyiqiang
	 */
	public class Animation
	{
		/**
		所有标点请用英文半角
		id  对应的任务编号
		name 任务名
		mapid 地图编号
		mapx  中心点X,Y
		player 玩家列表  1,100,100|  用|区分player     用,区分坐标   
		npc    npc列表
		
		action
		target   动作的执行者  数值与上面player或npc对应
		id       动作分类  1:对话，2:人物移动
		describe 动作描述
		1:对话，对话内容
		2:移动, 目标点坐标
		 */
		public var id : int;

		public var name : String;

		public var mapId : int;

		public var mapX : int;

		public var mapY : int;
		
		private var _assets : Vector.<String>;

		public var performerDic : Vector.<Performer> = new Vector.<Performer>();

		public var list : Vector.<Action>=new Vector.<Action>();

		/*
		 * <animation id="10100106" name="一句话引起的血案" mapid="1" mapx="100" mapy="100" player="1,100,100|2,200,200" npc="4001,500,100|4002,450,100">
		<action target="1" id="1" describe="轮到我说话" />
		<action target="2" id="1" describe="你快说，我还有好多话要说！" />
		<action target="4001" id="1" describe="话多的人类" />
		<action target="1" id="2" describe="500,90" />
		<action target="1" id="2" describe="敢打扰我们说话，找死!" />
		</animation>
		 */
		public function parse(xml : XML) : void
		{
			id = xml.@id;
			name = xml.@name;
			mapId = xml.@mapid;
			mapX = xml.@mapx;
			mapY = xml.@mapy;

			var tempArr : Array = String(xml.@player).split("|");
			var obj : Performer;
			for each (var msg:String in tempArr)
			{
				if (msg == "") continue;
				obj = new Performer(msg.split(","));
				performerDic.push(obj);
			}

			tempArr = String(xml.@npc).split("|");
			for each (msg in tempArr)
			{
				if (msg == "") continue;
				obj = new Performer(msg.split(","));
				performerDic.push(obj);
			}
			var xmlList : XMLList = xml.descendants("action");
			var action : Action;
			for each (var str:XML in xmlList)
			{
				action = new Action();
				action.parse(str);
				list.push(action);
			}
		}

		public function getAssets() : Vector.<String>
		{
//			if (_assets) return _assets;
//			_assets = new Vector.<String>();
//			for each (var obj:Performer in performerDic)
//			{
//				var _npcVo : VoBase = RSSManager.getInstance().getStructById(obj.id);
//				if (!_npcVo) continue;
//				_assets.push(_npcVo.avatarUrl);
//			}
			_assets = new Vector.<String>();
			return _assets;
		}

		private var _index : int = 0;

		public function getNextAction() : Action
		{
			if ((list.length - 1) < _index) return null;
			return list[_index++];
		}

		public function reset() : void
		{
			_index = 0;
		}
	}
}
class Performer
{
	public var id : int;

	public var x : int;

	public var y : int;

	public function Performer(arr : Array)
	{
		if (!arr || arr.length < 3) return;
		id = arr[0];
		x = arr[1];
		y = arr[2];
	}
}

