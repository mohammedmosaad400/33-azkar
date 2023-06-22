// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'package:Crazy_Mezo/main/ad_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//ADMOB
const int maxFailedLoadAttempts = 3;
const int maxSubmitToShowAd = 1;

// TODO import Dialogflow
DialogflowGrpcV2Beta1? dialogflow;


class Mezi extends StatefulWidget {
  const Mezi({Key? key}) : super(key: key);

  @override
  _MeziState createState() => _MeziState();
}

class _MeziState extends State<Mezi> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();

  // TODO DialogflowGrpc class instance
  // ADMOB Banner
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  void _createBannerAd(){
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_){
          _isBannerAdLoaded = true;
        },onAdFailedToLoad: (ad,error){
          ad.dispose();

        }),
        request: const AdRequest());
    _bannerAd?.load();

  }
  //ADMOB
  int _interstitialLoadAttempts = 0;
  int _showAdAfterSubmit = 0;
  InterstitialAd? _interstitialAd;
  void _createInterstitialAd(){
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad){
              _interstitialAd = ad;
              _interstitialLoadAttempts = 0;
        },
            onAdFailedToLoad: (LoadAdError error){
              _interstitialLoadAttempts += 1;
              _interstitialAd = null;
              if(_interstitialLoadAttempts >= maxFailedLoadAttempts){_createInterstitialAd();}
            }));}

  void _showInterstitialAd(){
    _showAdAfterSubmit += 1;
    if(_interstitialAd != null){
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad){
            ad.dispose();
            _createInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad,AdError error){
            ad.dispose();
            _createInterstitialAd();
          });
      if(_showAdAfterSubmit >= maxSubmitToShowAd) {
        _showAdAfterSubmit = 0;
        _interstitialAd?.show();
      }
    }
  }
  @override
  void initState() {
    //start
    WidgetsBinding.instance?.addPostFrameCallback((_) => {handleSubmitted("")});
    //
    super.initState();
    //ADMOB
    _createInterstitialAd();
    //ADMOB Banner
    _createBannerAd();
    initPlugin();
  }

  @override
  void dispose() {
    super.dispose();
    //ADMOB
    _interstitialAd?.dispose();
    //ADMOB Banner
    _bannerAd?.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    // TODO Get a Service account
    // Get a Service account
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/credentials.json')));
    // Create a DialogflowGrpc Instance
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);

  }

  void handleSubmitted(text) async {
    if (kDebugMode) {
      print(text);
    }
    _textController.clear();
    //if send empty message
    if(text==""){
      text = "start";
    }
    else {
      //TODO Dialogflow Code
      //Chat messages
      ChatMessage message = ChatMessage(
        text: text,
        name: "أنت",
        type: true,
      );
      setState(() {
        _messages.insert(0, message);
      });
    }



    DetectIntentResponse data = await dialogflow!.detectIntent(text, 'en-US');
    String fulfillmentText = data.queryResult.fulfillmentText;
    if(fulfillmentText.isNotEmpty) {
      ChatMessage botMessage = ChatMessage(
        text: fulfillmentText,
        name: "الاذكار",
        type: false,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    }

  }

  void handleFlower() async{
    if (kDebugMode) {
      print("flower");
    }
    handleSubmitted("اذكار");
  }
  void handleKiss() async{
    if (kDebugMode) {
      print("kiss");
    }
    handleSubmitted("الصباح");
  }
  void handleEgg() async{
    if (kDebugMode) {
      print("egg");
    }
    handleSubmitted("المساء");
  }
  // The chat interface
  //
  //------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {

    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      //ADMOB Banner
      bottomNavigationBar:
      _isBannerAdLoaded ? SizedBox(
        height: _bannerAd?.size.height.toDouble(),
        width: _bannerAd?.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),)
          : null ,
      //
      appBar: AppBar(
        title: const Text('الاذكار🙏'),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.chat),onPressed: (){},)
        ],
      ),
      body : Column(children: <Widget>[
        Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            )),
        Container(

        ),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: "btn1",
              onPressed: () {
                handleFlower();
                //ADMOB
                _showInterstitialAd();
              },
              label: const Text("🤲 اذكار"),
              backgroundColor: Colors.pink,
            ),
            FloatingActionButton.extended(
              heroTag: "btn2",
              onPressed: () {
                handleKiss();
                //ADMOB
                _showInterstitialAd();
              },
              label: const Text("🤲 الصباح"),
              backgroundColor: Colors.brown,
            ),
            FloatingActionButton.extended(
              heroTag: "btn3",
              onPressed: () {
                handleEgg();
                //ADMOB
                _showInterstitialAd();
              },
              label: const Text("🙏 المساء"),
            ),],),
        const Divider(height: 1.0),
        Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: handleSubmitted,
                        decoration: const InputDecoration.collapsed(hintText: "اكتب رسالة 🤲..."),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.send,color: Colors.purple,),
                        onPressed: () {
                          handleSubmitted(_textController.text);

                          //ADMOB
                          _showInterstitialAd();
                          },
                      ),
                    ),
                  ],
                ),
              ),
            )
        ),
      ]),),);
  }

}


//------------------------------------------------------------------------------------
// The chat message balloon
//
//------------------------------------------------------------------------------------
class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, required this.text, required this.name, required this.type}) : super(key: key);


  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: const CircleAvatar(child: Text('🤲')),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.subtitle1),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
            child: Text(
              name[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}