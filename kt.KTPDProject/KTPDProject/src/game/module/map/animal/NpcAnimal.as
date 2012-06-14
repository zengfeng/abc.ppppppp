package game.module.map.animal
{
	import game.core.avatar.AvatarThumb;
	import game.module.map.NpcSignals;
	import game.module.map.SelfPlayerSignal;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.animalstruct.NpcStruct;
	import game.module.map.proessors.ais.MonsterAIProcessor;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����5:42:42
	 */
	public class NpcAnimal extends Animal
	{
		protected var npcStruct : NpcStruct;
		protected var aiProcessor : MonsterAIProcessor;

		public function NpcAnimal(avatar : AvatarThumb, struct : AbstractStruct)
		{
			npcStruct = struct as NpcStruct;
			super(avatar, struct);
		}

		public function startupAI() : void
		{
			if (npcStruct.hasAvatar == false)
			{
				avatar.alpha = 0;
			}

			if (aiProcessor == null)
			{
				aiProcessor = new MonsterAIProcessor();
			}
			var self : SelfPlayerAnimal = AnimalManager.instance.selfPlayer;
			signalQuit.add(cancleAI);
			aiProcessor.signalWalkTo.add(walk);
			aiProcessor.signalHitEnemy.add(hitEnemy);
			aiProcessor.reset(npcStruct.position.x, npcStruct.position.y, npcStruct.standPostion, npcStruct.moveRadius, npcStruct.attackRadius, npcStruct.x, npcStruct.y, self.position);
			signalUpdatePosition.add(aiProcessor.updatePosition);
			self.signalUpdatePosition.add(aiProcessor.enemyUpdatePosition);
		}

		private function cancleAI() : void
		{
			SelfPlayerSignal.severTransport.remove(aiStart);
			signalQuit.remove(cancleAI);
			signalUpdatePosition.remove(aiProcessor.updatePosition);
			aiProcessor.destory();
		}

		public function aiStart() : void
		{
			SelfPlayerSignal.severTransport.remove(aiStart);
			aiProcessor.start();
		}

		public function aiStop() : void
		{
			aiProcessor.stop();
		}

		private function hitEnemy() : void
		{
			trace("hitEnemy");
			stopMove();
			var self : SelfPlayerAnimal = AnimalManager.instance.selfPlayer;
			self.stopMove();
			SelfPlayerSignal.severTransport.add(aiStart);
			NpcSignals.aiHit.dispatch(npcStruct.id);
		}
	}
}
