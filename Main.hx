import eval.luv.Random;
import haxe.crypto.Md5;
import eval.luv.Dir;
import haxe.Json;

class Main {
    public static function main(){
        var primary:Network = new Network();
        primary.addLayer(new Layer(8,1,SIGMOID));
        primary.addLayer(new Layer(16,8,SIGMOID));
        primary.addLayer(new Layer(8,16,RELU));
        primary.addLayer(new Layer(8,8,RELU));
        primary.addLayer(new Layer(1,8,SIGMOID));

        primary.Save();

        //var training_inputs:Array<Float> = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,];
        var training_inputs:Array<Float> = [for (i in 10...100) i];
        var training_outputs:Array<Array<Float>> = [for(i in 10...100) GenTrainingLabels(i)];
        //var training_outputs:Array<Array<Float>> = [[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0]];

        if(training_inputs.length != training_outputs.length){
            trace(training_inputs.length);
            trace(training_outputs.length);
        }

        var epochsLeft = 10000;
        var improvmentsFound:Int = 0;

        while(epochsLeft > 0){
            epochsLeft--;
            
            var contender:Network = primary.Clone();

            if(epochsLeft % 100 == 0){
                contender.Mutate(64);
            }
            else if(epochsLeft % 6 == 0){
                contender.Mutate(24);
            }
            else if((epochsLeft + 1) % 6 == 0){
                contender.Mutate(8);
            }
            else {
                contender.Mutate(3);
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
                Sys.println("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
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
        primary.Save();
        trace('TRAINING DONE! Found $improvmentsFound better configs! INFERENCE MODE!');
        while(true){

            var o = primary.Run([ Std.parseFloat(Sys.stdin().readLine())]);


            trace(o[0]);
        }

       
        
    }
    public static function GenTrainingLabels(i:Int):Array<Float>{
        return [ Math.sqrt(i) ];
    }
}

            