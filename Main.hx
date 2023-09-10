
import thx.csv.Csv;
import sys.io.File;
import haxe.crypto.Md5;
import haxe.Json;

class Main {
    public static function main(){
        


        var primary:Network = new Network();
        primary.addLayer(new Layer(4,1,RELU));
        primary.addLayer(new Layer(4,4,SIGMOID));
        primary.addLayer(new Layer(4,4,RELU));
        primary.addLayer(new Layer(4,4,SIGMOID));
        primary.addLayer(new Layer(1,4,RELU));

        var train = true;

        trace("To load a model press 'l' and then enter. To train new network press enter!");
        if(Sys.stdin().readLine() == "l"){
            var parser = new json2object.JsonParser<Network>(); // Creating a parser for Cls class
            trace("enter the model file path:");
            var path:String = Sys.stdin().readLine();

            parser.fromJson(File.getContent(path), "./error.txt"); // Parsing a string. A filename is specified for errors management
            var data:Network = parser.value;

            primary = data;
            train = false;
        }

        //primary.Save();

        //var training_inputs:Array<Float> = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,];
        var training_inputs:Array<Float> = [for (i in 1...5000) i];
        var training_outputs:Array<Array<Float>> = [for(i in 1...5000) GenTrainingLabels(i)];
        //var training_outputs:Array<Array<Float>> = [[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0]];

        if(training_inputs.length != training_outputs.length){
            trace(training_inputs.length);
            trace(training_outputs.length);
        }

        var epochsLeft = 2000;
        var improvmentsFound:Int = 0;

        while(epochsLeft > 0 && train){
            epochsLeft--;
            
            var contender:Network = primary.Clone();
            if(epochsLeft % 10 == 0){
                contender.Mutate(8);
            }
            else {
                contender.Mutate(2);
            }
            

            var i = 0;

            var deltaTotalPrimary:Float = 1;

            var deltaTotalContender:Float = 1;

            while(i < training_inputs.length){
                var predictionPrimary = primary.Run([training_inputs[i]]);
                var predictionContender = contender.Run([training_inputs[i]]);

                var deltaPrimary = Math.abs(predictionPrimary[0] - training_outputs[i][0]); //+ Math.abs(predictionPrimary[1] - training_outputs[i][1]);
                
                var deltaContender = Math.abs(predictionContender[0] - training_outputs[i][0]);// + Math.abs(predictionContender[1] - training_outputs[i][1]);
                
                deltaTotalPrimary += deltaPrimary;
                deltaTotalContender += deltaContender;
                i++;
            
            }

            var avgDelta:Float = 0;

            if(deltaTotalContender < deltaTotalPrimary){
                trace(Md5.encode(Json.stringify(primary)));
                primary = null;
                primary = contender.Clone();
                trace(Md5.encode(Json.stringify(primary)));
                avgDelta = deltaTotalContender/training_inputs.length;
                var avgDeltaOld = deltaTotalPrimary/training_inputs.length;
                //Sys.println("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
                trace('NEW RECORD DELTA $avgDelta! Old: $avgDeltaOld Epochs left: $epochsLeft');
                improvmentsFound += 1;
            } else {
                Sys.print(".");
                avgDelta = deltaTotalPrimary/training_inputs.length;
                //Sys.stdout().writeString(". ");
            }
            
            

            //trace('EPOCH COMPLETE($epochsLeft remaining) $deltaTotalPrimary vs $deltaTotalContender');
        }
        //trace(Md5.encode(Json.stringify(primary)));
        //primary.Mutate(3);
        trace(Md5.encode(Json.stringify(primary)));
        if(train){
            primary.Save();
        }
        
        trace('TRAINING DONE! Found $improvmentsFound better configs! ANALISYS MODE!');

        var results:Array<Array<String>> = [];

        for(i in 0...training_inputs.length){

            var modelPredicted = primary.Run([ training_inputs[i] ]);

            var expected = training_outputs[i][0];

            var delta = Math.abs(modelPredicted[0] - expected);

            results.push([Std.string(i),Std.string(delta)]);

            
        }

       
        File.saveContent("./analisys.csv",Csv.encode(results)); 

        trace("INFERENCE MODE!");

        while(true){
            trace(primary.Run([Std.parseFloat(Sys.stdin().readLine()) ]));
        }

    }
    public static function GenTrainingLabels(i:Int):Array<Float>{
        if(i % 2 != 0){
            return [ i * 2 ];
        }
        return [ i ];
    }
}
typedef AResult = {
    input:String,
    output:String
}

            