package rss.nebula.socialmedia.sharing.vo {
	/**
	 * @author Michiel van der Plas @ Rocket Science Studios
	 */
	public class FacebookShareVO {
		private var _url : String = '';
		
		public function get url() : String {
			return _url;
		}

		public function set url(url : String) : void {
			_url = url;
		}

		public function returnUrlVariables () : Object{
			var obj : Object = new Object();
			obj.u = _url;
			return obj;
		}
	}
}
