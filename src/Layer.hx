import sys.thread.ElasticThreadPool;
import sys.thread.Thread;

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
       // var threadOMap:Map<Int,Float> = [];
        //var threads:Array<Thread> = [];
        //var pool = new ElasticThreadPool(64,6);
        for(i in 0...nodes.length){

            switch (type){
                case RELU:
                    //Thread.create(() -> {
                        //trace("LOL1");
                   //     threadOMap.set(i,nodes[i].RunReLu(inputs));
                        //trace("LOL");
                    //});
                    
                    
                    returnable.push(nodes[i].RunReLu(inputs));
                case NON_COMPUTING:
                    returnable.push(0);
                case SIGMOID:
                   //Thread.create(() -> {
                    //    //trace("LOL2");
                        //threadOMap.set(i,nodes[i].RunSigmoid(inputs));
                        //trace("LOL");
                    //});
                    returnable.push(nodes[i].RunSigmoid(inputs));
            }
        }
        /*while(returnable.length != nodes.length){
            //trace("waiting for threads...");
        }
        trace("dun");
        var keys: Array<Int> = [];
        for (key in threadOMap.keys()) {
            keys.push(key);
        }
        keys.sort(function(a, b) return a - b);

        // Iterate through sorted keys and add corresponding float values to the array
        for (key in keys) {
            returnable.push(threadOMap[key]);
        }*/
        



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