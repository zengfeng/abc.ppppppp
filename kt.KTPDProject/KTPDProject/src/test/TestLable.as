package test
{
	import com.utils.UICreateUtils;
	import com.utils.StringUtils;
	import flash.text.TextField;
	import game.core.hero.HeroConfig;
	import game.core.hero.VoHero;
	import gameui.controls.GLabel;
	import gameui.controls.GToolTip;
	import gameui.data.GLabelData;
	import gameui.data.GToolTipData;
	import project.Game;





	/**
	 * @author yangyiqiang
	 */
	[ SWF ( frameRate="60" , backgroundColor=0x333333 ) ]
	public class TestLable extends Game
	{
		public function TestLable()
		{
			super();
			addView();
		}

		private var textFile : TextField;
		private var lable:GLabel;
		private var _text:String="asfdasfdqefwfwefwefwefwe/nfwefwefwefwefwefwef"; 
		private var _tip:GToolTip;

		private function addView() : void
		{
			textFile=UICreateUtils.createTextField("asfdasf");
			textFile.wordWrap=true;
//			textFile.htmlText=getToolTipText();
//			textFile.width=100;
			addChild(textFile);
//			var data:GLabelData=new GLabelData();
//			data.y=60;
//			lable=new GLabel(data);
//			lable.htmlText=getToolTipText();
//			addChild(lable);
//			var tipD:GToolTipData=new GToolTipData();
//			tipD.x=300;
//			_tip=new GToolTip(tipD);
//			_tip.source=getToolTipText();
//			addChild(_tip);
		}
		
		protected function getToolTipText():String
		{
			var text : String = "";
			var hero : VoHero = new VoHero();
			var heroConfig:HeroConfig=new HeroConfig();
			hero.config=heroConfig;
			text += "<b>" + hero.htmlName + " " + hero.level + "级" + "</b>" + "\n";
			text += "职业：" + hero.jobName + "\n";
			// TODO
			text += "战斗力：" + hero.bt + "\n\n";
			text += StringUtils.addColor("CTRL+左键发送到聊天频道", "#999999");
			
			return text;
		}
	}
}
