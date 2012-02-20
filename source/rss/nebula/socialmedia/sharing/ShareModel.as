package rss.nebula.socialmedia.sharing {
	import rss.nebula.socialmedia.sharing.vo.ISocialShare;
	import rss.nebula.robotlegs.environment.EnvironmentModel;
	import rss.nebula.socialmedia.sharing.vo.FacebookShareVO;
	import rss.nebula.socialmedia.sharing.vo.HyvesShareVO;
	import rss.nebula.socialmedia.sharing.vo.TwitterShareVO;

	import org.robotlegs.mvcs.Actor;

	/**
	 * @author Michiel van der Plas @ Rocket Science Studios
	 */
	public class ShareModel extends Actor {
		
		[Inject]
		public var em : EnvironmentModel;
		
		private var _facebookVO : FacebookShareVO;
		private var _twitterVO : TwitterShareVO;
		private var _hyvesVO : HyvesShareVO;

		public function ShareModel() {
		}
		
		public function share(platform : String) : void {
			var vo : ISocialShare;
			switch(platform){
				case SocialEnvironmentNames.FACEBOOK:
					vo = _facebookVO;
					break;
				case SocialEnvironmentNames.TWITTER:
					vo = _twitterVO;
					break;
				case SocialEnvironmentNames.HYVES:
					vo = _hyvesVO;
					notice(_hyvesVO.title);
					notice(vo.urlVariables().name);
					break;
				default:
			}
			em.navigateToByName(platform, "_blank", vo.urlVariables());
		}

		public function get facebookVO() : FacebookShareVO {
			return _facebookVO ||= _facebookVO = new FacebookShareVO();
		}

		public function get twitterVO() : TwitterShareVO {
			return _twitterVO ||= new TwitterShareVO();
		}

		public function get hyvesVO() : HyvesShareVO {
			return _hyvesVO ||= new HyvesShareVO();
		}
	}
}
