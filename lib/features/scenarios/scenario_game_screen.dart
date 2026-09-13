import 'dart:math';
import 'package:flutter/material.dart';
import 'custom_scenario_system.dart';
import 'hunter_scenario.dart';
import 'realistic_avatar.dart';
import 'scenario_catalog.dart';

class ScenarioGameScreen extends StatefulWidget {
  final ScenarioDefinition? scenario;
  final CustomScenario? customScenario;
  final ScenarioMode mode;
  final int playerCount;
  const ScenarioGameScreen({super.key, this.scenario, this.customScenario, required this.mode, required this.playerCount});
  @override State<ScenarioGameScreen> createState() => _ScenarioGameScreenState();
}

enum _Phase { night, nightResult, day, dayResult, ended }
class _ScenarioPlayer {
  final String name, role; final bool isUser, female; final int seat;
  bool alive = true, infected = false; int votes = 0;
  _ScenarioPlayer({required this.name, required this.role, required this.isUser, required this.female, required this.seat});
}

class _ScenarioGameScreenState extends State<ScenarioGameScreen> {
  final Random _random = Random();
  late final List<_ScenarioPlayer> _players;
  _Phase _phase = _Phase.night; int _round = 1; String? _target, _winner, _investigationResult; String _result = '';
  bool _sniperUsed = false, _hunterMasterUsed = false;
  final Set<String> _protected = {}, _blocked = {}, _silenced = {};
  bool get ranked => widget.mode == ScenarioMode.ranked;
  bool get hunterScenario => widget.scenario?.id == HunterScenario.id;
  String get title => widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریو';
  _ScenarioPlayer get user => _players.firstWhere((p) => p.isUser);
  List<_ScenarioPlayer> get alive => _players.where((p) => p.alive).toList();
  List<String> get roles {
    if (widget.customScenario != null) return List<String>.from(widget.customScenario!.roles).take(widget.playerCount).toList();
    if (hunterScenario && HunterScenario.supports(widget.playerCount)) return HunterScenario.rolesFor(widget.playerCount);
    final base = List<String>.from(widget.scenario?.roles ?? const <String>[]);
    if (base.isEmpty) return List<String>.filled(widget.playerCount, 'شهروند');
    while (base.length < widget.playerCount) base.add('شهروند');
    return base.take(widget.playerCount).toList();
  }
  @override void initState() {
    super.initState(); const names = ['شما','آرش','سارا','بابک','نگار','کیان','مهسا','رضا','الناز','پارسا','ترانه','مانی','هلیا','سام','نیکا','یاسین','رها','بردیا','آوا','نوید'];
    const females = {'سارا','نگار','مهسا','الناز','ترانه','هلیا','نیکا','رها','آوا'}; final r = roles;
    _players = List.generate(widget.playerCount, (i) => _ScenarioPlayer(name:names[i%names.length],role:r[i],isUser:i==0,female:females.contains(names[i%names.length]),seat:i+1));
  }
  bool mafia(String r) => r == 'مافیا' || r == 'پدرخوانده';
  bool independent(String r) => {'جوکر','قاتل مستقل','زامبی','دوئلیست'}.contains(r) || HunterScenario.hunterRoles.contains(r);
  bool blocked(_ScenarioPlayer p) => _blocked.contains(p.name);
  void select(String name) { if (_phase != _Phase.ended) setState(() => _target = name); }
  void confirm() { if (_phase == _Phase.night) _resolveNight(); else if (_phase == _Phase.day) _resolveVote(); }
  void _resolveNight() {
    final selected = _target; _investigationResult = null;
    if (selected == null) { _botNight(); _finishNight('شب بدون انتخاب کاربر اجرا شد.'); return; }
    final target = _players.firstWhere((p) => p.name == selected);
    if (!target.alive) { _finishNight('این بازیکن دیگر در بازی نیست.'); return; }
    if (blocked(user)) { _finishNight('توانایی شما برای این شب خنثی شد.'); return; }
    String message;
    switch (user.role) {
      case 'مافیا': case 'پدرخوانده': _kill(target); message='${target.name} هدف مافیا قرار گرفت.'; break;
      case 'دکتر': case 'محافظ': _protected.add(target.name); message='${target.name} برای این شب محافظت شد.'; break;
      case 'کارآگاه': case 'بازپرس': _investigationResult=_investigate(target); message='نتیجه بررسی ${target.name}: $_investigationResult'; break;
      case 'جک': if (_random.nextBool()) {_kill(target); message='جک به ${target.name} حمله کرد.';} else {message='توانایی جک ناموفق بود.';} break;
      case 'دادستان': case 'مذاکره': _blocked.add(target.name); message='توانایی ${target.name} برای شب بعد محدود شد.'; break;
      case 'تک‌تیرانداز': if (_sniperUsed) {message='گلوله تک‌تیرانداز قبلاً استفاده شده است.';} else {_sniperUsed=true; _kill(target); message='تک‌تیرانداز ${target.name} را هدف گرفت.';} break;
      case 'روانشناس': _silenced.add(target.name); message='${target.name} برای روز بعد ساکت شد.'; break;
      case 'تکاور': _protected.add(user.name); message='تکاور برای این شب از خود دفاع کرد.'; break;
      case 'شکارچی ارشد': if (_hunterMasterUsed) {message='قابلیت شکارچی ارشد قبلاً استفاده شده است.';} else {_hunterMasterUsed=true; if(mafia(target.role)) _kill(target); message='${target.name} بررسی و شکار شد.';} break;
      case 'ردیاب': message='${target.name}: ${_activeNight(target.role) ? 'توانایی شبانه فعال دارد.' : 'توانایی شبانه ندارد.'}'; break;
      case 'قاتل مستقل': _kill(target); message='قاتل مستقل ${target.name} را هدف گرفت.'; break;
      case 'زامبی': if(!mafia(target.role)){target.infected=true;message='${target.name} آلوده شد.';}else{message='زامبی نمی‌تواند عضو مافیا را آلوده کند.';} break;
      case 'دوئلیست': if(_random.nextBool()){_kill(target);message='دوئلیست در دوئل پیروز شد.';}else{user.alive=false;message='دوئلیست در دوئل شکست خورد.';} break;
      default: message='این نقش توانایی شبانه ویژه‌ای ندارد.';
    }
    _botNight(); _finishNight(message);
  }
  bool _activeNight(String r) => {'مافیا','پدرخوانده','دکتر','محافظ','کارآگاه','بازپرس','جک','دادستان','تک‌تیرانداز','ردیاب','شکارچی ارشد','روانشناس','تکاور','مذاکره','جوکر','قاتل مستقل','زامبی','دوئلیست'}.contains(r);
  void _botNight() {
    final living=List<_ScenarioPlayer>.from(alive); final mafiaPlayers=living.where((p)=>mafia(p.role)).toList();
    for(final bot in living.where((p)=>!p.isUser&&!blocked(p))){
      if(bot.role=='دکتر'||bot.role=='محافظ') _protected.add(living[_random.nextInt(living.length)].name);
      else if(bot.role=='تکاور') _protected.add(bot.name);
      else if(bot.role=='روانشناس'){final c=living.where((p)=>p!=bot).toList();if(c.isNotEmpty)_silenced.add(c[_random.nextInt(c.length)].name);}
    }
    if(mafiaPlayers.isNotEmpty){final c=living.where((p)=>!mafia(p.role)&&!p.isUser).toList();if(c.isNotEmpty)_kill(c[_random.nextInt(c.length)]);}
  }
  String _investigate(_ScenarioPlayer p){if(p.role=='پدرخوانده')return 'شهروند';if(mafia(p.role))return 'مافیا';if(independent(p.role))return 'مستقل';return 'شهروند';}
  void _kill(_ScenarioPlayer p){if(!p.alive||_protected.contains(p.name))return;if(p.role=='تکاور'&&_random.nextBool())return;p.alive=false;}
  void _finishNight(String m){_target=null;_result=m;_phase=_Phase.nightResult;setState((){});_checkWinner();}
  void _resolveVote(){
    final selected=_target;
    if(selected==null){_result='رأی‌گیری بدون انتخاب هدف انجام شد.';}else{final target=_players.firstWhere((p)=>p.name==selected);if(!target.alive){_result='هدف انتخاب‌شده دیگر زنده نیست.';}else{
      final candidates=alive.where((p)=>!p.isUser).toList();final counts=<String,int>{for(final p in candidates)p.name:0};counts[selected]=(counts[selected]??0)+(user.role=='شهردار'?2:1);
      for(final bot in alive.where((p)=>!p.isUser&&!_silenced.contains(p.name))){final c=candidates.where((p)=>p.name!=bot.name).toList();if(c.isNotEmpty){final choice=c[_random.nextInt(c.length)];counts[choice.name]=(counts[choice.name]??0)+1;}}
      final maxVotes=counts.values.isEmpty?0:counts.values.reduce(max);final leaders=counts.entries.where((e)=>e.value==maxVotes).map((e)=>e.key).toList();
      if(leaders.isNotEmpty){final eliminated=_players.firstWhere((p)=>p.name==leaders[_random.nextInt(leaders.length)]);eliminated.alive=false;eliminated.votes=counts[eliminated.name]??0;_result='${eliminated.name} با ${eliminated.votes} رأی از بازی خارج شد.';}
    }}
    _target=null;_silenced.clear();_phase=_Phase.dayResult;setState((){});_checkWinner();
  }
  void _checkWinner(){final m=alive.where((p)=>mafia(p.role)).length;final nonM=alive.length-m;String? w;
    if(hunterScenario&&m==0&&alive.any((p)=>HunterScenario.hunterRoles.contains(p.role)))w='ساید شکارچی 🎯';else if(user.role=='جوکر'&&!user.alive)w='جوکر';else if(user.role=='زامبی'&&user.alive&&alive.where((p)=>p.infected).length>=3)w='زامبی';else if(m==0)w='شهروندان';else if(m>=nonM)w='مافیا';if(w!=null){_winner=w;_phase=_Phase.ended;setState((){});}}
  void nextPhase(){if(_phase==_Phase.nightResult){_phase=_Phase.day;}else if(_phase==_Phase.dayResult){_round++;_protected.clear();_blocked.clear();_phase=_Phase.night;}setState((){});}
  String get phaseLabel=>switch(_phase){_Phase.night=>'شب $_round',_Phase.nightResult=>'نتیجه شب',_Phase.day=>'روز $_round • رأی‌گیری',_Phase.dayResult=>'نتیجه رأی‌گیری',_Phase.ended=>'پایان بازی'};

  @override Widget build(BuildContext context){final night=_phase==_Phase.night||_phase==_Phase.nightResult;final active=_phase==_Phase.night||_phase==_Phase.day;
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:night?const Color(0xFF060912):const Color(0xFF0B0908),body:Stack(children:[
      Positioned.fill(child:IgnorePointer(child:DecoratedBox(decoration:BoxDecoration(gradient:RadialGradient(center:Alignment.topCenter,radius:1.15,colors:night?const[Color(0xFF1B263B),Color(0xFF060912)]:const[Color(0xFF302017),Color(0xFF0B0908)]))))),
      SafeArea(child:Column(children:[
        Padding(padding:const EdgeInsets.fromLTRB(16,10,16,5),child:Row(children:[IconButton(onPressed:()=>Navigator.maybePop(context),style:IconButton.styleFrom(backgroundColor:const Color(0xCC10131B),foregroundColor:Colors.white),icon:const Icon(Icons.close_rounded)),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),Text(phaseLabel,style:const TextStyle(fontSize:11,color:Color(0xFF9AA1B2)))])),Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),decoration:BoxDecoration(color:const Color(0xAA10131B),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0x35E4B96B))),child:Text('${alive.length}/${_players.length}',style:const TextStyle(color:Color(0xFFFFD991),fontWeight:FontWeight.w900)))])),
        Padding(padding:const EdgeInsets.fromLTRB(16,2,16,7),child:_PhaseBanner(night:night,title:_winner??(active?(night?'توانایی نقش خود را اجرا کن':'یک بازیکن را برای رأی انتخاب کن'):_result),subtitle:_investigationResult)),
        Expanded(child:_RoundTable(players:_players,selected:_target,night:night,onSelect:active?select:null)),
        _ActionPanel(phase:_phase,result:_result,selectedName:_target,onConfirm:active?confirm:null,onNext:!active&&_phase!=_Phase.ended?nextPhase:null,winner:_winner),
      ]))])));
  }
}

class _PhaseBanner extends StatelessWidget{final bool night;final String title;final String? subtitle;const _PhaseBanner({required this.night,required this.title,this.subtitle});@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:15,vertical:11),decoration:BoxDecoration(gradient:LinearGradient(colors:night?[const Color(0xCC121C2D),const Color(0xAA10131B)]:[const Color(0xCC2A1715),const Color(0xAA10131B)]),borderRadius:BorderRadius.circular(20),border:Border.all(color:night?const Color(0x55E4B96B):const Color(0x55B92F45))),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(shape:BoxShape.circle,color:night?const Color(0x20E4B96B):const Color(0x20B92F45)),child:Icon(night?Icons.nights_stay_rounded:Icons.wb_sunny_rounded,color:night?const Color(0xFFFFD991):const Color(0xFFE34B61))),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w900)),if(subtitle!=null)Text(subtitle!,style:const TextStyle(color:Color(0xFFFFD991),fontSize:10))]))]));}

class _RoundTable extends StatelessWidget{final List<_ScenarioPlayer> players;final String? selected;final bool night;final ValueChanged<String>? onSelect;const _RoundTable({required this.players,required this.selected,required this.night,required this.onSelect});
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,c){final h=min(c.maxHeight,500.0);final w=c.maxWidth;final tableSize=min(w*.60,h*.64).clamp(205.0,315.0);final radius=tableSize/2+34;return Stack(alignment:Alignment.center,children:[
    Positioned(width:tableSize+48,height:tableSize+48,child:DecoratedBox(decoration:BoxDecoration(shape:BoxShape.circle,boxShadow:[BoxShadow(color:night?const Color(0x445C76B8):const Color(0x44E4B96B),blurRadius:48,spreadRadius:8)]))),
    Container(width:tableSize,height:tableSize,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:night?const[Color(0xFF30415A),Color(0xFF111722),Color(0xFF080C13)]:const[Color(0xFF4A3020),Color(0xFF19120F),Color(0xFF0C0A09)]),border:Border.all(color:night?const Color(0x77E4B96B):const Color(0x77B92F45),width:2),boxShadow:const[BoxShadow(color:Colors.black54,blurRadius:30,spreadRadius:4)]),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(night?Icons.nights_stay_rounded:Icons.wb_sunny_rounded,color:const Color(0xFFFFD991),size:30),const SizedBox(height:6),const Text('MAFIA',style:TextStyle(letterSpacing:5,fontSize:18,fontWeight:FontWeight.w900,color:Color(0xFFFFD991))),Text(night?'NIGHT TABLE':'DAY TABLE',style:const TextStyle(letterSpacing:2,fontSize:9,color:Color(0xFF9AA1B2))),const SizedBox(height:9),Container(width:65,height:1,color:const Color(0x55E4B96B))])),
    for(int i=0;i<players.length;i++)_seat(context,players[i],i,radius),
  ]);});
  Widget _seat(BuildContext context,_ScenarioPlayer p,int i,double radius){final a=-pi/2+2*pi*i/players.length;final center=Offset(MediaQuery.sizeOf(context).width/2,0);final x=center.dx+cos(a)*radius-39;final y=MediaQuery.sizeOf(context).height*.40+sin(a)*radius-43;return Positioned(left:x,top:y,width:78,height:88,child:_Seat(player:p,selected:p.name==selected,onTap:onSelect==null||!p.alive||p.isUser?null:()=>onSelect!(p.name)));}
}
class _Seat extends StatelessWidget{final _ScenarioPlayer player;final bool selected;final VoidCallback? onTap;const _Seat({required this.player,required this.selected,required this.onTap});@override Widget build(BuildContext context){final accent=selected?const Color(0xFFFFD991):player.isUser?const Color(0xFFE4B96B):player.alive?const Color(0x334E6E9E):const Color(0x44222222);return GestureDetector(onTap:onTap,child:AnimatedContainer(duration:const Duration(milliseconds:180),padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:selected?const Color(0x45E4B96B):const Color(0xDD10131B),borderRadius:BorderRadius.circular(17),border:Border.all(color:accent,width:selected||player.isUser?1.8:1),boxShadow:selected?[const BoxShadow(color:Color(0x55E4B96B),blurRadius:16)]:null),child:Column(children:[Expanded(child:Stack(alignment:Alignment.center,children:[Opacity(opacity:player.alive?1:.28,child:RealisticAvatar(role:player.role,female:player.female,size:58,alive:player.alive)),if(player.infected&&player.alive)Positioned(top:0,right:2,child:Container(width:16,height:16,decoration:const BoxDecoration(shape:BoxShape.circle,color:Color(0xFF66BB6A)),child:const Icon(Icons.coronavirus_rounded,size:10,color:Colors.white)))])),Text(player.name,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:9.5,fontWeight:FontWeight.w900,color:player.isUser?const Color(0xFFFFD991):Colors.white)),Text(player.alive?'#${player.seat}':'حذف',style:const TextStyle(fontSize:8,color:Color(0xFF9AA1B2)))])));}}
class _ActionPanel extends StatelessWidget{final _Phase phase;final String result;final String? selectedName;final VoidCallback? onConfirm,onNext;final String? winner;const _ActionPanel({required this.phase,required this.result,required this.selectedName,required this.onConfirm,required this.onNext,required this.winner});@override Widget build(BuildContext context){if(phase==_Phase.ended)return Container(margin:const EdgeInsets.fromLTRB(16,0,16,16),padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF201A12),Color(0xFF12151D)]),borderRadius:BorderRadius.circular(22),border:Border.all(color:const Color(0x66E4B96B))),child:Column(children:[const Icon(Icons.emoji_events_rounded,color:Color(0xFFFFD991),size:34),const SizedBox(height:5),Text('برنده: ${winner??'نامشخص'}',style:const TextStyle(color:Color(0xFFFFD991),fontSize:20,fontWeight:FontWeight.w900))]));final active=phase==_Phase.night||phase==_Phase.day;return Container(margin:const EdgeInsets.fromLTRB(16,0,16,14),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xEE10131B),borderRadius:BorderRadius.circular(22),border:Border.all(color:const Color(0x25FFFFFF)),boxShadow:const[BoxShadow(color:Color(0x66000000),blurRadius:20,offset:Offset(0,6))]),child:Row(children:[Expanded(child:Text(selectedName==null?(active?'یک صندلی را لمس کن':result):'هدف انتخاب‌شده: $selectedName',maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,color:Color(0xFFB8BFCD),fontWeight:FontWeight.w700))),const SizedBox(width:10),if(onConfirm!=null)FilledButton.icon(onPressed:onConfirm,icon:const Icon(Icons.bolt_rounded,size:18),label:Text(phase==_Phase.night?'اجرا':'رأی'))else if(onNext!=null)FilledButton.icon(onPressed:onNext,icon:const Icon(Icons.arrow_forward_rounded,size:18),label:const Text('ادامه'))]));}}
