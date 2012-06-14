package com.commUI.tooltip
{
	import com.utils.StringUtils;
	import game.core.user.UserData;
	import game.module.compete.VoCompeteToolTip;

	/**
	 * @author jian
	 */
	public class CompeteUserTip extends ToolTip
	{   
		private var _userVO : UserData = UserData.instance;
		
		public function CompeteUserTip(data : ToolTipData)
		{
			super(data);
		}

		override protected function getToolTipText() : String
		{
			var text : String = "";
			var user : VoCompeteToolTip = _source as VoCompeteToolTip;
		//	text += '<font size="14" color=""><b>' + user.name + " " + user.level + "级" + '</b></font>' + "\r";
			if(user.isuser==false)
			{
			text +='<font size="14" ><b>'+StringUtils.addColorById(user.name,user.color+1)+'</b></font>'+'<font size="14" ><b> ' + user.level+ "级" +'</b></font>' + "\r";
			}
			else
			{
				text +='<font size="14" ><b>'+_userVO.myHero.htmlName+'</b></font>'+'<font size="14" ><b> ' + user.level+ "级" +'</b></font>' + "\r";
			}
			text += "排名：" + "<font size='12' color='#FFCC00'>"+user.rank +"</font>"+"\r";
			text += "<font size='12' color='#ffffff'>每期排名奖励：</font>"+"\r";		
			text += "<font size='12' color='#FFCC00'>"+user.honor+"</font>" +"修为" +" <font size='12' color='#FFCC00'>"+ user.silver+"</font>" +"银币" +  "\r";
			if(user.equipment=="潜力保护符×1")
			text +="<font size='12'>"+StringUtils.addColorById(user.equipment,5)+"</font>"+"\r";
			else
			{
			text +="<font size='12',color='#ffffff'>"+user.equipment+"</font>"+"\r";
			}
			return text;
		}
	}
}
