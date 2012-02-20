package rss.nebula.socialmedia.sharing.vo {
	/**
	 * @author Michiel van der Plas @ Rocket Science Studios
	 */
	public class FacebookShareVO extends AbstractSocialShareVO implements ISocialShare {
		private var _url : String = '';
		
		override public function get url() : String {
			return _url;
		}

		override public function set url(url : String) : void {
			_url = url;
		}

		public function urlVariables () : Object{
			var obj : Object = new Object();
			obj.u = _url;
			return obj;
		}
	}
}
