package game.module.quest {
	import com.utils.StringUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author yangyiqiang
	 */
	public final class VoQuest extends EventDispatcher {
		public const QUEST_CHANGE : String = "quest_change";
		public var base : VoQuestBase;
		public var isCompleted : Boolean = false;
		public var stepMessages : Array = [];
		/** 状态 0：不可接 1:可接 2：已接 3：已提交 */
		private var _state : int = 0;
		private var _change : Boolean = true;
		private var _questString : String="";

		public function setVoTaskBase(vo : VoQuestBase) : void {
			base = vo;
		}

		private function initDialogue(type : int = 0) : void {
			var temp : Array = type == 0 ? base.actionMsg.split("|") : base.secondNpcDialog.split("|");
			var dialogue : VoDialogue;
			stepMessages = [];
			for each (var str:String in temp) {
				var arr : Array = str.split("$$");
				for (var i : int = 0;i < arr.length;i++) {
					dialogue = new VoDialogue();
					dialogue.id = i == 0 ? 1 : -1;
					dialogue.str = arr[i];
					stepMessages.push(dialogue);
				}
			}
		}

		public function get id() : int {
			return base.id;
		}

		/**
		 * 任务进度
		 */
		public  function getStep() : int {
			var max : int = base.reqStep.length;
			for (var i : int = 0;i < max;i++)
				if(base.reqStep[i] <= 0) return i;
			return 0;
		}

		// public function get isLastStep() : Boolean
		// {
		// if (base.npcFinish == 0) return false;
		// if (isCompleted) return false;
		// var step : int = getStep();
		// return step == base.reqStep.length - 1 ? true : false;
		// }
		/** 返回拖动框的任务字符 **/
		public function getQuestString() : String {
			if (!_change) return _questString;

			_questString = "[" + QuestManager.getInstance().typeString[base.type - 1] + "]" + base.name;
			if (_state == QuestManager.CURRENT) {
				if (isCompleted) {
					_questString += "(" + "已完成" + ")" ;
					return StringUtils.addLine(StringUtils.addEvent(StringUtils.addColor(_questString, "#00ff00"), String(id))) + "<br>";
				} else {
					_questString += "(" + StringUtils.addColorById("未完成", 5) + ")";
				}
			}

			if (_state == QuestManager.UNDONE) {
				_questString += "<br>";
				_questString += StringUtils.addColor(StringUtils.addIndent("主将" + this.base.playerLevel + "级可接受"), "#ff0000");
				return _questString;
			}
			if (_state == QuestManager.CAN_ACCEPT) {
				if (base.id == QuestManager.COMMON_DAILY)// 日常任务
					_questString += "(" + StringUtils.addColor("剩余" + QuestManager.getInstance().loopCount + "次", "#00ff00") + ")";
				_questString += "<br>";
				_questString += StringUtils.addLine(StringUtils.addIndent(QuestUtil.parseRegExpStr(base.questDesc)));
				return  StringUtils.addEvent(_questString, String(id)) + "<br>";
			}
			_questString += "<br>";
			_questString += StringUtils.addLine(StringUtils.addIndent(parseTargetDesc()));
			parseStep();
			_questString += "<br>";
			_change = false;
			_questString = StringUtils.addEvent(_questString, String(id));
			return  _questString;
		}

		public function getTargeString() : String {
			var str : String = StringUtils.addLine(StringUtils.addSize(StringUtils.addBold(this.base.name), 14));
			if (this.isCompleted) {
				str += StringUtils.addSize("（完成）", 12);
				return StringUtils.addColorById(str, 2);
			} else if (this.state == QuestManager.CAN_ACCEPT) {
				str += StringUtils.addSize("（可接）", 12);
			}
			return StringUtils.addColor(str, "#eb6100");
		}

		public function set state(value : int) : void {
			_state = value;
			_change = true;
			dispatchEvent(new Event(QUEST_CHANGE));
		}

		public function get state() : int {
			return _state;
		}


		private function parseTargetDesc() : String {
			return QuestUtil.parseRegExpStr(base.targetDesc, base.getCompleteTry());
		}
		
		public function parseQuestDesc():String{
			var str:String=QuestUtil.parseRegExpStr(base.targetDesc,base.getCompleteTry(),"#FF3300");
			var stepArray : Array = base.step.split("|");
			var max : int = stepArray.length;
			for (var i : int = 0;i < max;i++) {
				var numArray : Array = (stepArray[i] as String).split(",");
				// 01:对话 02:打怪 03:打怪收集 04:使用物品 05:采集
				switch(base.getCompleteTry()) {
					case 2:
						var repStr : String = "(" + (base.reqStep.length < i ? "0" : String(base.reqStep[i])) + "/" + numArray[1] + ")";
						str = str.replace("#" + i.toString() + "#", repStr);
						break;
					case 3:
						repStr = "(" + (base.reqStep.length < i ? "0" : String(base.reqStep[i])) + "/" + numArray[2] + ")";
						str = str.replace("#" + i.toString() + "#", repStr);
						break;
				}
			}
			return  str;
		}

		private function parseStep() : void {
			if (base.getCompleteTry() != 2 && base.getCompleteTry() != 3 && base.getCompleteTry() != 5) return ;
			var stepArray : Array = base.step.split("|");
			var max : int = stepArray.length;
			for (var i : int = 0;i < max;i++) {
				var numArray : Array = (stepArray[i] as String).split(",");
				// 01:对话 02:打怪 03:打怪收集 04:使用物品 05:采集
				switch(base.getCompleteTry()) {
					case 2:
						var repStr : String = "(" + (base.reqStep.length < i ? "0" : String(base.reqStep[i])) + "/" + numArray[1] + ")";
						_questString = _questString.replace("#" + i.toString() + "#", repStr);
						break;
					case 3:
						repStr = "(" + (base.reqStep.length < i ? "0" : String(base.reqStep[i])) + "/" + numArray[2] + ")";
						_questString = _questString.replace("#" + i.toString() + "#", repStr);
						break;
					case 5:
						break;
				}
			}
		}

		private var dialogueIndex : int = -1;

		public function resetDialogueIndex(type : int = 0) : void {
			if (type != 0 || !stepMessages || stepMessages.length == 0)
				initDialogue(type);
			dialogueIndex = -1;
		}

		public function resetReqStep() : void {
			var max : int = base.reqStep.length;
			for (var i : int = 0 ;i < max;i++) {
				base.reqStep[i] = 0;
			}
			isCompleted = false;
			resetDialogueIndex();
		}

		public function getNextDialogue() : VoDialogue {
			dialogueIndex++;
			return dialogueIndex >= stepMessages.length ? null : (stepMessages[dialogueIndex] as VoDialogue).str == "" ? getNextDialogue() : stepMessages[dialogueIndex];
		}
	}
}
