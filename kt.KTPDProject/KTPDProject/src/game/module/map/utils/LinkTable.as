package game.module.map.utils
{
    import flash.utils.Dictionary;

    public class LinkTable
    {
        public function LinkTable()
        {
        }

        public var head : LinkTableNode = null;
        public var dictionary : Array = [];
        public var shortDic : Array = [];

        public function isEmpty() : Boolean
        {
            return head == null;
        }

        public function clearTable() : void
        {
            head = null;
            dictionary = [];
            dictionary.length = 0;
            shortDic = [];
            shortDic.length = 0;
        }

        public function getNextNode(pNode : LinkTableNode) : LinkTableNode
        {
            var rt : LinkTableNode;
            if (pNode == null) return null;
            if (pNode.next != head)
            {
                rt = pNode.next;
            }
            else
            {
                rt = pNode.next.next;
                if (rt == head)
                {
                    rt = null;
                }
            }
            return rt;
        }

        public function getPrevNode(pNode : LinkTableNode) : LinkTableNode
        {
            if (pNode == null) return null;
            var rt : LinkTableNode;
            if (pNode.prev != head)
            {
                rt = pNode.prev;
            }
            else
            {
                rt = pNode.prev.prev;
                if (rt == head)
                {
                    rt = null;
                }
            }
            return rt;
        }

        public function autoInsert(pNode : LinkTableNode) : void
        {
            var insertIdx : uint = pushInShortDic(pNode);

            // insertBefore(pNode,retrieveNode((shortDic[insertIdx] as Node).id));

            if (isEmpty())
            {
                // 链表为空的时候插入第一个节点
                firstInsert(pNode);
            }

            if (insertIdx == 0)
            {
                pNode.prev = head;
                pNode.next = head.next;
                head.next.prev = pNode;
                head.next = pNode;
                // //trace("process .... start");
            }
            else if (insertIdx == shortDic.length - 1)
            {
                pNode.next = head;
                pNode.prev = head.prev;
                head.prev.next = pNode;
                head.prev = pNode;
                // //trace("process .... end");
            }
            else
            {
                var prevNode : LinkTableNode = retrieveNode((shortDic[insertIdx - 1] as LinkTableNode).id);
                var nextNode : LinkTableNode = retrieveNode((shortDic[insertIdx + 1] as LinkTableNode).id);
                pNode.next = nextNode;
                pNode.prev = prevNode;
                prevNode.next = pNode;
                nextNode.prev = pNode;
                // //trace("process .... middle");
                // //trace(insertIdx,"    ",pNode.prev.id,pNode.id,pNode.next.id,"         ",pNode.prev.next.id,pNode.next.prev.id);
            }

            // printInfo();
        }

        public function printInfo() : void
        {
            var t : String = "";
            for (var i : uint; i < shortDic.length; i++)
            {
                t += shortDic[i].id + " , ";
            }
            // //trace(t,"<--- shortDic");

            var w : String = "";
            for (var j:Object in dictionary)
            {
                w += dictionary[j].id + " , ";
                // w+=j+ " , ";
            }
            // //trace(w,"<--- dictionary");
        }

        private function pushInShortDic(pNode : LinkTableNode) : uint
        {
            var aa : Array = shortDic;
            var rtIdx : uint = 0;
            if (shortDic.length > 0)
            {
                if (shortDic.length > 1)
                {
                    while (aa.length > 1)
                    {
                        var midx : uint = aa.length / 2;
                        var mNode : LinkTableNode = aa[midx] as LinkTableNode;
                        if (pNode.data.y > mNode.data.y)
                        {
                            aa = aa.slice(midx);
                        }
                        else
                        {
                            aa = aa.slice(0, midx);
                        }
                    }
                    // while end

                    if (pNode.data.y > (aa[0] as LinkTableNode).data.y)
                    {
                        rtIdx = shortDic.indexOf(aa[0]) + 1;
                        shortDic.splice(rtIdx, 0, pNode);
                        // //trace("after   ",rtIdx);
                    }
                    else
                    {
                        rtIdx = shortDic.indexOf(aa[0]);
                        shortDic.splice(rtIdx, 0, pNode);
                        // //trace("before   ",rtIdx);
                    }
                }
                else
                {
                    if (pNode.data.y > shortDic[shortDic.length - 1].data.y)
                    {
                        shortDic.push(pNode);
                    }
                    else
                    {
                        shortDic.splice(shortDic.length - 1, 0, pNode);
                        rtIdx = shortDic.length - 1;
                    }
                }
            }
            else
            {
                shortDic.push(pNode);
            }
            dictionary[pNode.id] = pNode;
            dictionary.length += 1;

            return rtIdx;
        }

        public function insertBefore(pNewNode : LinkTableNode, pOldNode : LinkTableNode = null) : void
        {
            // 默认插入到head后面
            pushInShortDic(pNewNode);
            if (isEmpty())
            {
                // 链表为空的时候插入第一个节点
                firstInsert(pNewNode);
            }
            else
            {
                if (pOldNode != null)
                {
                    pNewNode.prev = pOldNode.prev;
                    pNewNode.next = pOldNode;
                    pOldNode.prev.next = pNewNode;
                    // 插入节点前一个节点的next
                    pOldNode.prev = pNewNode;
                    // 旧节点的前一个节点对着新节点
                }
                else
                {
                    pNewNode.next = head.next;
                    pNewNode.prev = head;
                    head.next.prev = pNewNode;
                    head.next = pNewNode;
                }
            }
        }

        public function insertAfter(pNewNode : LinkTableNode, pOldNode : LinkTableNode = null) : void
        {
            // 默认插入到head前面
            pushInShortDic(pNewNode);
            if (isEmpty())
            {
                // 链表为空的时候插入第一个节点
                firstInsert(pNewNode);
            }
            else
            {
                if (pOldNode != null)
                {
                    pNewNode.prev = pOldNode;
                    pNewNode.next = pOldNode.next;
                    pOldNode.next.prev = pNewNode;
                    // 插入节点前一个节点的next
                    pOldNode.next = pNewNode;
                    // 旧节点的前一个节点对着新节点
                }
                else
                {
                    pNewNode.next = head;
                    pNewNode.prev = head.prev;
                    head.prev.next = pNewNode;
                    head.prev = pNewNode;
                }
            }
        }

        private function firstInsert(pNode : LinkTableNode) : void
        {
            head = new LinkTableNode();
            head.next = pNode;
            head.prev = pNode;
            pNode.next = head;
            pNode.prev = head;
        }

        public function breakNode(pNode : LinkTableNode) : void
        {
            if (!isEmpty() && pNode != null)
            {
                pNode.prev.next = pNode.next;
                pNode.next.prev = pNode.prev;
                shortDic.splice(shortDic.indexOf(pNode), 1);
                delete(dictionary[pNode.id]);
                dictionary.length -= 1;
                // printInfo();
            }
            else
            {
                // throw("You link table is empty !");
            }
        }

        public function clearNode(pNode : LinkTableNode) : void
        {
            if (pNode != null)
            {
                pNode.prev = null;
                pNode.next = null;
            }
        }

        public function swap(pANode : LinkTableNode, pBNode : LinkTableNode) : void
        {
            var tempNode : LinkTableNode = new LinkTableNode();
            tempNode.prev = pANode.prev;
            tempNode.next = pANode.next;

            var idxA : uint = shortDic.indexOf(pANode);
            var idxB : uint = shortDic.indexOf(pBNode);
            shortDic[idxA] = pBNode;
            shortDic[idxB] = pANode;

            // //trace("head ID= ", head.id)
            // //trace("@@@@@@@@@", getNextNode(pANode).id, pBNode.id, getPrevNode(pANode).id);
            if (getNextNode(pANode).id != pBNode.id && getPrevNode(pANode).id != pBNode.id)
            {
                pANode.prev = pBNode.prev;
                pBNode.prev.next = pANode;
                pANode.next = pBNode.next;
                pBNode.next.prev = pANode;

                pBNode.prev = tempNode.prev;
                tempNode.prev.next = pBNode;
                pBNode.next = tempNode.next;
                tempNode.next.prev = pBNode;
            }
            else
            {
                if (getPrevNode(pANode).id == pBNode.id)
                {
                    pANode.next.prev = pBNode;
                    pBNode.prev.next = pANode;

                    pANode.prev = pBNode.prev;
                    pANode.next = pBNode;
                    pBNode.prev = pANode;
                    pBNode.next = tempNode.next;
                    // //trace("A--->B");
                }
                else if (getNextNode(pANode).id == pBNode.id)
                {
                    pANode.prev.next = pBNode;
                    pBNode.next.prev = pANode;

                    pANode.prev = pBNode;
                    pANode.next = pBNode.next;
                    pBNode.prev = tempNode.prev;
                    pBNode.next = pANode;
                    // //trace("B--->A");
                }

                // //trace("+++++++++++++++++++++++++");
                // //trace(getPrevNode(pANode).data.name, pANode.data.name, getNextNode(pANode).data.name);
                // //trace(getPrevNode(pBNode).data.name, pBNode.data.name, getNextNode(pBNode).data.name);
            }
        }

        /**
         *
         * @param pMoveNode 需要移动的节点
         * @param pStep 需要移动的步数
         * @param selfCenter 是否以自己为中心，默认是以自己为中心移动。否则以头节点移动（以头节点移动方便直接定位到链子的最底层和最高层，虽然是个循环链，也可以当做单链）
         *
         */
        public function stepMove(pMoveNode : LinkTableNode, pStep : int, selfCenter : Boolean = true) : void
        {
            var targetNode : LinkTableNode;
            var step : uint = Math.abs(pStep);
            var i : uint = 1;

            if (pStep > 0)
            {
                // 向后移
                if (selfCenter)
                {
                    targetNode = pMoveNode;
                }
                else
                {
                    targetNode = head;
                }
                for (i = 0; i < step; i++)
                {
                    // //trace(targetNode.id," --- ",pMoveNode.id," --- ",getPrevNode(targetNode).id);
                    swap(pMoveNode, getNextNode(targetNode));
                }
                // //trace("后移");
            }
            else
            {
                // 向前移
                if (selfCenter)
                {
                    targetNode = pMoveNode;
                }
                else
                {
                    targetNode = head;
                }
                for (i = 0; i < step; i++)
                {
                    swap(pMoveNode, getPrevNode(targetNode));
                }
                // //trace("前移");
            }
        }

        public function toHeadmost(pNode : LinkTableNode) : void
        {
            // 移动节点到最前面
            stepMove(pNode, 1, false);
        }

        public function toBackmost(pNode : LinkTableNode) : void
        {
            // 移动节点到最后面
            stepMove(pNode, -1, false);
        }

        public function retrieveNode(id : uint) : LinkTableNode
        {
            return dictionary[id];
        }
    }
}
