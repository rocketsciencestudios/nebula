package rss.nebula.video.threesixty {
	/**
	 * @author Ralph Kuijpers (c) RocketScienceStudios.com
	 */
	public class Video360VO {
		private var _url : String;
		private var _sourceWidth : String;
		private var _sourceHeight : String;

		public function get url() : String {
			return _url;
		}

		public function get sourceWidth() : String {
			return _sourceWidth;
		}

		public function get sourceHeight() : String {
			return _sourceHeight;
		}


		public function set url(url : String) : void {
			_url = url;
		}

		public function set sourceWidth(sourceWidth : String) : void {
			_sourceWidth = sourceWidth;
		}

		public function set sourceHeight(sourceHeight : String) : void {
			_sourceHeight = sourceHeight;
		}
		
		public function toString() : String {
			return "nl.rocketsciencestudios.model.vo.Video360VO:\n url: " + url + "\n sourceDimensions: " + sourceWidth + "x" + sourceHeight;
		}
	}
}
