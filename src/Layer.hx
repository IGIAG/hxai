enum LayerType {
    NON_COMPUTING;
    RELU;
    SIGMOID;
}


class Layer {
    public var nodes:Array<Node> = [];

    public var type:LayerType = NON_COMPUTING;

    public var inputCount = 0;

    public function new(nodeCount:Int,inputCount:Int,layerType:LayerType) {
        type = layerType;
        this.inputCount = inputCount;
        for(i in 0...nodeCount){
            nodes.push(new Node(inputCount));
        }

        
    }

    public function Run(inputs:Array<Float>):Array<Float>{
        var returnable:Array<Float> = [];
        
        for(i in 0...nodes.length){
            switch (type){
                case RELU:
                    returnable.push(nodes[i].RunReLu(inputs));
                case NON_COMPUTING:
                    returnable.push(0);
                case SIGMOID:
                    returnable.push(nodes[i].RunSigmoid(inputs));
            }
            
        }
        return returnable;
    }

    public function Clone():Layer{
        var copy:Layer = new Layer(0,inputCount,type);
        for(node in nodes){
            copy.nodes.push(node.Clone());
        }

        return copy;

        
    }

    public function Mutate(amount:Int) {
        for(i in 1...amount){
            nodes[Math.floor(Math.random() * nodes.length)].Mutate();
        }
        
    }

}