package game.module.sutra {
	import game.net.core.Common;
	import game.net.data.StoC.SCHeroEnhance;
	/**
	 * @author 1
	 */
	public class ProxySutra {
		public function ProxySutra():void
		{
			Common.game_server.addCallback(0x15, sCHeroEnhance );
		}

		private function sCHeroEnhance(e:SCHeroEnhance) : void {
			
		}
	}
}
