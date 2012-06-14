package game.module.map.animal
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import game.core.avatar.AvatarThumb;
	import game.core.user.StateManager;
	import game.core.user.StateType;
	import game.manager.SignalBusManager;
	import game.module.groupBattle.ui.UiDieTimer;
	import game.module.map.MapController;
	import game.module.map.MapProto;
	import game.module.map.MapSystem;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.utils.MapTo;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����6:14:53
     */
    public class SelfPlayerAnimal extends PlayerAnimal
    {
        public function SelfPlayerAnimal(avatar : AvatarThumb, struct : AbstractStruct)
        {
            super(avatar, struct);
            if (MapSystem.debugShowPath == true)
            {
                var p : Sprite = circle(200240060);
                p.x = 0;
                p.y = 0;
                avatar.addChild(p);
            }

            if (playerStruct.model == 20 || StateManager.instance.isPractice())
            {
                sitdownAction();
            }
        }

        override public function initAvatar() : void
        {
            super.initAvatar();
            if (StateManager.instance.isPractice())
            {
                sitdownAction();
            }
        }
		
        /** 初始化前检查是否添加AVATAR到地图 */
        override protected function initCheckIsAddAvatar() : Boolean
        {
            return true;
        }

        /** 移动到,和setPostion的区别是会有走路动作 */
        override public function moveTo(x : int, y : int, isRunBeFollow : Boolean = true) : void
        {
            super.moveTo(x, y, isRunBeFollow);
            if (playerTolimitManager.enable == true)
            {
                playerTolimitManager.run();
            }
        }

        override public function quit() : void
        {
            if (_uiDieTimer)
            {
                _uiDieTimer.stop();
            }
            super.quit();
        }

        private var fromX : int = 0;
        private var fromY : int = 0;

        /** 拐弯处 */
        override public function turn(x : int, y : int) : void
        {
            if (MapSystem.hideServerMode == true) return;
            if (isStartWalk)
            {
                fromX = this.x;
                fromY = this.y;
            }
            else
            {
                fromX = 0;
                fromY = 0;
            }
            MapProto.instance.cs_moveTo(x, y, fromX, fromY);
            isStartWalk = false;
        }

        /** 停止移动 */
        override public function stopMove() : void
        {
            super.stopMove();
            StateManager.instance.changeState(StateType.NO_STATE);
        }

        /** 走路(有经过验证) */
        override public function walk(toX : int, toY : int) : void
        {
            StateManager.instance.changeState(StateType.MOVE_STATE, true, walkPass, [toX, toY]);
        }

        /** 走路验证通过 */
        public function walkPass(toX : int, toY : int) : void
        {
            if (MapSystem.debugShowPath == true)
            {
                var c : Sprite ;
                while (circleList.length > 0)
                {
                    c = circleList.shift();
                    if (c.parent) c.parent.removeChild(c);
                }
                c = circle();
                c.scaleX = c.scaleY = 1.5;
                c.x = x;
                c.y = y;
                circleList.push(c);
                MapController.instance.elementLayer.addChild(c);

                c = circle();
                c.scaleX = c.scaleY = 1.5;
                c.x = toX;
                c.y = toY;
                circleList.push(c);
                MapController.instance.elementLayer.addChild(c);
            }

            if (position == null || position.length < 2) return;
            startWalk(toX, toY);
        }

        private var isStartWalk : Boolean = true;

        override protected function startWalk(toX : int, toY : int) : void
        {
            isStartWalk = true;
            super.startWalk(toX, toY);
            SignalBusManager.selfStartWalk.dispatch();
        }

        /** 走路完成 */
        override protected function walkComplete() : void
        {
            MapTo.instance.checkArrive();
            SignalBusManager.selfEndWalk.dispatch();
        }

        /** 复活时间 */
        private var _uiDieTimer : UiDieTimer;

        /** 复活时间 */
        public function get uiDieTimer() : UiDieTimer
        {
            if (_uiDieTimer == null)
            {
                _uiDieTimer = new UiDieTimer();
            }
            return _uiDieTimer;
        }

        /** 设置复活时间 */
        public function setDieTime(value : int = 0) : void
        {
            uiDieTimer.time = value;
            if (value > 1)
            {
                if (avatar)
                {
                    if (uiDieTimer.parent == null)
                    {
                        avatar.addStateObj(uiDieTimer);
                        // uiDieTimer.x = - (uiDieTimer.width) / 2;
                        // uiDieTimer.y = avatar.avatarBd.topY - 5;
                        // avatar.addChild(uiDieTimer);
                    }
                }
            }
            else
            {
                stopDieTime();
            }
        }

        /** 停止复活时间 */
        public function stopDieTime() : void
        {
            if (uiDieTimer.parent != null) avatar.addStateObj(null);
            uiDieTimer.x = 0;
            uiDieTimer.y = 0;
            uiDieTimer.stop();
        }

        public static var circleList : Vector.<Sprite> = new Vector.<Sprite>();

        override public function createPath() : void
        {
            var c : Sprite;

            for (var i : int = 0; i < pathData.length; i++)
            {
                c = circle();
                c.x = pathData[i].x;
                c.y = pathData[i].y;
                circleList.push(c);
                MapController.instance.elementLayer.addChild(c);
            }
        }

        public function circle(color : uint = 0xFF0000) : Sprite
        {
            var sprite : Sprite = new Sprite();
            var g : Graphics = sprite.graphics;
            g.beginFill(color);
            g.drawCircle(0, 0, 3);
            g.endFill();
            return sprite;
        }
    }
}
