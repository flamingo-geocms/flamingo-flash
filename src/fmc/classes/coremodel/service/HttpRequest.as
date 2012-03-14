/**
 * ...
 * @author <a href="mailto:roybraam@b3partners.nl">Roy Braam</a>
 */
/**
 * Class for a request. Holds the url and optional the body.
 */
class coremodel.service.HttpRequest {
	
	private var url:String;
	private var body:String;
	public function HttpRequest(url:String,body:String){
		this.url = url;
		this.body = body;
	}
	/**Getters setters**/
	/**
	 * Get the url
	 */
	public function getUrl():String 
	{
		return url;
	}
	/**
	 * Set the url
	 * @param value: the url
	 */
	public function setUrl(value:String):Void 
	{
		url = value;
	}
	/**
	 * Get the body of the request
	 */
	public function getBody():String 
	{
		return body;
	}
	/**
	 * Set the body 
	 * @param value the body of the request
	 */
	public function setBody(value:String):Void 
	{
		body = value;
	}
	
}