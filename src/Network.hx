import haxe.Json;

class Network {
    public var layers:Array<Layer> = [];

    public function addLayer(layer:Layer){
        layers.push(layer);
    }

    public function Clone():Network{
        var copy = new Network();
        for(layer in layers){
            copy.addLayer(layer.Clone());
        }
        return copy;

    }
    public function new(){

    }
    public function Mutate(amount:Int){
        for(i in 1...amount){
            layers[Math.floor(Math.random() * layers.length)].Mutate(amount);
        }
    }

    public function Save(){
        sys.io.File.saveContent('./model${Math.floor(Math.random() * 1000000)}.json',Json.stringify(this));
    }
    
    public function Run(inputs:Array<Float>):Array<Float>{
        var values:Array<Float> = Reflect.copy(inputs);

        for(layer in layers){
            values = layer.Run(values);
            
        }

        return values;
    }
}