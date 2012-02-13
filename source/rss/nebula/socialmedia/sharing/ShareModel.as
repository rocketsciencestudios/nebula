package rss.nebula.socialmedia.sharing {
	import rss.nebula.socialmedia.sharing.vo.ISocialShare;
	import rss.nebula.robotlegs.environment.EnvironmentModel;

	import org.robotlegs.mvcs.Actor;

	/**
	 * @author Michiel van der Plas @ Rocket Science Studios
	 */
	public class ShareModel extends Actor {
		
		[Inject]
		public var em : EnvironmentModel;

		public function ShareModel() {
		}

		public function shareOnSocialMedia(environmentNamePlatform : String, shareVO : ISocialShare) : void {
			em.navigateToByName(environmentNamePlatform, "_blank", shareVO.urlVariables());
		}
	}
}
