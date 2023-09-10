import sys.thread.Lock;
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

        var lock = new Lock();

        var chunkSize:Int = 4; // Number of elements to process in each thread
        var chunks:Array<Array<Node>> = splitArray(nodes, chunkSize);

        var threads:Array<sys.thread.Thread> = [];
        for (chunk in chunks) {
            var thread = Thread.create(function() {
                for (data in chunk) {
                    switch (type){
                        case RELU:
                            //Thread.create(() -> {
                                //trace("LOL1");
                           //     threadOMap.set(i,nodes[i].RunReLu(inputs));
                                //trace("LOL");
                            //});
                            
                            
                            data.RunReLu(inputs);
                        case NON_COMPUTING:
                            //returnable.push(0);
                        case SIGMOID:
                           //Thread.create(() -> {
                            //    //trace("LOL2");
                                //threadOMap.set(i,nodes[i].RunSigmoid(inputs));
                                //trace("LOL");
                            //});
                            data.RunSigmoid(inputs);
                    }
                    lock.release();
                }
            });
            threads.push(thread);
        }
        for (_ in nodes) {
            // Wait 3 times
            lock.wait();
            //trace("node");
            //Sys.stdout().writeString(",");
        }
        //lock.wait();

        //trace('layer! ${nodes.length}');

    
        /*for(i in 0...nodes.length){

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
        }*/




        /*trace("dun");
        var keys: Array<Int> = [];
        for (key in threadOMap.keys()) {
            keys.push(key);
        }
        keys.sort(function(a, b) return a - b);

        // Iterate through sorted keys and add corresponding float values to the array
        for (key in keys) {
            returnable.push(threadOMap[key]);
        }*/

        
        for(node in nodes){
            returnable.push(node.value);
        }

        return returnable;

        
    }
    private static function splitArray<T>(array:Array<T>, chunkSize:Int):Array<Array<T>> {
        var result:Array<Array<T>> = [];
        if(array.length == 1){
            return [ array ];
        }
        for (i in 0...Math.floor(array.length / chunkSize)) {
            var start:Int = i * chunkSize;
            var end:Int = Math.floor(Math.min(start + chunkSize, array.length));
            result.push(array.slice(start, end));
        }
        return result;
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