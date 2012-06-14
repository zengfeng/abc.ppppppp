package game.module.battle
{
	import game.module.battle.battleData.Area;
	import game.module.battle.battleData.AttackData;
	import game.module.battle.battleData.AttackPoint;
	import game.module.battle.battleData.BtBuffProcess;
	import game.module.battle.battleData.BtDefend;
	import game.module.battle.battleData.BtInit;
	import game.module.battle.battleData.BtInitProcess;
	import game.module.battle.battleData.BtOneAtk;
	import game.module.battle.battleData.BtProcess;
	import game.module.battle.battleData.BtRescued;
	import game.module.battle.battleData.BtStatus;
	import game.module.battle.battleData.Data;
	import game.module.battle.battleData.FighterStatus;
	import game.module.battle.battleData.PointEffect;
	import game.module.battle.battleData.PropInfo2Base;
	import game.module.battle.battleData.buffEffect;
	import game.module.battle.battleData.skillData;
	import game.module.battle.battleData.skillManager;
	import game.module.battle.battleData.skillType;
	import game.module.battle.view.BTSystem;
	import log4a.Logger;
	

	//
   

	public class BattleSimulator extends BattleField
	{
		static public  function  CompLess(lhs:BattleFighter , rhs:BattleFighter):int           //耗血由大到小排
		{
			if( lhs.getHpConsume() > rhs.getHpConsume())
				return -1;
			else if(lhs.getHpConsume() == rhs.getHpConsume())
				return 0;
			else 
				return 1;
		}
		
		public function BattleSimulator( player1:Player, player2:Player, location:uint, maxTurns:uint = 4294967295 )
		{
			super();
			_player[0] = player1;
			_player[1] = player2;
			_portrait[0] = 0;
			_portrait[1] = 0;
			//将将领加入阵中
			player1.put(this as BattleSimulator, 0);
			player2.put(this as BattleSimulator, 1);
		}
		
		private function getId():int
		{
			return _id;
		}
		
		private function getTurns():int
		{
			return _turns;
		}
		
		private function getMilliSecs():int
		{
			return _millisecs;
		}
		
		private function getWinner():int
		{
			return _winner;
		}
		
		private function setPortrait(side:uint, por:uint):void
		{
			_portrait[side] = por;
		}
		
		private function getMaxAction():int
		{
			return _maxAction;
		}
		
		private function setMaxAction(mxA:int):void
		{
			_maxAction = mxA;
		}
		
		public function newFighter(prop:PropInfo2Base, weaponType:uint, skillId:uint, side:uint, pos:uint, nstr:String, fID:uint, jobID:uint):BattleFighter
		{
			var pEf:PointEffect = Formation.Formationlist[fID];
			var bft:BattleFighter = new BattleFighter(prop, weaponType, skillId, side, pos, nstr, pEf, jobID);
			setObject(side, pos, bft);
			return bft;
		}
		
		private function getRandomFighter(side:uint, excepts:Array):BattleFighter
		{
			var posList:Array = [];
			var posSize:uint = 0;
			for(var i:int = 0; i < 25; ++i)
			{
				var bft:BattleFighter = _objs[side][i];
				if(bft == null || bft.getHP() == 0)
					continue;
				var except:Boolean = false;
				for(var j:int = 0; j < excepts.length; ++j)
				{
					if(excepts[j] == i)
					{
						except = true;
						break;
					}
				}
				if(except)
				{
					continue;
				}
				posList[posSize++] = i;
			}
			if(posSize == 0)
			{
				return null;
			}
			return _objs[side][posList[int(ForRand.getRand(posSize))]];
		}
	
		private function onDead(bo:BattleFighter):void
		{
			if(bo != null)
			{

				var toremove:FighterStatus = new FighterStatus();
				toremove.bfgt = bo;
				removeFighterStatus(toremove);
				
				_winner = testWinner();
			}
		}
		
        private function testWinner():uint
		{
		   var c:uint = _fgtlist.length;
		   var alive:Array = [0,0];
		   for(var i:int = 0; i < c; ++i)
		   {
			   alive[_fgtlist[i].bfgt.getSide()]++;
		   }
		   
		   if(alive[0] == 0)
		   {
			   return 2;
		   }
		   else if(alive[1] == 0)
		   {
			   return 1;
		   }
		   return 0; 
	   }
	   
	   
	      
	   public function start():int                //战斗开始
	   {	
		   ///Logger.debug("**********Begin to Fight*********");
		   
		   //清理上一战斗的数据
		   BTSystem.INSTANCE().clearLastBattle();
		   
		   //设置阵型buffer
		   addBufferByFormation();
		   
		   //设置选择规则
		   setAntiAction();
		   
		   //为战斗表现，判断战斗前阵上所有人的buff状态（目前仅有聚气这一种）
		   getNowBuffEfft();
		   
		   //初始tip
		   getInitGaugeAndHP();
		   
		   var act_count:uint = 0;
		   _winner = testWinner();
		   while(_winner == 0)
		   {
			   var pos:int = findFirstAttacker();
			   act_count += doAttack(pos);
		   }
		   
		   if(act_count == 0)
		   {
			   _winner = 1;
		   }
		   return _winner;
	   }
	   
	   private function getNowBuffEfft():void
	   {
		   var i:int;
		   var j:int;
		   for(i = 0; i < 2; ++i)
		   {
			   for(j = 0; j < 25; ++j)
			   {
				   var bf:BattleFighter = _objs[i][j];
				   if(bf != null)
				   {
					   //判断聚气
					   if(bf.getGauge() >= bf.getTrigger())
					   {
						   bf.setbHasGaugebuff(true);
							   
						   var btPro:BtBuffProcess = new BtBuffProcess();
						   var bs:BtStatus = new BtStatus();
						   bs.atkorBackatk = 2;
						   bs.sideFrom = bf.getSide();
						   bs.toside = bf.getSide();
						   bs.fpos = bf.getPos();
						   bs.tpos = bf.getPos();
						   bs.skillid = skillType.GAUGEFULL;
						   bs.type = 1;   //聚气满
						   btPro.StatusList.push(bs);
						   BtBuffProcess.data.push(btPro);
					   }
				   }
			   }
		   }
	   }
	   
	   private function getInitGaugeAndHP():void
	   {
		   var i:uint;
		   var j:uint;
		   for(i = 0; i < 2; ++i)
		   {
			   for(j = 0; j < 25; ++j)
			   {
				   var bf:BattleFighter = _objs[i][j];
				   if(bf)
				   {
					   var bin:BtInit = new BtInit();
					   bin.pside = bf.getSide();
					   bin.ppos = bf.getPos();
					   bin.pHp = bf.getHP();
					   bin.pGauge = bf.getGauge();
					   BtInitProcess.data.push(bin);
				   }
			   }
		   }
	   }
	   
	   private function setAntiAction():void
	   {
		   var maxa:int = 0;
		   var i:int;
		   var j:int;
		   for(i = 0; i < 2; ++i)
		   {
			   for(j = 0; j < 25; ++j)
			   {
				   var pf1:BattleFighter = _objs[i][j];
				   if(pf1 != null)
				   {
					   if(maxa < pf1.getSpeed())
					   {
						   maxa = pf1.getSpeed();
					   }
				   }
			   }
		   }
		   setMaxAction(maxa);               //设置最大的action
		   
		   for(i = 0; i < 2; ++i)
		   {
			   for(j = 0; j < 25; ++j )
			   {
				   var pf2:BattleFighter = _objs[i][j];
				   if(pf2 != null)
				   {
					   pf2.setCoolDown(uint((maxa * maxa)/pf2.getSpeed()));
					   var fs:FighterStatus = new FighterStatus(pf2, maxa, pf2.getCoolDown());
					   insertFighterStatus(fs);
				   }
			   }
		   }
	   }
	   
	   private function insertFighterStatus(fs:FighterStatus):void
	   {
		   var cnt:int = _fgtlist.length;
		   var tempA:Array = [];
		   for(var i:int = cnt-1; i >= 0; --i)
		   {
			   if(_fgtlist[i].antiAction < fs.antiAction)
			   {
				//   _fgtlist.splice(i+1,1,fs);
				   tempA = _fgtlist.splice(i+1);
				   _fgtlist.push(fs);
				   _fgtlist = _fgtlist.concat(tempA);
				   return;
			   }
		   }
		   _fgtlist.unshift(fs);
	   }
	   
	   private function removeFighterStatus(fs:FighterStatus):void
	   {
		   var c:uint = _fgtlist.length;
		   var i:uint = 0;
		   while(i < c)
		   {
			   if(_fgtlist[i].bfgt == fs.bfgt)
			   {
				   _fgtlist.splice(i, 1);
				   --c;
			   }
			   else
			   {
				   ++i
			   }
		   }
	   }
	   
	   private function removeFSByMark(pf:BattleFighter, mark:uint):void       //删除动作队列中已经存在的来自同一个人的动作
	   {
		   var c:uint = _fgtlist.length;
		   var i:uint = 0;
		   while(i < c)
		   {
			   if( _fgtlist[i].atkMark != 0 && _fgtlist[i].atkMark == mark && _fgtlist[i].bfgt == pf )
			   {
				   _fgtlist.splice(i, 1);
				   --c;
			   }
			   else
			   {
				   ++i;
			   }
		   }
	   }
	   
	   private function doAttack(pos:int):uint
	   {
		   var fs:FighterStatus = _fgtlist[pos];
		   var bf:BattleFighter = fs.bfgt;
		   if(bf == null)
		   {
			   return 0;
		   }
		   
		   //给客户端数据
		   var pPro:BtProcess = new BtProcess();
		   
		   _fgtlist.splice(pos, 1);
		   
		   //update all action points
		   var minact:uint = fs.antiAction;
		   for(var i:int = 0; i < _fgtlist.length; ++i)
		   {
			   if(_fgtlist[i].bfgt.getHP() == 0)
				   continue;
			   _fgtlist[i].MinusAction(minact);
		   }
		   
		   //此处判断中毒效果
		   if(fs.poisonAction)
		   {
			   if(bf.getHP() > 0)
			   {
				   var fdmg:int = fs.poisonDamage;
				   bf.makeDamage(fdmg);
				   var rd:uint = bf.getPRound();
				   bf.setPRound(--rd);
				   var bdie:int = 0;
				   if(bf.getHP() == 0)
				   {
					   onDead(bf);
					   bdie = 1;
				   }
				   
				   // Logger.debug("Posion------------------------------------");
				   // Logger.debug("Posion:" +  "side:" + bf.getSide() + "  Pos:" + bf.getPos() +"  HPDamage" + fdmg);
				   
				   var pBuf:BtStatus = new BtStatus();
				   pBuf.atkorBackatk = 0;
				   pBuf.data = -fdmg;
				   pBuf.letDie = bdie;
				   bf.MinusBuffRound(skillType.POISONTYPE, pPro, 0, pBuf);
			   }
			   return 1;
		   }
		   else
		   {
			   //有加速buff，减少一轮
			   bf.MinusBuffRound(skillType.SPEEDTYPE, pPro, 0);
			   
			   //有加速速buff,减少一轮
			   bf.MinusBuffRound(skillType.SLOWTYPE, pPro, 0);
			     			   			   
			   fs.resetAntiAction();
			   insertFighterStatus(fs);
		   }
		   
		   //判断是否是眩晕
		   var stun:uint = bf.getStunRound();
		   if(stun > 0)
		   {
			   --stun;
			   bf.setStunRound(stun);
			   if(stun >= 0)
			   {
				   
				   ///Logger.debug("stun------------------------------------");
				   ///Logger.debug("OnStun:" + bf.getSide() + "/" + bf.getPos());
				   bf.MinusBuffRound(skillType.STUNTYPE, pPro, 0);
				   return 0; 
			   }
		   }
		   
		   setAllPlayerDodge(false);
		   
		   if(bf.getGauge() >= bf.getTrigger())
		   {
			   //技能攻击
			   doSkillAttack(bf, pPro);
		   }
		   else
		   {
			   //物理攻击
			   doPhyAttack(bf, pPro);
		   }
		   
		   
		   //有暴击buff的,减少一轮
		   bf.MinusBuffRound(skillType.ADDCRIT, pPro, 0);
		   
		   //有破击buff，减少一轮
		   bf.MinusBuffRound(skillType.ADDPIERCE, pPro, 0);
		   
		   //有降低命中率的buff,去掉一轮
		   bf.MinusBuffRound(skillType.REDUCEHITRATE, pPro, 0);
	
		   //有加攻击的，减少一轮buff
		   bf.MinusBuffRound(skillType.ADDATTACK, pPro, 0);
		   
		   //有给自己加攻击的，减少一轮
		   bf.MinusBuffRound(skillType.ADDMYSELFATTACK, pPro, 0);
		   
		   return 1;
	   }
	   
	   
	   private function attackOncePhy(bf:BattleFighter, targetbf:BattleFighter, factor:Number, counter_deny:int, isCrit:Boolean, ispierce:Boolean, bGather:Boolean, pPro:BtProcess):uint
	   {
		   if(targetbf == null || targetbf.getHP() == 0)
			   return 0; 
		   var fdmg:uint;
		   var defender:BtDefend = new BtDefend();
		   defender.pos = targetbf.getPos();
	
		   if(bf.isCalcHit(targetbf))     //命中
		   {
			   var dmg:Number;
			   if(isCrit && ispierce)     //暴破
			   {
				   dmg = bf.calcCritpiercePhyAtk(targetbf);
			   }
			   else if(isCrit)
			   {
				   dmg = bf.calcCritPhyAtk(targetbf);
			   }
			   else if (ispierce)
			   {
				   dmg = bf.calcpiercePhyAtk(targetbf);
			   }
			   else
			   {
				   dmg = bf.calcNormalPhyAtk(targetbf);
			   }
			   
			   //如果触发聚气
			   if(bGather)
			   {
				   if (isCrit && ispierce)  //触发暴破
				   {
					   bf.addQiGather(50, true, pPro, 0);
					   targetbf.addQiGather(30, true, pPro, 0);
				   }
				   else if (isCrit)
				   {
					   bf.addQiGather(40, true, pPro, 0);
					   targetbf.addQiGather(30, true, pPro, 0);
				   }
				   else if (ispierce)
				   {
					   bf.addQiGather(40, true, pPro, 0);
					   targetbf.addQiGather(30, true, pPro, 0);
				   }
				   else
				   {
					   bf.addQiGather(30, true, pPro, 0);
					   targetbf.addQiGather(30, true, pPro, 0);
				   }
			   }
			   dmg = uint(dmg * factor);
			   
			   //判断格挡
			   var resisFac1:Number = targetbf.getResistanceFac();
			   fdmg = uint(dmg*(1.0-resisFac1));
			   targetbf.MinusBuffRound(skillType.RESISTANCE, pPro, 0);   //来自其它人的格挡作用轮数减去一轮
			  
			   //判断伤害加深
			   var hurtFac1:Number = targetbf.getDeepHurtFac();
			   fdmg += uint(dmg*hurtFac1);
			   targetbf.MinusBuffRound(skillType.DEEPHURT, pPro, 0);
			   
			   targetbf.makeDamage(fdmg);
			   		   
			   //判断是否dead
			   if(targetbf.getHP() == 0)
			   {
				   onDead(targetbf);
			   }
			   		   
			   defender.damage = fdmg;   //显示伤害
			   defender.leftHp = targetbf.getHP();
			   trace(defender.leftHp);
			   
			  ///Logger.debug("PHYSIC:-"+bf.getSide()+"-"+bf.getPos()+"-"+targetbf.getPos()+"--HPDmg"+fdmg);
		   }
		   else
		   {
			   //首要目标躲闪,聚气
			   if(bGather)
			   {
				   targetbf.addQiGather(30, true, pPro, 0);
			   }	
			   ///Logger.debug("PHYSIC:-"+bf.getSide()+"-"+bf.getPos()+"-"+targetbf.getPos()+"--Miss");
			   defender.damage = -1;   //显示伤害
			   defender.leftHp = targetbf.getHP();
		   }
		   
		   
		   //判断反击
		   if(_winner == 0 && counter_deny > 0 && bf.getHP() > 0 && targetbf.getHP() > 0 && targetbf.isCounter() && bGather) //首要目标才能触发反击
		   {
			   //如果命中
			   if(targetbf.isCalcHit(bf))
			   {
				   var backdmg:Number;    //反击伤害
				   var isbCrit:Boolean = false;
				   isbCrit = targetbf.isCritAttack(bf);
				   var isbpierce:Boolean = false;
				   isbpierce = targetbf.ispierceAttack(bf);
				   if(isbCrit && isbpierce)   //触发暴破
				   {
					   backdmg = targetbf.calcCritpiercePhyAtk(bf);
				   }
				   else if(isbCrit)
				   {
					   backdmg = targetbf.calcCritPhyAtk(bf);
				   }
				   else if(isbpierce)
				   {
					   backdmg = targetbf.calcpiercePhyAtk(bf);
				   }
				   else
				   {
					   backdmg = targetbf.calcNormalPhyAtk(bf);
				   }
				   
				   //加上反击伤害系数
				   var fbackdmg:uint;
				   backdmg = uint(backdmg * targetbf.calcBackAtkMultiple());
				   
				   //判断格挡
				   var resisFac2:Number = bf.getResistanceFac();
				   fbackdmg = uint(backdmg*(1-resisFac2));
				   targetbf.MinusBuffRound(skillType.RESISTANCE, pPro, 1);   //来自其它人的格挡作用轮数减去一轮
				   
				   //判断伤害加深
				   var hurtFac2:Number = bf.getDeepHurtFac();
				   fbackdmg += uint(backdmg*hurtFac2);
				   bf.MinusBuffRound(skillType.DEEPHURT, pPro, 1);
				   
				   bf.makeDamage(fbackdmg);
				   
				   defender.counterDmg = fbackdmg;
				   defender.counterLeft = bf.getHP();
				   
				   if(bf.getHP() == 0)
				   {
					   onDead(bf);
				   }
				   
				   //反击命中，首要被攻击者和攻击者聚气
				   if(bGather)
				   {
					   targetbf.addQiGather(0, true, pPro, 1);
					   bf.addQiGather(0, true, pPro, 1);
				   }
				   
				   ///Logger.debug("BackAttack BackDmg: "+fbackdmg);
			   }
			   else
			   {
				   //反击被闪避
				   defender.counterDmg = -1;
				   defender.counterLeft = bf.getHP();
				   ///Logger.debug("BackAttack Miss:");
			   }
		   }
		   
		   //有闪避的，减少一轮
		   targetbf.MinusBuffRound(skillType.ADDDODGE, pPro, 0);
		   //有添加防御的buff
		   targetbf.MinusBuffRound(skillType.ADDDEFEND, pPro, 0);
		   //有降低受到的法术伤害的buff
		//   targetbf.MinusBuffRound(skillType.REDUCESPELLDMG, pPro, 0);
		   
		   //有降低受到的暴击概率的buff，减少一轮
		   targetbf.MinusBuffRound(skillType.REBECRITPROB, pPro, 0);
		   
		   //有降低受到的破击概率的buff，减少一轮
		   targetbf.MinusBuffRound(skillType.REBEPIERCEPROB, pPro, 0);
		   
		   //有反击buff的，减少一轮
		   targetbf.MinusBuffRound(skillType.ADDCOUNTER, pPro, 0);
		   
		   
		   //被攻击者攻击完剩余hp，gauge
		   defender.leftHp = targetbf.getHP();
		   defender.leftGauge = targetbf.getGauge();
		  
		   //攻击者攻击完剩余hp，gauge
		   defender.aterleftHp = bf.getHP();
		   defender.aterleftGauge = bf.getGauge();
		   
		   pPro.defendList.push(defender);
		   
		   return fdmg;
	   }
	   
	   private function attackOnceSpell(bf:BattleFighter, targetbf:BattleFighter, ap:Array, i:int, factor1:Number, factor2:Number, skilltype:int, isCrit:Boolean, ispierce:Boolean, bGather:Boolean, pPro:BtProcess = null):uint
	   {
		   if(bf == null || targetbf == null || targetbf.getHP() == 0 )
		   {
			   return 0; 
		   }
		   var fdmg:uint;   //伤害
		   var side:uint = targetbf.getSide();
		   var pos:uint = targetbf.getPos();
		   var letDie:int = 0;
		   
		   var defender:BtDefend = new BtDefend();
		   defender.pos = targetbf.getPos();
		   
		   if(bf.isCalcHit(targetbf))    //命中
		   {
			   var dmg:Number;
			   if (isCrit && ispierce)  //触发暴破
			   {
				   dmg = bf.calcCritpierceSpellDamage(targetbf);
			   }
			   else if (isCrit)
			   {
				   dmg = bf.calcCritSpellDamage(targetbf);
			   }
			   else if (ispierce)
			   {
				   dmg = bf.calcPierceSpellDamage(targetbf);
			   }
			   else
			   {
				   dmg = bf.calcNormalSpellDamage(targetbf);
			   }
			   
			   //如果触发聚气
			   if(bGather)
			   {
				   if(isCrit && ispierce)   //触发暴破
				   {
					   bf.addQiGather(0, true, pPro, 0);
					   targetbf.addQiGather(0, true, pPro, 0);
				   }
				   else if(isCrit)
				   {
					   bf.addQiGather(0, true, pPro, 0);
					   targetbf.addQiGather(0, true, pPro, 0);
				   }
				   else if(ispierce)
				   {
					   bf.addQiGather(0, true, pPro, 0);
					   targetbf.addQiGather(0, true, pPro, 0);
				   }
				   else
				   {
					   bf.addQiGather(0, true, pPro, 0);
					   targetbf.addQiGather(0, true, pPro, 0);
				   }
			   }
			   
			 //  dmg = uint(factor1 * dmg);
			   
			   //判断格挡
			   var resisFac:Number = targetbf.getResistanceFac();
			   fdmg = uint(dmg*factor1*(1-resisFac));
			   targetbf.MinusBuffRound(skillType.RESISTANCE, pPro, 0);   //来自其它人的格挡作用轮数减去一轮
			   
			   //判断伤害加深
			   var hurtFac:Number = targetbf.getDeepHurtFac();
			   fdmg += uint(dmg*factor1*hurtFac);
			   targetbf.MinusBuffRound(skillType.DEEPHURT, pPro, 0);
			   
			   //判断降低法术伤害
			   var reSpellFac:Number = targetbf.getReSpelldmgFac();
			   fdmg -= uint(dmg*factor1*reSpellFac);
			   
			   targetbf.makeDamage(fdmg);
			   if(targetbf.getHP() == 0 )
				   letDie = 2;
			   if(skilltype == skillType.POISONTYPE)
				   targetbf.makeDamage(uint(factor2 * dmg));
			   if(targetbf.getHP() == 0)
				   letDie = 1;
			   			   
			   if(skilltype == skillType.POISONTYPE && factor2 != 0)  //客户端表现中毒buffer
			   {
				   bf.setPRound(bf.getPRound()-1);                    //回合数减少
				   var pBuf:BtStatus = new BtStatus();
				   pBuf.atkorBackatk = 0;
				   pBuf.sideFrom = bf.getSide();
				   pBuf.toside = targetbf.getSide();
				   pBuf.fpos = bf.getPos();
				   pBuf.tpos = targetbf.getPos();
				   pBuf.skillid = bf.getSkillID();
				   pBuf.type = (targetbf.getPRound() == 0) ? 2 : 1;   //为2，加上后立马让其消失，为1则持久加上中毒buffer
				   pBuf.data = 0-uint(factor2 * dmg);
				   pBuf.letDie = letDie;
				   pPro.SChangeList.push(pBuf);
			   }
			   		   

			   
			   //判断是否dead
			   if(targetbf.getHP() == 0)
			   {
				   onDead(targetbf);
			   }
			   
			   ///if(skilltype == skillType.POISONTYPE)
				   ///Logger.debug("SKILL:"+"-"+bf.getSide()+"-"+bf.getPos()+ "-" + targetbf.getPos() + "--HPDmg:" + fdmg + "--PosionDmg:" + uint(factor2 * dmg));
			   ///else
				   ///Logger.debug("SKILL:"+"-"+bf.getSide()+"-"+bf.getPos()+ "-" + targetbf.getPos() + "--HPDmg:" + fdmg );
			
			   defender.damage = fdmg;
			   defender.leftHp = targetbf.getHP();
			   trace(defender.leftHp);
		   }
		   else
		   {
			   fdmg = 0;
			   //如果miss取消中毒，眩晕等效果
			   ap[i].type = 0;
			   
			   //首要目标躲闪，聚气
			   if(bGather)
			   {
				   targetbf.addQiGather(0, true, pPro, 0);
			   }
			   Logger.debug("SKILLID:-"+skilltype+"-"+bf.getSide()+"-"+bf.getPos()+ "-" + targetbf.getPos() + "--Miss" );
			   
			   if(skilltype == skillType.POISONTYPE)
			   {
				   //trace("posion dodge");
			   }
			   defender.damage = -1;
			   defender.leftHp = targetbf.getHP();
			   
			   targetbf.setbDodge(true);
		   }
		   
		   
		   //有闪避的，减少一轮
		   targetbf.MinusBuffRound(skillType.ADDDODGE, pPro, 0);
		   //有添加防御的buff
		   targetbf.MinusBuffRound(skillType.ADDDEFEND, pPro, 0);
		   //有降低受到的法术伤害的buff
		   targetbf.MinusBuffRound(skillType.REDUCESPELLDMG, pPro, 0);
		   
		   //有降低受到的暴击概率的buff，减少一轮
		   targetbf.MinusBuffRound(skillType.REBECRITPROB, pPro, 0);
		   //有降低受到的破击概率的buff，减少一轮
		   targetbf.MinusBuffRound(skillType.REBEPIERCEPROB, pPro, 0);
		   
		   //有反击buff的，减少一轮
		   targetbf.MinusBuffRound(skillType.ADDCOUNTER, pPro, 0);
		
		   
		   //被攻击者攻击完剩余hp，gauge
		   defender.leftHp = targetbf.getHP();
		   defender.leftGauge = targetbf.getGauge();
		   
		   //攻击者攻击完剩余hp，gauge
		   defender.aterleftHp = bf.getHP();
		   defender.aterleftGauge = bf.getGauge();
		   
		   pPro.defendList.push(defender);
		   
		   return fdmg;
	   }
	   
	    private function attackOnceSpecial(bf:BattleFighter, targetbf:BattleFighter, ap:Array, i:int, factor1:Number, factor2:Number, skilltype:int, isCrit:Boolean, ispierce:Boolean, bGather:Boolean, additionVec:Array, pPro:BtProcess = null):uint
		{
			if(bf == null || targetbf == null || targetbf.getHP() == 0 )
			{
				return 0; 
			}
			var fdmg:uint;   //伤害
			var side:uint = targetbf.getSide();
			var pos:uint = targetbf.getPos();
			var letDie:int = 0;
			
			var defender:BtDefend = new BtDefend();
			defender.pos = targetbf.getPos();
			
			if(bf.isCalcHit(targetbf))    //命中
			{
				var dmg:Number;
				if (isCrit && ispierce)  //触发暴破
				{
					dmg = bf.calcCritpierceSpellDamage(targetbf);
				}
				else if (isCrit)
				{
					dmg = bf.calcCritSpellDamage(targetbf);
				}
				else if (ispierce)
				{
					dmg = bf.calcPierceSpellDamage(targetbf);
				}
				else
				{
					dmg = bf.calcNormalSpellDamage(targetbf);
				}
				
				//如果触发聚气
				if(bGather)
				{
					if(isCrit && ispierce)   //触发暴破
					{
						bf.addQiGather(0, true, pPro, 0);
						targetbf.addQiGather(0, true, pPro, 0);
					}
					else if(isCrit)
					{
						bf.addQiGather(0, true, pPro, 0);
						targetbf.addQiGather(0, true, pPro, 0);
					}
					else if(ispierce)
					{
						bf.addQiGather(0, true, pPro, 0);
						targetbf.addQiGather(0, true, pPro, 0);
					}
					else
					{
						bf.addQiGather(0, true, pPro, 0);
						targetbf.addQiGather(0, true, pPro, 0);
					}
				}
				
				dmg = uint(factor1 * dmg);
				
				//判断格挡
				var resisFac:Number = targetbf.getResistanceFac();
				fdmg = uint(dmg*(1-resisFac));
				targetbf.MinusBuffRound(skillType.RESISTANCE, pPro, 0);   //来自其它人的格挡作用轮数减去一轮
				
				//判断伤害加深
				var hurtFac:Number = targetbf.getDeepHurtFac();
				fdmg += uint(dmg*hurtFac);
				targetbf.MinusBuffRound(skillType.DEEPHURT, pPro, 0);
				
				//判断降低法术伤害
				var reSpellFac:Number = targetbf.getReSpelldmgFac();
				fdmg -= uint(dmg*factor1*reSpellFac);
				
				//获得攻击次数
				var atkNum:int = 0;
				var adtionFac:Number = 0;
				if (additionVec.size() >= 3)
				{
					atkNum = int(additionVec[0]);
					for (var i:int = 0; i < atkNum; i++)
					{
						if (additionVec[1] > additionVec[2])
						{
							adtionFac = additionVec[1]-additionVec[2];
							adtionFac = additionVec[2] + adtionFac*(ForRand.getRand(100)/Number(100.0));
						}
						else
						{
							adtionFac = additionVec[2]-additionVec[1];
							adtionFac = additionVec[1] + adtionFac*(ForRand.getRand(100)/Number(100.0));
						}
						
						targetbf.makeDamage(uint((fdmg + uint(factor2 * dmg))*adtionFac));
						//判断是否dead
						if (targetbf.getHP() == 0)
						{
							onDead(targetbf);
							break;
						}
					}
				}

				
				defender.damage = fdmg;
				defender.leftHp = targetbf.getHP();
//				targetbf.makeDamage(fdmg);
//				if(targetbf.getHP() == 0 )
//					letDie = 2;
//				targetbf.makeDamage(uint(factor2 * dmg));
//				if(targetbf.getHP() == 0)
//					letDie = 1;
//				
//				if(skilltype == skillType.POISONTYPE && factor2 != 0)  //客户端表现中毒buffer
//				{
//					var pBuf:BtStatus = new BtStatus();
//					pBuf.atkorBackatk = 0;
//					pBuf.sideFrom = bf.getSide();
//					pBuf.toside = targetbf.getSide();
//					pBuf.fpos = bf.getPos();
//					pBuf.tpos = targetbf.getPos();
//					pBuf.skillType = skillType.POISONTYPE;
//					pBuf.type = (targetbf.getPRound() == 0) ? 2 : 1;   //为2，加上后立马让其消失，为1则持久加上中毒buffer
//					pBuf.data = uint(factor2 * dmg);
//					pBuf.letDie = letDie;
//					pPro.SChangeList.push(pBuf);
//				}
				
			}
			else
			{
				//如果miss取消中毒，眩晕等效果
				ap[i].type = 0;
				
				//首要目标躲闪，聚气
				if(bGather)
				{
					targetbf.addQiGather(0, true, pPro, 0);
				}
				
				defender.damage = -1;
				defender.leftHp = targetbf.getHP();
			}
			
			
			//有闪避的，减少一轮
			targetbf.MinusBuffRound(skillType.ADDDODGE, pPro, 0);
			//有添加防御的buff
			targetbf.MinusBuffRound(skillType.ADDDEFEND, pPro, 0);
			//有降低受到的法术伤害的buff
			targetbf.MinusBuffRound(skillType.REDUCESPELLDMG, pPro, 0);
			
			//有降低受到的暴击概率的buff，减少一轮
			targetbf.MinusBuffRound(skillType.REBECRITPROB, pPro, 0);
			//有降低受到的破击概率的buff，减少一轮
			targetbf.MinusBuffRound(skillType.REBEPIERCEPROB, pPro, 0);
		    
			//有反击buff的，减少一轮
			targetbf.MinusBuffRound(skillType.ADDCOUNTER, pPro, 0);
			
			//被攻击者攻击完剩余hp，gauge
			defender.leftHp = targetbf.getHP();
			defender.leftGauge = targetbf.getGauge();
			
			//攻击者攻击完剩余hp，gauge
			defender.aterleftHp = bf.getHP();
			defender.aterleftGauge = bf.getGauge();
			
			pPro.defendList.push(defender);
			
			return fdmg;
		}
		
		private function fixAttackArea(cnt:int, ap:Array, apcnt:int, target_pos:int, atkarea:Area, isFullS:Boolean, isSkill:Boolean = true):int
		{
			var x_:int = target_pos % 5;
			var y_:int = target_pos / 5;
			var p:int = 0;
			var q:int = 0;
			if(isSkill)
				p = 0;
			else
				p = 1;
			//非全屏攻击
			if(!isFullS)
			{
				for( ; p < cnt; ++p)
				{
					var ad:Data = atkarea.getDataArray()[p];
					var x:int = x_ + ad.x;
					var y:int = y_ + ad.y;
					if(x < 0 || x > 4 || y < 0 || y > 4)
					{
						continue;
					}
					var pt1:AttackPoint = new AttackPoint();
					pt1.pos = x + y * 5; 
					pt1.type = ad.skilltype;
					pt1.factor = ad.factor;
					ap[apcnt] = pt1;
					apcnt++;
				}
			}
			else //全屏攻击
			{
				var ad1:Data = atkarea.getDataArray()[0];
				for( p = 0; p < 5; ++p)
				{
					for( q = 0; q < 5; ++q)
					{
						//if((p+q*5) != (x_+y_*5))
						{
							var pt2:AttackPoint = new AttackPoint();
							pt2.pos = p + q * 5; 
							pt2.type = ad1.skilltype;
							pt2.factor = ad1.factor;
							ap[apcnt] = pt2;
							apcnt++;
						}
					}
				}
			}
			return apcnt;
		}
	   
	   	private function doPhyAttack(bf:BattleFighter, pPro:BtProcess):uint
		{
	   		var dmg:Number = 0;
			var i:int = 0;
			var j:int = 0;
		
		    //获得被攻击方的pos
	   		var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
	   		if(target_pos < 0)
	   			return 0; 
			
	   		var otherside:int = 1 - bf.getSide();
	   		var targetObj:BattleFighter = _objs[otherside][target_pos];
	   		if(targetObj == null)
				return 0; 

			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;     //攻击的首要目标
			pPro.oneAtkInfo.skillType = -1;           //物理攻击
			
	   		//被攻击方
	   		var atkarea:Area = AttackData.arealist[bf.getWeaponType()];


	   		if(atkarea == null)
			{
	   			return 0; 
			}
	   		//判断是否是全屏攻击
	   		var isFullS:Boolean = false;
	   		if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
	   		{
				isFullS = true;     //全屏攻击
	   		}
	   		
	   		var cnt:int = atkarea.getCount();
	   		
	   		//判断是否是暴击，破击，暴破
	   		var isCrit:Boolean = false;
	   		isCrit = bf.isCritAttack(targetObj);
	   		var ispierce:Boolean = false;
	   		ispierce = bf.ispierceAttack(targetObj);
			
			///Logger.debug("--------------------------------------------");
			///Logger.debug(bf.getSide()+"/"+bf.getPos()+"--"+(isCrit? 1 : 0)+"--"+ (ispierce ? 1:0));
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
	   		
	   		//根据武器攻击类型
	   		if(cnt >= 1)
			{
	   			var ap:Array = [];
	   			var apcnt:int = 0;

				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS, false);
	   			dmg = attackOncePhy(bf, targetObj, atkarea.getDataArray()[0].factor, 1, isCrit, ispierce, true, pPro);

	   			for (i = 0; i < apcnt; ++i)
	   			{
	   				attackOncePhy(bf,  _objs[otherside][ap[i].pos], ap[i].factor, -1, isCrit, ispierce, false, pPro);
	   			}
	   		}
	   		else  //攻击对象等于1
	   		{
	   			dmg = attackOncePhy(bf, targetObj, atkarea.getDataArray()[0].factor, 1, isCrit, ispierce, true, pPro);
	   		}
			
			BtProcess.data.push(pPro);
	   		return 0; 
	   	}
	   
	   
		private function doSkillAttack(bf:BattleFighter, pPro:BtProcess):uint
		{
			if(bf == null)
				return 0;
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if(atkarea == null)
				return 0;
			var skilltype:uint = atkarea.getType();
		//	if(!skilltype)
		//		return 0;    0表示不带任何效果的法术攻击
			
			///Logger.debug("--------------------------------------------");
			//变动聚值
			bf.addQiGather(bf.getTrigger(), false, pPro, 0);
			switch(skilltype)
			{
				case 0:
					return NormalSkillAttack(bf, pPro);
					break;
				case skillType.POISONTYPE:
					return poisonAttack(bf, pPro);
					break;
				case skillType.STUNTYPE:
					return doStunAttack(bf, pPro);
					break;
				case skillType.SLOWTYPE:
					return doSlowDownAttack(bf, pPro);
					break;
				case skillType.ADDHP:
					return doAtkBackHp(bf, pPro);
					break;
				case skillType.SUKHP:
					return doSukHp(bf, pPro);
					break;
				case skillType.RESISTANCE:
					return doResisTance(bf, pPro);
					break;
				case skillType.DEEPHURT:
					return doDeepHurt(bf, pPro);
					break;
				case skillType.ADDCOUNTER:
					return doAddBasePropAtk(bf, skillType.ADDCOUNTER, pPro);
					break;
				case skillType.ADDCRIT:
					return doAddBasePropAtk(bf, skillType.ADDCRIT, pPro);
				case skillType.ADDATTACK:
					return doAddAttack(bf, pPro);
					break;
				case skillType.REDUCEHITRATE:
					return doReduceHitRate(bf, pPro);
					break;
//				case skillType.MULTIPLE:
//					return doMultipleAtk(bf, pPro);
//					break;
				case skillType.ADDDODGE:
					return doAddBasePropAtk(bf, skillType.ADDDODGE, pPro);
					break;
				case skillType.ADDDEFEND:
					return doAddBasePropAtk(bf, skillType.ADDDEFEND, pPro);
					break;
				case skillType.ADDPIERCE:
					return doAddBasePropAtk(bf, skillType.ADDPIERCE, pPro);
					break;
				case skillType.SPEEDTYPE:
					return 	doAddSpeedAttack(bf, pPro);
					break;
				case skillType.ADDGAUGE:
					return  doAddGauge(bf, pPro);
					break;
			    case skillType.REDUCESPELLDMG:
					return doReduceSpellDmg(bf, pPro);
					break;
				case skillType.REBECRITPROB:
					return doReBeCritAtk(bf, pPro);
					break;
				case skillType.REBEPIERCEPROB:
					return doReBePierceAtk(bf, pPro);
					break;
				case skillType.ADDMYSELFATTACK:
					return doAddMySelfAttack(bf, pPro);
					break;
				default:
					break;
			}

			return 0; 
		}
	   
	   
		private function NormalSkillAttack(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if(_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos

			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if(target_pos < 0)
			{
				return 0; 
			}
			var otherside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[otherside][target_pos];
			if(targetObj == null)
				return 0; 
			
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
				
			var atkarea:Area = AttackData.arealist[AttackData.skilllist[bf.getSkillID()].atkID];
			if(atkarea == null)
				return 0; 
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount();
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji; //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;  //破击
			}
			
			///Logger.debug(bf.getSide()+"/"+bf.getPos()+"--"+(isCrit? 1 : 0)+"--"+ (ispierce ? 1:0));
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var side:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if(psd)
				{

					for( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, 0, isCrit, ispierce, (i == 0 ?  true:false), pPro);
					}
				}
			}
			BtProcess.data.push(pPro);
			return 0; 
			
		}
		
		private function  poisonAttack(bf:BattleFighter, pPro:BtProcess):uint    //毒攻击
		{
			var i:int;
			var j:int;
			var targetfighter:BattleFighter;
			if(_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if(target_pos < 0)
				return 0; 
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = skillType.POISONTYPE;        //中毒攻击
			
			//被攻击方
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if(atkarea == null)
				return 0; 
			
			//判断是否全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;   //全屏攻击
			}
			var cnt:int = atkarea.getCount();
			
			//判断是否暴击， 破击， 暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji; //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji; //破击
			}
			
			///Logger.debug(bf.getSide()+"/"+bf.getPos()+"--"+(isCrit? 1 : 0)+"--"+ (ispierce ? 1:0));
			
			//第一次中毒攻击
			if( cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData =  AttackData.skilllist[bf.getSkillID()];
				if(psd)
				{
					var bPoison:Boolean = true;
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						bPoison  = false;  //未释放技能
					
					if(bPoison)
					{
						//删除某人已经存在来自同一人的中毒效果
						for( j = 0; j < apcnt; ++j)
						{
							targetfighter = _objs[otherside][ap[j].pos];
							removeFSByMark(targetfighter, (bf.getSide()+1)*10000+bf.getPos()*100+skillType.POISONTYPE);
						}
					}

					var BaseSpellAtk:Number = 0;
					for( i = 0; i < psd._atkFactorVec.length; ++i)
					{
						for( j = 0; j < apcnt; ++j)
						{
							targetfighter = _objs[otherside][ap[j].pos];
							if(!targetfighter)
								continue;
							if(i == 0)
							{
								var skillfactor:Number = 0.0;
								if(ap[i].type == skillType.POISONTYPE)
									skillfactor = psd._atkFactorVec[0];
								else 
									skillfactor = 0.0;
								
								if(!bPoison)
								{
									skillfactor = 0.0;				
								}
								else
								{
									if(ap[j].type == 1)
										targetfighter.setPRound(psd._atkFactorVec.length);
									else
										targetfighter.setPRound(0);	
								}
								

								attackOnceSpell(bf, _objs[otherside][ap[j].pos], ap, j, ap[i].factor, skillfactor, skillType.POISONTYPE, isCrit, ispierce, (j == 0 ? true:false), pPro);
								
	
								if(isCrit && ispierce)  //触发暴破
								{
									BaseSpellAtk = bf.calcCritpierceSpellDamage(targetfighter);
								}
								else if(isCrit)
								{
									BaseSpellAtk = bf.calcCritSpellDamage(targetfighter);
								}
								else if(ispierce)
								{
									BaseSpellAtk = bf.calcPierceSpellDamage(targetfighter);
								}
								else
								{
									BaseSpellAtk = bf.calcNormalSpellDamage(targetfighter);								
								}
								
								
								//加buff
								if(i == 0 && targetfighter.getbDodge() == false)
								{
									var pff:buffEffect = new buffEffect();
									pff.bfside = bf.getSide();
									pff.btoside = targetfighter.getSide();
									pff.bfpos = bf.getPos();
									pff.btpos = targetfighter.getPos();
									pff.bround = psd._atkFactorVec.length-1;
									pff.btype = skillType.POISONTYPE;
									pff.bvalue = 0;
									pff.bfirst = true;
									pff.bskillid =  bf.getSkillID();
									targetfighter.AddBufferEffect(pff);		
								}
							}
							else
							{
								if(!bPoison)
									return 0;
								//设置中毒回合数
								if(ap[j].type == skillType.POISONTYPE && targetfighter.getbDodge() == false)
								{
									var fsp:FighterStatus = new FighterStatus(targetfighter, getMaxAction(), getMaxAction()*getMaxAction()/bf.getSpeed() * 3 * (i) / 4, getMaxAction()*getMaxAction()/bf.getSpeed() * 3 * (i) / 4, uint(BaseSpellAtk * psd._atkFactorVec[i]), (bf.getSide()+1)*10000+bf.getPos()*100+skillType.POISONTYPE);
									insertFighterStatus(fsp);
									
									///Logger.debug("@@@@@@----"+targetfighter.getSide()+"/" + targetfighter.getPos() + "hit poision");
									//控制buff轮数
								}

							}
	
						}
					}
				}
				
			}
			return 0; 
		} 
	   
		private function doStunAttack(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if(_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos

			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if(target_pos < 0)
			{
				return 0; 
			}
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = skillType.STUNTYPE;        //中毒攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if(atkarea == null)
				return 0; 
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount();
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji; //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;  //破击
			}
			
			///Logger.debug(bf.getSide()+"/"+bf.getPos()+"--"+(isCrit? 1 : 0)+"--"+ (ispierce ? 1:0));
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if(psd)
				{
					var stunNum:int = 0;
					stunNum = psd._round;
					for(i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.STUNTYPE, isCrit, ispierce, (i == 0 ?  true:false), pPro);
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //
					
					for(j = 0; j < apcnt; ++j)
					{
						var targetfighter:BattleFighter = _objs[otherside][ap[j].pos];
						if( targetfighter && (targetfighter.getbDodge() == false) )
						{
							if(ap[j].type != 0)
							{
								if(stunNum > targetfighter.getStunRound())
								{
								   targetfighter.setStunRound(stunNum);

								   ///Logger.debug("@@@@@@----"+targetfighter.getSide()+"/" + targetfighter.getPos() + "hit stun");
								
								   var sff:buffEffect = new buffEffect();
								   sff.bfside = bf.getSide();
								   sff.btoside = targetfighter.getSide();
								   sff.bfpos = bf.getPos();
								   sff.btpos = targetfighter.getPos();
								   sff.bround = stunNum;
								   sff.btype = skillType.STUNTYPE;
								   sff.bvalue = 0;
								   sff.bfirst = true;
								   sff.bskillid =  bf.getSkillID();
								   targetfighter.AddBufferEffect(sff, pPro);		
								   
//								   {
//									   var sBuf:BtStatus = new BtStatus();
//									   sBuf.atkorBackatk = 0;
//									   sBuf.sideFrom = bf.getSide();
//									   sBuf.toside = targetfighter.getSide();
//									   sBuf.fpos = bf.getPos();
//									   sBuf.tpos = targetfighter.getPos();
//									   sBuf.skillid = bf.getSkillID();
//									   sBuf.type = 1;  
//									   sBuf.data = 0;
//									   sBuf.letDie = 0;
//									   pPro.SChangeList.push(sBuf);
//								   }
								}
							}
						}
					}
				}
			}

			return 0; 
		}
	   
	
		private function doSlowDownAttack(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if(_winner != 0)
			{
				return 0; 
			}
		
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if(target_pos < 0)
			{
				return 0; 
			}
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = skillType.SLOWTYPE;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if(atkarea == null)
				return 0; 
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount();
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji; //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;  //破击
			}
			
			///Logger.debug(bf.getSide()+"/"+bf.getPos()+"--"+(isCrit? 1 : 0)+"--"+ (ispierce ? 1:0));
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if(psd)
				{
					var slowNum:int = 0;
					slowNum = psd._round;
					var slowFac:Number = 0.0;
					slowFac = psd._atkFactorVec[0];
					
					for(i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.SLOWTYPE, isCrit, ispierce, (i == 0 ?  true:false), pPro);
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					for (j = 0; j < apcnt; ++j)
					{
						var targetfighter:BattleFighter = _objs[otherside][ap[j].pos];
						if (targetfighter && (targetfighter.getbDodge() == false) )
						{
							if(ap[j].type != 0)
							{
								//targetfighter->setCoolDown(static_cast<UInt32>(targetfighter->getCoolDown()*(1+slowFac)));
								var bff:buffEffect = new buffEffect();
								bff.bfside = bf.getSide();
								bff.btoside = targetfighter.getSide();
								bff.bfpos = bf.getPos();
								bff.btpos = targetfighter.getPos();
								bff.bround = slowNum;
								bff.btype = skillType.SLOWTYPE;
								bff.bvalue = slowFac;
								bff.bskillid = bf.getSkillID();
								bff.bfirst = true;
								targetfighter.AddBufferEffect(bff, pPro);
								
								//让客户端播放减速buff

								
								//变动间隔队列
								var c:int = 0;
								for (i = 0; i < _fgtlist.length; ++i)
								{
									if (_fgtlist[i].bfgt == targetfighter && _fgtlist[i].poisonAction == 0)
									{
										c = i;
										break;
									}
								}
								if (!targetfighter.HasBufferEffect(bff))
								{
									///Logger.debug("HitSlow before attack:    targetPos:" + targetfighter.getPos() + "Speed:" + _fgtlist[c].antiAction);
									_fgtlist[c].antiAction += uint(_fgtlist[c].bfgt.getBaseCoolDown()*bff.bvalue);
									//trace(uint(_fgtlist[c].bfgt.getBaseCoolDown()*bff.bvalue));
									var newFs:FighterStatus = new FighterStatus(_fgtlist[c].bfgt, _fgtlist[c].maxAction, _fgtlist[c].antiAction, _fgtlist[c].poisonAction, _fgtlist[c].poisonDamage, _fgtlist[c].atkMark);
									_fgtlist.splice(c, 1);
									insertFighterStatus(newFs);
									///Logger.debug("Slow after attack:    targetPos:" + targetfighter.getPos() + "Speed:" + newFs.antiAction);
								}
								
								//客户端如何表现
							}
						}
					}
				}
			}

			return 0; 
		}
		
		
		private function doAddSpeedAttack( bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if(_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if(target_pos < 0)
			{
				return 0; 
			}
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = skillType.SPEEDTYPE;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if(atkarea == null)
				return 0; 
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount();
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji; //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			///Logger.debug(bf.getSide()+"/"+bf.getPos()+"--"+(isCrit? 1 : 0)+"--"+ (ispierce ? 1:0));
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if(psd)
				{
					var slowNum:int = 0;
					slowNum = psd._round;
					var slowFac:Number = 0.0;
					slowFac = psd._atkFactorVec[0];
					
					for(i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.SPEEDTYPE, isCrit, ispierce, (i == 0 ?  true:false), pPro);
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					
						
					if (bf)
					{
	
						//targetfighter->setCoolDown(static_cast<UInt32>(targetfighter->getCoolDown()*(1+slowFac)));
						var bff:buffEffect = new buffEffect();
						bff.bfside = bf.getSide();
						bff.btoside = bf.getSide();
						bff.bfpos = bf.getPos();
					    bff.btpos = bf.getPos();
						bff.bround = slowNum;
						bff.btype = skillType.SPEEDTYPE;
						bff.bvalue = slowFac;
						bff.bfirst = true;
						bff.bskillid = bf.getSkillID();
						bf.AddBufferEffect(bff, pPro);
								
						//让客户端播放减速动画
//						var sBuf:BtStatus = new BtStatus();
//						sBuf.atkorBackatk = 0;
//						sBuf.sideFrom = bf.getSide();
//						sBuf.toside = bf.getSide();
//						sBuf.fpos = bf.getPos();
//						sBuf.tpos = bf.getPos();
//						sBuf.skillid = bf.getSkillID();
//						sBuf.type = 2;  
//						sBuf.data = 0;
//						sBuf.letDie = 0;
//						pPro.SChangeList.push(sBuf);
	
						//变动间隔队列
						var c:int = 0;
						for (i = 0; i < _fgtlist.length; ++i)
						{
							if (_fgtlist[i].bfgt == bf && _fgtlist[i].poisonAction == 0)
							{
								c = i;
								break;
							}
						}
						if (!bf.HasBufferEffect(bff))
						{
							///Logger.debug("HitSpeed before attack:    targetPos:" + bf.getPos() + "Speed:" + _fgtlist[c].antiAction);
									
							_fgtlist[c].antiAction -= uint(_fgtlist[c].bfgt.getBaseCoolDown()*bff.bvalue);
							var newFs:FighterStatus = new FighterStatus(_fgtlist[c].bfgt, _fgtlist[c].maxAction, _fgtlist[c].antiAction, _fgtlist[c].poisonAction, _fgtlist[c].poisonDamage, _fgtlist[c].atkMark);
							_fgtlist.splice(c, 1);
							insertFighterStatus(newFs);
									
							///Logger.debug("HitSpeed after attack:    targetPos:" + bf.getPos() + "Speed:" + newFs.antiAction);
						}
								
						//客户端如何表现
					}
						
					
				}
			}
			return 0; 
		}



		private function doAtkBackHp(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = skillType.ADDHP;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.ADDHP, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					//给自己方加血
					var effectNum:uint = uint(psd._atkFactorVec[0]);
					var effectFac:Number = psd._atkFactorVec[1];
					var addValue:uint = uint((bf.getAttack() + bf.getSpellDamage()) * effectFac);
					var toSide:int = bf.getSide();
					var myFlist:Array = [];
					for ( i = 0; i < _fgtlist.length; ++i)
					{
						if (_fgtlist[i].bfgt.getSide() == toSide)
						{
							myFlist.push(_fgtlist[i].bfgt);
						}
					}
					myFlist.sort(CompLess);

					for ( j = 0; j < myFlist.length && j < effectNum; ++j)
					{
						///Logger.debug("HPside:" + bf.getSide() + "/" + myFlist[j].getPos() +"HPConsume:" + myFlist[j].getHpConsume());
						
						var rescuer:BtRescued = new BtRescued();
						rescuer.side = bf.getSide();
						rescuer.pos = (myFlist[j] as BattleFighter).getPos();
						rescuer.addHp = addValue;
						
						(myFlist[j] as BattleFighter).AddHP(addValue);
						
						rescuer.leftHp =  (myFlist[j] as BattleFighter).getHP();
						pPro.rescuedList.push(rescuer);
						///Logger.debug("HPside:" + bf.getSide() + "/" + myFlist[j].getPos() +"addHPValue:" + addValue);
						
//						//给客户端表现加血技能
//						var addHpbuf:BtStatus = new BtStatus();
//						addHpbuf.atkorBackatk = 0;
//						addHpbuf.sideFrom = bf.getSide();
//						addHpbuf.toside = bf.getSide();
//						addHpbuf.fpos = bf.getPos();
//						addHpbuf.tpos = myFlist[j].getPos();
//						addHpbuf.skillid = bf.getSkillID();
//						addHpbuf.type = 2;              //加血buffer
//						addHpbuf.data = addValue;       //加血量
//						pPro.resuedSChangeList.push(addHpbuf);
						
					}
					//myFlist.clear();
				}  
			}
			return 0;
		}
		
		private function doSukHp(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				var firstOneDmg:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var dmgs:uint = 0;
					for ( i = 0; i < apcnt; ++i)
					{
						dmgs = attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.SUKHP, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					    if(i == 0)
						{
							firstOneDmg = dmgs;
						}
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					if(targetObj.getbDodge() == false)
					{
						//给自己加血
						var beforeHp:int = 0;
						beforeHp = bf.getHP();
						var effectFac:Number = psd._atkFactorVec[0];
						bf.AddHP(uint(effectFac * firstOneDmg));
						
						///Logger.debug("@@@@@@@@hitsukhp--" + bf.getSide() +  "/" + bf.getPos()+ "suk--" + uint(effectFac * firstOneDmg));
						
						//给客户端表现给自己加血buff
						var rescuer:BtRescued = new BtRescued();
						rescuer.side = bf.getSide();
						rescuer.pos = bf.getPos();
						rescuer.addHp = uint(effectFac * firstOneDmg);
						rescuer.leftHp =  bf.getHP();
						pPro.rescuedList.push(rescuer);
						//					var addHpbuf:BtStatus = new BtStatus();
						//					addHpbuf.atkorBackatk = 0;
						//					addHpbuf.sideFrom = bf.getSide();
						//					addHpbuf.toside = bf.getSide();
						//					addHpbuf.fpos = bf.getPos();
						//					addHpbuf.tpos = bf.getPos();
						//					addHpbuf.skillid = bf.getSkillID();
						//					addHpbuf.type = 2;              //加血buffer
						//					addHpbuf.data = uint(effectFac * firstOneDmg);       //加血量
						//					pPro.SChangeList.push(addHpbuf);
					}
				}  
			}
			return 0;
		}
		
		private function doResisTance(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;     //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var resisNum:uint = 0;        //格挡轮数
					resisNum = psd._round;
					var resisFac:Number = 0.0;
					resisFac = psd._atkFactorVec[0];
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.RESISTANCE, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					
					//添加格挡
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = bf.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = bf.getPos();
					bff.bround = resisNum;
					bff.btype = skillType.RESISTANCE;
					bff.bvalue = resisFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID()
					bf.AddBufferEffect(bff, pPro);
					
					//是佛表现格挡buff
//					//让客户端播放加格挡的buff
//					{
//						var sBuf:BtStatus = new BtStatus();
//						sBuf.atkorBackatk = 0;
//						sBuf.sideFrom = bf.getSide();
//						sBuf.toside = bf.getSide();
//						sBuf.fpos = bf.getPos();
//						sBuf.tpos = bf.getPos();
//						sBuf.skillid = bf.getSkillID();
//						sBuf.type = 2;  
//						sBuf.data = 0;
//						sBuf.letDie = 0;
//						pPro.SChangeList.push(sBuf);
//					}
				}  
			}
			return 0;
		}
		
		private function doDeepHurt(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var deepHurtNum:uint = 0;        //加深轮数
					deepHurtNum = psd._round;
					var hurtFac:Number = 0.0;
					hurtFac = psd._atkFactorVec[0];
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.DEEPHURT, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					var pTarget:BattleFighter = _objs[otherside][target_pos];
					if (pTarget == null || (pTarget.getbDodge() == true) )
						return 2;
					
					//加深伤害
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = pTarget.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = pTarget.getPos();
					bff.bround = deepHurtNum;
					bff.btype = skillType.DEEPHURT;
					bff.bvalue = hurtFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID();
					pTarget.AddBufferEffect(bff, pPro);
					
					
					///Logger.debug("@@@@@HitDeephurt"+ pTarget.getSide() + "/", pTarget.getPos(), "-", hurtFac* 100);
				
					//是否客户端表现
					//让客户端播放加深伤害的buff
//					{
//						var sBuf:BtStatus = new BtStatus();
//						sBuf.atkorBackatk = 0;
//						sBuf.sideFrom = bf.getSide();
//						sBuf.toside = pTarget.getSide();
//						sBuf.fpos = bf.getPos();
//						sBuf.tpos = pTarget.getPos();
//						sBuf.skillid = bf.getSkillID();
//						sBuf.type = 2;  
//						sBuf.data = 0;
//						sBuf.letDie = 0;
//						pPro.SChangeList.push(sBuf);
//					}
				}  
			}
			return 0;
		}
		
		//加攻击
		private function doAddAttack(bf:BattleFighter ,pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo;       //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;       //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var addAtkNum:uint = 0;        //
					addAtkNum = psd._round;
					var atkFac:Number = 0.0;
					atkFac = psd._atkFactorVec[0];
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.ADDATTACK, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					var pAddTarget:BattleFighter = null; 
					var joblist:Array = [2,3,1];
					for (i = 1; i < 4; i++)  //job从1到3
					{
						for ( j = 0; j < _fgtlist.length; ++j)
						{
							if (_fgtlist[j].bfgt.getSide() == bf.getSide() && _fgtlist[j].bfgt.getHP() > 0)
							{
								if (_fgtlist[j].bfgt.getJobID() == joblist[i-1] && _fgtlist[j].bfgt != bf )
								{
									pAddTarget = _fgtlist[j].bfgt;
									i = 4;
									break;
								}
							}
						}
					}
					
					//给队友添加攻击力
					if (pAddTarget)
					{							
						var bff:buffEffect = new buffEffect();
						bff.bfside = bf.getSide();
						bff.btoside = pAddTarget.getSide();
						bff.bfpos = bf.getPos();
						bff.btpos = pAddTarget.getPos();
						bff.bround = addAtkNum;
						bff.btype = skillType.ADDATTACK;
						bff.bvalue = atkFac;
						bff.bfirst = true;
						bff.bskillid = bf.getSkillID();
						pAddTarget.AddBufferEffect(bff, pPro);
					}
					
					//客户端表现加攻击的buff
//					if (pAddTarget)
//					{
//						var sBuf:BtStatus = new BtStatus();
//						sBuf.atkorBackatk = 0;
//						sBuf.sideFrom = bf.getSide();
//						sBuf.toside = pAddTarget.getSide();
//						sBuf.fpos = bf.getPos();
//						sBuf.tpos = pAddTarget.getPos();
//						sBuf.skillid = bf.getSkillID();
//						sBuf.type = 2;  
//						sBuf.data = 0;
//						sBuf.letDie = 0;
//						pPro.SChangeList.push(sBuf);
//						
//						///Logger.debug("@@@@@@HitAddAtk--" + pAddTarget.getSide() + "/" + pAddTarget.getPos() + "--"+addAtkNum + "--"+ atkFac*100);
//					}
				}  
			}
			return 0;
		}
		
		private function doAddMySelfAttack(bf:BattleFighter ,pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo;       //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;       //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var addAtkNum:uint = 0;        //
					addAtkNum = psd._round;
					var atkFac:Number = 0.0;
					atkFac = psd._atkFactorVec[0];
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.ADDMYSELFATTACK, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					//给队友添加攻击力
					if (bf)
					{							
						var bff:buffEffect = new buffEffect();
						bff.bfside = bf.getSide();
						bff.btoside = bf.getSide();
						bff.bfpos = bf.getPos();
						bff.btpos = bf.getPos();
						bff.bround = addAtkNum+1;  //设置多一轮 
						bff.btype = skillType.ADDMYSELFATTACK;
						bff.bvalue = atkFac;
						bff.bfirst = true;
						bff.bskillid = bf.getSkillID();
						bf.AddBufferEffect(bff, pPro);
					}
					
				}  
			}
			return 0;
		}
		
		//攻击降低对方命中率
		private function doReduceHitRate(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var reduceHitNum:uint = 0;        //加深轮数
					reduceHitNum = psd._round;
					var reduceFac:Number = 0.0;
					reduceFac = psd._atkFactorVec[0];
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.DEEPHURT, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					var reduceTarget:BattleFighter = _objs[otherside][target_pos];
					//降低下次攻击的命中率
					if (reduceTarget == null || (reduceTarget.getbDodge() == true))
						return 2;
		
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = reduceTarget.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = reduceTarget.getPos();
					bff.bround = reduceHitNum;
					bff.btype = skillType.REDUCEHITRATE;
					bff.bvalue = reduceFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID();
					reduceTarget.AddBufferEffect(bff, pPro);
					
					//客户端表现
					//降低下次攻击的命中率的buff
//					{
//						var sBuf:BtStatus = new BtStatus();
//						sBuf.atkorBackatk = 0;
//						sBuf.sideFrom = bf.getSide();
//						sBuf.toside = reduceTarget.getSide();
//						sBuf.fpos = bf.getPos();
//						sBuf.tpos = reduceTarget.getPos();
//						sBuf.skillid = bf.getSkillID();
//						sBuf.type = 2;  
//						sBuf.data = 0;
//						sBuf.letDie = 0;
//						pPro.SChangeList.push(sBuf);
//					}
					
					///Logger.debug("@@@@@_HitReHitRate-" + bf.getSide() +  "/" + bf.getPos() + "--" + reduceHitNum +"--" + int(reduceFac*100));
				}  
			}
			return 0;
		}
		
		//多次攻击 
		private function doMultipleAtk(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpecial(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.MULTIPLE, isCrit, ispierce, (i == 0 ?  true : false), psd._atkFactorVec, pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
				}  
			}
			BtProcess.data.push(pPro);
			return 0;
		}
		
		private function doAddGauge(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetobj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;  //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;   //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var gaugeNum:int = 0;
					gaugeNum = psd._round;
					var addValue:Number = 0.0;
					addValue = psd._atkFactorVec[0];
					

					
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.ADDGAUGE, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() < psd.prob*10000 )
					{
						//给目标减去聚气
						var targetobj:BattleFighter  = _objs[otherside][target_pos];
						if (targetobj == null || (targetobj.getbDodge() == true))
							return 1;
						
						var showgauge:uint = targetobj.getGauge();
						
						if(addValue > 0)
							targetobj.addQiGather( addValue, false, pPro, 0);
						
						///Logger.debug("@@@@@@Hit Gauge--" + targetobj.getSide() +  "/" + targetobj.getPos() + "--before--"+ showgauge + "--after--" + targetobj.getGauge()+ "--value-- " + uint(addValue));
						
						//给客户端表现减聚气技能
						var gaugeBuf:BtStatus = new BtStatus();
						gaugeBuf.atkorBackatk = 0;
						gaugeBuf.sideFrom = bf.getSide();
						gaugeBuf.toside = targetobj.getSide();
						gaugeBuf.fpos = bf.getPos();
						gaugeBuf.tpos = targetobj.getPos();
						gaugeBuf.skillid = bf.getSkillID();
						gaugeBuf.type = 2;       //加血buffer
						gaugeBuf.data = 0;       //减少量
						pPro.SChangeList.push(gaugeBuf);
					}
					
					//myFlist.clear();
				}  
			}
			return 0;
		}
		
		private function doReBeCritAtk(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;  //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;   //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var reNum:int = 0;
					reNum = psd._round;
					var mFac:Number = 0.0;
					mFac = psd._atkFactorVec[0];
					
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.REBECRITPROB, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					//给客户端表现降低受暴击概率技能
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = bf.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = bf.getPos();
					bff.bround = reNum;
					bff.btype = skillType.REBECRITPROB;
					bff.bvalue = mFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID();
					bf.AddBufferEffect(bff, pPro);
					
					//给客户端表现降低受暴击概率技能
//					var gaugeBuf:BtStatus = new BtStatus();
//					gaugeBuf.atkorBackatk = 0;
//					gaugeBuf.sideFrom = bf.getSide();
//					gaugeBuf.toside = bf.getSide();
//					gaugeBuf.fpos = bf.getPos();
//					gaugeBuf.tpos = bf.getPos();
//					gaugeBuf.skillid = bf.getSkillID();
//					gaugeBuf.type = 2;              
//					gaugeBuf.data = mFac;       
//					pPro.SChangeList.push(gaugeBuf);
					
					
					///Logger.debug("@@@@@_HitReBeCrit-" + bf.getSide() +  "/" + bf.getPos() + "--" + mFac*100 +"--" + reNum);
				}  
			}
			return 0;
		}
		
		private function doReBePierceAtk(bf:BattleFighter, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 

			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;  //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;   //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var reNum:int = 0;
					reNum = psd._round;
					var mFac:Number = 0.0;
					mFac = psd._atkFactorVec[0];
					
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.REBEPIERCEPROB, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					//给客户端表现降低受破击概率技能
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = bf.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = bf.getPos();
					bff.bround = reNum;
					bff.btype = skillType.REBEPIERCEPROB;
					bff.bvalue = mFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID();
					bf.AddBufferEffect(bff, pPro);
					
					//给客户端表现降低受破击概率技能
//					var gaugeBuf:BtStatus = new BtStatus();
//					gaugeBuf.atkorBackatk = 0;
//					gaugeBuf.sideFrom = bf.getSide();
//					gaugeBuf.toside = bf.getSide();
//					gaugeBuf.fpos = bf.getPos();
//					gaugeBuf.tpos = bf.getPos();
//					gaugeBuf.skillid = bf.getSkillID();
//					gaugeBuf.type = 2;              
//					gaugeBuf.data = mFac;       
//					pPro.SChangeList.push(gaugeBuf);
					
					
					///Logger.debug("@@@@@_HitReBePierce-" + bf.getSide() +  "/" + bf.getPos() + "--" + mFac*100 +"--" + reNum);
				}  
			}

			return 0;
		}
		
		
		private function doReduceSpellDmg(bf:BattleFighter, pPro:BtProcess):uint   //降低受到的仙术伤害
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
			
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;  //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;   //破击
			}
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var reduceNum:int = 0;
					reduceNum = psd._round;
					var reduceFac:Number = 0.0;
					reduceFac = psd._atkFactorVec[0];
					
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, skillType.REDUCESPELLDMG, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//释放技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					//降低下次受仙术攻击的伤害
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = bf.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = bf.getPos();
					bff.bround = reduceNum;
					bff.btype = skillType.REDUCESPELLDMG;
					bff.bvalue = reduceFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID();
					bf.AddBufferEffect(bff, pPro);
					
					//给客户端表现减少法术伤害
//					var gaugeBuf:BtStatus = new BtStatus();
//					gaugeBuf.atkorBackatk = 0;
//					gaugeBuf.sideFrom = bf.getSide();
//					gaugeBuf.toside = bf.getSide();
//					gaugeBuf.fpos = bf.getPos();
//					gaugeBuf.tpos = bf.getPos();
//					gaugeBuf.skillid = bf.getSkillID();
//					gaugeBuf.type = 2;              //加减少法术伤害的buff
//					gaugeBuf.data = 0;       //减少量
//					pPro.SChangeList.push(gaugeBuf);
					
					//myFlist.clear();
				    ///Logger.debug("@@@@@_HitReSpellDmg-" + bf.getSide() +  "/" + bf.getPos()+ "--" + int(reduceFac*100));
				}  
			}
			return 0;
		}
		
		
		//基础的加属性的攻击
		private function doAddBasePropAtk(bf:BattleFighter, addType:uint, pPro:BtProcess):uint
		{
			var i:int;
			var j:int;
			if (_winner != 0)
			{
				return 0; 
			}
					
			//获得被攻击方的pos
			var target_pos:int = getPossibleTarget(bf.getSide(), bf.getPos());
			if (target_pos < 0)
				return 0;
			var nextside:int = 1 - bf.getSide();
			var targetObj:BattleFighter = _objs[nextside][target_pos];
			if(targetObj == null)
				return 0; 
			
			BtProcess.data.push(pPro);
			pPro.oneAtkInfo = new BtOneAtk();
			pPro.oneAtkInfo.atkerSide = bf.getSide();  //攻击者side
			pPro.oneAtkInfo.atkerPos = bf.getPos();
			pPro.oneAtkInfo.atkPos = target_pos;
			pPro.oneAtkInfo.skillType = 0;        //普通技能攻击
			
			var pskilldata:skillData = AttackData.skilllist[bf.getSkillID()];
			if (pskilldata == null)
				return 0;
			var atkarea:Area = AttackData.arealist[pskilldata.atkID];
			if ( atkarea == null)
				return 0;
			//判断是否是全屏攻击
			var isFullS:Boolean = false;
			if(atkarea.getDataArray()[0].x == 6 && atkarea.getDataArray()[0].y == 6)
			{
				isFullS = true;    //全屏攻击
			}
			var cnt:int = atkarea.getCount(); 
			
			//判断是否暴击，破击，暴破
			var isCrit:Boolean = false;
			isCrit = bf.isCritAttack(targetObj);
			var ispierce:Boolean = false;
			ispierce = bf.ispierceAttack(targetObj);
			
			if( isCrit && ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baopo; //暴破
			}
			else if( isCrit )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Baoji;       //暴击
			}
			else if( ispierce )
			{
				pPro.oneAtkInfo.effectType = BTSystem.ID_Poji;     //破击
			}
			
			
			//第一次攻击
			if(cnt >= 1)
			{
				var ap:Array = [];
				var apcnt:int = 0;
				apcnt = fixAttackArea(cnt, ap, apcnt, target_pos, atkarea, isFullS);
				
				var otherside:int = 1 - bf.getSide();
				var psd:skillData = AttackData.skilllist[bf.getSkillID()];
				if (psd)
				{	
					var roundNum:int = 0;      //轮数
					roundNum = psd._round;
					var propFac:Number = 0.0;
					propFac = psd._atkFactorVec[0];
					var propTarget:BattleFighter = null; 
					for ( i = 0; i < apcnt; ++i)
					{
						attackOnceSpell(bf, _objs[otherside][ap[i].pos], ap, i, ap[i].factor, 0, addType, isCrit, ispierce, (i == 0 ?  true : false), pPro); //(i == 0 ?  true, false)首要目标才触发聚气
					}
					
					//触发该技能概率
					if( ForRand.getRand() > psd.prob*10000 )
						return 1;  //未释放技能
					
					//加基础属性buff
					var bff:buffEffect = new buffEffect();
					bff.bfside = bf.getSide();
					bff.btoside = bf.getSide();
					bff.bfpos = bf.getPos();
					bff.btpos = bf.getPos();
					if ( addType == skillType.ADDDODGE || addType == skillType.ADDDEFEND)
						bff.bround = roundNum;
					else
						bff.bround = roundNum+1;
					bff.btype = addType;
					bff.bvalue = propFac;
					bff.bfirst = true;
					bff.bskillid = bf.getSkillID();
					bf.AddBufferEffect(bff, pPro);
					
					/*if(addType == skillType.ADDCRIT)
						Logger.debug("@@@@@___My add Crit : my side: " + bf.getSide() +  "my  Pos: " + bf.getPos()+ "add fac: " + propFac);
					else if(addType == skillType.ADDPIERCE)
						Logger.debug("@@@@@___My add Pierce : my side: " + bf.getSide() +  "my  Pos: " + bf.getPos()+ "add fac: " + propFac);
					else if(addType == skillType.ADDCOUNTER)
						Logger.debug("@@@@@___My add Counter : my side: " + bf.getSide() +  "my  Pos: " + bf.getPos()+ "afteradd: " + bf.getCounter()*100);
					else if(addType == skillType.ADDDODGE)
						Logger.debug("@@@@@___My add Aodge : my side: " + bf.getSide() +  "my  Pos: " + bf.getPos()+ "afteradd: " + bf.getdodge()*100);
					else if(addType == skillType.ADDDEFEND)
						Logger.debug("@@@@@___My add Defend : my side: " + bf.getSide() +  "my  Pos: " + bf.getPos()+ "afteradd: " + bf.getDefend());*/
						
					//加基础属性的buff
//					{
//						var sBuf:BtStatus = new BtStatus();
//						sBuf.atkorBackatk = 0;
//						sBuf.sideFrom = bf.getSide();
//						sBuf.toside = bf.getSide();
//						sBuf.fpos = bf.getPos();
//						sBuf.tpos = bf.getPos();
//						sBuf.skillid = bf.getSkillID();
//						sBuf.type = 2;  
//						sBuf.data = 0;
//						sBuf.letDie = 0;
//						pPro.SChangeList.push(sBuf);
//					}

				}  
			}
			return 0;
		}
		//找到攻击者
		private function findFirstAttacker():int
		{
			var c:uint = 1;
			var cnt:uint = _fgtlist.length;
			var act:uint = _fgtlist[0].antiAction;
			while( c < cnt && _fgtlist[c].antiAction == act )
				++c;
			if( c == 1)
				return 0;
			return (ForRand.getRand(c));
		}
		
		private function addBufferByFormation():void
		{
			for (var i:int = 0; i < 2; i++)
			{
				for (var j:int = 0; j < 25; j++)
				{
					if (_objs[i][j] != null)
					{
						_objs[i][j].AddFEffect();
					}
				}
			}
		}
		
		public function setAllPlayerDodge(b:Boolean):void
		{
			var i:int;
			var j:int;
			for (i = 0; i < 2; ++i)
			{
				for (j = 0; j < 25; ++j)
				{
					if ( _objs[i][j] != null )
					{
						(_objs[i][j] as BattleFighter).setbDodge(b);
					}
				}
			}
		}
	   
		private var _id:int;
		private var _winner:int;
		private var _turns:int;
		private var _millisecs:int;
		private var _location:int;
		private var _maxTurns:int;
		private var _fgtlist:Array = [];
		private var _portrait:Array = [];
		private var _player:Array = [];
		private var _maxAction:uint;
		private var _randNumber:uint;
	   
		
	}
	
}