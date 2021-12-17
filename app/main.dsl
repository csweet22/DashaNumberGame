import "commonReactions/all.dsl";

context 
{
    input phone: string;

    targetNum: number = 0;
    guess: string = "";
    compare: number = -10;
    max: number = 100;
}

external function consoleLog(data: string): string;
external function compareGuess(data: string, targetNumber: number): number;
external function getRandNum(passedMax: number): number;


start node root 
{
    do //actions executed in this node 
    {
        #connectSafe($phone); // connecting to the phone number which is specified in index.js that it can also be in-terminal text chat
        #waitForSpeech(1000); // give the person a second to start speaking 
        #sayText("Welcome to the number guessing game! I choose a number, you try to guess it.");

        set $targetNum = external getRandNum($max);

        wait *;
    }
    transitions 
    {
        guessed: goto guessed on #messageHasData("number");
    }
}

node startingNode 
{
    do //actions executed in this node 
    {
        #sayText("I choose a number, you try to guess it.");
        set $targetNum = external getRandNum($max);
        wait *;
    }
    transitions 
    {
        guessed: goto guessed on #messageHasData("number");
    }
}

node tryAgain{
    do{
    #sayText("Sorry! I couldn't hear what you said, could you say it again?");
    
        wait *;
    }
    transitions 
    {
        guessed: goto guessed on #messageHasData("number");
    }
}

node guessed{
    do{

        set $guess =  #messageGetData("number")[0]?.value??""; 
        // external consoleLog($guess);
        set $compare = external compareGuess($guess, $targetNum);


        // external consoleLog();
        // var num: number = 15;
        // #log(num.toString()); // "15"


        if ($compare == 0){
            goto correct;
        } else if ($compare == 1){
            goto guessLower;
        } else if ($compare == -1) {
            goto guessHigher;
        } else {
            goto tryAgain;
        }

    }
    transitions{
            correct: goto correct;
            guessLower: goto guessLower;
            guessHigher: goto guessHigher;
            tryAgain: goto tryAgain;
    }
}

node correct{
    do{
        #sayText("Correct!");
        goto startingNode;
    }
    transitions {
        startingNode: goto startingNode;
    }
}

node guessHigher{
    do{
        #sayText("Guess higher!");
        wait *;
    }
    transitions {
        guessed: goto guessed on #messageHasData("number");
    }
}
node guessLower{
    do{
        #sayText("Guess lower!");
        wait *;
    }
    transitions {
        guessed: goto guessed on #messageHasData("number");
    }
}
