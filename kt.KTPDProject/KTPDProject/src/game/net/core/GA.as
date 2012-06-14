package game.net.core
{
	/**
	 * @author yangyiqiang
	 */
	public class GA
	{
	/**
	 * ## 统计事件
	PreLoading 部分
	创建角色：
	Loader 载入，开始可执行 AS 代码：
	已创建角色：_gaq.push(['ue._trackEvent', 'InitGame', 'CharCreation', 'StartLoading'])
	未创建角色：_gaq.push(['ue._trackEvent', 'PreLoading', 'CharCreation', 'StartLoading'])
	记录变量：
	_gaq.push(['_setCustomVar', 1, _src])
	创建角色页载入完毕：_gaq.push(['ue._trackTiming', 'PreLoading', 'CharCreation', <创建角色页面加载了多少豪秒，非负整数>, 'FinishLoading'])
	创建角色页面停留时间：_gaq.push(['ue._trackTiming', 'PreLoading', 'StayTime', <停留了多少毫秒，非负整数>, 'CharCreation'])
	预加载资源：每个需要预加载的资源，有个唯一的 <UniqueAssetsName>
	_gaq.push(['ue._trackEvent' , 'PreLoading', '<UniqueAssetsName>', 'StartLoading'])
	_gaq.push(['ue._trackEvent' , 'PreLoading', 'AssetsLoadedCount' , '', <总共预加载了多少个资源，非负整数>])
	_gaq.push(['ue._trackTiming', 'PreLoading', '<UniqueAssetsName>', <这个资源一共加载了多少豪秒，非负整数>, 'FinishLoading'])
	_gaq.push(['ue._trackTiming', 'PreLoading', 'AssetsLoadedTime'  , <预加载的资源总计耗时多少豪秒，非负整数>, '<角色性别职业ID>'])
	创建完毕后，记录变量
	_gaq.push(['ue._setCustomVar', 2, '<角色性别职业ID>'])
	升级：_gaq.push(['ue._trackEvent', 'Level', 'Up', '<角色性别职业ID>', <数字级别>])
	 */
	}
}
