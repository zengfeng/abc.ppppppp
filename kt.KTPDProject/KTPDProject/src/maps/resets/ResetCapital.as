package maps.resets
{
    import maps.resets.ResetNormal;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class ResetCapital extends ResetNormal
    {
        /** 单例对像 */
        private static var _instance : ResetCapital;

        /** 获取单例对像 */
        public static function get instance() : ResetCapital
        {
            if (_instance == null)
            {
                _instance = new ResetCapital(new Singleton());
            }
            return _instance;
        }

        public function ResetCapital(singleton : Singleton)
        {
        }
    }
}
class Singleton
{
}