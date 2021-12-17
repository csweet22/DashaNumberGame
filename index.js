const dasha = require("@dasha.ai/sdk");
const fs = require("fs");


async function main() 
{
  const app = await dasha.deploy("./app");

  app.connectionProvider = async (conv) =>
    conv.input.phone === "chat"
      ? dasha.chat.connect(await dasha.chat.createConsoleChat())
      : dasha.sip.connect(new dasha.sip.Endpoint("default"));

  app.ttsDispatcher = () => "dasha";


  // VARIABLES

  var maxNumber = 100;
  var currentGuess = -1;

  // FUNCTIONS

  app.setExternal("setMaxNumber", (args, conv)=> {
    maxNumber = args[0];
  });

  app.setExternal("getRandNum", (args, conv)=> {
    var max = args.passedMax;
    var targetNum = Math.floor(Math.random() * max);
    return targetNum;
  });
  
  app.setExternal("compareGuess", (args, conv)=> {
    var guess = parseInt(args.data);
    var targetNumber = parseInt(args.targetNumber);
    if (guess > targetNumber){
      return 1;
    } else if (guess < targetNumber){
      return -1;
    } else if (guess == targetNumber){
      return 0;
    } else {
      return 2;
    }
  });
  
  app.setExternal("consoleLog", (args, conv)=> {
    console.log(args);
  });


  // STARTING THE APP

  await app.start();

  const conv = app.createConversation({ phone: process.argv[2] ?? "", name: process.argv[3] ?? "" });

  if (conv.input.phone !== "chat") conv.on("transcription", console.log);

  const logFile = await fs.promises.open("./log.txt", "w");
  await logFile.appendFile("#".repeat(100) + "\n");

  conv.on("transcription", async (entry) => {
    await logFile.appendFile(`${entry.speaker}: ${entry.text}\n`);
  });

  conv.on("debugLog", async (event) => {
    if (event?.msg?.msgId === "RecognizedSpeechMessage") {
      const logEntry = event?.msg?.results[0]?.facts;
      await logFile.appendFile(JSON.stringify(logEntry, undefined, 2) + "\n");
    }
  });

  const result = await conv.execute();

  console.log(result.output);

  await app.stop();
  app.dispose();

  await logFile.close();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
