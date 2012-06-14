package game.module.quest
{
	/**
	 * @author yangyiqiang
	 */
	public class VoNpcLink
	{
		public var id : int;

		public var type : int;

		public var messgage : String;

		public var link : String;

		public function parse(xml:XML) : void
		{
			id = xml.@id;
			type = xml.@type;
			messgage =  xml.@messgage;;
			link =  xml.@link;;
		}
	}
}
