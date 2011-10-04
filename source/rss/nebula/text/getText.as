package rss.nebula.text {
	/**
	 * @author Ralph Kuijpers @ Rocket Science Studios
	 */
	public function getText(id : String) : String {
		return TextSource.instance.getTextById(id);
	}
}
