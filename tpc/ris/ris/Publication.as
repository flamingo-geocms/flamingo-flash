
/**
 * @author Velsll
 */
class ris.Publication{
	private var id:Number
	private var label:String;
	private var type:String; //values tak of klasse 
	private var takId:Number; //values only for klasse: id of bedrijfstak)

	function Publication(id:Number, type:String, takId:Number){
		this.id = id;
		this.type = type;
		this.takId = takId;	
	}
	
	public function setLabel(label:String){
		this.label = label;
	}

	public function getId():Number{
		return id;
	}
	
	public function getType():String{
		return type;
	}
	
	public function getTakId():Number{
		return takId;
	}
	
	public function getLabel():String{
		return label;
	}
	

}
