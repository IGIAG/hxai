
import sys.thread.Lock;
import sys.io.File;
import haxe.crypto.Md5;
import haxe.Json;

class Main {
    public static function main(){
        


        var primary:Network = new Network();
        primary.addLayer(new Layer(8,1,SIGMOID));
        primary.addLayer(new Layer(8,8,SIGMOID));
        primary.addLayer(new Layer(8,8,RELU));
        primary.addLayer(new Layer(8,8,SIGMOID));
        primary.addLayer(new Layer(1,8,RELU));

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

        var epochsLeft = 5000;
        var improvmentsFound:Int = 0;

        while(epochsLeft > 0 && train){
            var startTime: Float = Sys.time();
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
                Sys.stdout().flush();

            }


            
            var avgDelta:Float = 0;

            var endTime: Float = Sys.time();


            if(deltaTotalContender < deltaTotalPrimary){
                trace(Md5.encode(Json.stringify(primary)));
                primary = null;
                primary = contender.Clone();
                trace(Md5.encode(Json.stringify(primary)));
                avgDelta = deltaTotalContender/training_inputs.length;
                var avgDeltaOld = deltaTotalPrimary/training_inputs.length;
                Sys.println("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
                var elapsedTime: Float = endTime - startTime;
                trace('NEW RECORD DELTA $avgDelta! Old: $avgDeltaOld Epochs left: $epochsLeft, Epoch took $elapsedTime ms.');
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
        
        trace('TRAINING DONE! Found $improvmentsFound better configs! INFERENCE MODE!');
        //trace(primary.Run([ 36 ]));
        while(true){
            var input:String = Sys.stdin().readLine();
            var startTime: Float = Sys.time();
            var o = primary.Run([ Std.parseFloat(input)]);

            var endTime:Float = Sys.time(); // Get the current time again

            var elapsedTime:Float = endTime - startTime; // Calculate the elapsed time in milliseconds

            trace(o[0] + ' $elapsedTime ms');
        }

       
        
    }
    public static function GenTrainingLabels(i:Int):Array<Float>{
        return [ Math.sqrt(i) ];
    }
}

            