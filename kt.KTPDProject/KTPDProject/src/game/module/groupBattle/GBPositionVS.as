package game.module.groupBattle
{
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-4 ����8:42:50
     */
    public class GBPositionVS
    {
        /** 范围 */
        public var rect : Rectangle;
        /** 列数 */
        public var lineCout : int = 1;
        /** 一列多少个数轮换 */
        public var changeLineLength : int = 10;
        /** 位置数量 */
        public var positionCount : int = 200;
        /** 位置储备列表 */
        private var _listA : Vector.<Point>;
        private var _listB : Vector.<Point>;
        /** 位置空出列表 */
        private var emptyListA : Vector.<Point> = new Vector.<Point>();
        private var emptyListB : Vector.<Point> = new Vector.<Point>();
        /** 位置空出列表 */
        private var emptyIdListA : Vector.<int> = new Vector.<int>();
        private var emptyIdListB : Vector.<int> = new Vector.<int>();
        /** 位置使用数量 */
        private var useCountA : int = 0;
        private var useCountB : int = 0;
        public var positionVSGroupA : GBPositionVSGroup;
        public var positionVSGroupB : GBPositionVSGroup;

        function GBPositionVS() : void
        {
        }

        public function clear() : void
        {
            if (_listA)
            {
                while (_listA.length > 0)
                {
                    _listA.shift();
                }
            }

            if (_listB)
            {
                while (_listB.length > 0)
                {
                    _listB.shift();
                }
            }

            while (emptyListA.length > 0)
            {
                emptyListA.shift();
            }

            while (emptyListB.length > 0)
            {
                emptyListB.shift();
            }

            emptyIdListA = new Vector.<int>();
            emptyIdListB = new Vector.<int>();
            
            emptyIndexList = [];
            _index = 0;

            useCountA = 0;
            useCountB = 0;

            _listA = null;
            _listB = null;
        }

        public function get listA() : Vector.<Point>
        {
            if (_listA == null)
            {
                initList();
            }
            return _listA;
        }

        public function get listB() : Vector.<Point>
        {
            if (_listB == null)
            {
                initList();
            }
            return _listB;
        }

        public function initList() : void
        {
            if (_listA != null) return;
            var positionVSGroup : GBPositionVSGroup;
            // A
            positionVSGroup = new GBPositionVSGroup();
            positionVSGroup.rect = rect.clone();
//            positionVSGroup.rect.y -= 30;
            positionVSGroup.rect.width = rect.width / 2;
            positionVSGroup.lineCount = lineCout;
            positionVSGroup.changeLineLength = changeLineLength;
            _listA = positionVSGroup.getPointList(positionCount);
            positionVSGroupA = positionVSGroup;
            // B
            positionVSGroup = new GBPositionVSGroup();
            positionVSGroup.rect = rect.clone();
//            positionVSGroup.rect.y += 30;
            positionVSGroup.rect.x = rect.x + rect.width / 2;
            positionVSGroup.rect.width = rect.width / 2;
            positionVSGroup.lineCount = lineCout;
            positionVSGroup.changeLineLength = changeLineLength;
            _listB = positionVSGroup.getPointList(positionCount);
            positionVSGroupB = positionVSGroup;
        }

        private var _index : int = 0;

        public function get index() : int
        {
            var value : int = -1 ;
            if (emptyIndexList.length > 0)
            {
                value = emptyIndexList.shift();
            }
            else
            {
                value = _index;
                _index++;
                if (_index > 14) _index = 0;
            }
            return value;
        }

        public var emptyIndexList : Array = new Array();

        public function getPointByIndex(index : int, groupAB : int) : Point
        {
            var point : Point;
            if (groupAB == GBSystem.GROUP_A_ID)
            {
                point = listA[index];
            }
            else
            {
                point = listB[index];
            }
            return point;
        }

        public function setEmptyIndex(point : Point) : void
        {
            if (point == null) return;
            var indexPosition : int = listA.indexOf(point);
            if (indexPosition > -1)
            {
                if (emptyIndexList.indexOf(indexPosition) == -1)
                {
                    emptyIndexList.push(indexPosition);
                    //trace("emptyIndexList = " + emptyIndexList);
                    emptyIndexList.sort(Array.NUMERIC);
                }
            }
        }

        public function getPoint(groupAB : int) : Point
        {
            var point : Point;
            if (groupAB == GBSystem.GROUP_A_ID)
            {
                if (useCountA - useCountB >= 2) useCountA = useCountB;
                point = listA[useCountA];
                useCountA++;
                // if (emptyIdListA.length > 0)
                // {
                // point = listA[emptyIdListA.shift()];
                // }
                // else
                // {
                // point = listA[useCountA];
                // useCountA++;
                // }
            }
            else
            {
                if (useCountB - useCountA >= 2) useCountB = useCountA;
                point = listB[useCountB];
                useCountB++;
                // if (emptyListB.length > 0)
                // {
                // point = listB[emptyIdListB.shift()];
                // }
                // else
                // {
                // point = listB[useCountB];
                // useCountB++;
                // }
            }

            if (useCountA >= 31 && useCountB >= 31)
            {
                useCountA = 0;
                useCountB = 0;
            }
            test("groupAB = " + groupAB + "  useCountA = " + useCountA + "  useCountB = " + useCountB + "  point = " + point);
            return point;
        }

        private var _testStr : String = "";

        public function test(str : String) : void
        {
            _testStr = _testStr + "\n" + str;
            //trace(_testStr);
        }

        /** 使用完成的位置 */
        public function setEmpty(point : Point, groupAB : int) : void
        {
            if (point == null) return;
            var index : int;
            if (groupAB == GBSystem.GROUP_A_ID)
            {
                index = listA.indexOf(point);
                if (index > -1)
                {
                    if (emptyIdListA.indexOf(index) == -1)
                    {
                        emptyIdListA.push(index);
                        emptySort(emptyIdListA);
                    }
                }
            }
            else
            {
                index = listB.indexOf(point);
                if (index > -1)
                {
                    if (emptyIdListB.indexOf(index) == -1)
                    {
                        emptyIdListB.push(index);
                        emptySort(emptyIdListB);
                    }
                }
            }
        }

        private function emptySort(list : Vector.<int>) : void
        {
            if (list == null || list.length == 0) return;
            var fun : Function = function(a : int, b : int) : Number
            {
                if (a < b)
                {
                    return  -1;
                }
                else if (a > b)
                {
                    return  1;
                }
                else
                {
                    return 0;
                }
            };
            list.sort(fun);
        }

        public function getPoint2(groupAB : int) : Point
        {
            var point : Point;
            if (groupAB == GBSystem.GROUP_A_ID)
            {
                if (emptyListA.length > 0)
                {
                    point = emptyListA.shift();
                }
                else
                {
                    point = listA[useCountA];
                    useCountA++;
                }
            }
            else
            {
                if (emptyListB.length > 0)
                {
                    point = emptyListB.shift();
                }
                else
                {
                    point = listB[useCountB];
                    useCountB++;
                }
            }
            return point;
        }

        /** 使用完成的位置 */
        public function setEmpty2(point : Point, groupAB : int) : void
        {
            if (point == null) return;
            if (groupAB == GBSystem.GROUP_A_ID)
            {
                emptyListA.unshift(point);
            }
            else
            {
                emptyListB.unshift(point);
            }
        }
    }
}
