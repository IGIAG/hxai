import thx.csv.Csv;
import sys.io.File;
import haxe.crypto.Md5;
import haxe.Json;

class TextTokenizer {
    public static function Run(){
        var primary:Network = new Network();
        primary.addLayer(new Layer(32,24,RELU));
        primary.addLayer(new Layer(8,32,SIGMOID));
        primary.addLayer(new Layer(2,8,RELU));
        primary.addLayer(new Layer(8,2,SIGMOID));
        primary.addLayer(new Layer(32,8,RELU));
        primary.addLayer(new Layer(24,32,SIGMOID));

        var train = true;

        /*trace("To load a model press 'l' and then enter. To train new network press enter!");
        if(Sys.stdin().readLine() == "l"){
            var parser = new json2object.JsonParser<Network>(); // Creating a parser for Cls class
            trace("enter the model file path:");
            var path:String = Sys.stdin().readLine();

            parser.fromJson(File.getContent(path), "./error.txt"); // Parsing a string. A filename is specified for errors management
            var data:Network = parser.value;

            primary = data;
            train = true;
        }*/

        //primary.Save();

        //var training_inputs:Array<Float> = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,];
        var trainingWords:Array<String> = File.getContent("./datasets/datasetad").split("\n");
        //var training_outputs:Array<Array<Float>> = [[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0],[0,10],[10,0]];

        /*if(training_inputs.length != training_outputs.length){
            trace(training_inputs.length);
            trace(training_outputs.length);
        }*/

        var epochsLeft = 10000;
        var improvmentsFound:Int = 0;

        while(epochsLeft > 0 && train){
            epochsLeft--;
            
            var contender:Network = primary.Clone();
            if(epochsLeft % 10 == 0){
                contender.Mutate(4);
            }
            else if((epochsLeft + 1) % 10 == 0){
                contender.Mutate(16);
            }
            else {
                contender.Mutate(2);
            }
            

            var i = 0;

            var deltaTotalPrimary:Float = 1;

            var deltaTotalContender:Float = 1;

            while(i < trainingWords.length){
                var floated = stringToFloatArray(trainingWords[i],24);
                //trace(floated);

                var predictionPrimary = primary.Run(floated);
                var predictionContender = contender.Run(floated);

                var deltaPrimary = calculateAverageDifference(predictionPrimary,floated);
                var deltaContender = calculateAverageDifference(predictionContender,floated);



                //var deltaPrimary = Math.abs(predictionPrimary[0] - training_outputs[i][0]); //+ Math.abs(predictionPrimary[1] - training_outputs[i][1]);
                
                //var deltaContender = Math.abs(predictionContender[0] - training_outputs[i][0]);// + Math.abs(predictionContender[1] - training_outputs[i][1]);
                
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
                avgDelta = deltaTotalContender/trainingWords.length;
                var avgDeltaOld = deltaTotalPrimary/trainingWords.length;
                //Sys.println("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
                trace('NEW RECORD DELTA $avgDelta! Old: $avgDeltaOld Epochs left: $epochsLeft');
                improvmentsFound += 1;
            } else {
                Sys.print(".");
                avgDelta = deltaTotalPrimary/trainingWords.length;
                //Sys.stdout().writeString(". ");
            }
            if(epochsLeft % 1000 == 0){
                primary.Save(epochsLeft);
            }
            
            

            //trace('EPOCH COMPLETE($epochsLeft remaining) $deltaTotalPrimary vs $deltaTotalContender');
        }
        //trace(Md5.encode(Json.stringify(primary)));
        //primary.Mutate(3);
        trace(Md5.encode(Json.stringify(primary)));
        if(train){
            primary.Save(-1);
        }
        
        trace('TRAINING DONE! Found $improvmentsFound better configs! ANALISYS MODE!');

        /*var results:Array<Array<String>> = [];

        for(i in 0...trainingWords.length){

            var modelPredicted = primary.Run([ trainingWords[i] ]);

            var expected = training_outputs[i][0];

            var delta = Math.abs(modelPredicted[0] - expected);

            results.push([Std.string(i),Std.string(delta)]);

            
        }

       
        File.saveContent("./analisys.csv",Csv.encode(results));*/

        trace("INFERENCE MODE!");

        while(true){
            trace(floatArrayToString(primary.Run(stringToFloatArray(Sys.stdin().readLine(),24))));
        }
    }
    public static function GenTrainingLabels(i:Int):Array<Float>{
        return [ Math.sqrt(i) ];
    }
    static function floatArrayToString(floatArray:Array<Float>):String {
        var result:String = '';
        
        for (value in floatArray) {
            // Round the float value to the nearest integer and convert it to a character
            var charCode:Int = Math.round(value);
            var char:String = String.fromCharCode(charCode);
            
            // Append the character to the result string
            result += char;
        }
        
        return result;
    }
    static function stringToFloatArray(input:String,length:Int):Array<Float> {
        var result:Array<Float> = [];
        
        for (i in 0...(Math.floor(Math.min(input.length,24)))) {
            // Get the ASCII value of the character at index i
            var asciiValue:Float = input.charCodeAt(i);
            
            // Add the ASCII value as a float to the result array
            result.push(asciiValue);
        }
        while(result.length < length){
            result.push(-1);
        }
        
        return result;
    }
    static function calculateAverageDifference(arr1: Array<Float>, arr2: Array<Float>): Float {
        if (arr1.length != arr2.length) {
            throw "Input arrays must have the same size.";
        }
        
        var sumDifference: Float = 0.0;
        
        for (i in 0...arr1.length) {
            sumDifference += Math.abs(arr1[i] - arr2[i]);
        }
        
        return sumDifference / arr1.length;
    }
    
}