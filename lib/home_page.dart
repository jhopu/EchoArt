import 'package:first_ashish/openai_service.dart';
import 'package:first_ashish/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:animate_do/animate_do.dart';
import 'feature_box.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});
  @override
  State<HomePage> createState()=>_HomePageState();
}

class _HomePageState extends State<HomePage>{
  final speechToText=SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  String lastWords='';
  final OpenAIService openAIService=OpenAIService();
  String ? as;
  String ? generatedContent;
  String ? generatedImageUrl;

  @override
  void initState(){
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }
  Future<void>initTextToSpeech() async{
    await flutterTts.setSharedInstance(true);
    setState(() {
    });
  }
  Future<void>initSpeechToText() async{
  await speechToText.initialize();
  setState(() {
  });

  }
  Future<void>startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void>stopListening() async {
    await speechToText.stop();
    setState(() {});
  }
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }
  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }
  @override
  void dispose(){
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Bounce(child: const Text('Allen')),
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed:(){
generatedImageUrl=null;
generatedContent=null;
setState(() {

});
          },
        ),

        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //profile image part
            
           ZoomIn(
             child: Stack(
               children: [
                 Center(
                   child: Container(
                     height: 120,
                     width: 120,
                     margin: const EdgeInsets.only(top:4),
                     decoration: const BoxDecoration(
                       color: Pallete.assistantCircleColor,
                       shape:BoxShape.circle,
                     ),
                   ),
                 ),
                 Container(
                   height: 123,
                   decoration: const BoxDecoration(
                     shape: BoxShape.circle,
                     image:DecorationImage(image: AssetImage(
                       'assets/images/virtualAssistant.png',
                     ),),
                   ),
                 )
               ],
             ),
           ),
            //chat box
            
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal:20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top:30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:Pallete.borderColor,
              
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
              
                  ),
                  child:  Padding(
                    padding:  const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent==null?'Good Morning, what task can I do for you?':generatedContent!,style:TextStyle(
                               color: Pallete.mainFontColor,
                    fontSize: generatedContent==null ?25:18,
                    fontFamily: 'Cera Pro'
                        ),),
                  ),
                ),
              ),
            ),
            //some text
            if(generatedImageUrl!=null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(generatedImageUrl!),
              ),

            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top:10,left:22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color:Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //features box
             Visibility(
               visible: generatedContent==null && generatedImageUrl==null,
               child: Column(
                children: [
                  
                  SlideInLeft(
                    child: const FeatureBox(color:Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText: 'A smarter way to stay organized and informed with ChatGPT',),
                  ),
                  SlideInRight(
                    child: const FeatureBox(color:Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText: 'A smarter way to stay organized and informed with ChatGPT',),
                  ),
                  
                  SlideInLeft(
                    child: const FeatureBox(color:Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText: 'A smarter way to stay organized and informed with ChatGPT',),
                  ),
                ],
                           ),
             ),
          ],
        ),
      ), 
       
      floatingActionButton: ZoomIn(
        child: FloatingActionButton(onPressed: ()async{
          if(await speechToText.hasPermission && speechToText.isNotListening){
           await startListening();
        }
          else if(speechToText.isListening){
            final speech=await openAIService.isArtPromptAPI(lastWords);
            if(speech.contains('https')){
              generatedImageUrl=speech;
              generatedContent=null;
              setState(() {

              });
            }
            else{
              generatedImageUrl=null;
              generatedContent=speech;
              setState(() {
        
              });
              await systemSpeak(speech);
            }
        
           await stopListening();
          }
          else{
            initSpeechToText();
          }
        },
          backgroundColor: Pallete.firstSuggestionBoxColor,
          child:  Icon(speechToText.isListening?Icons.stop:Icons.mic),
        ),
      ),
    );
  }
}