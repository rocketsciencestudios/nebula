package rss.nebula.socialmedia.sharing {
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

		public function shareOnSocialMedia(environmentNamePlatform : String, shareOptions : Object) : void {
			em.navigateToByName(environmentNamePlatform, "_blank", shareOptions);
		}
	}
}
