
/**
 * @author velsll
 */
 

 
class ris.BridgisAccount {
	private var userName:String = "";
	private var passWord:String = "";
	
	public function getUserName():String{
		return userName;
	}
	
	public function getPassword():String{
		return passWord;
	}
	
	public function setUserName(userName:String):Void{
		this.userName = userName;
	}
	
	public function setPassWord(passWord:String):Void{
		this.passWord = passWord;
	}
}
