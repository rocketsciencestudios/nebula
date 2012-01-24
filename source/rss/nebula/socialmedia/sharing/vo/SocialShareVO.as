package rss.nebula.socialmedia.sharing.vo {
	/**
	 * @author fns-rss-005
	 */
	public class SocialShareVO {
		private var _shareText : String = '';
		private var _url : String = '';
		
		public function get shareText() : String {
			return _shareText;
		}

		public function set shareText(shareText : String) : void {
			_shareText = shareText;
		}

		public function get url() : String {
			return _url;
		}

		public function set url(url : String) : void {
			_url = url;
		}
		
	}
}
