package game.module.map.animal
{
	import game.core.avatar.AvatarThumb;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.animalstruct.StoryStruct;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-20 ����9:01:05
	 */
	public class StoryAnimal extends Animal
	{
		public function StoryAnimal(avatar : AvatarThumb, struct : AbstractStruct)
		{
			super(avatar, struct);
		}

		override protected function init() : void
		{
			var index : int;
			if (childIndex == 0)
			{
				linkNode = new AnimationLinkNode();
				linkNode.data = avatar;
				index = linkList.sortAdd(linkNode);
				index += elementLayer.getMaxIndexGate() + 1;
				try
				{
					if (elementLayer) elementLayer.addChildAt(avatar, index);
				}
				catch(error : Error)
				{
					//trace(index);
				}
			}
			else if (childIndex == 1)
			{
				index = elementLayer.getMinIndexMask();
				if (index > elementLayer.numChildren)
				{
					elementLayer.addChildAt(avatar, elementLayer.numChildren - 1);
				}
				else
				{
					elementLayer.addChildAt(avatar, index);
				}
			}
			else if (childIndex == -1)
			{
				index = elementLayer.getMaxIndexGate() + 1;
				if (index > elementLayer.numChildren)
				{
					elementLayer.addChildAt(avatar, elementLayer.numChildren - 1);
				}
				else
				{
					elementLayer.addChildAt(avatar, index);
				}
			}
		}

		/** 更新显示索引 */
		override protected function updateChildIndex() : void
		{
			if (childIndex != 0) return;
			super.updateChildIndex();
		}

		public function get storyStruct() : StoryStruct
		{
			return _struct as StoryStruct;
		}

		public function get childIndex() : int
		{
			return storyStruct.childIndex;
		}
	}
}
