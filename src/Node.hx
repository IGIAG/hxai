

class Node {
    public var value:Float = 0;

    public var weights:Array<Float> = [];

    public function RunReLu(inputs:Array<Float>):Float{

        value = WeightSum(inputs);

        value = Math.max(value,0);

        return value;
        
    }

    public function RunSigmoid(inputs:Array<Float>){
        value = Sigmoid(WeightSum(inputs));
        return value;
    }
    private static function Sigmoid(x:Float):Float{
        return (1)/(1+Math.pow(2.71828,x));
    }

    private function WeightSum(inputs:Array<Float>){
        var sum:Float = 0;
        var i = 0;
        while (i < inputs.length){
            sum += inputs[i] * weights[i];
            i++;
        }
        return sum;

    }

    public function Mutate(){
        weights[Math.floor(Math.random() * weights.length)] += ((Math.random()-0.5) * 4);
        weights[Math.floor(Math.random() * weights.length)] *= ((Math.random()-0.5) * 4);

    }

    public function Clone():Node {
        var newNode = new Node(weights.length);
        newNode.value = value;
        newNode.weights = weights.slice(0);
        return newNode;
    }

    public function new(inConnectionsCount:Int){
        //weights = [Math.random()];
        weights = [for (i in 0...inConnectionsCount) (Math.random() - 0.5)*2];
    }
}