package game.module.mapFeast.element {
	import game.module.map.animal.AnimalType;
	import game.module.map.animalstruct.AbstractStruct;

	/**
	 * @author 1
	 */
	public class CoupleStruct extends AbstractStruct {
		
		public var coupleId:uint ;
		
		public function CoupleStruct() {
		}
		
		/** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.COUPLE;
        }
	}
}
