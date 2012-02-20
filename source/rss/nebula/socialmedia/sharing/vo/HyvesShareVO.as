package rss.nebula.socialmedia.sharing.vo {
	/**
	 * @author Michiel van der Plas @ Rocket Science Studios
	 */
	public class HyvesShareVO extends AbstractSocialShareVO implements ISocialShare{
		private var _title : String = '';
		private var _rating : int;
		private var _type : int;

		public function get title() : String {
			return _title;
		}

		public function set title(title : String) : void {
			_title = title;
		}

		public function get rating() : int {
			return _rating;
		}

		public function set rating(rating : int) : void {
			_rating = rating;
		}

		public function get type() : int {
			return _type;
		}

		public function set type(type : int) : void {
			_type = type;
		}
		
		public function urlVariables () : Object{
			var obj : Object = new Object();
			
			obj.text = '';
			if(shareText) obj.body = unescape(shareText + ' ');
			if(url) obj.text += url;
			if(_title) obj.title = _title;
			if(_rating) obj.rating = _rating;
			if(_type) obj.type = _type;
			
			return obj;
		}
	}
}
