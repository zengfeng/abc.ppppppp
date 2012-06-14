package game.module.battle
{
	import game.config.StaticConfig;
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarType;
	import game.core.user.StateManager;
	import game.core.user.StateType;
	import game.core.user.UserData;
	import game.module.battle.battleData.Area;
	import game.module.battle.battleData.AttackData;
	import game.module.battle.battleData.BtProcess;
	import game.module.battle.battleData.FighterInfo;
	import game.module.battle.battleData.PropInfo2Base;
	import game.module.battle.battleData.mapData;
	import game.module.battle.battleData.skillData;
	import game.module.battle.battleData.skillType;
	import game.module.battle.view.BTSystem;
	import game.module.map.utils.MapUtil;
	import game.net.core.Common;
	import game.net.data.StoC.SCBattleInfo;

    import com.commUI.LoaderPanel;
    
    import flash.events.Event;
    import flash.utils.setTimeout;
    
    import game.config.StaticConfig;
    import game.manager.RSSManager;
    import game.manager.SignalBusManager;
    import game.module.battle.battleData.Area;
    import game.module.battle.battleData.AttackData;
    import game.module.battle.battleData.BtProcess;
    import game.module.battle.battleData.FighterInfo;
    import game.module.battle.battleData.PropInfo2Base;
    import game.module.battle.battleData.mapData;
    import game.module.battle.battleData.skillData;
    import game.module.battle.battleData.skillType;
    import game.module.battle.view.BTSystem;
    import game.module.map.utils.MapUtil;
    import game.net.core.Common;
    import game.net.data.StoC.SCBattleInfo;
    
    import gameui.manager.UIManager;
    
    import log4a.Logger;


	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;

	import com.commUI.CommonLoading;

	import flash.events.Event;
    

    /**
     * @author yangyiqiang
     */
    public class BattleInterface
    {
        private var _load_lm : CommonLoading;

        public function BattleInterface() : void
        {
            _res = RESManager.instance;
            Common.game_server.addCallback(0x66, startBattle);
        }

        private var playerA : Player;
        private var playerB : Player;
        private var arr1 : Vector.<FighterInfo>;
        private	var arr2 : Vector.<FighterInfo>;
        public static var  DEBUG_RETURN_BATTLE : Boolean = false;

		/** 战斗开始 **/
		private function startBattle(msg : SCBattleInfo) : void
		{
			return;
			var i:int;
			var ispvp:Boolean = false;
			var playerRoleId:int;
			var playerRoleName:String = "";
			var playerLevel:int;
			var playerColor:uint;
			var enemyRoleId:int;
			var enemyLevel:int;
			var enemyRoleName:String = "";
			var enemyColor:uint;
			StateManager.instance.changeState(StateType.BATTLE);
			BTSystem.INSTANCE().isInBattle=true;
			_load_lm =Common.getInstance().loadPanel;
//			_load_lm.model = _res.model;
			ForRand.setRandSeed(msg.randomseed);
			BTSystem.INSTANCE().mySide = msg.myside;
			if(msg.hasPlayeraid)
			{
				if(UserData.instance.playerId == msg.playeraid)
					BTSystem.INSTANCE().mySide = 0;		
			}
			
			if(msg.hasPlayerbid)
			{
				if(UserData.instance.playerId == msg.playerbid)
					BTSystem.INSTANCE().mySide = 1;	
				
				ispvp = true;
			}

			BTSystem.INSTANCE().setFightType(msg.overtype);
			BTSystem.INSTANCE().setEarnExp(msg.exp);
			var rewardlist:Array = [];
			for(i = 0; i < msg.itemlist.length; i++)
			{
				rewardlist.push(msg.itemlist[i]);
			}
			BTSystem.INSTANCE().setRewardList(rewardlist);

			var max : int = msg.vecpropertyb.length;
			arr1 = new Vector.<FighterInfo>();
			arr2 = new Vector.<FighterInfo>();
			for (i = 0; i < max;i++)
			{
				var info : FighterInfo = new FighterInfo();
				info.pInfo2 = new PropInfo2Base().clonePropertyB(msg.vecpropertyb[i]);
	            info.initHp = info.pInfo2.health;
				info.maxHp = info.pInfo2.maxhp; 
				info.setMaxGauge(info.pInfo2.gaugeMax);
				info.setGaugeUse(info.pInfo2.gaugeUse);
				info.id = msg.vecpropertyb[i].id;
				info.fID = info.pInfo2.formationid;   //阵型id
				info.name =info.id<10?msg.vecpropertyb[i].fname:"";
				info.job = msg.vecpropertyb[i].job;
				info.ftype = msg.vecpropertyb[i].ftype;
				info.weaponId = msg.vecpropertyb[i].weaponid;
				info.skillId = msg.vecpropertyb[i].skillid;
				info.side = msg.vecpropertyb[i].side;
				
				info.pos = msg.vecpropertyb[i].pos;
				info.setLevel(msg.vecpropertyb[i].level);
				info.setCloth((msg.vecpropertyb[i].color >> 4) & 0xF);
				info.setColor((msg.vecpropertyb[i].color) & 0xF);
				///Logger.debug("info.side="+info.side,"info.pos====>"+info.pos);
				(info.side == 0) ? arr1.push(info) : arr2.push(info);	
				
				//test
				//				if(info.id == 2)
				//   			{
				//					info.skillId = 2;
				//info.pInfo2.gaugeInit = 200;
				//info.pInfo2.critical = 0.8;
				//info.pInfo2.pierce = 0.8;
				//info.pInfo2.dodge = 0.5;
				//				}
				
				info.resetKey();
				if(BTSystem.INSTANCE().mySide == 1)
				{
					if(info.side == 0)
						info.side = 1;
					else if(info.side == 1)
						info.side = 0;
				}
				
				if(ispvp)
				{
					if(info.side == 0 && info.id <= 6)
					{
						playerRoleId = info.id;
						playerRoleName = info.name;
						playerLevel = info.getLevel();
						playerColor = info.getColor();
					}
					else if(info.side == 1 && info.id <= 6)
					{
						enemyRoleId = info.id;
						enemyRoleName = info.name;
						enemyLevel = info.getLevel();
						enemyColor = info.getColor();
					}
				}
				else
				{
					if(info.side == 0 && info.id <= 6)
					{
						playerRoleId = info.id;
						playerRoleName = info.name;
						playerLevel = info.getLevel();
						playerColor = info.getColor();
					}
					else
					{
						enemyRoleId = info.id;  //monster role id
						enemyRoleName = info.name;
						enemyLevel = info.getLevel();
						enemyColor = info.getColor();
					}
					
				}
				

				_res.add(new SWFLoader(new LibData(info.getAvatarUrl(),info.getAvatarUrl(),true,false),AvatarManager.instance.getAvatarBD(info.key).parse,[info.getAvatarUrl(),1]));
				if(info.skillId>0){
										
					var skillUUID:int;
					var skilltype:int;
					var url:String;
					var frontOrback:uint = info.side ? 0 : 1;
							
					var pskilldata:skillData = AttackData.skilllist[info.skillId];
					if (pskilldata == null)	continue;
					var atkarea:Area = AttackData.arealist[pskilldata.atkID];
					if(atkarea == null)continue;
		
					//加载技能动画1
					trace(pskilldata.getSpellEftId());
					if(pskilldata.getSpellEftId() > 0) //需要加载技能动画
					{
						if(pskilldata.getCanTurnOver() == 0 || pskilldata.getCanTurnOver() == 1 )
						{
							skillUUID=AvatarManager.instance.getUUId(info.getSpellEftId(), AvatarType.SKILL_TYPE_SPELL, 1);
							url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
							_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
							BTSystem.INSTANCE().RESOURCES.push(skillUUID);
							
						}
						else if(pskilldata.getCanTurnOver() == 2)
						{
							skillUUID=AvatarManager.instance.getUUId(info.getSpellEftId(), AvatarType.SKILL_TYPE_SPELL, frontOrback);
							url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
							_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
							BTSystem.INSTANCE().RESOURCES.push(skillUUID);
						}	
					}
					
					//需要加载地面效果
					if(pskilldata.getGroundSkillID() > 0)
					{
						if(pskilldata.getGroundCanTurnOver() == 0 || pskilldata.getGroundCanTurnOver() == 1)
						{
							skillUUID=AvatarManager.instance.getUUId(pskilldata.getGroundSkillID(), AvatarType.SKILL_TYPE_GROUND, 1);
							url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
							_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
							BTSystem.INSTANCE().RESOURCES.push(skillUUID);
						}
						else if(pskilldata.getGroundCanTurnOver() == 2)
						{
							skillUUID=AvatarManager.instance.getUUId(pskilldata.getGroundSkillID(), AvatarType.SKILL_TYPE_GROUND, frontOrback);
							url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
							_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
							BTSystem.INSTANCE().RESOURCES.push(skillUUID);
						}
					}
					
					//,,,,
					//加载技能动画2
					if(pskilldata.getSpellEftId2() > 0) //需要加载技能动画
					{
						if(pskilldata.getCanTurnOver2() == 1)  //可以翻转
						{
							skillUUID=AvatarManager.instance.getUUId(info.getSpellEftId2(), AvatarType.SKILL_TYPE_SPELL, 1);
							url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
							_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
							BTSystem.INSTANCE().RESOURCES.push(skillUUID);
							
						}
						else if(pskilldata.getCanTurnOver2() == 2)
						{
							skillUUID=AvatarManager.instance.getUUId(info.getSpellEftId2(), AvatarType.SKILL_TYPE_SPELL, 1-frontOrback);  //因为是给己方的效果
							url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
							_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
							BTSystem.INSTANCE().RESOURCES.push(skillUUID);
						}	
					}
					
					//需要加载地面效果
					if(pskilldata.getGroundSkillID2() > 0)
					{
						skillUUID=AvatarManager.instance.getUUId(pskilldata.getGroundSkillID2(), AvatarType.SKILL_TYPE_GROUND, 1);
						url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
						_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
						BTSystem.INSTANCE().RESOURCES.push(skillUUID);
					}
					
					//加载buff
					if(pskilldata.getBuffID() > 0)  //需要加载buff
					{		
						//skilltype = atkarea.getType(); 
						skillUUID=AvatarManager.instance.getUUId(pskilldata.getBuffID(), AvatarType.BUFF_TYPE);
						url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
						_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
						BTSystem.INSTANCE().RESOURCES.push(skillUUID);
					}
					
					//加载buff2
					if(pskilldata.getBuffID2() > 0)  //需要加载buff
					{		
						//skilltype = atkarea.getType(); 
						skillUUID=AvatarManager.instance.getUUId(pskilldata.getBuffID2(), AvatarType.BUFF_TYPE);
						url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
						_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
						BTSystem.INSTANCE().RESOURCES.push(skillUUID);
					}
					
					if(0 == i)  //单独加载聚气
					{
						skillUUID=AvatarManager.instance.getUUId(skillType.GAUGEFULL, AvatarType.BUFF_TYPE);
						url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
						_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
						BTSystem.INSTANCE().RESOURCES.push(skillUUID);
						
						skillUUID=AvatarManager.instance.getUUId(skillType.GAUGEFULL+1, AvatarType.BUFF_TYPE);
						url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
						_res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
						BTSystem.INSTANCE().RESOURCES.push(skillUUID);
					}
										
			
					//加载技能名字
					
					
                    // if(pskilldata.getOverType() > 0)
                    // {
                    // switch(pskilldata.getOverType())
                    // {
                    // case 1:      // 物理正反面,技能正反面         （只正面：两边人只播放正面 ，只反面：对面人播放时技能需翻转）
                    // {
                    // skillUUID=AvatarManager.instance.getUUId(info.getPhyShowID(), AvatarType.SKILL_TYPE_PHY, frontOrback);
                    // url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
                    // _res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
                    //								
                    // skillUUID=AvatarManager.instance.getUUId(info.getSpellShowID(), AvatarType.SKILL_TYPE_SPELL, frontOrback);
                    // url=StaticConfig.cdnRoot + "assets/avatar/" + skillUUID+".swf";
                    // _res.add(new SWFLoader(new LibData(url,url,true,false),AvatarManager.instance.getAvatarBD(skillUUID).parse,[url,2]));
                    // break;
                    // }
                    // }
                    // }
                }
            }
			
			//设置头像id
			BTSystem.INSTANCE().setPlayerRoleID(playerRoleId);
			BTSystem.INSTANCE().setPlayerRoleName(playerRoleName);
			BTSystem.INSTANCE().setPlayerLevel(playerLevel);
			BTSystem.INSTANCE().setEnemyRoleID(enemyRoleId);
			BTSystem.INSTANCE().setEnemyLevel(enemyLevel);
			BTSystem.INSTANCE().setEnemyRoleName(enemyRoleName);
			BTSystem.INSTANCE().setPlayerColor(playerColor);
			BTSystem.INSTANCE().setEnemyColor(enemyColor);
			
            BtProcess.selfList = arr1;
            BtProcess.enemyList = arr2;
            playerA = new Player();
            playerB = new Player();
            playerA.putFighterInfoArr(arr1);
            playerB.putFighterInfoArr(arr2);
            _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + "assets/avatar/battle/die.swf", "diessss")));
			BTSystem.INSTANCE().RESOURCES.push("diessss");
			
            // if(MapUtil.isDungeonMap() == true)
            // {
            // _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot+"assets/battleBG/dugeon.jpg","dugeon")));
            // }
            // else
            // {
            // if(MapUtil.getCurrentMapId() == 1)
            // {
            // _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot+"assets/battleBG/cloud.jpg","cloud")));
            // }
            // else
            // {
            // _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot+"assets/battleBG/tree.jpg","tree")));
            // }
            // }
            //trace(BTSystem.INSTANCE().getFightTypeID());
            var mapID : uint;
            var picNameStr : String;
            var mapD : mapData;

            // var arr:Array = [];
            // BTSystem.INSTANCE().setFightType((9<<8));
            // arr.push((2007<<16) + 2);
            // arr.push((2551<<16) + 2);
            // arr.push((2551<<16) + 3);
            // arr.push((25003<<16) + 200);
            // arr.push((25004<<16) + 500);
            // arr.push((2106<<16) + 2);
            // arr.push((2106<<16) + 2);
            // arr.push((2551<<16) + 3);
            // arr.push((2551<<16) + 4);
            // BTSystem.INSTANCE().setRewardList(arr);
            // 加载背景图
            if (BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_DUGEON)  // 副本
            {
                mapID = MapUtil.getCurrentMapId();
                mapD = AttackData.mapidlist[mapID] as mapData;
                picNameStr = mapD.urlStr;
                if (mapID % 2 == 0) // 大boss截图
                {
                    // 截图
                }
                else if (mapID % 2 == 1) // 小boss单独背景图
                {
                    _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + picNameStr, picNameStr)));
					BTSystem.INSTANCE().RESOURCES.push(picNameStr);
					
                }
            }
            else if (BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_QUESTNPC)  // 任务,单独背景图
            {
                mapID = MapUtil.getCurrentMapId();
                mapD = AttackData.mapidlist[mapID] as mapData;
                picNameStr = mapD.urlStr;
                _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + picNameStr, picNameStr)));
				BTSystem.INSTANCE().RESOURCES.push(picNameStr);
            }
            else if (BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_COUNTRY || BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_BOSS || BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_GUILDDUGEON)// 国战，boss战，家族boss战，截图
            {
                // 截图
            }
            else if (BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_GUARD || BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_GBODYGUARD || BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_ATHLETICS)  // 运镖，家族运镖，竞技场，锁妖塔，单独背景图
            {
                // 单独load地图
                mapID = BTSystem.FT_GUARD * 100000;
                mapD = AttackData.mapidlist[mapID] as mapData;
                picNameStr = mapD.urlStr;
                _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + picNameStr, picNameStr)));
				BTSystem.INSTANCE().RESOURCES.push(picNameStr);
            }
            else if ( BTSystem.INSTANCE().getFightTypeID() == BTSystem.FT_LOCKBOSS)
            {
                mapID = BTSystem.FT_LOCKBOSS * 100000;
                mapD = AttackData.mapidlist[mapID] as mapData;
                picNameStr = mapD.urlStr;
                _res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + picNameStr, picNameStr)));
				BTSystem.INSTANCE().RESOURCES.push(picNameStr);
            }

            _res.addEventListener(Event.COMPLETE, loadComplete);
            _load_lm.startShow();
            _res.startLoad();
        }

        private var _res : RESManager;

        private function loadComplete(evt : Event) : void
        {
            _load_lm.hide();
            _res.removeEventListener(Event.COMPLETE, loadComplete);
            playerA.assault(playerB);
            BTSystem.INSTANCE().b_Result = playerA.getBattleResult();
            BTSystem.INSTANCE().start();
        }
    }
}
