package game.module.demonTower.demonTips {
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipData;
	import game.module.duplMap.data.DuplStruct;

	/**
	 * @author Lv
	 */
	public class DemonUpTips extends ToolTip {
		public function DemonUpTips(data : ToolTipData) {
			super(data);
		}
		override protected function getToolTipText():String
		{
			var text : String = "";
			var item : DuplStruct = _source as DuplStruct;
			text += "进入等级："+String(item.enterLevel)+" \r";
			text += "掉落物品："+ item.itemStr + "\r";
			return text;
			
			
//			var item : DuplStruct = _source as DuplStruct;
//			text += StringUtils.addColor(StringUtils.addSize(StringUtils.addBold(item.name),14),"#FFFF00")+" \r";
//			text += StringUtils.addColor("掉落","#000000") + "\r";
//			text += item.
		}
	}
}
