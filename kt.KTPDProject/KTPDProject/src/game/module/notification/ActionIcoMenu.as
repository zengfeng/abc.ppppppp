package game.module.notification
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import flash.events.MouseEvent;
	import game.manager.ViewManager;
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;




	/**
	 * @author yangyiqiang
	 * 底部的活动菜单
	 */
	public class ActionIcoMenu extends GComponent
	{
		public function ActionIcoMenu()
		{
			_base = new GComponentData();
			_base.parent = ViewManager.instance.getContainer(ViewManager.AUTO_CONTAINER);
			_base.width = 500;
			_base.height = 71;
			_base.align = new GAlign(-1, -1, -1, 100, 0);
			super(_base);
		}

		override protected function onShow() : void
		{
			super.onShow();
			GLayout.update(UIManager.root, this);
		}

		override protected function onHide() : void
		{
			super.onHide();
			if (_lable)
				_lable.removeEventListener(MouseEvent.CLICK, onClickAll);
		}

		private var _lable : message;

		private function addLable() : void
		{
			if (!_lable)
			{
				_lable = new message(this);
				_lable.addEventListener(MouseEvent.CLICK, onClickAll);
			}
			addChild(_lable);
			GLayout.layout(_lable);
		}

		private function onClickAll(event : MouseEvent) : void
		{
			var list : Vector.<uint>=new Vector.<uint>();
			for each (var value:ActionIcoButton in _list)
			{
				if (value.typeId == 0)
				{
					NotificationProxy.opNotification(0, 0);
					continue;
				}
				else if (value.typeId == 1)
				{
					NotificationProxy.opNotification(1, 0);
					continue;
				}
				list.push(value.uuid);
			}
			NotificationProxy.delNotifications(list);
		}

		public const MAX : int = 10;

		private var _list : Vector.<ActionIcoButton>=new Vector.<ActionIcoButton>();

		private var _wait : Vector.<ActionIcoButton>=new Vector.<ActionIcoButton>();

		private var _transforming : Vector.<Struct>=new Vector.<Struct>();

		private var _waitForTrans : Vector.<Struct>=new Vector.<Struct>();

		public function addButton(item : VoNotification) : void
		{
			if ((_list.length + _transforming.length + _waitForTrans.length) < 10)
			{
				showButton(createButton(item));
			}
			else _wait.push(createButton(item));
		}

		public function removeButton(uuid : int) : void
		{
			for (var i : int;i < _wait.length;i++)
			{
				if (_wait[i].uuid == uuid)
				{
					_wait.splice(i, 1);
					if (_list.length < 5 && _lable)
						_lable.hide();
					if (_wait.length == 0 && _list.length == 0 && _waitForTrans.length == 0)
						this.hide();
					return;
				}
			}
			for (i = 0;i < _list.length;i++)
			{
				if (_list[i].uuid == uuid)
				{
					_list[i].hide();
					_list.splice(i, 1);
					showButton(_wait.pop(), i);
					if (_list.length < 5 && _lable)
						_lable.hide();
					if (_wait.length == 0 && _list.length == 0 && _waitForTrans.length == 0)
						this.hide();
					return;
				}
			}
			if (_list.length < 5&&_lable)
				_lable.hide();
		}

		public function updateButtonNum(num : int = 1, type : int = 0) : void
		{
//			if (type != 0) return;
			for (var i : int;i < _wait.length;i++)
			{
				if (_wait[i].typeId == type)
				{
					_wait[i].updateNum(num);
					return;
				}
			}
			for (i = 0;i < _list.length;i++)
			{
				if (_list[i].typeId == type)
				{
					_list[i].updateNum(num);
				}
			}
		}

		private function showButton(value : ActionIcoButton, index : int = 0) : void
		{
			if(!value)return;
			_waitForTrans.push(new Struct(value, index));
			if (_transforming.length == 0)
				execute(_waitForTrans.pop());
		}

		private function execute(struct : Struct) : void
		{
			if (!struct||!struct.value) return;
			var max : int = _list.length;
			var ioc : ActionIcoButton;
			var startX : int = (this.width - _list.length * 50) / 2;
			for (var i : int = struct.index;i < max;i++)
			{
				ioc = _list[i];
				TweenLite.to(ioc, 0.5, {x:startX + (max - i) * 50, overwrite:0});
			}
			struct.index = _transforming.push(struct) - 1;
			struct.value.x = -200;
			struct.value.alpha = 0;
			addChild(struct.value);
			TweenLite.to(struct.value, 2, {alpha:1, x:startX, overwrite:0, onComplete:addToStage, onCompleteParams:[struct], ease:Bounce.easeOut});
		}

		private function addToStage(struct : Struct) : void
		{
			_transforming.splice(struct.index, 1);
			_list.push(struct.value);
			struct.value.enabled = true;
			execute(_waitForTrans.pop());
			if (_list.length > 3)
				addLable();
		}

		private  var _iocData : GComponentData = new GComponentData();

		private function createButton(item : VoNotification) : ActionIcoButton
		{
			_iocData = _iocData.clone();
			_iocData.parent = this;
			return new ActionIcoButton(_iocData, item);
		}
		
		override public function show():void
		{
			_base.parent.addChildAt(this,0); 
		}
	}
}
import com.greensock.TweenLite;
import flash.display.Sprite;
import flash.events.MouseEvent;
import game.module.notification.ActionIcoButton;
import gameui.controls.GLabel;
import gameui.core.GAlign;
import gameui.core.GComponent;
import gameui.core.GComponentData;
import gameui.data.GLabelData;




class Struct
{
	public var value : ActionIcoButton;

	public var index : int = 0;

	public function Struct(_value : ActionIcoButton, _index : int = 0)
	{
		value = _value;
		index = _index;
		if (value)
			value.enabled = false;
	}
}
class message extends GComponent
{
	public function message(sprite : GComponent)
	{
		_base = new GComponentData();
		_base.parent = sprite;
		_base.align = new GAlign(-1, -1, -20, -1, 0);
		super(_base);
	}

	private var _lable : GLabel;

	private var _sprite : Sprite;

	override protected function create() : void
	{
		_sprite = new Sprite();
		_sprite.alpha = 0.3;
		var data : GLabelData = new GLabelData();
		_lable = new GLabel(data);
		_lable.text = "快速查看";
		addChild(_sprite);
		addChild(_lable);
		with(_sprite.graphics)
		{
			beginFill(0x999999);
			drawRoundRect(-10, -5, _lable.width + 20, _lable.height + 10, 5, 5);
			endFill();
		}
	}

	override protected function onShow() : void
	{
		super.show();
		this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
	}

	override protected function onHide() : void
	{
		super.onHide();
		this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
	}

	private function onRollOut(event : MouseEvent) : void
	{
		TweenLite.to(_sprite, 0.2, {alpha:0.3});
	}

	private function onRollOver(event : MouseEvent) : void
	{
		TweenLite.to(_sprite, 0.2, {alpha:0.8});
	}
}


